## Persistent volume for Redis cart

### Why persistence matters

The **cart** service stores session/cart state in **Redis**. Without a persistent volume, Redis data lives on the container filesystem and is **lost** when the pod is deleted or rescheduled. A **PersistentVolumeClaim (PVC)** requests durable storage so cart data can survive pod restarts (subject to reclaim policy and backing storage).

### How PVC fits in

- **PersistentVolume (PV)**: cluster-level storage resource (here: **hostPath** for local demo).
- **PersistentVolumeClaim (PVC)**: namespaced request for storage; pods mount the bound PV via the claim.
- The **redis-cart** Deployment mounts the PVC at **`/data`**.

### Local demo caveat

**hostPath** is acceptable **only** for local Kubernetes (e.g. Docker Desktop). It binds to a path on the node VM and is **not** portable or suitable for production. Production should use cloud storage classes (e.g. Azure Disk, AWS EBS, GCE PD) or **managed Redis**.

### Verification commands

```powershell
kubectl get pv
kubectl get pvc -n online-boutique
kubectl describe pvc redis-cart-pvc -n online-boutique
kubectl describe pod -l app=redis-cart -n online-boutique
```

Confirm the redis pod shows the volume mounted and **Bound** for `redis-cart-pvc`.
