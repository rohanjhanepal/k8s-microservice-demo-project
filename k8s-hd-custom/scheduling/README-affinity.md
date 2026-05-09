## Pod affinity / anti-affinity (preferred rules)

### What this does

**Pod anti-affinity** expresses scheduling preferences: “try not to place multiple replicas of the same app on the same node.” We use **`preferredDuringSchedulingIgnoredDuringExecution`** so scheduling remains **soft**: if only one node exists, pods still schedule.

### Why `preferred` instead of `required`

On **Docker Desktop**, the cluster is usually **single-node**. **Required** anti-affinity can prevent second replicas from scheduling at all. **Preferred** rules demonstrate production intent without breaking local demos.

### Where implemented

- `frontend.yaml` — spread `frontend` replicas across nodes when possible
- `checkoutservice.yaml` — spread `checkoutservice` replicas
- `recommendationservice.yaml` — spread `recommendationservice` replicas

### Verification

```powershell
kubectl describe deploy frontend -n online-boutique
kubectl describe deploy checkoutservice -n online-boutique
kubectl describe deploy recommendationservice -n online-boutique
```

Look under **Annotations** / template metadata and **Affinity** in the pod template spec when describing the ReplicaSet or Pod.
