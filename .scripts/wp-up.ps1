# Starts the local WordPress + MariaDB environment for tests.
# Requirements: Docker Desktop installed and running.
# Ports: 8080 (http), 8443 (https).
# Optional env vars: WP_USERNAME, WP_PASSWORD, WP_EMAIL, WP_BLOG_NAME, WP_PLUGINS

param(
  [switch]$Recreate
)

$ErrorActionPreference = 'Stop'

$compose = "docker-compose.wordpress.yml"
if (!(Test-Path $compose)) {
  Write-Error "Cannot find $compose in repo root."
}

if ($Recreate) {
  docker compose -f $compose down -v
}

docker compose -f $compose up -d

Write-Host "Waiting for WordPress health..."
# Simple wait loop for /wp-json to be ready
$max = 60
for ($i = 0; $i -lt $max; $i++) {
  try {
    $resp = Invoke-WebRequest -UseBasicParsing http://localhost:8080/wp-json -TimeoutSec 5
    if ($resp.StatusCode -eq 200) { break }
  } catch {}
  Start-Sleep -Seconds 3
}

Write-Host "WP ready at http://localhost:8080/wp-json"
