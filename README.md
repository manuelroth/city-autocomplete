## City Autocomplete
A city autocomplete menu using the [GeoNames](http://www.geonames.org/) datasets and the [Algolia](https://www.algolia.com/) search engine

### Implementation

This repository contains a process to generate a city index based on the [GeoNames](http://www.geonames.org/) dataset. When uploaded to the [Algolia](https://www.algolia.com/) platform, this index can be used to create a city autocomplete menu. The demo of the autocomplete menu using the generated index can be found [here](https://manuelroth.github.io/city-autocomplete/).

### Output Format

The exported file `./data/export/city_index.csv` contains the following columns:

| Column name    | Description                           | GeoNames Table |
|----------------|---------------------------------------|----------------|
| name           | The city name (utf8)                  | geoname        |
| alternatenames | The alternate names (comma separated) | geoname        |
| country        | The country name                      | countryInfo    |
| postalcodes    | The postalcode(s) (comma separated)   | postalcodes    |
| population     | The city population                   | geoname        |
| lat            | latitude in decimal degrees (wgs84)   | geoname        |
| lng            | longitude in decimal degrees (wgs84)  | geoname        |

### Usage
The data processing pipline is built with [Docker](https://www.docker.com/). Specifically, it is built with [Docker Compose](https://docs.docker.com/compose/) thus allowing to define a multi-container architecture defined in [a single file](https://github.com/manuelroth/city-autocomplete/blob/master/docker-compose.yml). To run through the city index generation process both need to be installed:

- Install [Docker](https://docs.docker.com/engine/installation/)
- Install [Docker Compose](https://docs.docker.com/compose/install/)

In order to generate the city index the following steps need to be followed:

1. Clone the repository and change directory to it:

```bash
git clone https://github.com/manuelroth/city-autocomplete.git
cd city-autocomplete
```

2. Run the `download-geonames` command:

```bash
docker-compose run --rm download-geonames
```

This downloads the necessary GeoNames datasets, extracts and places it into the `./data/import` folder -> [Source Code](https://github.com/manuelroth/city-autocomplete/blob/master/src/download-geonames/download_geonames.sh)

3. Now start up the database container (as a daemon process):

```bash
docker-compose up -d postgres
```

4. Import the GeoNames datasets into the PostgreSQL database:

```bash
docker-compose run --rm import-geonames
```

This takes the datasets previously placed into the `./data/import` folder and imports them into the database -> [Source Code](https://github.com/manuelroth/city-autocomplete/blob/master/src/import-geonames/import_geonames.sql)

5. Generate and export the city index:

```bash
docker-compose run --rm export-city-index
```

This generates the city index and saves it as CSV-file in the `./data/export` folder -> [Source Code](https://github.com/manuelroth/city-autocomplete/blob/master/src/export-city-index/export_city_index.sql)

(optional) 6. Upload the city-index to the Algolia platform:

```bash
docker-compose run --rm upload-city-index
```

Befor uploading the city-index the environment variables `APP_ID`, `API_KEY` and `INDEX_NAME` in the [docker-compose.yml](https://github.com/manuelroth/city-autocomplete/blob/master/docker-compose.yml#L30) file need to be updated -> [Source Code](https://github.com/manuelroth/city-autocomplete/blob/master/src/upload-city-index/Dockerfile)

```bash
environment:
    APP_ID: <replace with your Algolia app_id>
    API_KEY: <replace with your Algolia app_key>
    INDEX_NAME: <replace with your Algolia index_name>
```
### Used GeoNames datasets and relations between tabels

The city index contains data of different GeoNames datasets ([Place data of all countries](http://download.geonames.org/export/dump/allCountries.zip), [Postalcodes of all countries](http://download.geonames.org/export/zip/allCountries.zip) and the [Country Info](http://download.geonames.org/export/dump/countryInfo.txt)). In order to combine the different datasets, a relation between them needs to be established. Datasets usually use id's for that purpose, but many times there are no id's which help to link the datasets. Therefore other methodes need to be applied.

For both the countryInfo and the postalcodes dataset I decided to link the dataset using one or multiple columns which have the same values. This works very well if the datasets are complete and there is enough information to be able to create a correct match between the tables.

This approach worked very well to create a relation between the geonames and the countryInfo tables. The country code column of both tables is complete. So the strings can be matched and a relation is established.

However the same approach did not work as seamless with the geonames and postalcodes tables. Both tables have columns for the city name, country code, 1. administrative division (state), 2. adm. division (county/province), 3. adm. division (community), latitude and longitude fields. As with every dataset, the geonames dataset is not perfect. There are many rows which do not have data for all the columns. Therefore it was not possible to use all the columns to create a relation between the two tables.

With manual testing I found out that in most cases it is suitable to create a relation using the country code, 1. administrative division (state) and the city name between the tables. These are the minimal required fields. Otherwise postalcodes get related to the wrong citys. The current solution is not perfect yet and should be further improved in the future.
