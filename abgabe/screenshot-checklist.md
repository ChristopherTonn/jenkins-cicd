# Jenkins CI/CD Pipeline - Screenshot Checklist 📸

Für die Abgabe sind folgende Screenshots erforderlich:

## 1. Jenkins Pipeline Overview ✅
- **Was zeigen**: Vollständige Pipeline mit allen Stages
- **Wo finden**: Jenkins Dashboard → Pipeline Job → Build History → Blue Ocean View
- **Zu sehen**: 
  - ✅ Checkout Stage
  - ✅ Build Docker Images (parallel für both services)
  - ✅ Test Services (parallel tests)
  - ✅ Push to DockerHub
  - ✅ Deploy to Dev
  - ✅ Deploy to QA  
  - ✅ Deploy to Staging
  - ✅ Manual Approval for Production
  - ✅ Deploy to Production (wenn approved)

## 2. DockerHub Images 📸
- **Was zeigen**: Gepushte Images in DockerHub
- **Wo finden**: hub.docker.com/r/christophertonn/
- **Zu sehen**:
  - christophertonn/cast-service mit Tags (latest, versioned)
  - christophertonn/movie-service mit Tags (latest, versioned)
  - Push-Zeitstempel
  - Image Größen

## 3. Kubernetes Pods Status 🏃‍♂️
Für jedes Environment folgende Commands ausführen und Screenshots machen:

```bash
# Development Environment
kubectl get all -n dev

# QA Environment  
kubectl get all -n qa

# Staging Environment
kubectl get all -n staging

# Production Environment (wenn deployed)
kubectl get all -n prod
```

**Zu sehen in den Screenshots**:
- ✅ Running Pods für cast-service und movie-service
- ✅ Services (ClusterIP)
- ✅ Deployments mit gewünschter Replica Count
- ✅ ReplicaSets
- ✅ Korrekte Namespaces (dev, qa, staging, prod)

## 4. Zusätzliche hilfreiche Screenshots (optional)

### Jenkins Console Output
- Detailed logs einer erfolgreichen Pipeline-Ausführung
- Error handling und cleanup logs

### Helm Releases
```bash
helm list -A
```

### Docker Images lokal
```bash
docker images | grep christophertonn
```

## Screenshot Qualität Tipps 📷
- **Hohe Auflösung** für gute Lesbarkeit
- **Vollständige Ansicht** - alle relevanten Informationen sichtbar
- **Timestamp/Datum** sichtbar lassen
- **Browser/Terminal Titel** für Kontext
- **Farbige Outputs** (grün für Success, rot für Fehler)

## Reihenfolge für finale Demo 🎬
1. Code-Änderung in main.py committen und pushen
2. Jenkins Pipeline triggert automatisch  
3. Pipeline läuft durch bis Staging
4. Manual Approval für Production
5. Screenshots während/nach Pipeline-Ausführung
6. Kubernetes Status in allen Environments überprüfen
7. DockerHub Images verifizieren

## Datei-Organisation 📁
```
results.pdf
├── Page 1: Jenkins Pipeline Overview
├── Page 2: DockerHub Images  
├── Page 3: kubectl get all -n dev
├── Page 4: kubectl get all -n qa
├── Page 5: kubectl get all -n staging
└── Page 6: kubectl get all -n prod
```

Viel Erfolg! 🚀