$ErrorActionPreference = 'Stop'

Push-Location "$PSScriptRoot\..\apps\ucpae_android"
flutter pub get
flutter run
Pop-Location
