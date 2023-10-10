--Zad. 2.--
CREATE DATABASE postgres;

--Zad. 3.
CREATE EXTENSION postgis;

--Zad. 4. Utwórz tabele
CREATE TABLE budynki (id INT, geometria GEOMETRY, nazwa VARCHAR(60) );
CREATE TABLE drogi (id INT, geometria GEOMETRY, nazwa VARCHAR(60) );
CREATE TABLE punkty_informacyjne (id INT, geometria GEOMETRY, nazwa VARCHAR(60) );

--Zad. 5. Wprowadzenie danych
INSERT INTO punkty_informacyjne VALUES(1,ST_GeomFromText('POINT(6 9.5)',-1),'K');
INSERT INTO punkty_informacyjne VALUES(2,ST_GeomFromText('POINT(6.5 6)',-1),'J');
INSERT INTO punkty_informacyjne VALUES(3,ST_GeomFromText('POINT(9.5 6)',-1),'I');
INSERT INTO punkty_informacyjne VALUES(4,ST_GeomFromText('POINT(1 3.5)',-1),'G');
INSERT INTO punkty_informacyjne VALUES(5,ST_GeomFromText('POINT(5.5 1.5)',-1),'H');

INSERT INTO drogi VALUES(1,ST_GeomFromText('LINESTRING(0 4.5,12 4.5)',-1),'RoadX');
INSERT INTO drogi VALUES(2,ST_GeomFromText('LINESTRING(7.5 0,7.5 10.5)',-1),'RoadY');

INSERT INTO budynki VALUES(1,ST_GeomFromText('POLYGON((8 1.5,10.5 1.5,10.5 4,8 4,8 1.5))',-1),'BuildingA');
INSERT INTO budynki VALUES(2,ST_GeomFromText('POLYGON((4 5,4 7,6 7,6 5,4 5))',-1),'BuildingB');
INSERT INTO budynki VALUES(3,ST_GeomFromText('POLYGON((3 6,5 6,5 8,3 8,3 6))',-1),'BuildingC');
INSERT INTO budynki VALUES(4,ST_GeomFromText('POLYGON((9 8,10 8,10 9,9 9,9 8))',-1),'BuildingD');
INSERT INTO budynki VALUES(5,ST_GeomFromText('POLYGON((1 1,2 1,2 2,1 2,1 1))',-1),'BuildingF');

--Zad. 6.
--a)Wyznacz całkowitą długość dróg w analizowanym mieście.
SELECT SUM(ST_Length(geometria)) FROM drogi;

--b)Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego
--budynek o nazwie BuildingA.
SELECT ST_AsText(geometria), ST_Area(geometria), ST_Perimeter(geometria)
FROM budynki WHERE nazwa = 'BuildingA';

--c)Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki
--posortuj alfabetycznie.

SELECT nazwa, ST_Area(geometria) FROM budynki
ORDER BY nazwa ASC;

--d)Wypisz nazwy i obwody 2 budynków o największej powierzchni.

SELECT  nazwa, ST_Perimeter(geometria) FROM budynki
ORDER BY ST_AREA(geometria) DESC LIMIT 2;

--e)Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.

SELECT ST_Distance
(
	(SELECT geometria FROM budynki WHERE nazwa = 'BuildingC'),     --geometria Budynku A jako pierwszy argument
	(SELECT geometria FROM punkty_informacyjne WHERE nazwa = 'G')  --geometria punktu G jako drugi argument
)

--f)Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w
--odległości większej niż 0.5 od budynku BuildingB.


WITH bufor (geometria) AS
(
	SELECT ST_Buffer((SELECT geometria FROM budynki WHERE nazwa = 'BuildingB'),0.5)
)
SELECT ST_Area((SELECT geometria FROM budynki WHERE nazwa = 'BuildingC')) - ST_Area(ST_Intersection(
	(SELECT geometria FROM budynki WHERE nazwa = 'BuildingC'),
	(SELECT * FROM bufor)
));

--g)Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi
--o nazwie RoadX. 
WITH budynki_powyzej(id, geometria, nazwa) AS
(
	SELECT * FROM budynki WHERE ST_Y(ST_Centroid(geometria)) > (SELECT ST_Y(ST_Centroid(geometria)) FROM drogi WHERE nazwa = 'RoadX')
)

SELECT * FROM budynki_powyzej;

--h)Oblicz pole powierzchni tych części budynku BuildingC i poligonu
--o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch
--obiektów.

--NIE DZIAŁA
-- wzór to (BuildingC - poligon) + (poligon - BuildingC)
--SELECT 
-- (ST_Area((SELECT geometria FROM budynki WHERE nazwa = 'BuildingC')) - ST_Area(ST_GeomFromText('Polygon((4 7, 6 7, 6 8, 4 8, 4 7))',-1)))
-- +
-- (ST_Area(ST_GeomFromText('Polygon((4 7, 6 7, 6 8, 4 8, 4 7))',-1)) - ST_Area((SELECT geometria FROM budynki WHERE nazwa = 'BuildingC')));

SELECT ST_Area(ST_Union(
(SELECT geometria FROM budynki WHERE nazwa='BuildingC'),ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))',-1)
)) - 
ST_Area(ST_Difference(
(SELECT geometria FROM budynki WHERE nazwa='BuildingC'),ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))',-1)
));

