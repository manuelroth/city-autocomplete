/* Adjust database configuration to workload (based on pgtune - http://pgtune.leopard.in.ua/) */
ALTER SYSTEM SET min_wal_size = '4GB';
ALTER SYSTEM SET max_wal_size = '8GB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
SELECT pg_reload_conf();

DROP TABLE IF EXISTS geonames;
CREATE TABLE IF NOT EXISTS geonames (
	geonameid	int,
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
	iso_alpha2 char(2),
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

DROP TABLE IF EXISTS postalcodes;
CREATE TABLE IF NOT EXISTS postalcodes (
	countryCode char(2),
	postalcode varchar(20),
	placename varchar(180),
	adminname1 varchar(100),
	admincode1 varchar(20),
	adminname2 varchar(100),
	admincode2 varchar(20),
	adminname3 varchar(100),
	admincode3 varchar(20),
	lat float,
	lng float,
	accuracy smallint
);

\copy geonames (geonameid,name,asciiname,alternatenames,lat,lng,fclass,fcode,country,cc2,admin1,admin2,admin3,admin4,population,elevation,gtopo30,timezone,moddate) from './import/geonames.txt' null as '';
\copy countryinfo (iso_alpha2,iso_alpha3,iso_numeric,fips_code,name,capital,areainsqkm,population,continent,tld,currencycode,currencyname,phone,postalcode,postalcoderegex,languages,geonameid,neighbors,equivfipscode) from './import/countryInfo.txt' null as '';
\copy postalcodes (countryCode,postalcode,placename,adminname1,admincode1,adminname2,admincode2,adminname3,admincode3,lat,lng,accuracy) from './import/postalCodes.txt' null as '';

DELETE FROM geonames WHERE fclass NOT LIKE 'P' OR population < 2000;
DELETE FROM postalcodes WHERE placename IS NULL;

ALTER TABLE ONLY geonames ADD CONSTRAINT pk_geonameid PRIMARY KEY (geonameid);
ALTER TABLE ONLY countryinfo ADD CONSTRAINT pk_iso_alpha2 PRIMARY KEY (iso_alpha2);
ALTER TABLE ONLY postalcodes ADD CONSTRAINT pk_lat_lng PRIMARY KEY (postalcode, placename, lat, lng);

CREATE OR REPLACE FUNCTION get_isocode_by_countryname (isocode text ) RETURNS text AS $$
    SELECT name FROM countryinfo WHERE iso_alpha2 LIKE isocode;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION get_postalcodes (admin1 varchar(20), admin2 varchar(20), admin3 varchar(20), name varchar(200) ) RETURNS text AS $$
    SELECT string_agg(postalcode, ', ')
	FROM postalcodes
	WHERE (
		admincode1 LIKE admin1
		AND admincode2 LIKE admin2
		AND admincode3 LIKE admin3
		AND placename LIKE name
	) OR (
		admincode1 LIKE admin1
		AND admincode2 LIKE admin2
		AND placename LIKE name
	) OR (
		admincode1 LIKE admin1
		AND placename LIKE name
	) OR (
		placename LIKE name
	)
	GROUP BY placename;
$$ LANGUAGE SQL IMMUTABLE;

DROP INDEX IF EXISTS isocode_to_countryname_index;
CREATE INDEX isocode_to_countryname_index ON geonames(get_isocode_by_countryname(country));
