/* Export data */
\COPY ( SELECT g.name, g.alternatenames, c.name AS country, p.postalcodes, g.population, g.lat, g.lng FROM geonames g LEFT JOIN countryinfo c ON g.country = c.iso_alpha2 LEFT JOIN agg_postalcodes p ON g.geonameid = p.geonameid ) TO ./export/city_index.csv WITH (FORMAT csv, HEADER true);
