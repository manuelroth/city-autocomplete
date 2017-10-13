/* Export data without postalcodes */
\COPY ( SELECT name, alternatenames AS alternative_names, get_isocode_by_countryname(country) AS country, population, lat, lng FROM geonames ) TO ./export/city_index.csv WITH (FORMAT csv, HEADER true);

/* Export data with postalcodes
\COPY (
SELECT name, alternatenames AS alternative_names,
get_isocode_by_countryname(country) AS country,
get_postalcodes(admin1, admin2, admin3, name) AS postalcodes,
population, lat, lng
FROM geonames
) TO ./export/city_index.csv
WITH (FORMAT csv, HEADER true);
*/
