## Overview

This folder contains a **SIT727 HD custom Kubernetes deployment** for the upstream **GoogleCloudPlatform/microservices-demo (Online Boutique)** project.

- The original upstream manifests remain unchanged in `kubernetes-manifests/` and `release/`.
- This `k8s-hd-custom/` folder is a **separate, deployable variant** that demonstrates HD-level Kubernetes engineering while keeping the app deployable to the **`online-boutique`** namespace.

Apply everything with Kustomize:

```powershell
kubectl apply -k .\k8s-hd-custom\
```

Important: use `-k`, not `-f`, for this folder because it contains `kustomization.yaml`.

## What changed (vs upstream manifests)

### Local images (HD engineering work)
Upstream uses prebuilt images from Google registries (e.g. `us-central1-docker.pkg.dev/...`).

This HD version switches Deployments to **locally built images**:

- `online-boutique/frontend:hd-local`
- `online-boutique/checkoutservice:hd-local`
- `online-boutique/cartservice:hd-local`
- `online-boutique/productcatalogservice:hd-local`
- `online-boutique/recommendationservice:hd-local`
- `online-boutique/paymentservice:hd-local`
- `online-boutique/shippingservice:hd-local`
- `online-boutique/currencyservice:hd-local`
- `online-boutique/emailservice:hd-local`
- `online-boutique/adservice:hd-local`
- `online-boutique/loadgenerator:hd-local`

Each Deployment sets:

- `imagePullPolicy: IfNotPresent`

This is appropriate for Docker Desktop Kubernetes where images exist locally.

### A) Resource requests and limits
Major services have **explicit CPU/memory requests and limits** to:

- enable fair scheduling and prevent noisy-neighbor issues
- support autoscaling based on CPU (HPA requires CPU requests)
- demonstrate production-minded capacity planning

### B) Readiness and liveness probes (plus startup probes)
Services include health probes:

- **HTTP probes** on `frontend` (`/_healthz`)
- **TCP socket probes** for gRPC services (checkout/cart/productcatalog/recommendation/payment/etc.) to keep the setup portable across Kubernetes versions

This HD variant also adds/tunes **`startupProbe`** and standardizes probe timings to reduce flapping during cold starts and rollouts.

### C) Horizontal Pod Autoscalers (autoscaling/v2)
HPAs are added for:

- `frontend`
- `checkoutservice`
- `recommendationservice`

Settings:

- `minReplicas: 1`
- `maxReplicas: 5`
- CPU utilization target: ~60%

### D) NetworkPolicies (safe, “do not break app”)
The `networkpolicy/` folder adds **ingress-only** NetworkPolicies that demonstrate controlled communication without restricting egress:

- frontend accepts ingress (safe allow)
- backend services only accept calls from the expected callers
  - frontend → checkout/cart/currency/productcatalog/recommendation/shipping/ad
  - checkoutservice → paymentservice/cartservice/currencyservice/shippingservice/emailservice
  - recommendationservice → productcatalogservice
  - cartservice → redis-cart

### E) ConfigMap (non-sensitive config)
`configmap-hd-config.yaml` defines demo configuration:

- `ENVIRONMENT_NAME`
- `DEMO_MODE`
- `LOG_LEVEL`

Wired into:

- `frontend` (via `envFrom`)
- `checkoutservice` (via `envFrom`)

### F) Secret (dummy credential)
`secret-payment-demo.yaml` defines a **dummy** payment API key and wires it into `paymentservice`:

- `PAYMENT_API_KEY` via `secretKeyRef`

### G) PodDisruptionBudgets
PDBs are added for:

- `frontend` (`minAvailable: 2`)
- `checkoutservice` (`maxUnavailable: 1`)

These demonstrate resilience during voluntary disruptions (node drains, upgrades).

## How to build local images

From the repo root (or anywhere), run:

```bash
python ./k8s-hd-custom/build-local-images.py
```

Optional arguments:

```bash
python ./k8s-hd-custom/build-local-images.py --tag hd-local --platform linux/amd64
```

Verify images exist locally:

```powershell
docker images online-boutique/*
```

### How Docker Desktop Kubernetes uses local images
When **Docker Desktop Kubernetes** is enabled, the Kubernetes cluster uses the **same Docker engine** as `docker build`.
That means images you build locally (like `online-boutique/frontend:hd-local`) are available to Kubernetes without pushing to a registry.

