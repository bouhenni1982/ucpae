param(
  [switch]$RunFlutter
)

$ErrorActionPreference = 'Stop'

Push-Location "$PSScriptRoot\..\apps\ucpae_windows\windows\worker\Ucpae.AccessibilityWorker"
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
  throw 'dotnet SDK is required to build the Windows worker.'
}

dotnet build
Pop-Location

if ($RunFlutter) {
  Push-Location "$PSScriptRoot\..\apps\ucpae_windows"
  flutter run -d windows
  Pop-Location
}
