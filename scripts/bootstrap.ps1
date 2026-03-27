param(
  [switch]$Android,
  [switch]$Windows
)

$ErrorActionPreference = 'Stop'

function Ensure-Tool($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required tool '$name' was not found in PATH."
  }
}

Ensure-Tool flutter

if (-not $Android -and -not $Windows) {
  $Android = $true
  $Windows = $true
}

if ($Android) {
  Push-Location "$PSScriptRoot\..\apps\ucpae_android"
  flutter pub get
  Pop-Location
}

if ($Windows) {
  Push-Location "$PSScriptRoot\..\apps\ucpae_windows"
  flutter pub get
  Pop-Location
}

Write-Host 'Workspace bootstrap completed.'
