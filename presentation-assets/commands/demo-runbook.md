# SIT727 HD demo runbook (recording order)

Run from the repository root unless noted. Namespace: **`online-boutique`**.

---

## 1. Preconditions

**Check cluster and context**

```powershell
kubectl config current-context
kubectl cluster-info
```

Ensures you are on the intended cluster (e.g. Docker Desktop).

**Check Docker**

```powershell
docker version
```

Required for local image builds.

---

## 2. Build local container images

```powershell
python ./k8s-hd-custom/build-local-images.py
```

Builds `online-boutique/<service>:hd-local` images from `src/` per `build-local-images.py`.

**Verify images**

```powershell
docker images online-boutique/*
```

---

## 3. Deploy the HD stack

```powershell
kubectl apply -k .\k8s-hd-custom\
```

Applies namespace, workloads, storage, ingress, HPAs, PDBs, NetworkPolicies, ConfigMap, Secret, etc. (see `k8s-hd-custom/kustomization.yaml`).

**Wait for rollouts (optional but cleaner on recording)**

```powershell
kubectl rollout status deployment/frontend -n online-boutique --timeout=120s
kubectl rollout status deployment/checkoutservice -n online-boutique --timeout=120s
```

---

## 4. Verify pods and services

```powershell
kubectl get pods -n online-boutique
kubectl get deploy,svc -n online-boutique
kubectl get endpoints -n online-boutique
```

Confirms scheduling, Services, and endpoints.

---

## 5. Access the web UI

**Option A — Ingress (after ingress-nginx + hosts file)**

Hosts file: `127.0.0.1 boutique.local`

```powershell
kubectl get ingress -n online-boutique
```

Browser: `http://boutique.local`

**Option B — Port forward (always works)**

```powershell
kubectl port-forward svc/frontend 8080:80 -n online-boutique
```

Browser: `http://localhost:8080`

---

## 6. HD feature evidence (quick sweep)

```powershell
kubectl get hpa,pdb,netpol,ingress,pvc -n online-boutique
kubectl get pv
kubectl get configmap,secret -n online-boutique
```

---

## 7. Monitoring evidence

```powershell
kubectl top pods -n online-boutique
kubectl top nodes
kubectl get hpa -n online-boutique
kubectl describe hpa frontend -n online-boutique
```

Or the bundled script:

```powershell
.\k8s-hd-custom\monitoring\metrics-evidence-commands.ps1
```

---

## 8. Logging evidence

```powershell
kubectl logs deployment/frontend -n online-boutique --tail=80
kubectl get events -n online-boutique --sort-by=.metadata.creationTimestamp | Select-Object -Last 30
```

Or:

```powershell
.\k8s-hd-custom\logging\log-evidence-commands.ps1
```

---

## 9. Scaling demo (HPA + load)

**Show HPA before load**

```powershell
kubectl get hpa -n online-boutique
```

**Optional: increase load generator (use reasonable values for your laptop)**

```powershell
kubectl set env deployment/loadgenerator USERS=50 -n online-boutique
```

**Watch scaling**

```powershell
kubectl get hpa -n online-boutique -w
```

(Press Ctrl+C when done.) Revert load if needed by re-applying `k8s-hd-custom/loadgenerator.yaml` or setting `USERS` back.

---

## 10. Failure recovery demo

**Pick a frontend pod name from:**

```powershell
kubectl get pods -n online-boutique -l app=frontend
```

**Delete one pod (replace `<pod-name>`)**

```powershell
kubectl delete pod <pod-name> -n online-boutique
```

**Watch replacement**

```powershell
kubectl get pods -n online-boutique -l app=frontend -w
```

Shows Deployment recreating the pod.

---

## 11. Rolling update demo (no new image required)

**Trigger rollout restart**

```powershell
kubectl rollout restart deployment/frontend -n online-boutique
kubectl rollout status deployment/frontend -n online-boutique
```

**Describe deployment for ReplicaSet history**

```powershell
kubectl describe deployment frontend -n online-boutique
```

---

## 12. Scheduling (affinity) — describe only

```powershell
kubectl describe deployment frontend -n online-boutique
kubectl describe deployment checkoutservice -n online-boutique
kubectl describe deployment recommendationservice -n online-boutique
```

Scroll to pod template for **affinity** (preferred anti-affinity).

---

## 13. Storage (Redis PVC)

```powershell
kubectl get pvc -n online-boutique
kubectl describe pvc redis-cart-pvc -n online-boutique
kubectl describe pod -l app=redis-cart -n online-boutique
```

---

## 14. Full “submission evidence” one-liner sweep (optional)

```powershell
kubectl get pods,deploy,svc,hpa,ingress,pdb,netpol,cm,secret,pvc -n online-boutique; kubectl get pv
```

---

## 15. Shutdown (optional, after demo)

```powershell
kubectl delete -k .\k8s-hd-custom\
```

**Warning:** deletes resources defined in kustomize. Only run if you intend to tear down.

For a full project reference, see **`README-HD-PROJECT.md`** and **`k8s-hd-custom/README.md`**.