If you use a different Kubernetes environment (e.g., Minikube, kind, remote cluster), you may need to load/push images differently.

## Deploy / verify commands

### Apply (create/update everything)

```powershell
kubectl apply -k .\k8s-hd-custom\
```

### Verify pods and services

```powershell
kubectl get pods -n online-boutique
kubectl get svc -n online-boutique
kubectl get endpoints -n online-boutique
```

### Verify probes (readiness/liveness/startup)

```powershell
kubectl describe pod -n online-boutique -l app=frontend
kubectl describe pod -n online-boutique -l app=checkoutservice
```

### Verify HPAs (requires metrics-server)

```powershell
kubectl get hpa -n online-boutique
kubectl describe hpa frontend -n online-boutique
```

### Verify NetworkPolicies

```powershell
kubectl get networkpolicy -n online-boutique
kubectl describe networkpolicy frontend-allow-ingress -n online-boutique
```

### Verify PodDisruptionBudgets

```powershell
kubectl get pdb -n online-boutique
kubectl describe pdb frontend -n online-boutique
```

## Troubleshooting (ImagePullBackOff)

If pods show `ImagePullBackOff`:

- confirm the image name and tag match exactly (example: `online-boutique/frontend:hd-local`)
- confirm Docker Desktop Kubernetes is enabled
- confirm images were built in the same Docker Desktop environment
- switch `imagePullPolicy` from `IfNotPresent` to `Never` for strict local-only testing
- inspect the exact error:

```powershell
kubectl describe pod <pod-name> -n online-boutique
```

## Why this demonstrates SIT727 HD-level Kubernetes work

This `k8s-hd-custom/` deployment shows:

- **production-style reliability** (probes, PDBs)
- **scalability** (autoscaling/v2 HPAs with CPU targets)
- **security posture** (NetworkPolicies and Secret usage)
- **operational maturity** (requests/limits for scheduling + predictable capacity)
- **engineering ownership** (local image build pipeline + manifests wired to those images)
- **ingress, storage, scheduling, and ops evidence** (documented below with proposal mapping)

---

## Final SIT727 7.2HD Kubernetes Feature Coverage

| Feature | Implemented? | File / folder | Evidence command (examples) | Proposal mapping |
|--------|---------------|---------------|------------------------------|--------------------|
| Local image builds | Yes | `build-local-images.py` | `docker images online-boutique/*` | Build ownership; reproducible images |
| Namespace | Yes | `namespace.yaml` | `kubectl get ns online-boutique` | Multi-tenant isolation |
| Deployments / Services | Yes | `*.yaml` (workloads) | `kubectl get deploy,svc -n online-boutique` | App delivery |
| Resource requests/limits | Yes | workload YAML | `kubectl describe pod -l app=frontend -n online-boutique` | Capacity, scheduling, HPA |
| Liveness/readiness/startup probes | Yes | workload YAML | `kubectl describe pod -l app=frontend -n online-boutique` | Health, rollouts |
| HPA (CPU) | Yes | `hpa-*.yaml` | `kubectl get hpa -n online-boutique` | Elastic scaling |
| ConfigMap | Yes | `configmap-hd-config.yaml` | `kubectl get cm hd-demo-config -n online-boutique -o yaml` | Externalized config |
| Secret | Yes | `secret-payment-demo.yaml` | `kubectl get secret payment-demo-credentials -n online-boutique` | Sensitive config pattern |
| NetworkPolicy | Yes | `networkpolicy/` | `kubectl get netpol -n online-boutique` | Zero-trust-style traffic rules |
| PodDisruptionBudget | Yes | `pdb-*.yaml` | `kubectl get pdb -n online-boutique` | Upgrade/drain safety |
| Ingress | Yes | `ingress/frontend-ingress.yaml` | `kubectl get ingress -n online-boutique` | Realistic HTTP access |
| PV / PVC (Redis) | Yes | `storage/redis-pv-pvc.yaml` + `cartservice.yaml` | `kubectl get pv,pvc -n online-boutique` | Stateful data pattern |
| Monitoring (lightweight) | Yes (docs + scripts) | `monitoring/` | `.\k8s-hd-custom\monitoring\metrics-evidence-commands.ps1` | Metrics / top / HPA signals |
| Logging (lightweight) | Yes (docs + scripts) | `logging/` | `.\k8s-hd-custom\logging\log-evidence-commands.ps1` | Central inspection via APIs |
| Alerting (examples) | Example only | `examples/prometheus-alert-rules-example.yaml` | `kubectl get crd prometheusrules.monitoring.coreos.com` | Alert-as-code design |
| Pod affinity / anti-affinity | Yes (preferred) | `frontend.yaml`, `checkoutservice.yaml`, `recommendationservice.yaml` | `kubectl describe deploy frontend -n online-boutique` | HA scheduling intent |
| Rolling updates | Yes (Deployment defaults) | workload YAML | `kubectl rollout status deploy/frontend -n online-boutique` | Safe releases |
| Failure recovery | Operational | events/logs/PDB | `kubectl get events -n online-boutique --sort-by=.metadata.creationTimestamp` | Ops troubleshooting |
| Custom metrics HPA | Example only | `examples/frontend-custom-metrics-hpa-example.yaml` | See `autoscaling/README-custom-metrics-hpa.md` (custom metrics API) | Advanced scaling story |

