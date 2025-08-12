$Root = Split-Path $MyInvocation.MyCommand.Path -Parent | Split-Path -Parent
$EnvFile = Join-Path $Root '.env.desktop'
if (Test-Path $EnvFile) {
  Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^(\w+)=(.*)$') {
      $name = $matches[1]
      $value = $matches[2]
      if ($value) { Set-Item -Path Env:$name -Value $value }
    }
  }
}

$Binary = Join-Path $Root 'app-launcher/src-tauri/target/release/app-launcher.exe'
if (Test-Path $Binary) {
  & $Binary @args
} else {
  Write-Error 'Built launcher not found. Run make build first.'
}
