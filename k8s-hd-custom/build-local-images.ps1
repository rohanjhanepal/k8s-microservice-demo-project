[CmdletBinding()]
param(
  # Image tag suffix used by the HD manifests.
  [string]$Tag = "hd-local",

  # Build for a specific platform (helpful for Kubernetes on Docker Desktop).
  [string]$Platform = "linux/amd64"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

$images = @(
  @{ Name = "frontend";             Context = "src/frontend";             Dockerfile = "src/frontend/Dockerfile" }
  @{ Name = "checkoutservice";      Context = "src/checkoutservice";      Dockerfile = "src/checkoutservice/Dockerfile" }
  @{ Name = "cartservice";          Context = "src/cartservice/src";      Dockerfile = "src/cartservice/src/Dockerfile" }
  @{ Name = "productcatalogservice";Context = "src/productcatalogservice";Dockerfile = "src/productcatalogservice/Dockerfile" }
  @{ Name = "recommendationservice";Context = "src/recommendationservice";Dockerfile = "src/recommendationservice/Dockerfile" }
  @{ Name = "paymentservice";       Context = "src/paymentservice";       Dockerfile = "src/paymentservice/Dockerfile" }
  @{ Name = "shippingservice";      Context = "src/shippingservice";      Dockerfile = "src/shippingservice/Dockerfile" }
  @{ Name = "currencyservice";      Context = "src/currencyservice";      Dockerfile = "src/currencyservice/Dockerfile" }
  @{ Name = "emailservice";         Context = "src/emailservice";         Dockerfile = "src/emailservice/Dockerfile" }
  @{ Name = "adservice";            Context = "src/adservice";            Dockerfile = "src/adservice/Dockerfile" }
  @{ Name = "loadgenerator";        Context = "src/loadgenerator";        Dockerfile = "src/loadgenerator/Dockerfile" }
)

Write-Host "Repo root: $RepoRoot"
Write-Host "Building local images with tag: $Tag"
Write-Host "Platform: $Platform"
Write-Host ""

foreach ($img in $images) {
  $name = $img.Name
  $tag = "online-boutique/$name:$Tag"
  $contextPath = Join-Path $RepoRoot $img.Context
  $dockerfilePath = Join-Path $RepoRoot $img.Dockerfile

  if (-not (Test-Path $contextPath)) { throw "Missing build context: $contextPath" }
  if (-not (Test-Path $dockerfilePath)) { throw "Missing Dockerfile: $dockerfilePath" }

  Write-Host "==> Building $tag"
  docker build --platform $Platform -t $tag -f $dockerfilePath $contextPath
  if ($LASTEXITCODE -ne 0) { throw "docker build failed for $tag" }
  Write-Host ""
}

Write-Host "Done."
Write-Host "Verify with: docker images online-boutique/*"
