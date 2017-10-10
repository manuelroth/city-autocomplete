#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly GEONAMES_DB=${GEONAMES_DB:-geonames}
readonly GEONAMES_USER=${GEONAMES_USER:-geonames}
readonly GEONAMES_PASSWORD=${GEONAMES_PASSWORD:-geonames}


function export_city_index() {
  PGPASSWORD="$GEONAMES_PASSWORD" psql \
  --host="postgres" \
  --port="5432" \
  --dbname="$GEONAMES_DB" \
  --username="$GEONAMES_USER" \
  -a -f "/usr/src/app/export_city_index.sql"
}

function main() {
  export_city_index
}

main
