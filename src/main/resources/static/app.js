let player;
let playerReady = false;
let currentCity = null;

// Welcome screen function
function hideWelcomeScreen() {
    const welcomeScreen = document.getElementById('welcome-screen');
    welcomeScreen.classList.add('hidden');

    // Show instruction overlay after welcome screen fades out
    setTimeout(() => {
        const instructionOverlay = document.getElementById('instruction-overlay');
        instructionOverlay.classList.add('visible');
    }, 500);
}

// Function to hide instruction overlay
function hideInstructionOverlay() {
    const instructionOverlay = document.getElementById('instruction-overlay');
    instructionOverlay.classList.add('fade-out');
    setTimeout(() => {
        instructionOverlay.classList.remove('visible');
        instructionOverlay.classList.remove('fade-out');
    }, 500);
}

window.onSpotifyIframeApiReady = (IFrameAPI) => {
    const element = document.getElementById('embed-iframe');
    const options = {
        width: '100%',
        height: '80'
    };

    IFrameAPI.createController(element, options, (EmbedController) => {
        player = EmbedController;
        playerReady = true;
        console.log('Spotify player ready');

        // Listen for play events
        player.addListener('playback_update', (e) => {
            if (!e.isPaused && currentCity) {
                startRings(currentCity);
            } else {
                stopRings();
            }
        });
    });
};

const globe = Globe()
    .globeImageUrl('https://unpkg.com/three-globe/example/img/earth-blue-marble.jpg')
    .backgroundImageUrl('https://unpkg.com/three-globe/example/img/night-sky.png')
    (document.getElementById('globe-container'));

// Panel resize functionality
let isResizing = false;
const panel = document.getElementById('info-panel');
const resizeHandle = document.querySelector('.resize-handle');
const globeContainer = document.getElementById('globe-container');

resizeHandle.addEventListener('mousedown', (e) => {
    isResizing = true;
    document.body.style.cursor = 'ew-resize';
    document.body.style.userSelect = 'none';
});

document.addEventListener('mousemove', (e) => {
    if (!isResizing) return;

    const newWidth = window.innerWidth - e.clientX;
    if (newWidth >= 320 && newWidth <= 600) {
        panel.style.width = newWidth + 'px';
    }
});

document.addEventListener('mouseup', () => {
    if (isResizing) {
        isResizing = false;
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
    }
});

// Close panel function
function closePanel() {
    document.getElementById('info-panel').classList.remove('active');
    document.getElementById('globe-container').classList.remove('panel-active');
}

fetch('https://unpkg.com/world-atlas/countries-110m.json')
    .then(r => r.json())
    .then(worldData => {
        const countries = topojson.feature(worldData, worldData.objects.countries).features;

        globe
            .polygonsData(countries)
            .polygonAltitude(0.01)
            .polygonCapColor(() => 'rgba(200, 200, 200, 0.15)')
            .polygonSideColor(() => 'rgba(100, 100, 100, 0.2)')
            .polygonStrokeColor(() => '#000000ff')
            .polygonLabel(({ properties: d }) => `
                <b>${d.name}</b>
            `);
    });

// Store rings data
let ringsData = [];
let currentRingIntervals = [];
let citiesData = [];
let arcsData = [];
let activeArc = null;

function stopRings() {
    currentRingIntervals.forEach(interval => clearInterval(interval));
    currentRingIntervals = [];
    ringsData = [];
    globe.ringsData([]);
}

function startRings(city) {
    stopRings();

    // Add a new ring every 300ms indefinitely
    const ringInterval = setInterval(() => {
        ringsData.push({
            lat: city.latitude,
            lng: city.longitude
        });
        globe.ringsData([...ringsData]);

        // Remove old rings after they complete (keep last 7 rings visible)
        if (ringsData.length > 7) {
            ringsData.shift();
        }
    }, 300);

    currentRingIntervals.push(ringInterval);
}

