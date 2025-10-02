#!/bin/bash

# Quick Test Script for Local Development
# Usage: ./scripts/test-local.sh

set -e

echo "🧪 Testing Microservices locally..."

# Function to test a service
test_service() {
    local service_name=$1
    local port=$2
    local service_dir=$3
    
    echo "🔧 Testing $service_name..."
    
    # Build image if it doesn't exist
    if ! docker images | grep -q "christophertonn/$service_name"; then
        echo "📦 Building $service_name image..."
        docker build -t "christophertonn/$service_name:test" "$service_dir"
    fi
    
    # Stop existing container if running
    docker stop "$service_name-test" 2>/dev/null || true
    docker rm "$service_name-test" 2>/dev/null || true
    
    # Start container
    echo "🚀 Starting $service_name container..."
    docker run -d --name "$service_name-test" -p "$port:80" "christophertonn/$service_name:test"
    
    # Wait for service to start
    echo "⏳ Waiting for $service_name to start..."
    sleep 10
    
    # Test the service
    echo "🔍 Testing $service_name endpoints..."
    if curl -f "http://localhost:$port/docs" > /dev/null 2>&1; then
        echo "✅ $service_name is working correctly!"
    else
        echo "❌ $service_name test failed!"
        docker logs "$service_name-test"
        return 1
    fi
    
    # Cleanup
    docker stop "$service_name-test"
    docker rm "$service_name-test"
}

# Test both services
test_service "cast-service" 8081 "cast-service"
test_service "movie-service" 8082 "movie-service"

echo "🎉 All services tested successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Run './scripts/build-and-push.sh' to build and push to DockerHub"
echo "2. Run './scripts/deploy.sh dev' to deploy to development environment"