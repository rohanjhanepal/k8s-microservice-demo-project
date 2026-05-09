## Example-only manifests (do not apply by default)

Files in this folder are for **documentation**, **design demonstration**, or **optional extensions**. They are **not** referenced by `kustomization.yaml` and are **not** required for Online Boutique to run.

| File | Purpose |
|------|---------|
| `prometheus-alert-rules-example.yaml` | `PrometheusRule` samples — requires **Prometheus Operator CRDs** |
| `frontend-custom-metrics-hpa-example.yaml` | Custom-metrics HPA sample — requires **`custom.metrics.k8s.io`** / adapter |
| `fluent-bit-daemonset-example.yaml` | Optional log forwarder pattern — not required locally |

### Safe checks before applying

```powershell
kubectl get crd prometheusrules.monitoring.coreos.com
kubectl api-resources | findstr custom.metrics
```

If CRDs/APIs are missing, **do not apply** the corresponding YAML.
