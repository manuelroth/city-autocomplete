 drop table if exists cities cascade;
 create table if not exists cities (
	geonameid	int,
	name varchar(200),
	asciiname varchar(200),
	alternatenames text,
	latitude float,
	longitude float,
	fclass char(1),
	fcode varchar(10),
	country varchar(2),
	cc2 varchar(80),
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

 drop table if exists alternatename cascade;
 create table if not exists alternatename (
	alternatenameId int,
	geonameid int,
	isoLanguage varchar(7),
	alternateName varchar(200),
	isPreferredName boolean,
	isShortName boolean,
	isColloquial boolean,
	isHistoric boolean
 );

drop table if exists countryinfo cascade;
create table if not exists countryinfo (
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

drop table if exists postalcode cascade;
create table if not exists postalcode (
	countryCode char(2),
	postalcode varchar(20),
	placename varchar(180),
	adminname1 varchar(100),
	admincode1 varchar(20),
	adminname2 varchar(100),
	admincode2 varchar(20),
	adminname3 varchar(100),
	admincode3 varchar(20),
	latitude float,
	longitude float,
	accuracy integer
);

ALTER TABLE ONLY cities ADD CONSTRAINT pk_geonameid PRIMARY KEY (geonameid);
ALTER TABLE ONLY alternatename ADD CONSTRAINT pk_alternatenameid PRIMARY KEY (alternatenameid);
ALTER TABLE ONLY alternatename ADD CONSTRAINT fk_geonameid FOREIGN KEY (geonameid) REFERENCES cities(geonameid);
ALTER TABLE ONLY countryinfo ADD CONSTRAINT pk_iso_alpha2 PRIMARY KEY (iso_alpha2);
ALTER TABLE ONLY countryinfo ADD CONSTRAINT fk_geonameid FOREIGN KEY (geonameid) REFERENCES cities(geonameid);

\copy cities (geonameid,name,asciiname,alternatenames,latitude,longitude,fclass,fcode,country,cc2,admin1,admin2,admin3,admin4,population,elevation,gtopo30,timezone,moddate) from './import/cities.txt' null as '';
\copy alternatename  (alternatenameid,geonameid,isolanguage,alternatename,ispreferredname,isshortname,iscolloquial,ishistoric) from './import/alternateNames.txt' null as '';
\copy countryinfo (iso_alpha2,iso_alpha3,iso_numeric,fips_code,name,capital,areainsqkm,population,continent,tld,currencycode,currencyname,phone,postalcode,postalcoderegex,languages,geonameid,neighbors,equivfipscode) from './import/countryInfo.txt' null as '';
\copy postalcode (countryCode,postalcode,placename,adminname1,admincode1,adminname2,admincode2,adminname3,admincode3,latitude,longitude,accuracy) from './import/postalCodes.txt' null as '';
