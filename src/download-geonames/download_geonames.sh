#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

function prepare_geonames() {
    wget -O geonames.zip http://download.geonames.org/export/dump/allCountries.zip &&
    unzip geonames.zip &&
    mv allCountries.txt ./import/geonames.txt &&
    rm geonames.zip
}

function prepare_postalcodes() {
    wget -O postalCodes.zip http://download.geonames.org/export/zip/allCountries.zip &&
    unzip postalCodes.zip &&
    sed 's/\\//g' < allCountries.txt > ./import/postalCodes.txt &&
    rm postalCodes.zip
}

function prepare_countryInfo {
    wget -O countryInfo.txt http://download.geonames.org/export/dump/countryInfo.txt &&
    sed -i -e 1,51d countryInfo.txt &&
    mv countryInfo.txt ./import/countryInfo.txt
}

function main() {
  prepare_geonames
  prepare_postalcodes
  prepare_countryInfo
}

main
