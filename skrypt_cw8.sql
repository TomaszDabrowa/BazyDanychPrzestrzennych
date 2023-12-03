CREATE SCHEMA lab8;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
select * from 
CREATE TABLE public.uk_250k(
id serial,
rast raster
);

--Zad.5
SELECT * FROM national_parks;

--Zad.6.
--SELECT ST_SRID(geom) FROM public.national_parks;

CREATE TABLE public.uk_lake_district AS
SELECT ST_Clip(a.rast, b.geom, true)
FROM  lab8.uk_250 AS a, public.national_parks AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.gid  = 1;

--DROP TABLE public.uk_lake_district
select * from public.national_parks

--Zad.7.
SELECT ST_AsTIFF(ST_Union(st_clip), 'GTiff') 
FROM public.uk_lake_district;

select * from public.uk_lake_district;
--SELECT *
--FROM pg_settings
--WHERE name = 'port';

--Zad.10.
--połączenie pasm

--przycięcie pasma 4
CREATE TABLE public.band4 AS
SELECT ST_Clip(a.rast, b.geom, true) AS rast
FROM public.sentinel2_band4_1 AS a, public.national_parks AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.gid = 1;

--przycięcie pasma 8
CREATE TABLE public.band8 AS
SELECT ST_Clip(a.rast, b.geom, true) AS rast
FROM public.sentinel2_band8_1 AS a, public.national_parks AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.gid = 1;

SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] +
[rast1.val])::float','32BF'
) AS rast

create table redd as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM public.sentinel2_band4_1
                        UNION ALL
                         SELECT rast FROM public.sentinel2_band4_2) foo;
						 
create table nirr as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM public.sentinel2_band8_1
                        UNION ALL
                         SELECT rast FROM public.sentinel2_band8_2) foo;
						 
						 WITH r1 AS (
(SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
            FROM public.redd AS a, public.national_parks AS b
            WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.gid=1))
,
r2 AS (
(SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
    FROM public.nirr AS a, public.national_parks AS b
    WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.gid=1))

SELECT ST_MapAlgebra(r1.rast, r2.rast, '([rast1.val]-[rast2.val])/([rast1.val]+[rast2.val])::float', '32BF') AS rast
INTO lake_district_ndwi FROM r1, r2;

--Zad. 11.
SELECT ST_AsTIFF(ST_Union(rast), 'GTiff') 
FROM public.lake_district_ndwi;