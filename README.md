# CitySounds

CitySounds is an interactive 3D globe application that connects cities with their musical heritage and culture. By clicking on any of 50 major cities around the world, find curated tracks from artists who shaped that city's sound via  the Spotify web API, rendered in  3D using Globe.GL.

** [Live Demo](https://citysounds.onrender.com)** | ** Dockerized** | **Deployed on Render**

---

## Table of Contents
- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture Deep Dive](#architecture-deep-dive)
  - [Backend: Spring Boot MVC](#backend-spring-boot-mvc)
  - [Frontend: Vanilla JavaScript + 3D Visualization](#frontend-vanilla-javascript--3d-visualization)
- [What I Learned](#what-i-learned)
- [Getting Started](#getting-started)
  - [Local Development](#local-development)
  - [Docker Deployment](#docker-deployment)
- [Demo & Features](#demo--features)

---

## Overview

CitySounds is a full-stack Java Spring Boot application that visualizes the relationship between geography and music. The app displays a 3D interactive globe where each city is connected to others through intelligent musical relationships:

- **Genre Connections** (red arcs): Cities sharing the same music genre, connected to their nearest neighbor
- **Cross-Genre Connections** (blue arcs): Cities with different genres, showing musical diversity and cultural exchange

When you click a city, you get:
- A Spotify track preview from a local artist
- Information about the city's primary music genre
- A list of connected cities you can explore
- GPS coordinates

This application combines data persistence, external API integration, 3D graphics, and RESTful architecture into one project.

---

## Tech Stack

### Backend
- **Java 25**
- **Spring Boot 4.0.1** - Application framework
- **Spring Data JPA / Hibernate** - ORM for database interactions
- **PostgreSQL** - Relational database
- **Maven** - Build and dependency management
- **Gson** - JSON parsing for Spotify API responses

### Frontend
- **HTML / CSS** - Structure and styling
- **Vanilla JavaScript**
- **Three.js** - 3D rendering engine
- **Globe.GL** - 3D globe visualization library
- **Spotify Embed API** - Music player integration
- **TopoJSON** - World map topology data

### External APIs
- **Spotify Web API** - Artist search and track retrieval

---

## Architecture Deep Dive

CitySounds follows Java Springboots **Model-View-Controller (MVC)** pattern, with a clear separation between the backend (Spring Boot) and frontend (JavaScript). Here's how each layer works:

---

### Backend: Spring Boot MVC

The backend is built with Spring Boot and follows a clean, layered architecture. Let me break down each component:

---

#### **Models (Entities)**

The models represent the database schema and map directly to PostgreSQL tables via JPA annotations.

**[City.java](src/main/java/com/citysounds/models/City.java)**
```java
@Entity
@Table(name = "cities")
public class City {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;           // "New York"
    private String country;        // "United States"
    private String countryCode;    // "US" (ISO 2-letter)
    private Double latitude;       // 40.7128
    private Double longitude;      // -74.0060
    private String musicGenre;     // "Hip Hop"
}
```

**Purpose:** Stores geographic and musical metadata for 50 major cities worldwide.

---

**[CityArtist.java](src/main/java/com/citysounds/models/CityArtist.java)**
```java
@Entity
@Table(name = "city_artists")
public class CityArtist {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long cityId;              // Foreign key to cities table
    private String artistName;        // "Jay-Z"
    private String spotifyArtistId;   // "3nFkdlSjzX9mRTtwJOzDYB"
}
```

**Purpose:** Maps artists to their cities. Each city has 5-6 artists, totaling ~300 artist records. The `spotifyArtistId` enables direct lookups in Spotify's catalog.

---

#### **Repositories (Data Access Layer)**

Repositories handle all database operations using Spring Data JPA. They extend `JpaRepository`, which provides built-in CRUD methods.

**[CityRepository.java](src/main/java/com/citysounds/repository/CityRepository.java)**
```java
@Repository
public interface CityRepository extends JpaRepository<City, Long> {
    // Inherits: findAll(), findById(), save(), delete(), etc.
}
```

**Methods Used:**
- `findAll()` - Retrieves all 50 cities (used to populate the globe)
- `findById(Long id)` - Retrieves a single city by ID (used when user clicks a city)

---

**[CityArtistRepository.java](src/main/java/com/citysounds/repository/CityArtistRepository.java)**
```java
@Repository
public interface CityArtistRepository extends JpaRepository<CityArtist, Long> {
    List<CityArtist> findByCityId(Long cityId);
}
```

**Custom Method:**
- `findByCityId(Long cityId)` - Returns all artists associated with a specific city. This is a derived query method—Spring automatically generates the SQL based on the method name.


---

#### **Services (Business Logic Layer)**

Services contain the core business logic and handle interactions with external APIs. They're where the "intelligence" of the application lives.

**[SpotifyService.java](src/main/java/com/citysounds/services/SpotifyService.java)**

This service is the heart of the primary function of the curation system. It integrates with Spotify's API to deliver personalized tracks for each city.

**Key Method: `getCuratedCityTrack(Long cityId, String countryCode)`**

Work Flow:
1. **Fetch artists** for the city from the database using `CityArtistRepository`
2. **Randomly select** one artist from the city's roster
3. **Search Spotify** for the artist's Spotify ID
4. **Retrieve** the artist's top tracks in the specified country
5. **Return** a random track ID

```java
public String getCuratedCityTrack(Long cityId, String countryCode) {
    List<CityArtist> artists = cityArtistRepository.findByCityId(cityId);
    if (artists.isEmpty()) return null;

    // Pick a random artist
    CityArtist randomArtist = artists.get(new Random().nextInt(artists.size()));

    // Search Spotify
    String artistId = searchArtistId(randomArtist.getArtistName());
    if (artistId == null) return null;

    // Get top tracks
    return getArtistTopTrack(artistId, countryCode);
}
```

**Authentication: `getAccessToken()`**

Spotify requires OAuth2 authentication. This method:
- Uses the **Client Credentials Flow** (app-to-app auth)
- Caches the access token in memory
- Only refreshes when the token expires (~1 hour)

```java
private String getAccessToken() {
    if (cachedAccessToken != null && !isTokenExpired()) {
        return cachedAccessToken; // Return cached token
    }

    // Request new token from Spotify
    // POST https://accounts.spotify.com/api/token
    // Returns: { "access_token": "...", "expires_in": 3600 }
}
```

**Why caching matters:** Without caching, we'd make an auth request for every single track fetch. That's wasteful and could hit rate limits. By caching, we reduce API calls dramatically...

---

**Other Service Methods:**
- `searchArtistId(String artistName)` - Searches Spotify's catalog for an artist, returns their Spotify ID
- `getArtistTopTrack(String artistId, String countryCode)` - Fetches an artist's top tracks in a specific market (e.g., US, BR, JP)

**External API Endpoints Used:**
- `https://accounts.spotify.com/api/token` - OAuth2 authentication
- `https://api.spotify.com/v1/search?q={artist}&type=artist` - Artist search
- `https://api.spotify.com/v1/artists/{id}/top-tracks?market={country}` - Top tracks retrieval

---

#### **Controllers (REST API Layer)**

Controllers expose endpoints that the frontend can call. They handle HTTP requests and return responses.

**[HomeController.java](src/main/java/com/citysounds/controllers/HomeController.java)**
```java
@Controller
public class HomeController {
    @GetMapping("/")
    public String home() {
        return "index.html"; // Serves the main frontend
    }
}
```

**Purpose:** Serves the single-page application at the home URL.
---

**[CityController.java](src/main/java/com/citysounds/controllers/CityController.java)**

This is a `@RestController`, meaning all methods return JSON (or plain text) instead of HTML views.

**Endpoint 1: `GET /api/cities`**
```java
@GetMapping("/api/cities")
public List<City> getAllCities() {
    return cityRepository.findAll();
}
```
**Returns:** JSON array of all 50 cities
**Used by:** Frontend during initialization to populate the globe with city points

---

**Endpoint 2: `GET /api/cities/{id}`**
```java
@GetMapping("/api/cities/{id}")
public ResponseEntity<City> getCityById(@PathVariable Long id) {
    return cityRepository.findById(id)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
}
```
**Returns:** JSON object of a single city (or 404 if not found)
**Used by:** Frontend when user clicks a city (though currently the frontend uses the cached city data)

---

**Endpoint 3: `GET /api/cities/{id}/music`**
```java
@GetMapping("/api/cities/{id}/music")
public ResponseEntity<String> getCityMusic(
    @PathVariable Long id,
    @RequestParam(defaultValue = "US") String country
) {
    String trackId = spotifyService.getCuratedCityTrack(id, country);
    return trackId != null
        ? ResponseEntity.ok(trackId)
        : ResponseEntity.notFound().build();
}
```
**Returns:** Plain text Spotify track ID (e.g., `"3nFkdlSjzX9mRTtwJOzDYB"`)
**Used by:** Frontend when displaying music for a city
**Note:** Accepts optional `country` query parameter to localize tracks (defaults to "US")

---

### Frontend: Vanilla JavaScript + 3D Visualization

The frontend is a single-page application with no frameworks—just clean, vanilla JavaScript. It's roughly 500 lines of code that handle 3D rendering, user interaction, and API calls.

---

#### **index.html**

The HTML file sets up the structure and loads external libraries:

**Key Components:**
1. **Welcome Screen:** Initial overlay with "Click Here to Begin" button
2. **Globe Container:** Canvas element where Three.js renders the 3D globe
3. **Info Panel:** Sliding sidebar on the right that displays:
   - City name, country, flag emoji
   - Music genre badge
   - Embedded Spotify player
   - List of connected cities (clickable)
   - GPS coordinates
4. **Legend:** Explains the difference between genre connections (red) vs. cross-genre (blue)
5. **Instructions:** Persistent hint at the bottom ("Click on any city to explore its music scene")

**Styling Highlights:**
- Dark theme (midnight blue background, red accents)
- Custom CSS for responsive layout
- Globe takes up full viewport height
- Panel slides in from right with smooth transitions

---

#### **app.js**

This is where all the scripting and interactions occur. 

---

**1. Globe Initialization**

```javascript
const globe = Globe()
    .globeImageUrl('//unpkg.com/three-globe/example/img/earth-night.jpg')
    .backgroundImageUrl('//unpkg.com/three-globe/example/img/night-sky.png')
    .pointAltitude(0.02) // How much cities "float" above surface
    .pointColor(() => '#ff4444') // Red city points
    .labelColor(() => 'white')
    .labelSize(1.5)
    .arcColor('color') // Use the 'color' property from arc data
    .arcStroke(0.5)
    .arcAltitude(0.3);
```

This creates the 3D globe using Globe.GL. It sets:
- Earth texture (night-time satellite imagery)
- Star field background
- Point colors for cities
- Arc rendering properties

---

**2. Data Fetching & City Placement**

```javascript
fetch('/api/cities')
    .then(res => res.json())
    .then(cities => {
        // Store cities globally
        allCities = cities;

        // Add points to globe
        globe.pointsData(cities);

        // Add country polygons with labels
        globe.polygonsData(/* TopoJSON world data */);

        // Calculate and render connection arcs
        const arcs = generateArcs(cities);
        globe.arcsData(arcs);
    });
```

When the app loads, it fetches all cities from the backend and:
1. Stores them in a global array for later reference
2. Renders city points on the globe using latitude/longitude
3. Draws country borders and labels
4. Generates intelligent connection arcs

---

**3. Intelligent Arc Connections**

This is one of the coolest features. The `generateArcs()` function creates visual connections between cities based on musical relationships:

```javascript
function generateArcs(cities) {
    const arcs = [];

    cities.forEach(city => {
        // GENRE CONNECTIONS (red)
        // Find nearest city with SAME genre
        const sameGenreCities = cities.filter(c =>
            c.id !== city.id && c.musicGenre === city.musicGenre
        );
        const nearestSameGenre = findNearest(city, sameGenreCities);
        if (nearestSameGenre) {
            arcs.push({
                startLat: city.latitude,
                startLng: city.longitude,
                endLat: nearestSameGenre.latitude,
                endLng: nearestSameGenre.longitude,
                color: '#ff4444' // Red
            });
        }

        // CROSS-GENRE CONNECTIONS (blue)
        // Find nearest city with DIFFERENT genre
        const differentGenreCities = cities.filter(c =>
            c.id !== city.id && c.musicGenre !== city.musicGenre
        );
        const nearestDifferent = findNearest(city, differentGenreCities);
        if (nearestDifferent) {
            arcs.push({
                startLat: city.latitude,
                startLng: city.longitude,
                endLat: nearestDifferent.latitude,
                endLng: nearestDifferent.longitude,
                color: '#4444ff' // Blue
            });
        }
    });

    return arcs;
}
```

**The Algorithm:**
- For each city, find its nearest neighbor with the **same** genre → red arc
- Find its nearest neighbor with a **different** genre → blue arc
- Prevents arcs that would pass through Earth (only connects cities < 90° apart)

**Result:** You get clusters of similar genres (e.g., Hip Hop cities connected in red) while also seeing cross-cultural influences (blue arcs between Hip Hop and Jazz, or K-Pop and J-Pop).

---

**4. City Click Handler**

When you click a city point:

```javascript
globe.onPointClick((city) => {
    // Animate camera to city
    globe.pointOfView({
        lat: city.latitude,
        lng: city.longitude,
        altitude: 1.5
    }, 1000); // 1 second animation

    // Update info panel
    document.getElementById('city-name').textContent = city.name;
    document.getElementById('music-genre').textContent = city.musicGenre;

    // Fetch music for this city
    fetch(`/api/cities/${city.id}/music?country=${city.countryCode}`)
        .then(res => res.text())
        .then(trackId => {
            loadSpotifyPlayer(trackId);
            animatePulsingRings(city); // Visual effect
        });

    // Show connected cities
    displayConnectedCities(city);

    // Open info panel
    infoPanel.classList.add('open');
});
```

**What happens:**
1. Camera smoothly flies to the clicked city
2. Info panel slides in with city details
3. Fetches a curated track from the backend
4. Loads Spotify player with the track
5. Displays pulsing ring animation at the city location
6. Shows list of connected cities (clickable for navigation)

---

**5. Spotify Player Integration**

The app uses Spotify's **Embed API** (not the full Playback SDK) for simplicity:

```javascript
function loadSpotifyPlayer(trackId) {
    const iframe = document.createElement('iframe');
    iframe.src = `https://open.spotify.com/embed/track/${trackId}`;
    iframe.width = '100%';
    iframe.height = '80';
    iframe.frameBorder = '0';
    iframe.allow = 'encrypted-media';

    playerContainer.innerHTML = '';
    playerContainer.appendChild(iframe);
}
```

This creates an embedded player that works without requiring user authentication. Users can play/pause directly in the app.

---

**6. Pulsing Ring Animation**

When music plays, a visual effect appears on the globe:

```javascript
function animatePulsingRings(city) {
    // Creates expanding concentric rings at city location
    // Uses Three.js RingGeometry
    // Fades out and removes after animation completes
}
```
---

**7. Connected Cities Display**

The info panel shows which cities are connected to the current city via arcs:

```javascript
function displayConnectedCities(city) {
    const connectedCities = arcs
        .filter(arc => arc.startLat === city.latitude)
        .map(arc => findCityByCoords(arc.endLat, arc.endLng));

    // Render as clickable list
    connectedCities.forEach(connectedCity => {
        const li = document.createElement('li');
        li.textContent = `${connectedCity.name} (${connectedCity.musicGenre})`;
        li.onclick = () => globe.onPointClick(connectedCity); // Navigate
        list.appendChild(li);
    });
}
```

This creates a navigation mechanism—you can hop from city to city by clicking connected cities

---

**8. Panel Resizing**

The info panel is resizable—users can drag the left edge to make it wider or narrower:

```javascript
let isResizing = false;

panelResizeHandle.addEventListener('mousedown', () => {
    isResizing = true;
});

document.addEventListener('mousemove', (e) => {
    if (isResizing) {
        const newWidth = window.innerWidth - e.clientX;
        infoPanel.style.width = `${newWidth}px`;
    }
});

document.addEventListener('mouseup', () => {
    isResizing = false;
});
```

A small UX touch that makes the interface feel polished.

---

## What I Learned

Building CitySounds taught me a ton about full-stack development, API integration, and 3D graphics. Here are the key takeaways:

### **Spring Boot & MVC Architecture**
- **Separation of concerns:** Keeping models, repositories, services, and controllers distinct makes the codebase maintainable and testable. If I need to swap Spotify for another music API, I only touch the service layer.
- **Spring Data JPA magic:** Derived query methods like `findByCityId()` are incredibly powerful. Spring generates the SQL for you based on method names—no need to write raw queries.

### **Working with External APIs**
- **OAuth2 flows:** Implementing the Client Credentials flow taught me how app-to-app authentication works. Managing token expiration and caching was crucial for performance.
- **Rate limiting considerations:** Caching the access token reduced API calls dramatically, a good thing

### **Database Design**
- **Normalization:** Splitting cities and artists into separate tables prevents data duplication. The `city_artists` junction table creates a clean many-to-many relationship (one city → many artists, one artist → potentially many cities).
- **Indexing matters:** Adding an index on `city_artists.city_id` improved query performance significantly when fetching artists for a city.

### **Frontend Development**
- **Vanilla JS is powerful:** With modern features, vanilla JavaScript handles state management, DOM manipulation, and async operations beautifully.
- **Three.js/Globe.GL:** Working with 3D graphics was challenging but rewarding. Understanding concepts like camera positioning, altitude, and arc rendering opened up a new dimension (literally) of web development.
- **Performance optimization:** Rendering 50 cities, 100+ arcs, and country polygons requires efficient rendering. Globe.GL handles this, but I learned to minimize re-renders and cache data where possible.

### **User Experience**
- **Progressive disclosure:** The welcome screen → globe → info panel flow guides users naturally through the experience.
- **Visual feedback:** Pulsing rings, camera animations, and smooth transitions make the app feel alive and responsive.

### **Build Tools & Configuration**
- **Maven dependency management:** Managing Spring Boot dependencies, JDBC drivers, and Gson with Maven taught me about build systems and version compatibility.
- **Environment configuration:** Using `application.properties.template` keeps sensitive credentials out of version control while documenting what's needed to run the app.

### **Debugging & Problem-Solving**
- **CORS issues:** Working with Spotify's API required understanding CORS policies and how browsers handle cross-origin requests.
- **Async JavaScript:** Managing multiple async operations (fetch city data, fetch music, load Spotify player) required careful promise handling and error management.

---

## Getting Started (Working on creating a more useable deployment)

### **Prerequisites**
- **Java 17+** (project uses Java 25)
- **PostgreSQL** database
- **Spotify Developer Account** (free at [developer.spotify.com](https://developer.spotify.com/dashboard))
- **Maven** (included via Maven wrapper)

---

### **Step 1: Clone the Repository**
```bash
git clone https://github.com/yourusername/CitySounds.git
cd CitySounds
```

---

### **Step 2: Set Up the Database**

1. **Create a PostgreSQL database:**
```bash
psql -U postgres
CREATE DATABASE citysounds;
\q
```

2. **Run the SQL scripts** (in order):
```bash
psql -U postgres -d citysounds -f src/main/resources/create_tables.sql
psql -U postgres -d citysounds -f src/main/resources/citiesData.sql
psql -U postgres -d citysounds -f src/main/resources/cityArtistsData.sql
```

This creates the `cities` and `city_artists` tables and populates them with 50 cities and ~300 artists.

---

### **Step 3: Get Spotify API Credentials**

1. Go to [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)
2. Log in (or create an account)
3. Click **"Create App"**
4. Fill in:
   - App Name: `CitySounds`
   - App Description: `Music exploration app`
   - Redirect URI: `http://localhost:8080` (not used, but required)
5. Click **"Create"**
6. Copy your **Client ID** and **Client Secret**

---

### **Step 4: Configure Application Properties**

1. Copy the template:
```bash
cp src/main/resources/application.properties.template src/main/resources/application.properties
```

2. Edit `application.properties`:
```properties
# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/citysounds
spring.datasource.username=postgres
spring.datasource.password=your_password_here

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true

# Spotify API
spotify.client-id=your_spotify_client_id_here
spotify.client-secret=your_spotify_client_secret_here

# Server
server.port=8080
```

---

### **Step 5: Run the Application**

**On Mac/Linux:**
```bash
./mvnw spring-boot:run
```

**On Windows:**
```bash
mvnw.cmd spring-boot:run
```

The app will start on [http://localhost:8080](http://localhost:8080)

---

### **Step 6: Explore!**

1. Open your browser to [http://localhost:8080](http://localhost:8080)
2. Click **"Click Here to Begin"**
3. Click on any city on the globe
4. Listen to curated tracks from local artists
5. Navigate between connected cities

---

## Demo & Features

### **Key Features**
Interactive 3D globe with 50 major world cities
Real-time Spotify integration for music playback
Intelligent arc connections showing musical relationships
Genre-based clustering (Hip Hop, Jazz, K-Pop, etc.)
Responsive info panel with city details
Clickable connected cities for exploration
Smooth camera animations and visual effects
Resizable UI panels

## Project Structure

```
CitySounds/
├── src/
│   ├── main/
│   │   ├── java/com/citysounds/
│   │   │   ├── CitySoundsApplication.java
│   │   │   ├── controllers/
│   │   │   │   ├── HomeController.java
│   │   │   │   └── CityController.java
│   │   │   ├── models/
│   │   │   │   ├── City.java
│   │   │   │   └── CityArtist.java
│   │   │   ├── repository/
│   │   │   │   ├── CityRepository.java
│   │   │   │   └── CityArtistRepository.java
│   │   │   └── services/
│   │   │       └── SpotifyService.java
│   │   └── resources/
│   │       ├── application.properties.template
│   │       ├── create_tables.sql
│   │       ├── citiesData.sql
│   │       ├── cityArtistsData.sql
│   │       └── static/
│   │           ├── index.html
│   │           └── app.js
├── Dockerfile                      # Docker build configuration
├── docker-compose.yml              # Local Docker deployment
├── .dockerignore                   
├── .env.example                    # Template for environment variables
├── .gitignore                      # Prevents secrets in version control
├── pom.xml
├── README.md
└── README-DOCKER.md                # Comprehensive Docker guide
```

---

## Docker Deployment

This project is fully Dockerized for easy deployment to render.

## License

This project is open source and available under the [MIT License](LICENSE).

---

## Contact

Built by Isaac Keninger
GitHub: [@IsaacKeninger](https://github.com/IsaacKeninger)
LinkedIn: [Isaac Keninger](https://www.linkedin.com/in/isaac-keninger-363a6b233/)

---
