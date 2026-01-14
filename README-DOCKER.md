# CitySounds - Docker Deployment Guide

This guide explains how to run CitySounds using Docker, without exposing sensitive credentials.

## What is Docker?

Docker is a platform that packages applications and their dependencies into **containers**—lightweight, portable environments that run consistently anywhere. Think of containers as isolated boxes that contain everything your app needs to run.

### Key Docker Concepts

1. **Docker Image**: A blueprint/template for your application (like a recipe)
2. **Docker Container**: A running instance of an image (like a meal made from the recipe)
3. **Dockerfile**: Instructions for building an image
4. **Docker Compose**: Tool for defining and running multi-container applications
5. **Docker Volume**: Persistent storage that survives container restarts

### How This Project Uses Docker

```
┌─────────────────────────────────────────┐
│         Docker Compose                   │
│                                          │
│  ┌──────────────┐    ┌──────────────┐  │
│  │   App        │◄───┤  PostgreSQL   │  │
│  │  Container   │    │   Container   │  │
│  │  (Port 8080) │    │  (Port 5432)  │  │
│  └──────────────┘    └──────────────┘  │
│         ▲                    ▲          │
│         │                    │          │
│    Environment           Volume         │
│    Variables            (Data)          │
└─────────────────────────────────────────┘
```

## Prerequisites

