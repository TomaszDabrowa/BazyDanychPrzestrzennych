CREATE DATABASE karlsruhe;

CREATE EXTENSION postgis;

--Zad.1.
--Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana 
--pomiędzy 2018 a 2019).

--SELECT
--	(SELECT COUNT(*) FROM t2019_kar_buildings) -
--	(SELECT COUNT(*) FROM t2018_kar_buildings);
	
--albo
--SELECT * FROM t2018_kar_buildings 
--SELECT * FROM t2019_kar_buildings
CREATE TABLE nowe_budynki AS
SELECT * FROM t2018_kar_buildings os
JOIN t2019_kar_buildings dz ON os.gid = dz.gid
WHERE os.height != dz.height 
OR ST_Equals(os.geom, dz.geom);

CREATE TABLE nowe_budynki AS
SELECT dz.geom FROM t2018_kar_buildings os
JOIN t2019_kar_buildings dz ON os.gid = dz.gid
WHERE os.height != dz.height 
OR ST_Equals(os.geom, dz.geom);
--select * from nowe_budynki

--Zad.2.
--Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub 
--wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.
	
select * from t2019_kar_poi_table;


SELECT ST_Buffer(ST_Union(os.geom),500) FROM t2018_kar_buildings os
JOIN t2019_kar_buildings dz ON os.gid = dz.gid
WHERE os.height != dz.height 
OR ST_Equals(os.geom, dz.geom); -- DŁUGO SIĘ LICZY

WITH noweBudynkiCTE AS
(
	SELECT dz.geom FROM t2018_kar_buildings os
	JOIN t2019_kar_buildings dz ON os.gid = dz.gid
	WHERE os.height != dz.height 
	OR ST_Equals(os.geom, dz.geom)
)

SELECT ST_DWithin(poi.geom, ST_Union((SELECT * FROM noweBudynkiCTE)),500) 
FROM t2019_kar_poi_table poi

--Zad.3.
--Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli 
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
--select * from t2019_kar_streets
--CREATE TABLE streets_reprojected AS
--SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, 
--speed_cat, fr_speed_l, to_speed_l, dir_travel, ST_Transform(geom, 'EPSG:3068') AS geom
--FROM t2019_kar_streets;

select * from streets_reprojected

CREATE TABLE streets_reprojected AS
SELECT * FROM t2019_kar_streets;

ALTER TABLE streets_reprojected
ALTER COLUMN geom
TYPE GEOMETRY(MULTILINESTRING, 3068)
USING ST_Transform(geom, 3068);


--Zad.4.
--Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej. 
--Użyj następujących współrzędnych:. Przyjmij układ współrzędnych GPS

CREATE TABLE input_points 
(
    id int PRIMARY KEY,
    geom geometry(Point, 4326)
);

INSERT INTO input_points VALUES (1,ST_GeomFromText('POINT(8.36093 49.03174)', 4326));
INSERT INTO input_points VALUES (2,ST_GeomFromText('POINT(8.39876 49.00644)', 4326));

--Zad.5.
--Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych 
--DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().

UPDATE input_points SET geom = ST_Transform(geom,'EPSG:3068');
SELECT ST_AsText(geom) FROM input_points;

--Zad.6.
--Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej 
--z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj 
--reprojekcji geometrii, aby była zgodna z resztą tabel

select * from t2019_kar_street_node 
SELECT * FROM t2019_kar_street_node skrz
WHERE ST_DWithin
(
	skrz.geom,
	ST_Transform(ST_MakeLine((SELECT geom FROM input_points WHERE id = 1 ) , (SELECT geom FROM input_points WHERE id = 2 )),'EPSG:4326'),
	200
)=True;

--Zad.7.
--Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się 
--w odległości 300 m od parków (LAND_USE_A).

select * from t2019_kar_poi_table WHERE type = 'Sporting Goods Store'
select * from t2019_kar_land_use_a WHERE type = 'Park (City/County)';

SELECT COUNT(gid)
FROM t2019_kar_poi_table WHERE type='Sporting Goods Store'
AND ST_DWithin
(
	geom,
	(SELECT ST_Union(geom) FROM t2019_kar_land_use_a WHERE type = 'Park (City/County)'),
	300.0
);

--Zad.8.
--Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz 
--znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
CREATE TABLE T2019_KAR_BRIDGES AS
SELECT ST_Intersection(cieki.geom,tory.geom) 
FROM t2019_kar_water_lines cieki, t2019_kar_railways tory;

select * from T2019_KAR_BRIDGES