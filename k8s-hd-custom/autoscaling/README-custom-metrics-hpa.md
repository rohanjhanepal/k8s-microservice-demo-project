## Custom metrics HPA (advanced extension — documentation only)

### What you run today (implemented)

The HorizontalPodAutoscaler objects in this folder use **`autoscaling/v2`** with **CPU** utilization targets, backed by **metrics-server**. That is **intentionally simple** and **works on Docker Desktop** when metrics-server is available.

### Why custom metrics exist

CPU-only scaling is easy to demonstrate but may not match user-facing SLOs. Production teams often scale on:

- HTTP **requests per second**
- **Latency** (p95/p99)
- Domain metrics (**checkout rate**, **queue depth**, **gRPC duration**)

### What custom metrics HPA needs

Scaling on non-CPU metrics typically requires a **custom metrics API** implementation, commonly:

- **Prometheus Adapter** (`custom.metrics.k8s.io`)
- Other adapters for cloud vendor metrics

That adds components and tuning beyond this local HD demo, so we ship **only an example manifest** under `examples/`—do **not** apply it unless those APIs are installed and metrics exist.

See: `examples/frontend-custom-metrics-hpa-example.yaml` (**example only**).
