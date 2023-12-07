CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

--Zad.4.
CREATE TABLE mergedExports AS
SELECT ST_Union(rast) rast FROM public."Exports";

--SELECT * FROM  public."Exports"