-- Drop tables if they exist (cascades will remove foreign key constraints)
DROP TABLE IF EXISTS city_artists CASCADE;
DROP TABLE IF EXISTS cities CASCADE;

-- Create cities table
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    country_code VARCHAR(2),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    music_genre VARCHAR(255)
);

-- Create city_artists table
CREATE TABLE city_artists (
    id SERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL REFERENCES cities(id),
    artist_name VARCHAR(255) NOT NULL,
    spotify_artist_id VARCHAR(255)
);

-- Create indexes
CREATE INDEX idx_city_artists_city_id ON city_artists(city_id);
