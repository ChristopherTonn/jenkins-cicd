#!/bin/bash

# Helm Deployment Script for Microservices
# Usage: ./scripts/deploy.sh [environment] [version]

set -e

# Configuration
ENVIRONMENTS=("dev" "qa" "staging" "prod")
DOCKER_REGISTRY="christophertonn"
SERVICES=("cast-service" "movie-service")

# Function to display usage
usage() {
    echo "Usage: $0 [environment] [version]"
    echo "Environments: ${ENVIRONMENTS[*]}"
    echo "Version: Docker image tag (default: latest)"
    echo ""
    echo "Examples:"
    echo "  $0 dev latest"
    echo "  $0 prod 20241002-abc123"
    echo "  $0 all latest  # Deploy to all environments except prod"
    exit 1
}

# Function to validate environment
validate_environment() {
    local env=$1
    if [[ "$env" != "all" ]] && [[ ! " ${ENVIRONMENTS[*]} " =~ " $env " ]]; then
        echo "❌ Invalid environment: $env"
        echo "Valid environments: ${ENVIRONMENTS[*]}, all"
        exit 1
    fi
}

# Function to deploy to a specific environment
deploy_to_environment() {
    local env=$1
    local version=$2
    local replica_count=$3
    
    echo "🚀 Deploying to $env environment with version $version (replicas: $replica_count)"
    
    # Create namespace if it doesn't exist
    kubectl apply -f k8s/namespaces.yaml
    
    # Deploy each service
    for service in "${SERVICES[@]}"; do
        echo "📦 Deploying $service to $env..."
        
        helm upgrade --install "${service}-${env}" "charts/${service}" \
            --namespace "$env" \
            --set image.tag="$version" \
            --set replicaCount="$replica_count" \
            --wait \
            --timeout=5m
        
        echo "✅ $service deployed successfully to $env"
    done
    
    echo "🎉 All services deployed to $env environment!"
}

# Function to get replica count based on environment
get_replica_count() {
    local env=$1
    case $env in
        "dev") echo 1 ;;
        "qa") echo 2 ;;
        "staging") echo 3 ;;
        "prod") echo 5 ;;
        *) echo 1 ;;
    esac
}

# Function to verify deployment
verify_deployment() {
    local env=$1
    
    echo "🔍 Verifying deployment in $env environment..."
    
    # Check pod status
    kubectl get pods -n "$env" -l app.kubernetes.io/name=cast-service
    kubectl get pods -n "$env" -l app.kubernetes.io/name=movie-service
    
    # Check services
    kubectl get services -n "$env"
    
    echo "✅ Deployment verification completed for $env"
}

# Main script
ENVIRONMENT=${1:-""}
VERSION=${2:-"latest"}

if [ -z "$ENVIRONMENT" ]; then
    usage
fi

validate_environment "$ENVIRONMENT"

# Check if kubectl and helm are available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed or not in PATH"
    exit 1
fi

# Check if kubeconfig is set
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Check your kubeconfig."
    exit 1
fi

echo "🎯 Starting deployment..."
echo "Environment: $ENVIRONMENT"
echo "Version: $VERSION"
echo ""

if [ "$ENVIRONMENT" = "all" ]; then
    # Deploy to dev, qa, staging (exclude prod for safety)
    for env in "dev" "qa" "staging"; do
        replica_count=$(get_replica_count "$env")
        deploy_to_environment "$env" "$VERSION" "$replica_count"
        verify_deployment "$env"
        echo ""
    done
    
    echo "⚠️  Production deployment skipped for safety."
    echo "To deploy to production, run: $0 prod $VERSION"
    
elif [ "$ENVIRONMENT" = "prod" ]; then
    # Extra confirmation for production
    echo "⚠️  You are about to deploy to PRODUCTION!"
    echo "Version: $VERSION"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        replica_count=$(get_replica_count "prod")
        deploy_to_environment "prod" "$VERSION" "$replica_count"
        verify_deployment "prod"
    else
        echo "❌ Production deployment cancelled."
        exit 1
    fi
    
else
    # Deploy to specific environment
    replica_count=$(get_replica_count "$ENVIRONMENT")
    deploy_to_environment "$ENVIRONMENT" "$VERSION" "$replica_count"
    verify_deployment "$ENVIRONMENT"
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo "📋 To check the status:"
echo "   kubectl get all -n $ENVIRONMENT"