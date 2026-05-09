# SIT727 7.2HD — Online Boutique on Kubernetes

Professional deployment and demonstration of **GoogleCloudPlatform/microservices-demo (Online Boutique)** with a custom HD Kubernetes overlay: **`k8s-hd-custom/`**.

---

## 1. Project overview

This submission packages **microservice source** (`src/`), **local image builds**, and **plain Kubernetes YAML** (no Helm) deployable to the **`online-boutique`** namespace on **Docker Desktop Kubernetes**. The overlay adds production-style patterns: resources, probes, HPA, PDBs, NetworkPolicies, ConfigMap/Secret, Ingress, persistent Redis storage, scheduling preferences, and operational documentation.

---

## 2. Architecture summary

Browser/clients reach **`frontend`** (ClusterIP, optional **Ingress** at `boutique.local`, or **port-forward**). **Frontend** calls catalog, cart, currency, recommendations, shipping, checkout, ads, etc. **Checkout** coordinates payment, email, cart, currency, shipping. **Cart** uses **Redis** (`redis-cart`) with a **PVC** for durable demo storage. Supporting services expose gRPC/HTTP per upstream design.

Use `docs/img/architecture-diagram.png` (upstream) or place your own diagram in `presentation-assets/diagrams/`.

---

## 3. Technologies used

| Area | Stack |
|------|--------|
| Runtime | Go, .NET, Node.js, Python, Java (per service) |
| Containers | Docker; images tagged `online-boutique/*:hd-local` |
| Orchestration | Kubernetes; Kustomize (`kubectl apply -k`) |
| Ingress | ingress-nginx (install separately; see `k8s-hd-custom/ingress/README-ingress.md`) |
| Evidence | `kubectl`, metrics-server (for `kubectl top`), scripts in `k8s-hd-custom/monitoring/` and `logging/` |

---

## 4. Kubernetes features implemented (HD)

See **`k8s-hd-custom/README.md`** for the full feature matrix. Highlights:

- Resource requests/limits, HTTP/TCP probes, **autoscaling/v2** HPA (CPU), PDB, NetworkPolicy, ConfigMap + Secret, **PV/PVC** for Redis, **Ingress**, preferred **pod anti-affinity**, optional **PrometheusRule / custom-metrics HPA / Fluent Bit** examples under `k8s-hd-custom/examples/` (not applied by default).

---

## 5. Local image build workflow

From repo root:

```bash
python ./k8s-hd-custom/build-local-images.py
docker images online-boutique/*
```

Cross-platform script: `k8s-hd-custom/build-local-images.py`. Legacy: `k8s-hd-custom/build-local-images.ps1`.

---

## 6. Deployment

```powershell
kubectl apply -k .\k8s-hd-custom\
```

Use **`-k`**, not `-f`, for this folder (it contains `kustomization.yaml`).

**Access**

- Ingress + hosts: see `k8s-hd-custom/ingress/README-ingress.md`
- Fallback: `kubectl port-forward svc/frontend 8080:80 -n online-boutique` → http://localhost:8080

---

## 7. Demo workflow

Follow **`presentation-assets/commands/demo-runbook.md`** and **`demo-checklist.md`** for recording order and screenshots.

---

## 8. Folder structure (delivery)

| Path | Purpose |
|------|---------|
| `k8s-hd-custom/` | HD manifests, Kustomize, docs, build script (**primary deploy path**) |
| `src/` | Service source + Dockerfiles (build inputs) |
| `kubernetes-manifests/` | **Upstream** reference manifests (unmodified baseline) |
| `release/` | Upstream release bundles (optional reference) |
| `docs/` | Upstream project documentation |
| `presentation-assets/` | Screenshots, diagrams, commands, notes for assessment |
| `submission/` | Report/presentation placeholders; ZIP guidance |
| `archive/` | Non-critical archived notes (e.g. old command scratch) |

---

## 9. Key Kubernetes concepts demonstrated

Workload design (Deployments, Services), **declarative config** (Kustomize), **observability hooks** (probes, `kubectl top`/`logs`/`events`), **scaling** (HPA), **reliability** (PDB, rolling updates), **security** (NetworkPolicy, Secrets), **storage** (PV/PVC), **edge routing** (Ingress), **scheduling** (soft anti-affinity).

---

## 10. Known limitations (Docker Desktop)

Single-node clusters limit **anti-affinity** effects; **hostPath** Redis PV is **demo-only**; full Prometheus/Grafana stacks are **optional** and documented, not required locally; **CPU-based** HPA is primary; **custom-metrics HPA** is example-only.

---

## 11. Mapping to SIT727 HD proposal goals

Align your proposal text to: reproducible **build** (`build-local-images.py`), **declarative deploy** (`kubectl apply -k`), **measurable evidence** (runbook + `kubectl` outputs), **design depth** (NetworkPolicy, storage, ingress, HPA, PDB), and **honest scope** (examples in `examples/` vs core apply).

---

## 12. Final evidence commands (summary)

```powershell
kubectl get pods,deploy,svc,hpa,ingress,pdb,netpol,cm,secret,pvc -n online-boutique
kubectl get pv
kubectl top pods -n online-boutique
kubectl get events -n online-boutique --sort-by=.metadata.creationTimestamp
```

Full list: `k8s-hd-custom/README.md` → *Evidence commands for presentation*.

---

## 13. Screenshots (placeholders)

Save captures under **`presentation-assets/screenshots/`**, for example:

- `01-pods-online-boutique.png`
- `02-hpa.png`
- `03-networkpolicy.png`
- `04-ingress-or-port-forward-note.png`
- `05-pvc-redis.png`
- `06-browser-shop.png`

---

## Pointers

| Document | Role |
|----------|------|
| `k8s-hd-custom/README.md` | Full HD technical README |
| `presentation-assets/commands/demo-runbook.md` | Step-by-step demo |
| `submission/final-zip/ZIP-CONTENTS.md` | What to submit in the ZIP |
