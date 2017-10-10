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

function main() {
  export_city_index
}

main
