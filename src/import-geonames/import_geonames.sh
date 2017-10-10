#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly GEONAMES_DB=${GEONAMES_DB:-geonames}
readonly GEONAMES_USER=${GEONAMES_USER:-geonames}
readonly GEONAMES_PASSWORD=${GEONAMES_PASSWORD:-geonames}

function import_geonames() {
  PGPASSWORD="$GEONAMES_PASSWORD" psql \
  --host="postgres" \
  --port="5432" \
  --dbname="$GEONAMES_DB" \
  --username="$GEONAMES_USER" \
  -a -f "/usr/src/app/import_geonames.sql"
}

function main() {
  import_geonames
}

main
