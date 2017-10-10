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

function cleanup_index_file() {
  sed -i '.original' 's/#//g' /usr/src/app/export/city_index.csv
}

function main() {
  export_city_index
  cleanup_index_file
}

main
