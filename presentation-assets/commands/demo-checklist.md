# Demo checklist (before and during recording)

## Before recording

- [ ] Docker Desktop running; **Kubernetes** enabled
- [ ] `kubectl config current-context` points at the demo cluster
- [ ] Built images: `python ./k8s-hd-custom/build-local-images.py`
- [ ] Verified: `docker images online-boutique/*`
- [ ] Deployed: `kubectl apply -k .\k8s-hd-custom\`
- [ ] All pods `Running`: `kubectl get pods -n online-boutique`
- [ ] **Ingress path:** ingress-nginx installed (if using `boutique.local`)
- [ ] **Hosts file:** `127.0.0.1 boutique.local` (if using Ingress)
- [ ] **Fallback ready:** `kubectl port-forward svc/frontend 8080:80 -n online-boutique`
- [ ] Browser opens shop (Ingress or port-forward)
- [ ] Terminal font/zoom readable for recording

## Core verification (evidence)

- [ ] `kubectl get deploy,svc -n online-boutique`
- [ ] `kubectl get hpa,pdb,netpol -n online-boutique`
- [ ] `kubectl get ingress -n online-boutique` (if using Ingress)
- [ ] `kubectl get pvc -n online-boutique` + `kubectl get pv`
- [ ] `kubectl get configmap,secret -n online-boutique`

## Access

- [ ] Open **boutique.local** (Ingress) **or** **localhost:8080** (port-forward)
- [ ] Add item to cart / browse (happy path visible)

## Scaling demo

- [ ] `kubectl get hpa -n online-boutique` (baseline)
- [ ] Optional: `kubectl set env deployment/loadgenerator USERS=50 -n online-boutique`
- [ ] `kubectl top pods -n online-boutique` (if metrics-server works)
- [ ] `kubectl get hpa -n online-boutique -w` (short clip, then Ctrl+C)

## Failure recovery

- [ ] `kubectl get pods -l app=frontend -n online-boutique`
- [ ] `kubectl delete pod <one-frontend-pod> -n online-boutique`
- [ ] `kubectl get pods -n online-boutique -w` until new pod Ready

## Rolling update

- [ ] `kubectl rollout restart deployment/frontend -n online-boutique`
- [ ] `kubectl rollout status deployment/frontend -n online-boutique`

## Monitoring / logging evidence

- [ ] `.\k8s-hd-custom\monitoring\metrics-evidence-commands.ps1` (or manual `kubectl top` / `describe hpa`)
- [ ] `.\k8s-hd-custom\logging\log-evidence-commands.ps1` (or `kubectl logs` / `get events`)

## Screenshots to capture (drop files in `presentation-assets/screenshots/`)

- [ ] `kubectl get pods -n online-boutique` (all healthy)
- [ ] `kubectl get hpa -n online-boutique`
- [ ] `kubectl get netpol -n online-boutique`
- [ ] `kubectl get ingress -n online-boutique` (if applicable)
- [ ] `kubectl get pvc` + `kubectl describe pod -l app=redis-cart -n online-boutique` (volume)
- [ ] Browser: shop home page + cart (optional)
- [ ] Optional: `kubectl describe hpa frontend -n online-boutique`

## Diagrams / assets

- [ ] Copy architecture diagram into `presentation-assets/diagrams/` (e.g. from `docs/img/` or your report)
- [ ] Speaker notes in `presentation-assets/notes/` if needed

## Backup / fallback

- [ ] If Ingress fails: use **port-forward** + localhost
- [ ] If `kubectl top` fails: note metrics-server; use **describe hpa** + **events** instead
- [ ] If cluster unstable: restart cluster; re-`apply -k`; keep last good recording

## After recording

- [ ] Optionally reduce `loadgenerator` load for your machine
- [ ] Save ZIP per `submission/final-zip/ZIP-CONTENTS.md`
