## Centralized logging approach (lightweight)

### Local demonstration

For this project, **centralized log inspection** means using Kubernetes APIs consistently:

- **`kubectl logs`** on Deployments/pods/Jobs
- **Label selectors** to aggregate logs across replicas
- **`kubectl describe`** and **`kubectl get events`** for failures and scheduling issues

This avoids running Elasticsearch, Loki, or Grafana as mandatory dependencies.

### Useful commands

```powershell
kubectl logs deployment/frontend -n online-boutique
kubectl logs deployment/checkoutservice -n online-boutique
kubectl logs -l app=frontend -n online-boutique --tail=100
kubectl get events -n online-boutique --sort-by=.metadata.creationTimestamp
```

### Optional extension: Fluent Bit

A **DaemonSet**-based log collector (e.g. Fluent Bit) can ship logs to stdout, files, or cloud sinks. An **optional, non-core** example lives in:

- `examples/fluent-bit-daemonset-example.yaml`

Do **not** apply it unless you intend to run Fluent Bit; it is not required for the boutique app to function.

See also: `log-evidence-commands.ps1`.