- **Docker Desktop** (includes Docker Engine and Docker Compose)
  - Windows/Mac: [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Linux: Install [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)

To verify installation:
```bash
docker --version
docker-compose --version
```

## Quick Start

### Step 1: Clone the Repository
```bash
git clone https://github.com/yourusername/CitySounds.git
cd CitySounds
```

### Step 2: Set Up Environment Variables

Docker uses **environment variables** to pass sensitive data to containers without hardcoding them in files.

1. **Copy the example environment file:**
```bash
cp .env.example .env
```

2. **Edit `.env` with your actual credentials:**
```env
# Database Configuration
DB_NAME=citysounds_db
DB_USER=postgres
DB_PASSWORD=YourSecurePasswordHere123!

# Spotify API Configuration
SPOTIFY_CLIENT_ID=7f7620730e6f439ba991ace11e3c9d9c
SPOTIFY_CLIENT_SECRET=143adf2c47094a95a7200d47fda2bb4f
```

**Important:** The `.env` file is already in `.gitignore`, so it won't be committed to version control.

### Step 3: Build and Run
```bash
docker-compose up --build
```

This command:
- Builds the Spring Boot application into a Docker image
- Pulls the PostgreSQL image
- Creates containers for both services
- Initializes the database with your SQL scripts
- Starts both containers

### Step 4: Access the Application
Open your browser to: [http://localhost:8080](http://localhost:8080)

## Docker Commands Reference

### Starting the Application
```bash
# Start in foreground (see logs)
docker-compose up

# Start in background (detached mode)
docker-compose up -d

# Rebuild and start (after code changes)
docker-compose up --build
```

### Stopping the Application
```bash
# Stop containers (keeps data)
docker-compose down

# Stop and remove volumes (deletes database data)
docker-compose down -v
```

### Viewing Logs
```bash
# All services
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# Only app logs
docker-compose logs -f app

# Only database logs
docker-compose logs -f postgres
```

### Accessing Containers
```bash
# Access app container shell
docker exec -it citysounds-app sh

# Access database
docker exec -it citysounds-postgres psql -U postgres -d citysounds_db
```

### Viewing Running Containers
```bash
docker ps
```

### Cleaning Up
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove everything (nuclear option)
docker system prune -a --volumes
```

## How Docker Keeps Secrets Safe

### 1. Environment Variables
Instead of hardcoding credentials in `application.properties`, Docker injects them at runtime:

```yaml
# docker-compose.yml
environment:
  SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD}
  SPOTIFY_CLIENT_SECRET: ${SPOTIFY_CLIENT_SECRET}
```

These values come from your `.env` file, which is **never committed to Git**.

### 2. .dockerignore
This file tells Docker to ignore sensitive files during image builds:
```
src/main/resources/application.properties
.env
```

Even if someone gets your Docker image, they won't get your secrets.

### 3. .gitignore
Prevents accidental commits:
```
.env
src/main/resources/application.properties
```

## Understanding the Docker Setup

### Dockerfile Explanation

```dockerfile
# Multi-stage build (smaller final image)
FROM maven:3.9-eclipse-temurin-21 AS build
# Stage 1: Build the JAR file using Maven

FROM eclipse-temurin:21-jre
# Stage 2: Runtime image (only needs Java, not Maven)

USER spring
# Run as non-root user for security

EXPOSE 8080
# Document which port the app uses
```

**Benefits:**
- **Security**: Non-root user reduces attack surface
- **Size**: Final image is ~300MB instead of ~700MB
- **Speed**: Cached layers make rebuilds faster

### docker-compose.yml Explanation

```yaml
services:
  postgres:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data  # Persist data
      - ./src/main/resources/*.sql:/docker-entrypoint-initdb.d/  # Initialize DB
    healthcheck:
      # Wait for database to be ready before starting app

  app:
    depends_on:
      postgres:
        condition: service_healthy  # Start only after DB is healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/citysounds_db
      # Container network allows "postgres" hostname
```

**Key Features:**
- **Automatic database initialization**: SQL scripts run on first start
- **Health checks**: Ensures database is ready before app starts
- **Persistent storage**: Data survives container restarts
- **Network isolation**: Containers communicate via internal network

## Sharing Your Project Securely

### Safe to Share:
- `.env.example` (template with placeholder values)
- `Dockerfile`
- `docker-compose.yml`
- `.dockerignore`
- `.gitignore`

### Never Share:
- `.env` (contains real credentials)
- `src/main/resources/application.properties` (already in `.gitignore`)

### When Sharing on GitHub:
1. Ensure `.env` is in `.gitignore`
2. Provide `.env.example` with instructions
3. Document where to get API keys (Spotify Developer Dashboard)

### For Collaborators:
1. They clone the repo
2. Copy `.env.example` to `.env`
3. Fill in their own credentials
4. Run `docker-compose up`

## Production Deployment

For production environments (AWS, Google Cloud, etc.), use **Docker Secrets** or managed secret services:

```bash
# Example: Docker Swarm Secrets
echo "my_secret_password" | docker secret create db_password -

# Or use cloud provider secret managers:
# - AWS Secrets Manager
# - Google Cloud Secret Manager
# - Azure Key Vault
```

## Troubleshooting

### Port Already in Use
```bash
# Change ports in docker-compose.yml
ports:
  - "8081:8080"  # Use 8081 instead of 8080
```

### Database Connection Failed
```bash
# Check database logs
docker-compose logs postgres

# Verify database is healthy
docker ps  # Look for "healthy" status
```

### Application Won't Start
```bash
# Check app logs
docker-compose logs app

# Rebuild from scratch
docker-compose down -v
docker-compose up --build
```

### Changes Not Reflected
```bash
# Rebuild after code changes
docker-compose up --build
```

## Advantages of Docker

1. **Consistency**: Works the same on any machine
2. **Isolation**: Dependencies don't conflict with your system
3. **Easy Setup**: No manual PostgreSQL installation needed
4. **Portability**: Share with anyone who has Docker
5. **Security**: Secrets managed via environment variables
6. **Scalability**: Easy to add more services (Redis, etc.)

## Next Steps

- Learn about [Docker Volumes](https://docs.docker.com/storage/volumes/) for data persistence
- Explore [Docker Networks](https://docs.docker.com/network/) for inter-container communication
- Read about [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/) for optimization
- Check out [Docker Compose best practices](https://docs.docker.com/compose/production/)

## Need Help?

- Docker Documentation: [https://docs.docker.com/](https://docs.docker.com/)
- Docker Compose Reference: [https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/)
- Report issues: [GitHub Issues](https://github.com/yourusername/CitySounds/issues)
