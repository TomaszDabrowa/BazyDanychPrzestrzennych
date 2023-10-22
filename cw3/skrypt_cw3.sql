--Zad. 3.
CREATE DATABASE cw3;

CREATE EXTENSION postgis;

--Zad.4.
--Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
--położonych w odległości mniejszej niż 1000 jednostek od głównych rzek. Budynki spełniające to
--kryterium zapisz do osobnej tabeli tableB.
--select * from rivers
--SELECT * FROM popp WHERE f_codedesc = 'Building'; -- ilość budynków ogółem
SELECT * FROM popp, rivers WHERE popp.f_codedesc = 'Building' AND ST_DWithin(popp.geom, rivers.geom, 1000) = TRUE;

--Zad.5.
--Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
--geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.
--a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.
--b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie
--środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB.
--Wysokość n.p.m. przyjmij dowolną.
--Uwaga: geodezyjny układ współrzędnych prostokątnych płaskich (x – oś pionowa, y – oś
--pozioma)

CREATE TABLE airportsNew AS SELECT name, geom, elev FROM airports;
SELECT * FROM airportsNew;

--a)
--najbardziej na zachód
SELECT name FROM airportsNew ORDER BY ST_Y(geom) DESC LIMIT 1;
--najbardziej na wschód
SELECT name FROM airportsNew ORDER BY ST_Y(geom) ASC LIMIT 1;

--b)
INSERT INTO airportsNew VALUES(
	'airportB',
	(SELECT 
	ST_Centroid
	(
		ST_MakeLine
		(
			(SELECT geom FROM airportsNew ORDER BY ST_Y(geom) DESC LIMIT 1),
			(SELECT geom FROM airportsNew ORDER BY ST_Y(geom) ASC LIMIT 1)
		)
	)),
	34
);

--Zad.6.
--Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
--linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”
SELECT ST_Area(ST_Buffer(ST_ShortestLine(airports.geom, lakes.geom), 1000))
FROM lakes, airports
WHERE airports.name='AMBLER' AND lakes.names='Iliamna Lake';

--Zad.7.
--Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
--poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps)
--select * from trees
SELECT trees.vegdesc, SUM(ST_Area(trees.geom)) FROM trees, tundra, swamp
WHERE ST_Within(trees.geom,tundra.geom) OR ST_Within(trees.geom,swamp.geom)
GROUP BY trees.vegdesc;