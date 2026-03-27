$ErrorActionPreference = 'Stop'

Push-Location "$PSScriptRoot\..\apps\ucpae_windows"
flutter pub get
flutter run -d windows
Pop-Location