fetch('/api/cities')
    .then(r => r.json())
    .then(cities => {
        console.log('Cities:', cities);
        citiesData = cities;

        // Calculate distance between two cities (returns radians)
        const getDistance = (city1, city2) => {
            const lat1 = city1.latitude * Math.PI / 180;
            const lat2 = city2.latitude * Math.PI / 180;
            const lng1 = city1.longitude * Math.PI / 180;
            const lng2 = city2.longitude * Math.PI / 180;

            const dLat = lat2 - lat1;
            const dLng = lng2 - lng1;

            const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                     Math.cos(lat1) * Math.cos(lat2) *
                     Math.sin(dLng/2) * Math.sin(dLng/2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            return c;
        };

        // Check if arc would go through earth (angle > 90 degrees)
        const wouldArcGoThroughEarth = (city1, city2) => {
            const distance = getDistance(city1, city2);
            const maxAngle = Math.PI * 0.5; // 90 degrees in radians
            return distance > maxAngle;
        };

        // Group cities by music genre
        const genreGroups = {};
        cities.forEach(city => {
            if (!genreGroups[city.musicGenre]) {
                genreGroups[city.musicGenre] = [];
            }
            genreGroups[city.musicGenre].push(city);
        });

        // Strategy: Connect cities in intelligent ways. claude did this and it is very cool
        // 1. Within each genre: connect to nearest neighbor (creates genre clusters)
        Object.values(genreGroups).forEach(group => {
            if (group.length < 2) return;

            group.forEach(city => {
                const distances = group
                    .filter(c => c.id !== city.id)
                    .map(c => ({
                        city: c,
                        distance: getDistance(city, c)
                    }))
                    .sort((a, b) => a.distance - b.distance);

                // Connect to nearest same-genre city (skip if arc would go through earth)
                if (distances.length > 0 && !wouldArcGoThroughEarth(city, distances[0].city)) {
                    arcsData.push({
                        startLat: city.latitude,
                        startLng: city.longitude,
                        endLat: distances[0].city.latitude,
                        endLng: distances[0].city.longitude,
                        type: 'genre'
                    });
                }
            });
        });

        // 2. Cross-genre connections: connect to nearest different-genre city
        //    (shows how music influences spread between genres)
        cities.forEach(city => {
            const differentGenreCities = cities
                .filter(c => c.id !== city.id && c.musicGenre !== city.musicGenre)
                .map(c => ({
                    city: c,
                    distance: getDistance(city, c)
                }))
                .sort((a, b) => a.distance - b.distance);

            // Connect to nearest different genre (skip if arc would go through earth)
            if (differentGenreCities.length > 0 && !wouldArcGoThroughEarth(city, differentGenreCities[0].city)) {
                arcsData.push({
                    startLat: city.latitude,
                    startLng: city.longitude,
                    endLat: differentGenreCities[0].city.latitude,
                    endLng: differentGenreCities[0].city.longitude,
                    type: 'cross-genre'
                });
            }
        });

        // 3. Regional hubs: Find cities with most connections and highlight them
        const connectionCounts = {};
        arcsData.forEach(arc => {
            const key1 = `${arc.startLat},${arc.startLng}`;
            const key2 = `${arc.endLat},${arc.endLng}`;
            connectionCounts[key1] = (connectionCounts[key1] || 0) + 1;
            connectionCounts[key2] = (connectionCounts[key2] || 0) + 1;
        });

        console.log('Created arcs:', arcsData.length);

        globe
            // points
            .pointsData(cities)
            .pointLat('latitude')
            .pointLng('longitude')
            .pointAltitude(0.1)

            // atmosphere
            .atmosphereColor('rgba(234, 221, 221, 0.02)') 
            .atmosphereAltitude(0.2)

            //labels/text
            .labelsData(cities)
            .labelLat('latitude')
            .labelLng('longitude')
            .labelText('name')
            .labelSize(.5)
            .labelColor(() => 'rgba(238, 238, 238, 1)')
            .labelDotRadius(0.0)
            .labelAltitude(0.15)

            // arcs between cities
            .arcsData(arcsData)
            .arcStartLat('startLat')
            .arcStartLng('startLng')
            .arcEndLat('endLat')
            .arcEndLng('endLng')
            .arcColor(arc => {        
                // Genre connections are red, cross-genre are blue
                return arc.type === 'genre'
                    ? 'rgba(255, 100, 100, 0.4)'
                    : 'rgba(100, 150, 255, 0.25)';
            })
            .arcStroke(arc => {
                // Make active arc thicker
                if (activeArc &&
                    arc.startLat === activeArc.startLat &&
                    arc.startLng === activeArc.startLng &&
                    arc.endLat === activeArc.endLat &&
                    arc.endLng === activeArc.endLng) {
                    return 1.5;
                }
                return arc.type === 'genre' ? 0.6 : 0.6;
            })
            .arcDashLength(0.9)
            .arcDashGap(0.1)
            .arcDashAnimateTime(8000)
            .arcAltitude(arc => arc.type === 'genre' ? 0.15 : 0.15)

            // rings and point update
            .pointRadius(city => currentCity && city.id === currentCity.id ? 1.5 : 0.5)
            .pointColor(city => currentCity && city.id === currentCity.id ? 'red' : 'white')
            .ringsData(ringsData)
            .ringLat('lat')
            .ringLng('lng')
            .ringMaxRadius(5)
            .ringPropagationSpeed(3)
            .ringRepeatPeriod(2000)
            .ringAltitude(0.02)
            .ringColor(() => 'rgba(255, 0, 0, 0.9)')
            .onPointClick(p => {
                console.log('City clicked:', p);

                // Hide instruction overlay on first city click
                hideInstructionOverlay();

                // Animate camera to center on the clicked city
                globe.pointOfView({
                    lat: p.latitude,
                    lng: p.longitude,
                    altitude: 2.5
                }, 1000); // 1000ms animation duration

                // Stop rings from previous city
                stopRings();

                currentCity = p;

                // Update point appearance to highlight selected city
                globe.pointsData([...citiesData]);

                // Update info panel
                document.getElementById('city-name').textContent = p.name;
                document.getElementById('country-name').textContent = p.country;
                const genreTag = document.getElementById('genre-tag');
                genreTag.textContent = p.musicGenre;
                genreTag.style.display = 'inline-flex';
                document.getElementById('coordinates').textContent = `${p.latitude.toFixed(4)}° N, ${p.longitude.toFixed(4)}° E`;

                // Set country flag emoji (basic mapping)
                const flagEmoji = String.fromCodePoint(...[...p.countryCode.toUpperCase()].map(c => 0x1F1E6 - 65 + c.charCodeAt(0)));
                document.getElementById('city-flag').textContent = flagEmoji;

                // Find and display connected cities
                const connectedCities = [];
                arcsData.forEach(arc => {
                    const startCity = citiesData.find(c => c.latitude === arc.startLat && c.longitude === arc.startLng);
                    const endCity = citiesData.find(c => c.latitude === arc.endLat && c.longitude === arc.endLng);

                    if (startCity && startCity.id === p.id && endCity) {
                        connectedCities.push(endCity);
                    } else if (endCity && endCity.id === p.id && startCity) {
                        connectedCities.push(startCity);
                    }
                });

                // Remove duplicates
                const uniqueConnected = [...new Map(connectedCities.map(c => [c.id, c])).values()];

                const connectedList = document.getElementById('connected-cities');
                connectedList.innerHTML = '';
                uniqueConnected.slice(0, 6).forEach(city => {
                    const li = document.createElement('li');
                    li.innerHTML = `<strong>${city.name}</strong><br><small style="color: rgba(255,255,255,0.5)">${city.country} • ${city.musicGenre}</small>`;
                    li.onclick = () => {
                        // Find the arc connecting current city to the clicked city
                        const arc = arcsData.find(a =>
                            (a.startLat === p.latitude && a.startLng === p.longitude &&
                             a.endLat === city.latitude && a.endLng === city.longitude) ||
                            (a.endLat === p.latitude && a.endLng === p.longitude &&
                             a.startLat === city.latitude && a.startLng === city.longitude)
                        );

                        // Set the active arc and refresh
                        activeArc = arc;
                        globe.arcsData([...arcsData]);

                        // Animate camera to center on the clicked city
                        globe.pointOfView({
                            lat: city.latitude,
                            lng: city.longitude,
                            altitude: 2.5
                        }, 1000); // 1000ms animation duration

                        // Simulate clicking that city
                        currentCity = city;
                        globe.pointsData([...citiesData]);
                        // Recursively trigger the click
                        const clickEvent = { ...city };
                        globe.onPointClick()(clickEvent);
                    };
                    connectedList.appendChild(li);
                });

                // Show panel and player
                document.getElementById('info-panel').classList.add('active');
                document.getElementById('globe-container').classList.add('panel-active');
                document.getElementById('player-container').style.display = 'block';

                fetch(`/api/cities/${p.id}/music`)
                    .then(r => r.text())
                    .then(id => {
                        console.log('Track ID received:', id);
                        if (!id || id.trim() === '') {
                            console.error('No track ID returned from server');
                            return;
                        }
                        if (!playerReady || !player) {
                            console.error('Player not ready yet - please wait a moment and try again');
                            return;
                        }
                        console.log('Loading track:', `spotify:track:${id}`);
                        player.loadUri(`spotify:track:${id}`);

                        // Try to autoplay after a short delay
                        setTimeout(() => {
                            if (player.play) {
                                player.play().then(() => {
                                    console.log('Autoplay successful!');
                                }).catch(err => {
                                    console.log('Autoplay prevented by browser:', err.message);
                                });
                            } else {
                                console.log('Play method not available on Spotify embed player');
                            }
                        }, 500);
                    })
                    .catch(err => console.error('Error fetching music:', err));
            }
        
        );
    });
