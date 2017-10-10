#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}


function export_city_index() {
  PGPASSWORD="osm" psql \
  --host="postgres" \
  --port="5432" \
  --dbname="$OSM_DB" \
  --username="$OSM_USER" \
  -a -f "/usr/src/app/export_city_index.sql"
}

function cleanup_index_file() {
  sed -i '.original' 's/#//g' city_index.csv
}

function main() {
  export_city_index
  cleanup_index_file
}

main
