python ./k8s-hd-custom/build-local-images.py
kubectl apply -k .\k8s-hd-custom\
kubectl get pods -n online-boutique
kubectl port-forward svc/frontend 8080:80 -n online-boutique