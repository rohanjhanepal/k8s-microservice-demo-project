# Evidence commands for logs and cluster events (PowerShell).
$ErrorActionPreference = "Continue"
$ns = "online-boutique"

Write-Host "=== kubectl logs deployment/frontend -n $ns (tail 50) ==="
kubectl logs deployment/frontend -n $ns --tail=50

Write-Host "`n=== kubectl logs deployment/checkoutservice -n $ns (tail 50) ==="
kubectl logs deployment/checkoutservice -n $ns --tail=50

Write-Host "`n=== kubectl logs -l app=frontend -n $ns --tail=100 ==="
kubectl logs -l app=frontend -n $ns --tail=100

Write-Host "`n=== kubectl get events -n $ns --sort-by=.metadata.creationTimestamp (tail via Select-Object) ==="
kubectl get events -n $ns --sort-by=.metadata.creationTimestamp | Select-Object -Last 40
