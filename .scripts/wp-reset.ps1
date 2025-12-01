# Destroys and recreates the WP env with a fresh DB.
$ErrorActionPreference = 'Stop'
$compose = "docker-compose.wordpress.yml"
if (!(Test-Path $compose)) { Write-Error "Cannot find $compose" }

docker compose -f $compose down -v
./.scripts/wp-up.ps1
