#!/usr/bin/env pwsh

param (
    [Parameter()]
    [string]
    $RdfPath = "../Dump/wbdump.ttl"
)

function checkLastExitCode() {
    if ($LASTEXITCODE) {
        Write-Error "Command exit code indicates failure: $LASTEXITCODE"
        Exit $LASTEXITCODE
    }
}

$ErrorActionPreference = "Stop"

$RdfPath = (Resolve-Path $RdfPath).Path
$DataPath = (New-Item "./assets/data" -ItemType Directory -Force).FullName
$AssetsBuilderProjectDir = (Resolve-Path "./DataBuilder/AssetsBuilder/AssetsBuilder.csproj").Path

# Assumes $PWD is repo root
dotnet run -c Release -p $AssetsBuilderProjectDir -- $RdfPath $DataPath
checkLastExitCode

yarn build-prod
checkLastExitCode

yarn build-embed-prod
checkLastExitCode
New-Item -ItemType Directory ./dist/embed -Force
Copy-Item ./embed/dist/* ./dist/embed/ -Recurse
