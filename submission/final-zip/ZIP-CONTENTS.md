# Final submission ZIP — what to include

## Purpose

The ZIP should let a marker **rebuild images**, **apply manifests**, and **verify** your HD work without hunting through vendor clutter.

---

## Recommended INCLUSIONS

| Path | Why |
|------|-----|
| `README-HD-PROJECT.md` | Entry point for your HD submission |
| `k8s-hd-custom/` | **Entire folder** — Kustomize, YAML, docs, `build-local-images.py` |
| `src/` | **Entire folder** — required to rebuild `online-boutique/*:hd-local` images |
| `kubernetes-manifests/` | Optional but valuable: proves upstream baseline vs your overlay |
| `presentation-assets/` | Screenshots, diagrams, demo runbook — **strongly recommended** |
| `submission/report/` | Your written report PDF/DOCX if the brief allows bundling |

---

## Recommended EXCLUSIONS (keep repo smaller / safer)

| Path / pattern | Why exclude |
|----------------|-------------|
| `.git/` | Usually not required unless asked for full VCS history |
| `node_modules/`, `__pycache__/`, `.pytest_cache/` | Regenerated; use `.gitignore` |
| `bin/`, `obj/`, `vendor/` (if present) | Build artifacts |
| `release/kubernetes-manifests.yaml` | Large consolidated bundle; optional if `kubernetes-manifests/` is included |
| `.deploystack/`, `.terraform/` | Not needed for your kubectl workflow |
| `submission/final-zip/export-*` | Staging folders from the zip script |
| `*.zip` outputs | Avoid nesting duplicate archives |

**Optional CRD examples:** `k8s-hd-custom/examples/` is small and educational — include for “extension” narrative, or exclude if you need a minimal ZIP.

**`archive/`:** Include only if you want markers to see old notes; otherwise omit.

---

## Approximate ZIP structure (example)

```
microservices-demo-hd/
  README-HD-PROJECT.md
  k8s-hd-custom/
    kustomization.yaml
    *.yaml
    build-local-images.py
    README.md
    ingress/ storage/ monitoring/ logging/ ...
    examples/          # optional
  src/
    adservice/
    cartservice/
    ...
  kubernetes-manifests/   # optional reference
  presentation-assets/
    commands/
    screenshots/
    diagrams/
  submission/
    report/
```

---

## Single-command packaging

Use **`submission/final-zip/prepare-final-zip.ps1`** on Windows to stage a clean folder and optionally create `sit727-hd-submission.zip`.

Adjust paths inside the script if your marker requires extra files (e.g. full `docs/`).
