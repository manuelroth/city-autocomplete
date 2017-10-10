\copy (SELECT name, alternatenames AS alternative_names, get_isocode_by_countryname(country) AS country, population, lat, lng FROM cities ) TO ./export/city_index.csv WITH (FORMAT csv, HEADER true)
