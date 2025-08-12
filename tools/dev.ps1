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

# Build backend and start it
npm --prefix (Join-Path $Root 'backend') run build | Out-Null
Start-Process npm -ArgumentList @('--prefix', (Join-Path $Root 'backend'), 'run', 'start')

# Start frontend dev server
Start-Process npm -ArgumentList @('--prefix', (Join-Path $Root 'frontend'), 'run', 'start')

Start-Sleep -Seconds 5

# Launch Tauri dev
npm --prefix (Join-Path $Root 'app-launcher') run dev
