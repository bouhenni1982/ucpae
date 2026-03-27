$ErrorActionPreference = 'Stop'

Push-Location "$PSScriptRoot\..\apps\ucpae_android"
flutter pub get
flutter build apk --debug
Pop-Location
