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

npm --prefix (Join-Path $Root 'frontend') run build
npm --prefix (Join-Path $Root 'backend') run build
npm --prefix (Join-Path $Root 'app-launcher') run build
