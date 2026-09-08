#!/usr/bin/env sh
set -eu

base_url="${BASE_URL:-http://localhost:8000}"

curl --fail --silent "${base_url}/api/suppliers" >/dev/null
curl --fail --silent "${base_url}/api/suppliers/1" >/dev/null
curl --fail --silent --request POST "${base_url}/api/suppliers" \
  --header 'Content-Type: application/json' \
  --data '{"name":"Smoke Supplier","email":"smoke-'"$(date +%s)"'@example.com"}' >/dev/null

echo "API smoke tests passed. Inspect 'make collector-logs' for normalized records."

