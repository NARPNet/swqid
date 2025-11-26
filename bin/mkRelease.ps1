#!/usr/bin/env pwsh
# PowerShell port of mkRelease.sh (updated behavior)

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Read version from ../version.txt
try {
    $versionFile = Join-Path $scriptDir "../version.txt"
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
    $srcPath = (Resolve-Path "../src").Path
    Set-Location $srcPath

    # Set executable bits when chmod is available
    if (Get-Command chmod -ErrorAction SilentlyContinue) {
        Get-ChildItem -Path . -Recurse -Filter '*.sh' -File -ErrorAction SilentlyContinue | ForEach-Object { & chmod 770 $_.FullName }
        Get-ChildItem -Path . -Recurse -Filter '*.ps1' -File -ErrorAction SilentlyContinue | ForEach-Object { & chmod 770 $_.FullName }
    }

    $releaseDir = (Resolve-Path "../release").Path
    if (Test-Path $releaseDir) { Remove-Item -Recurse -Force $releaseDir -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Path $releaseDir | Out-Null

    # Ensure swqid directory exists in src
    if (-not (Test-Path -Path "swqid" -PathType Container)) {
        New-Item -ItemType Directory -Path "swqid" | Out-Null
    }

    # Copy README into swqid/
    $rootReadme = Join-Path $scriptDir "../README.md"
    if (Test-Path $rootReadme) {
        Copy-Item -Path $rootReadme -Destination "swqid/README.md" -Force
    }

    $archiveName = "swqid-$VERSION.zip"
    $archivePath = Join-Path $releaseDir $archiveName

    # Prefer external zip if available (to match original behavior), else use Compress-Archive
    if (Get-Command zip -ErrorAction SilentlyContinue) {
        & zip -9 -r $archivePath "swqid"
    } else {
        # Use Compress-Archive; include the directory itself so archive root contains 'swqid/'
        $swqidFull = (Resolve-Path "swqid").Path
        Compress-Archive -Path (Join-Path $swqidFull "*") -DestinationPath $archivePath -Force
    }

    # Remove copied README from swqid/
    $copiedReadme = Join-Path (Get-Location) "swqid/README.md"
    if (Test-Path $copiedReadme) { Remove-Item -Force $copiedReadme -ErrorAction SilentlyContinue }

}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Done."
Write-Host ""
Read-Host "Press enter to continue" | Out-Null

exit 0
