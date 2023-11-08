-- Zad. 1.
--Utwórz tabelę obiekty. W tabeli umieść nazwy i geometrie obiektów przedstawionych poniżej. Układ odniesienia
--ustal jako niezdefiniowany. Definicja geometrii powinna odbyć się za pomocą typów złożonych, właściwych dla EWKT.
CREATE EXTENSION postgis;
CREATE TABLE obiekty
(
	nazwa VARCHAR(60),
	geom geometry
)

INSERT INTO obiekty VALUES
(
	'obiekt1',
	ST_GeomFromEWKT('CompoundCurve((0 1,1 1),CIRCULARSTRING(1 1,2 0,3 1,4 2,5 1),(5 1,6 1))')
);

INSERT INTO obiekty VALUES
(
	'obiekt2',
	ST_GeomFromEWKT('CURVEPOLYGON( COMPOUNDCURVE((10 2, 10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2, 12 0, 10 2)), CIRCULARSTRING(11 2, 13 2, 11 2))')
);

INSERT INTO obiekty VALUES
(
	'obiekt3',
	ST_GeomFromEWKT('TRIANGLE( (7 15, 10 17, 12 13, 7 15) )')
);

INSERT INTO obiekty VALUES
(
	'obiekt4',
	ST_GeomFromEWKT('MULTILINESTRING( (20 20, 25 25), (25 25, 27 24), (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))')
);

INSERT INTO obiekty VALUES
(
	'obiekt5',
	ST_GeomFromEWKT('MULTIPOINT( (30 30 59), (38 32 234) )')
);

INSERT INTO obiekty VALUES
(
	'obiekt6',
	ST_GeomFromEWKT('GEOMETRYCOLLECTION( LINESTRING( 1 1, 3 2 ), POINT(4 2))')
);

--select * from obiekty
--delete from obiekty where nazwa = 'obiekt3'

--Zad.1.
--Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej
--obiekt 3 i 4.

SELECT 
ST_Area
(
	ST_Buffer
	(
		ST_ShortestLine
		(
			(SELECT geom FROM obiekty WHERE nazwa = 'obiekt3'),
			(SELECT geom FROM obiekty WHERE nazwa = 'obiekt4')
		),
		5
	)
);

--Zad.2.
--Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te
--warunki.

--sprawdzenie, czy obiekt4 jest poprawny topologicznie, czy nie zawiera przecięć
SELECT ST_IsValid((SELECT geom FROM obiekty WHERE nazwa='obiekt4')); -- true
--sprawdzenie, czy obiekt jest zamknięty
SELECT ST_IsClosed((SELECT geom FROM obiekty WHERE nazwa='obiekt4')) -- false

UPDATE obiekty
SET geom = ST_MakePolygon(ST_AddPoint(ST_LineMerge((SELECT geom FROM obiekty WHERE nazwa='obiekt4')),ST_GeomFromEWKT('POINT(20 20)')))
WHERE nazwa = 'obiekt4';

--Zad.3.
--W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.

INSERT INTO obiekty VALUES
(
	'obiekt7',
	ST_Collect((SELECT geom FROM obiekty WHERE nazwa = 'obiekt3'),(SELECT geom FROM obiekty WHERE nazwa = 'obiekt4'))
);

--Zad.4.
--Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie
--zawierających łuków.

SELECT ST_Area(ST_Buffer(ST_Union((SELECT geom FROM obiekty WHERE ST_HasArc(geom) = FALSE)),5))

