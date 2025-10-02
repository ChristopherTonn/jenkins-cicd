#!/bin/bash

# Demo Script - Vollständige CI/CD Demo
# Usage: ./scripts/demo.sh

set -e

echo "🎬 Jenkins CI/CD Demo für Microservices"
echo "========================================"
echo ""

# Configuration
DEMO_VERSION="demo-$(date +%Y%m%d-%H%M%S)"

echo "📋 Demo Plan:"
echo "1. Lokale Tests ausführen"
echo "2. Docker Images bauen und pushen"  
echo "3. Kubernetes Deployment demonstrieren"
echo "4. Services überprüfen"
echo ""

# Function to pause for user input
pause() {
    read -p "Drücken Sie Enter um fortzufahren..."
}

echo "🧪 Schritt 1: Lokale Tests"
echo "=========================="
pause
./scripts/test-local.sh

echo ""
echo "🐳 Schritt 2: Docker Images bauen und pushen"
echo "=============================================="
echo "Version: $DEMO_VERSION"
pause

# Check Docker Hub credentials
if [ -z "$DOCKER_HUB_USERNAME" ] || [ -z "$DOCKER_HUB_PASSWORD" ]; then
    echo "⚠️  DockerHub Credentials nicht gesetzt."
    echo "Setzen Sie DOCKER_HUB_USERNAME und DOCKER_HUB_PASSWORD Umgebungsvariablen."
    echo "Oder führen Sie 'docker login' manuell aus."
    pause
fi

./scripts/build-and-push.sh "$DEMO_VERSION"

echo ""
echo "☸️  Schritt 3: Kubernetes Deployment"
echo "===================================="
echo "Deploying zu Development Environment..."
pause
./scripts/deploy.sh dev "$DEMO_VERSION"

echo ""
echo "QA Environment deployment..."
pause
./scripts/deploy.sh qa "$DEMO_VERSION"

echo ""
echo "🔍 Schritt 4: Service Verifikation"
echo "=================================="
echo "Überprüfung der deployten Services..."
pause

for env in dev qa; do
    echo ""
    echo "📊 Environment: $env"
    echo "-------------------"
    kubectl get all -n "$env"
    
    echo ""
    echo "Pod Details:"
    kubectl get pods -n "$env" -o wide
    
    echo ""
done

echo ""
echo "🎉 Demo abgeschlossen!"
echo "====================="
echo ""
echo "📸 Nächste Schritte für Screenshots:"
echo "1. Jenkins Pipeline triggern (Git push)"
echo "2. Screenshots der Pipeline Stages machen"
echo "3. DockerHub Images Screenshot"
echo "4. kubectl get all -n [env] Screenshots"
echo ""
echo "📋 Abgabe-Dateien sind bereit in ./abgabe/"
echo "   - github.txt"
echo "   - dockerhub.txt"  
echo "   - screenshot-checklist.md"
echo ""
echo "🚀 Jenkins Pipeline URL: http://your-jenkins-url/job/your-pipeline/"
echo "🐳 DockerHub: https://hub.docker.com/r/christophertonn/"
echo ""
echo "Viel Erfolg bei der Prüfung! 🎯"