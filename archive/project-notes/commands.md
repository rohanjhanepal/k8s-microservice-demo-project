# Legacy command notes (superseded)

**Use instead:** `presentation-assets/commands/demo-runbook.md`

Original scratch content preserved below.

---

python ./k8s-hd-custom/build-local-images.py
kubectl apply -k .\k8s-hd-custom\
kubectl get pods -n online-boutique
kubectl port-forward svc/frontend 8080:80 -n online-boutique

kubectl get deploy -n online-boutique
kubectl get svc -n online-boutique
kubectl get hpa -n online-boutique
kubectl get pdb -n online-boutique
kubectl get networkpolicy -n online-boutique
kubectl get configmap -n online-boutique
kubectl get secret -n online-boutique


kubectl describe hpa frontend -n online-boutique
kubectl describe deploy frontend -n online-boutique
kubectl describe deploy paymentservice -n online-boutique

Next experiment: failure recovery

Run:

kubectl delete pod frontend-7c8454447-7mzc5 -n online-boutique

Then immediately:

kubectl get pods -n online-boutique -w

Capture that Kubernetes recreates the pod.
