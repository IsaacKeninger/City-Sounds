-- 50 Major Cities Based on Cultural Significance, Economic Importance, and Regional Representation
INSERT INTO cities (name, country, latitude, longitude, music_genre, country_code) VALUES
-- North America
('New York', 'United States', 40.7128, -74.0060, 'Hip Hop', 'US'),
('Los Angeles', 'United States', 34.0522, -118.2437, 'Pop', 'US'),
('Chicago', 'United States', 41.8781, -87.6298, 'Blues', 'US'),
('Nashville', 'United States', 36.1627, -86.7816, 'Country', 'US'),
('New Orleans', 'United States', 29.9511, -90.0715, 'Jazz', 'US'),
('Detroit', 'United States', 42.3314, -83.0458, 'Motown', 'US'),
('Memphis', 'United States', 35.1495, -90.0490, 'Soul', 'US'),
('Seattle', 'United States', 47.6062, -122.3321, 'Grunge', 'US'),
('Miami', 'United States', 25.7617, -80.1918, 'Latin', 'US'),
('Toronto', 'Canada', 43.6532, -79.3832, 'Hip Hop', 'CA'),
('Montreal', 'Canada', 45.5017, -73.5673, 'Indie', 'CA'),
('Mexico City', 'Mexico', 19.4326, -99.1332, 'Mariachi', 'MX'),
('Havana', 'Cuba', 23.1136, -82.3666, 'Salsa', 'CU'),

-- South America
('Rio de Janeiro', 'Brazil', -22.9068, -43.1729, 'Bossa Nova', 'BR'),
('Sao Paulo', 'Brazil', -23.5505, -46.6333, 'Samba', 'BR'),
('Buenos Aires', 'Argentina', -34.6037, -58.3816, 'Tango', 'AR'),
('Bogota', 'Colombia', 4.7110, -74.0721, 'Cumbia', 'CO'),
('Lima', 'Peru', -12.0464, -77.0428, 'Cumbia', 'PE'),

-- Europe
('London', 'United Kingdom', 51.5074, -0.1278, 'Rock', 'GB'),
('Liverpool', 'United Kingdom', 53.4084, -2.9916, 'Rock', 'GB'),
('Manchester', 'United Kingdom', 53.4808, -2.2426, 'Indie', 'GB'),
('Paris', 'France', 48.8566, 2.3522, 'Chanson', 'FR'),
('Berlin', 'Germany', 52.5200, 13.4050, 'Electronic', 'DE'),
('Vienna', 'Austria', 48.2082, 16.3738, 'Classical', 'AT'),
('Amsterdam', 'Netherlands', 52.3676, 4.9041, 'Electronic', 'NL'),
('Dublin', 'Ireland', 53.3498, -6.2603, 'Folk', 'IE'),
('Barcelona', 'Spain', 41.3851, 2.1734, 'Flamenco', 'ES'),
('Rome', 'Italy', 41.9028, 12.4964, 'Opera', 'IT'),
('Milan', 'Italy', 45.4642, 9.1900, 'Opera', 'IT'),
('Stockholm', 'Sweden', 59.3293, 18.0686, 'Pop', 'SE'),
('Moscow', 'Russia', 55.7558, 37.6173, 'Classical', 'RU'),

-- Africa
('Lagos', 'Nigeria', 6.5244, 3.3792, 'Afrobeat', 'NG'),
('Johannesburg', 'South Africa', -26.2041, 28.0473, 'Jazz', 'ZA'),
('Cairo', 'Egypt', 30.0444, 31.2357, 'Arabic Pop', 'EG'),
('Accra', 'Ghana', 5.6037, -0.1870, 'Highlife', 'GH'),

-- Middle East
('Istanbul', 'Turkey', 41.0082, 28.9784, 'Turkish Pop', 'TR'),
('Dubai', 'United Arab Emirates', 25.2048, 55.2708, 'Arabic Pop', 'AE'),
('Tel Aviv', 'Israel', 32.0853, 34.7818, 'Electronic', 'IL'),

-- Asia
('Tokyo', 'Japan', 35.6762, 139.6503, 'J-Pop', 'JP'),
('Osaka', 'Japan', 34.6937, 135.5023, 'J-Pop', 'JP'),
('Seoul', 'South Korea', 37.5665, 126.9780, 'K-Pop', 'KR'),
('Beijing', 'China', 39.9042, 116.4074, 'Mandopop', 'CN'),
('Shanghai', 'China', 31.2304, 121.4737, 'Mandopop', 'CN'),
('Hong Kong', 'China', 22.3193, 114.1694, 'Cantopop', 'HK'),
('Mumbai', 'India', 19.0760, 72.8777, 'Bollywood', 'IN'),
('Bangkok', 'Thailand', 13.7563, 100.5018, 'Thai Pop', 'TH'),
('Singapore', 'Singapore', 1.3521, 103.8198, 'Pop', 'SG'),
('Manila', 'Philippines', 14.5995, 120.9842, 'OPM', 'PH'),

-- Oceania
('Sydney', 'Australia', -33.8688, 151.2093, 'Rock', 'AU'),
('Melbourne', 'Australia', -37.8136, 144.9631, 'Indie', 'AU'),
('Auckland', 'New Zealand', -36.8485, 174.7633, 'Indie', 'NZ');
