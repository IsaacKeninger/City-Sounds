# CitySounds

A Original Java Spring Boot application that connects cities with their music scenes using the Spotify API and Globe.Gl Javascript UI Component.

Total Project is still a WIP...

## Setup

### Prerequisites
- Java 17 or higher
- PostgreSQL database
- Spotify Developer Account

### Configuration

1. Copy the template configuration file:
   ```bash
   cp src/main/resources/application.properties.template src/main/resources/application.properties
   ```

2. Edit `application.properties` and fill in your credentials:
   - Database connection details
   - Spotify API credentials (get them from [Spotify Developer Dashboard](https://developer.spotify.com/dashboard))

3. Run the application:
   ```bash
   ./mvnw spring-boot:run
   ```
