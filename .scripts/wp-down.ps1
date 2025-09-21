# Stops the local WordPress environment for tests.
$ErrorActionPreference = 'Stop'
$compose = "docker-compose.wordpress.yml"
if (!(Test-Path $compose)) { Write-Error "Cannot find $compose" }

docker compose -f $compose down
