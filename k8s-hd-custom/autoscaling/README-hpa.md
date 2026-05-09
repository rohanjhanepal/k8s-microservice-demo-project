## Horizontal Pod Autoscaler (implemented)

### Deployments covered

CPU-based HPAs (see repo root `k8s-hd-custom/`):

- `hpa-frontend.yaml` → scales `Deployment/frontend`
- `hpa-checkoutservice.yaml` → scales `Deployment/checkoutservice`
- `hpa-recommendationservice.yaml` → scales `Deployment/recommendationservice`

Settings (see files): **`minReplicas: 1`**, **`maxReplicas: 5`**, CPU **`averageUtilization: ~60%`**.

### Evidence commands

```powershell
kubectl get hpa -n online-boutique
kubectl describe hpa frontend -n online-boutique
kubectl top pods -n online-boutique
```

### Optional load bump (demo)

Increase synthetic load (use carefully on your machine):

```powershell
kubectl set env deployment/loadgenerator USERS=100 -n online-boutique
```

Revert by setting `USERS` back to a lower value or re-applying `loadgenerator.yaml`.

### Custom metrics (not applied by default)

See `README-custom-metrics-hpa.md` and `examples/frontend-custom-metrics-hpa-example.yaml`.
