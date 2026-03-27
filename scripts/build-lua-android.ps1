param(
  [string]$Version = '5.4.8',
  [string]$Sha256 = '4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae',
  [string]$ApiLevel = '21'
)

$ErrorActionPreference = 'Stop'

$root = Resolve-Path "$PSScriptRoot\.."
$luaRoot = Join-Path $root 'third_party\lua'
$archive = Join-Path $luaRoot "lua-$Version.tar.gz"
$srcDir = Join-Path $luaRoot "lua-$Version"
$ndkRoot = Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\ndk" | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
$toolchain = Join-Path $ndkRoot 'toolchains\llvm\prebuilt\windows-x86_64\bin'

New-Item -ItemType Directory -Force $luaRoot | Out-Null

if (-not (Test-Path $archive)) {
  Invoke-WebRequest -Uri "https://www.lua.org/ftp/lua-$Version.tar.gz" -OutFile $archive
}

$hash = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hash -ne $Sha256.ToLowerInvariant()) {
  throw "Lua source checksum mismatch. Expected $Sha256 but got $hash"
}

if (-not (Test-Path $srcDir)) {
  tar -xf $archive -C $luaRoot
}

$sources = Get-ChildItem (Join-Path $srcDir 'src\*.c') | Where-Object {
  $_.Name -notin @('lua.c', 'luac.c')
} | Select-Object -ExpandProperty FullName

$abis = @(
  @{ Name = 'arm64-v8a'; Target = "aarch64-linux-android$ApiLevel-clang" },
  @{ Name = 'armeabi-v7a'; Target = "armv7a-linux-androideabi$ApiLevel-clang" },
  @{ Name = 'x86_64'; Target = "x86_64-linux-android$ApiLevel-clang" }
)

foreach ($abi in $abis) {
  $outDir = Join-Path $root "apps\ucpae_android\android\app\src\main\jniLibs\$($abi.Name)"
  New-Item -ItemType Directory -Force $outDir | Out-Null
  $compiler = Join-Path $toolchain $abi.Target
  if (-not (Test-Path $compiler)) {
    throw "Missing NDK compiler: $compiler"
  }

  $arguments = @(
    '-shared',
    '-fPIC',
    '-O2',
    '-DLUA_USE_POSIX',
    '-I', (Join-Path $srcDir 'src'),
    '-o', (Join-Path $outDir 'liblua.so')
  ) + $sources + @('-lm')

  & $compiler @arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Lua Android build failed for ABI $($abi.Name)"
  }
}

Write-Host 'Built Android Lua libraries successfully.'
