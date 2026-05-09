## Ingress for the frontend (HD demonstration)

This Ingress exposes the **`frontend`** Service on host **`boutique.local`** with path **`/`**, using the **nginx** ingress class. It replaces ad-hoc **`kubectl port-forward`** with a more realistic HTTP entry pattern for demos and reports.

### Prerequisites

- An Ingress controller must be installed in the cluster. For **Docker Desktop**, install **ingress-nginx** using **plain manifests** (do **not** use Helm for this project).

Official install (pick the manifest that matches your cluster; verify on the upstream docs):

```powershell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
```

If that URL/version changes, use the current manifest from the [ingress-nginx installation guide](https://kubernetes.github.io/ingress-nginx/deploy/).

### Apply this repo’s Ingress

From the repository root:

```powershell
kubectl apply -f .\k8s-hd-custom\ingress\frontend-ingress.yaml -n online-boutique
```

Or apply everything with Kustomize (includes this Ingress if listed in `kustomization.yaml`):

```powershell
kubectl apply -k .\k8s-hd-custom\
```

### Map `boutique.local` to localhost

Edit your hosts file (Windows: typically `C:\Windows\System32\drivers\etc\hosts`) and add:

```text
127.0.0.1 boutique.local
```

### Verify

```powershell
kubectl get ingress -n online-boutique
```

Test (Ingress controller usually listens on port **80** locally):

```powershell
curl http://boutique.local
```

Use a browser: `http://boutique.local`

### Fallback (always works)

If Ingress is not installed or DNS/hosts are wrong:

```powershell
kubectl port-forward svc/frontend 8080:80 -n online-boutique
```

Then open `http://localhost:8080`.
