param(
    [string]$Config = "Release"
)

$ErrorActionPreference = "Stop"

# Корень репозитория (там лежит этот скрипт).
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host "==> Build Rust core (cargo build --release)" -ForegroundColor Cyan
cargo build --release

# Путь до Qt. Если установишь Qt в другое место — поправь эту строку.
$QtPath = "C:/Qt/6.10.1/msvc2022_64"

Write-Host "==> Configure CMake (if no cpp_client/build/CMakeCache.txt)" -ForegroundColor Cyan
if (-not (Test-Path "cpp_client/build/CMakeCache.txt")) {
    cmake -S cpp_client -B cpp_client/build -DCMAKE_PREFIX_PATH="$QtPath"
}

Write-Host ("==> Build Qt client (config: {0})" -f $Config) -ForegroundColor Cyan
cmake --build cpp_client/build --config $Config

Write-Host "==> Running windeployqt..." -ForegroundColor Cyan
$ExePath = "cpp_client/build/$Config/hw_desktop_client.exe"
$WinDeployQt = "$QtPath/bin/windeployqt.exe"
if (Test-Path $WinDeployQt) {
    & $WinDeployQt --no-translations --no-opengl-sw --no-system-d3d-compiler "$ExePath"
} else {
    Write-Warning "windeployqt.exe not found at $WinDeployQt. Skip deployment."
}

# Копируем нашу Rust DLL вручную на всякий случай, если CMake не справился
$RustDll = "target/release/hw_core.dll"
if (Test-Path $RustDll) {
    Copy-Item $RustDll "cpp_client/build/$Config/" -Force
}

Write-Host ("==> Done. exe: {0}" -f $ExePath) -ForegroundColor Green
