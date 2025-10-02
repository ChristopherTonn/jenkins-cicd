# DATASCIENTEST JENKINS EXAM
# Python Microservice FastAPI - CI/CD mit Jenkins

Dieses Projekt demonstriert eine vollständige CI/CD-Pipeline mit Jenkins für zwei Microservices (cast-service und movie-service) mit Docker, Kubernetes und Helm.

## Projektstruktur

```
jenkins-cicd/
├── cast-service/           # Cast Microservice
│   ├── app/               # FastAPI Application
│   ├── Dockerfile         # Docker Build
│   └── requirements.txt   # Python Dependencies
├── movie-service/         # Movie Microservice
│   ├── app/               # FastAPI Application
│   ├── Dockerfile         # Docker Build
│   └── requirements.txt   # Python Dependencies
├── charts/                # Helm Charts
│   ├── cast-service/      # Cast Service Chart
│   └── movie-service/     # Movie Service Chart
├── k8s/                   # Kubernetes Manifests
│   └── namespaces.yaml    # dev, qa, staging, prod
├── scripts/               # Deployment Scripts
│   ├── build-and-push.sh  # Docker Build & Push
│   ├── deploy.sh          # Helm Deployment
│   └── test-local.sh      # Local Testing
├── Jenkinsfile            # CI/CD Pipeline
└── docker-compose.yml     # Local Development
```

## 🚀 Quick Start - Lokale Entwicklung

### Voraussetzungen
- Docker & Docker Compose installiert
- Kubernetes Cluster verfügbar
- Helm 3.x installiert
- kubectl konfiguriert

### Lokaler Test
```bash
# Alle Services testen
./scripts/test-local.sh

# Mit Docker Compose (Development)
docker-compose up -d

# Services verfügbar unter:
# - Cast Service: http://localhost:8080/api/v1/casts/docs
# - Movie Service: http://localhost:8080/api/v1/movies/docs
```

## 🏗️ Docker Images

### Manueller Build
```bash
# Beide Services bauen und zu DockerHub pushen
./scripts/build-and-push.sh [version]

# Beispiele:
./scripts/build-and-push.sh latest
./scripts/build-and-push.sh v1.0.0
```

### DockerHub Images
- `christophertonn/cast-service:latest`
- `christophertonn/movie-service:latest`

## ☸️ Kubernetes Deployment

### Namespaces erstellen
```bash
kubectl apply -f k8s/namespaces.yaml
```

### Helm Deployment
```bash
# Development Environment
./scripts/deploy.sh dev latest

# QA Environment
./scripts/deploy.sh qa v1.0.0

# Staging Environment
./scripts/deploy.sh staging v1.0.0

# Production (mit Bestätigung)
./scripts/deploy.sh prod v1.0.0

# Alle Environments (außer prod)
./scripts/deploy.sh all latest
```

### Manuelle Helm Commands
```bash
# Cast Service deployen
helm upgrade --install cast-dev charts/cast-service \
  --namespace dev \
  --set image.tag=latest \
  --set replicaCount=1

# Movie Service deployen
helm upgrade --install movie-dev charts/movie-service \
  --namespace dev \
  --set image.tag=latest \
  --set replicaCount=1
```

## 🔧 Jenkins CI/CD Pipeline

### Pipeline Übersicht
1. **Checkout** - Code aus Git Repository
2. **Build** - Docker Images für beide Services
3. **Test** - Lokale Container Tests
4. **Push** - Images zu DockerHub
5. **Deploy Dev** - Automatisches Deployment zu Development
6. **Deploy QA** - Automatisches Deployment zu QA
7. **Deploy Staging** - Automatisches Deployment zu Staging
8. **Manual Approval** - Manuelle Freigabe für Production
9. **Deploy Prod** - Deployment zu Production

### Jenkins Setup

#### 1. Credentials konfigurieren
- `DOCKER_HUB_PASS`: DockerHub Username/Password
- `config`: Kubernetes kubeconfig file

#### 2. Pipeline Job erstellen
- **Job Type**: Pipeline
- **Pipeline Script**: From SCM
- **Repository**: Ihr GitHub Repository
- **Script Path**: Jenkinsfile

#### 3. Webhook Setup
- GitHub Repository → Settings → Webhooks
- Payload URL: `http://your-jenkins-url/github-webhook/`
- Content type: `application/json`
- Events: `push` events on `main` branch

### Environment-spezifische Konfiguration
- **Dev**: 1 Replica
- **QA**: 2 Replicas
- **Staging**: 3 Replicas
- **Production**: 5 Replicas

## 📊 Monitoring & Überprüfung

### Deployment Status prüfen
```bash
# Alle Ressourcen in einem Namespace
kubectl get all -n dev
kubectl get all -n qa
kubectl get all -n staging
kubectl get all -n prod

# Pod Logs anzeigen
kubectl logs -f deployment/cast-service-dev -n dev
kubectl logs -f deployment/movie-service-dev -n dev

# Service Health Check
kubectl port-forward svc/cast-service-dev 8081:80 -n dev
curl http://localhost:8081/docs
```

### Pipeline Monitoring
- Jenkins Dashboard: Alle Stages und deren Status
- DockerHub: Verfügbare Image Tags
- Kubernetes: Running Pods in allen Namespaces

## 🧪 Testing

### Akzeptanztests
Die Pipeline führt automatisch folgende Tests durch:
- Container Start Test
- Health Check auf `/docs` Endpoint
- Service Erreichbarkeit

### Lokale Tests
```bash
# Einzelne Services testen
./scripts/test-local.sh

# Mit curl testen
curl -f http://localhost:8081/api/v1/casts/docs
curl -f http://localhost:8082/api/v1/movies/docs
```

## 📦 Abgabe-Dateien

Für die finale Prüfung sammeln Sie:

1. **results.pdf**: Screenshots von
   - Jenkins Pipeline Overview (alle Stages ✅)
   - DockerHub mit gepushten Images 📸
   - `kubectl get all -n dev|qa|staging|prod` mit Running Pods

2. **github.txt**: Link zum GitHub Repository

3. **dockerhub.txt**: Link zu DockerHub Images

## 🔍 Troubleshooting

### Häufige Probleme
```bash
# Docker Build Fehler
docker build --no-cache -t test-image .

# Kubernetes Verbindung
kubectl cluster-info

# Helm Release Status
helm status cast-dev -n dev

# Pod Debug
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### Jenkins Pipeline Debug
- Console Output für detaillierte Logs
- Blue Ocean Plugin für visuelle Pipeline-Ansicht
- Pipeline Syntax Generator für Jenkinsfile-Hilfe

## 📚 Weitere Informationen

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Helm Charts Guide](https://helm.sh/docs/chart_template_guide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
