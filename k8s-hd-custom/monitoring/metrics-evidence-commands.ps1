# Evidence commands for monitoring / autoscaling (PowerShell).
# Requires metrics-server for kubectl top.
$ErrorActionPreference = "Continue"
$ns = "online-boutique"

Write-Host "=== kubectl top pods -n $ns ==="
kubectl top pods -n $ns

Write-Host "`n=== kubectl top nodes ==="
kubectl top nodes

Write-Host "`n=== kubectl get hpa -n $ns ==="
kubectl get hpa -n $ns

Write-Host "`n=== kubectl describe hpa frontend -n $ns ==="
kubectl describe hpa frontend -n $ns
