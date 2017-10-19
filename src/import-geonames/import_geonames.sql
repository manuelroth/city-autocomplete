/* Adjust database configuration to workload (based on pgtune - http://pgtune.leopard.in.ua/) */
ALTER SYSTEM SET min_wal_size = '4GB';
ALTER SYSTEM SET max_wal_size = '8GB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
SELECT pg_reload_conf();

/* Create tables with all properties */
DROP TABLE IF EXISTS geonames CASCADE;
CREATE TABLE IF NOT EXISTS geonames (
	geonameid	int PRIMARY KEY,
	name varchar(200),
	asciiname varchar(200),
	alternatenames text,
	lat float,
	lng float,
	fclass char(1),
	fcode varchar(10),
	country varchar(2),
	cc2 varchar(200),
	admin1 varchar(20),
	admin2 varchar(80),
	admin3 varchar(20),
	admin4 varchar(20),
	population bigint,
	elevation int,
	gtopo30 int,
	timezone varchar(40),
	moddate date
);

DROP TABLE IF EXISTS countryinfo;
CREATE TABLE IF NOT EXISTS countryinfo (
	iso_alpha2 char(2) PRIMARY KEY,
	iso_alpha3 char(3),
	iso_numeric integer,
	fips_code varchar(3),
	name varchar(200),
	capital varchar(200),
	areainsqkm double precision,
	population integer,
	continent varchar(2),
	tld varchar(10),
	currencycode varchar(3),
	currencyname varchar(20),
	phone varchar(20),
	postalcode varchar(100),
	postalcoderegex varchar(200),
	languages varchar(200),
	geonameId int,
	neighbors varchar(50),
	equivfipscode varchar(3)
);

DROP TABLE IF EXISTS postalcodes CASCADE;
CREATE TABLE IF NOT EXISTS postalcodes (
	countryCode char(2),
	postalcode varchar(20),
	placename varchar(180),
	adminname1 varchar(100),
	admincode1 varchar(20),
	adminname2 varchar(100),
	admincode2 varchar(80),
	adminname3 varchar(100),
	admincode3 varchar(20),
	lat float,
	lng float,
	accuracy smallint
);

/* Import all data into the different tables */
\COPY geonames (geonameid,name,asciiname,alternatenames,lat,lng,fclass,fcode,country,cc2,admin1,admin2,admin3,admin4,population,elevation,gtopo30,timezone,moddate) FROM './import/geonames.txt' NULL AS '';
\COPY countryinfo (iso_alpha2,iso_alpha3,iso_numeric,fips_code,name,capital,areainsqkm,population,continent,tld,currencycode,currencyname,phone,postalcode,postalcoderegex,languages,geonameid,neighbors,equivfipscode) FROM './import/countryInfo.txt' NULL AS '';
\COPY postalcodes (countryCode,postalcode,placename,adminname1,admincode1,adminname2,admincode2,adminname3,admincode3,lat,lng,accuracy) FROM './import/postalCodes.txt' NULL AS '';

/* Drop all geoname rows which are not tagged as a populated places or have a population lower than 2000 citizens */
DELETE FROM geonames WHERE fclass NOT LIKE 'P' OR population < 2000;

/* Create indices on important fields */
DROP INDEX IF EXISTS postalcodes_index;
CREATE INDEX postalcodes_index ON postalcodes(placename, countryCode, admincode1);
DROP INDEX IF EXISTS geonames_index;
CREATE INDEX geonames_index ON geonames(name, country, admin1);
ANALYZE;

/* Create amaterialized view with all postalcodes which have a corresponding row in the geonames table */
DROP MATERIALIZED VIEW existing_postalcodes;
CREATE MATERIALIZED VIEW existing_postalcodes AS
SELECT g.geonameid, p.postalcode FROM postalcodes p, geonames g
WHERE p.placename = g.name
AND p.countryCode = g.country
AND p.admincode1 = g.admin1;

/* Create a materialized view which aggregates all postalcodes with the same geonameid */
DROP MATERIALIZED VIEW agg_postalcodes;
CREATE MATERIALIZED VIEW agg_postalcodes AS
SELECT geonameid, string_agg(postalcode, ', ') AS postalcodes
FROM existing_postalcodes
GROUP BY geonameid;
