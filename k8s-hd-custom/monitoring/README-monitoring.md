## Lightweight monitoring (no Helm)

This project uses **metrics-server** (when installed in the cluster) plus Kubernetes APIs for a **lightweight, demo-friendly** observability story—without bundling full Prometheus/Grafana into Docker Desktop by default.

### Level 1: Implemented lightweight monitoring (recommended for local demo)

| Mechanism | What it demonstrates |
|-----------|----------------------|
| **metrics-server** | Exposes CPU/memory metrics used by `kubectl top` and **HPA** |
| **HPA (CPU)** | Scales workloads based on **averageUtilization** (see `hpa-*.yaml`) |
| **`kubectl top pods`** | Pod-level CPU/memory usage |
| **`kubectl top nodes`** | Node-level usage (often one node on Docker Desktop) |
| **`kubectl describe hpa`** | Autoscaling events, metrics, conditions |
| **`kubectl describe pod` / `deployment`** | Probe status, restarts, recent events |
| **`kubectl get events`** | Cluster operational timeline |

### Commands (evidence for reports/presentations)

```powershell
kubectl top pods -n online-boutique
kubectl top nodes
kubectl get hpa -n online-boutique
kubectl describe hpa frontend -n online-boutique
kubectl describe deployment frontend -n online-boutique
kubectl get events -n online-boutique --sort-by=.metadata.creationTimestamp
```

**Note:** If `kubectl top` fails, install or enable **metrics-server** for your environment (Docker Desktop often includes it; if not, apply the upstream metrics-server manifest for your cluster version).

### Level 2: Optional production monitoring (documented only)

Full **Prometheus + Grafana** stacks are typically installed via **plain YAML** manifests, **operators**, or vendor bundles. That is **not required** for this HD local demo because:

- Docker Desktop has limited CPU/RAM
- Large vendor manifests are hard to maintain in a student repo
- Your HD evidence already includes **HPA + kubectl top + describe**

If you extend to production later, prefer upstream install docs and pin versions—still **without Helm** if that is a project constraint.

See also: `metrics-evidence-commands.ps1` for a repeatable evidence script.
