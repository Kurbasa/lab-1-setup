# Лабораторна робота №4: Kubernetes + Minikube (Windows PowerShell)
# Передумови: встановлені kubectl, Minikube, увімкнена віртуалізація (Hyper-V / WSL2).
# Запуск: відкрий PowerShell від імені адміністратора (рекомендовано для Minikube) і виконуй блоки по черзі.

$ErrorActionPreference = "Stop"

function Step-Header($msg) {
    Write-Host "`n========== $msg ==========" -ForegroundColor Cyan
}

# --- Етап 1: кластер ---
Step-Header "Етап 1: старт Minikube та перевірка кластера"
Write-Host @"
minikube start --cpus 2 --memory 4096
kubectl cluster-info
kubectl get nodes
"@ -ForegroundColor Yellow

# Розкоментуй після встановлення Minikube:
# minikube start --cpus 2 --memory 4096
# kubectl cluster-info
# kubectl get nodes

# --- Етап 2: Deployment + масштабування ---
Step-Header "Етап 2: Deployment та 3 репліки"
Write-Host @"
kubectl create deployment web-app --image=registry.k8s.io/e2e-test-images/agnhost:2.53 -- /agnhost netexec --http-port=8080
kubectl scale deployment web-app --replicas=3
kubectl get pods -o wide
"@ -ForegroundColor Yellow

# --- Етап 3: Service NodePort ---
Step-Header "Етап 3: Service"
Write-Host @"
kubectl expose deployment web-app --type=NodePort --port=8080
minikube service web-app --url
"@ -ForegroundColor Yellow
Write-Host "Перевірка в браузері або: curl (URL з minikube service --url)" -ForegroundColor Gray

# --- Етап 4: Rolling update + rollback ---
Step-Header "Етап 4: оновлення образу та відкат"
Write-Host @"
# Ім'я контейнера зазвичай 'agnhost' (перевір: kubectl get deploy web-app -o jsonpath='{.spec.template.spec.containers[0].name}')
kubectl set image deployment/web-app agnhost=registry.k8s.io/e2e-test-images/agnhost:2.39
kubectl rollout status deployment/web-app
kubectl rollout undo deployment/web-app
kubectl rollout status deployment/web-app
"@ -ForegroundColor Yellow

# --- Етап 5: metrics-server + dashboard ---
Step-Header "Етап 5: аддони"
Write-Host @"
minikube addons enable metrics-server
# зачекай 1-2 хв, поки metrics-server підніметься
kubectl top pods
minikube dashboard
"@ -ForegroundColor Yellow

Write-Host "`nГотово. Скріншоти для звіту: cluster-info, get nodes, get pods -o wide, curl/browser, kubectl top pods, dashboard." -ForegroundColor Green
