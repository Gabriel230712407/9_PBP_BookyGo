param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$localPubCache = Join-Path $projectRoot ".bookygo_pub_cache"

if (!(Test-Path $localPubCache)) {
    New-Item -ItemType Directory -Path $localPubCache | Out-Null
}

$env:PUB_CACHE = $localPubCache

Write-Host "Using PUB_CACHE: $env:PUB_CACHE"

& flutter pub get
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if ($FlutterArgs.Count -eq 0) {
    Write-Host "No Flutter command provided. Example: .\\flutter_local.ps1 run"
    exit 0
}

& flutter @FlutterArgs
exit $LASTEXITCODE
