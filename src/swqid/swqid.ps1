#!/usr/bin/env pwsh
# PowerShell port of FLAMP Relay File Queue ID Switcher
$version = "0.9.0-beta"
$author = "lobanz@protonmail.com"

function Show-Help {
    Write-Output ""
    Write-Output "FLAMP Relay File Queue ID Switcher"
    Write-Output "Version: $version"
    Write-Output "Author: $author"
    Write-Output ""
    Write-Output "Simple program to change a FLAMP relay file from one queue id to another."
    Write-Output ""
    $name = Split-Path -Leaf $MyInvocation.MyCommand.Name
    Write-Output "Usage: $name <new_queue> <relay_file>"
    Write-Output ""
    Write-Output "Where <new_queue> is the new queue ID you want to use, and"
    Write-Output "<relay_file> is the relay file you want to switch the queue in."
    Write-Output "The new relay file is printed to the standard output."
    Write-Output ""
    Write-Output "Example: pwsh $name 1234 my_file.txt > new_file.txt"
    Write-Output ""
}

if ($args.Count -ne 2) {
    Show-Help
    exit 1
}

$QUEUE_NEW = $args[0]
$RELAY_FILE = $args[1]

# Make sure relay file is readable
if (-not (Test-Path -Path $RELAY_FILE -PathType Leaf)) {
    Write-Error "Could not read file '$RELAY_FILE'"
    exit 2
}

try {
    $content = Get-Content -Raw -ErrorAction Stop $RELAY_FILE
} catch {
    Write-Error "Could not read file '$RELAY_FILE'"
    exit 2
}

# Determine existing queue id of relay file
# Looks for ">{XXXX:" where XXXX is the queue id and uses the first match
$match = [regex]::Match($content, '>{(\w+):')

if (-not $match.Success) {
    Write-Error "Could not determine queue id for file '$RELAY_FILE'"
    exit 3
} else {
    # Replace the existing queue id with the new one (global replacement like the original sed)
    $pattern = '>{(\w+)'
    $replacement = ">{$QUEUE_NEW"
    $newContent = [regex]::Replace($content, $pattern, $replacement)
    Write-Output $newContent
    exit 0
}
