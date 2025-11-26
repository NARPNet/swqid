#!/usr/bin/env pwsh
# PowerShell port of bin/mkRelease.sh

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

try {
    $versionFile = Join-Path $scriptDir "..\version.txt"
    $VERSION = (Get-Content -Path $versionFile -ErrorAction Stop | Select-Object -First 1).Trim()
} catch {
    Write-Error "Could not read version from '$versionFile'"
    exit 2
}

Write-Host "DID YOU UPDATE THE VERSION?"
Read-Host "Press enter to continue" | Out-Null
Write-Host ""
Write-Host "Making release zip ..."
Write-Host ""

Push-Location $scriptDir
try {
    Set-Location (Join-Path $scriptDir "..\src")

    # Set executable bits when chmod is available
    if (Get-Command chmod -ErrorAction SilentlyContinue) {
        Get-ChildItem -Path . -Recurse -Filter '*.sh' -File -ErrorAction SilentlyContinue | ForEach-Object { & chmod 770 $_.FullName }
        Get-ChildItem -Path . -Recurse -Filter '*.ps1' -File -ErrorAction SilentlyContinue | ForEach-Object { & chmod 770 $_.FullName }
    }

    $releaseDir = Join-Path $scriptDir "..\release"
    if (Test-Path $releaseDir) { Remove-Item -Recurse -Force $releaseDir -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Path $releaseDir | Out-Null

    # Copy README into swqid/
    $rootReadme = Join-Path $scriptDir "..\README.md"
    if (Test-Path $rootReadme) {
        Copy-Item -Path $rootReadme -Destination "swqid/README.md" -Force
    }

    $archivePath = Join-Path $releaseDir "swqid-$VERSION.zip"

    # Prefer external zip if available (to match original behavior), else use Compress-Archive
    if (Get-Command zip -ErrorAction SilentlyContinue) {
        & zip -9 -r $archivePath "swqid"
    } else {
        $swqidFull = (Resolve-Path "swqid").Path
        Compress-Archive -Path (Join-Path $swqidFull "*") -DestinationPath $archivePath -Force
    }

    # Remove copied README from swqid/
    if (Test-Path "swqid/README.md") { Remove-Item -Force "swqid/README.md" -ErrorAction SilentlyContinue }

}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Done."
Write-Host ""
Read-Host "Press enter to continue" | Out-Null

exit 0
