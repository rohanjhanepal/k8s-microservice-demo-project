#!/usr/bin/env python3
"""
Cross-platform local image builder for Online Boutique HD manifests.

Usage:
  python k8s-hd-custom/build-local-images.py
  python k8s-hd-custom/build-local-images.py --tag hd-local --platform linux/amd64
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


IMAGES = [
    {
        "name": "frontend",
        "context": "src/frontend",
        "dockerfile": "src/frontend/Dockerfile",
    },
    {
        "name": "checkoutservice",
        "context": "src/checkoutservice",
        "dockerfile": "src/checkoutservice/Dockerfile",
    },
    {
        "name": "cartservice",
        "context": "src/cartservice/src",
        "dockerfile": "src/cartservice/src/Dockerfile",
    },
    {
        "name": "productcatalogservice",
        "context": "src/productcatalogservice",
        "dockerfile": "src/productcatalogservice/Dockerfile",
    },
    {
        "name": "recommendationservice",
        "context": "src/recommendationservice",
        "dockerfile": "src/recommendationservice/Dockerfile",
    },
    {
        "name": "paymentservice",
        "context": "src/paymentservice",
        "dockerfile": "src/paymentservice/Dockerfile",
    },
    {
        "name": "shippingservice",
        "context": "src/shippingservice",
        "dockerfile": "src/shippingservice/Dockerfile",
    },
    {
        "name": "currencyservice",
        "context": "src/currencyservice",
        "dockerfile": "src/currencyservice/Dockerfile",
    },
    {
        "name": "emailservice",
        "context": "src/emailservice",
        "dockerfile": "src/emailservice/Dockerfile",
    },
    {
        "name": "adservice",
        "context": "src/adservice",
        "dockerfile": "src/adservice/Dockerfile",
    },
    {
        "name": "loadgenerator",
        "context": "src/loadgenerator",
        "dockerfile": "src/loadgenerator/Dockerfile",
    },
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build local Online Boutique images.")
    parser.add_argument("--tag", default="hd-local", help="Image tag suffix (default: hd-local)")
    parser.add_argument(
        "--platform",
        default="linux/amd64",
        help="Build platform for docker build (default: linux/amd64)",
    )
    return parser.parse_args()


def run(cmd: list[str]) -> None:
    process = subprocess.run(cmd, check=False)
    if process.returncode != 0:
        raise RuntimeError(f"Command failed ({process.returncode}): {' '.join(cmd)}")


def main() -> int:
    args = parse_args()

    if shutil.which("docker") is None:
        print("Error: 'docker' command not found in PATH.", file=sys.stderr)
        return 1

    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent

    print(f"Repo root: {repo_root}")
    print(f"Building local images with tag: {args.tag}")
    print(f"Platform: {args.platform}")
    print("")

    for image in IMAGES:
        name = image["name"]
        tag = f"online-boutique/{name}:{args.tag}"
        context_path = repo_root / image["context"]
        dockerfile_path = repo_root / image["dockerfile"]

        if not context_path.exists():
            raise FileNotFoundError(f"Missing build context: {context_path}")
        if not dockerfile_path.exists():
            raise FileNotFoundError(f"Missing Dockerfile: {dockerfile_path}")

        print(f"==> Building {tag}")
        run(
            [
                "docker",
                "build",
                "--platform",
                args.platform,
                "-t",
                tag,
                "-f",
                str(dockerfile_path),
                str(context_path),
            ]
        )
        print("")

    print("Done.")
    print("Verify with: docker images online-boutique/*")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, FileNotFoundError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
