param(
  [string]$WindowsLuaDll,
  [string]$AndroidArm64So,
  [string]$AndroidArmv7So,
  [string]$AndroidX64So
)

$ErrorActionPreference = 'Stop'

function Copy-IfProvided($source, $destination) {
  if ([string]::IsNullOrWhiteSpace($source)) {
    return
  }

  if (-not (Test-Path $source)) {
    throw "Missing file: $source"
  }

  Copy-Item $source $destination -Force
  Write-Host "Copied $source -> $destination"
}

Copy-IfProvided $WindowsLuaDll "$PSScriptRoot\..\apps\ucpae_windows\windows\runner\third_party\lua\lua54.dll"
Copy-IfProvided $AndroidArm64So "$PSScriptRoot\..\apps\ucpae_android\android\app\src\main\jniLibs\arm64-v8a\liblua.so"
Copy-IfProvided $AndroidArmv7So "$PSScriptRoot\..\apps\ucpae_android\android\app\src\main\jniLibs\armeabi-v7a\liblua.so"
Copy-IfProvided $AndroidX64So "$PSScriptRoot\..\apps\ucpae_android\android\app\src\main\jniLibs\x86_64\liblua.so"

Write-Host 'Native Lua libraries prepared.'
