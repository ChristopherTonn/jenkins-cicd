#!/bin/bash

# Docker Build and Push Script for Microservices
# Usage: ./scripts/build-and-push.sh [version]

set -e

# Configuration
DOCKER_REGISTRY="christophertonn"
VERSION=${1:-"latest"}
BUILD_DATE=$(date '+%Y%m%d-%H%M%S')
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# If version is not provided, create one with build date and git commit
if [ "$VERSION" = "latest" ]; then
    VERSION="${BUILD_DATE}-${GIT_COMMIT}"
fi

echo "🚀 Building and pushing Docker images with version: $VERSION"

# Function to build and push a service
build_and_push_service() {
    local service_name=$1
    local service_dir=$2
    
    echo "📦 Building $service_name..."
    
    # Build Docker image
    docker build -t "${DOCKER_REGISTRY}/${service_name}:${VERSION}" "$service_dir"
    docker tag "${DOCKER_REGISTRY}/${service_name}:${VERSION}" "${DOCKER_REGISTRY}/${service_name}:latest"
    
    echo "✅ Built $service_name successfully"
    
    # Push to DockerHub
    echo "🔄 Pushing $service_name to DockerHub..."
    docker push "${DOCKER_REGISTRY}/${service_name}:${VERSION}"
    docker push "${DOCKER_REGISTRY}/${service_name}:latest"
    
    echo "✅ Pushed $service_name successfully"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Login to DockerHub (if credentials are provided)
if [ -n "$DOCKER_HUB_USERNAME" ] && [ -n "$DOCKER_HUB_PASSWORD" ]; then
    echo "🔐 Logging in to DockerHub..."
    echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
fi

# Build and push services
build_and_push_service "cast-service" "cast-service"
build_and_push_service "movie-service" "movie-service"

echo "🎉 All services built and pushed successfully!"
echo "📋 Images created:"
echo "   - ${DOCKER_REGISTRY}/cast-service:${VERSION}"
echo "   - ${DOCKER_REGISTRY}/cast-service:latest"
echo "   - ${DOCKER_REGISTRY}/movie-service:${VERSION}"
echo "   - ${DOCKER_REGISTRY}/movie-service:latest"

# Save version info
echo "$VERSION" > .docker-version
echo "💾 Version saved to .docker-version file"