---

## Core apply order (recommended)

**Preferred:** one command applies all core manifests (including namespace ordering inside `kustomization.yaml`):

```powershell
kubectl apply -k .\k8s-hd-custom\
```

**Why not `kubectl apply -f ... --recursive`?**  
That pattern attempts to apply `kustomization.yaml` as a Kubernetes object and **fails**. Use **`-k`** (Kustomize) for this folder.

**Optional split** (if you want explicit steps):

```powershell
kubectl apply -f .\k8s-hd-custom\storage\redis-pv-pvc.yaml
kubectl apply -k .\k8s-hd-custom\
kubectl apply -f .\k8s-hd-custom\ingress\frontend-ingress.yaml -n online-boutique
```

(In practice, `kubectl apply -k` already includes storage and ingress when listed in `kustomization.yaml`.)

**Do not apply** `examples/*.yaml` unless you have the required CRDs/APIs (see `examples/README.md`).

---

## Evidence commands for presentation

```powershell
kubectl get pods -n online-boutique
kubectl get deploy -n online-boutique
kubectl get svc -n online-boutique
kubectl get hpa -n online-boutique
kubectl get ingress -n online-boutique
kubectl get pv
kubectl get pvc -n online-boutique
kubectl get pdb -n online-boutique
kubectl get networkpolicy -n online-boutique
kubectl get configmap -n online-boutique
kubectl get secret -n online-boutique
kubectl top pods -n online-boutique
kubectl get events -n online-boutique --sort-by=.metadata.creationTimestamp
```

---

## Known local demo limitations

- **Single-node clusters** (typical Docker Desktop): **preferred** anti-affinity shows scheduling intent but may not spread pods across nodes.
- **hostPath PV** for Redis is **demo-only**; production should use cloud storage or managed Redis.
- **CPU-based HPA** is implemented; **custom-metrics HPA** is an **example only** under `examples/`.
- **Prometheus/Grafana/alert rules**: core demo uses **kubectl + metrics-server + events**; operator CRD examples are optional.
- **Ingress** requires installing an Ingress controller (e.g. ingress-nginx); **`kubectl port-forward`** remains a valid fallback (see `ingress/README-ingress.md`).

---

## Further reading (inside this folder)

| Topic | Location |
|-------|----------|
| Ingress install + hosts file | `ingress/README-ingress.md` |
| Redis PV/PVC | `storage/README-storage.md` |
| Metrics / HPA evidence | `monitoring/README-monitoring.md`, `monitoring/metrics-evidence-commands.ps1` |
| Alerting examples | `monitoring/README-alerting.md`, `examples/prometheus-alert-rules-example.yaml` |
| Logging evidence | `logging/README-logging.md`, `logging/log-evidence-commands.ps1` |
| Fluent Bit (optional) | `examples/fluent-bit-daemonset-example.yaml` |
| Affinity | `scheduling/README-affinity.md` |
| HPA reference | `autoscaling/README-hpa.md` |
| Custom metrics HPA (theory + example) | `autoscaling/README-custom-metrics-hpa.md`, `examples/frontend-custom-metrics-hpa-example.yaml` |
| Example-only CRDs | `examples/README.md` |
