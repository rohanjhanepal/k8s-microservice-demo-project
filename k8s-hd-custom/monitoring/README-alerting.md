## Alerting (design + examples; no heavy stack in core demo)

### Local demo stance

In **Docker Desktop**, alerting is demonstrated through:

- **Example** `PrometheusRule` manifests (see `examples/prometheus-alert-rules-example.yaml`)
- **Operational evidence**: `kubectl get events`, `kubectl describe pod`, HPA status, probe failures

This shows **alerting design** and **production intent** without forcing Prometheus Operator + Alertmanager into your laptop cluster.

### Production stance

In production, you would typically:

1. Run **Prometheus** (often via Prometheus Operator)
2. Install **PrometheusRule** CRDs (`prometheusrules.monitoring.coreos.com`)
3. Apply curated alert rules and route notifications (PagerDuty, Slack, email, etc.)

### Safe check before applying example rules

```powershell
kubectl get crd prometheusrules.monitoring.coreos.com
```

Only apply `examples/prometheus-alert-rules-example.yaml` if this CRD exists and you intentionally want operator-managed alerts.
