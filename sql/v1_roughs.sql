select * from p220018.chennaizones as z, p220018.chennaiwaterheight as y
not st_intersects(z.wkb_geometry,y.geom)

select * from p220018.chennaizones
select * from p220018.chennaiwaterheight

DELETE FROM chennaiwaterheight WHERE

SELECT B.ogc_fid, B.height, B.geom
from p220018.chennaizones as A, p220018.chennaiwaterheight as B
where st_intersects(A.wkb_geometry,B.geom)
--------------------------------------------------------------------------------view
DROP VIEW IF EXISTS chennaizoneheight;
CREATE OR REPLACE VIEW
chennaizoneheight AS
SELECT B.ogc_fid, B.height, B.geom
from p220018.chennaizones as A, p220018.chennaiwaterheight as B
where st_intersects(A.wkb_geometry,B.geom)


CREATE TABLE chennaizonewaterheight
AS 
SELECT *
from p220018.chennaizones as A, p220018.chennaiwaterheight as B
where st_intersects(A.wkb_geometry,B.geom)

select * from p220018.chennairesources

CREATE TABLE chennairesourceslist
AS 
SELECT B.ogc_fid, B.name, B.type, B.wkb_geometry
from p220018.chennaizones as A, p220018.chennairesources as B
where st_intersects(A.wkb_geometry,B.wkb_geometry)
DROP TABLE IF EXISTS chennairesources CASCADE;

--
select * from p220018.chennaipreflood

CREATE TABLE chennaiprefloodlist
AS 
SELECT B.ogc_fid, B.sensor_id, B.sensor_dat, B.confidence, B.field_vali, B.water_Stat, B.notes, 
B.area_m2, B.area_ha, B.staffid, B.eventcode, B.wkb_geometry
from p220018.chennaizones as A, p220018.chennaipreflood as B
where st_intersects(A.wkb_geometry,B.wkb_geometry)
DROP TABLE IF EXISTS chennaipreflood CASCADE;
--
select * from p220018.chennaipreflood

CREATE TABLE chennaiflooddatalist
AS 
SELECT B.ogc_fid, B.sensor_id, B.sensor_dat, B.confidence, B.field_vali, B.water_Stat, B.notes, 
B.area_m2, B.area_ha, B.staffid, B.eventcode, B.wkb_geometry
from p220018.chennaizones as A, p220018.chennaiflooddata as B
where st_intersects(A.wkb_geometry,B.wkb_geometry)
DROP TABLE IF EXISTS chennaiflooddata CASCADE;

--
select * from p220018.chennaiwaterbodies

CREATE TABLE chennaiwaterbodieslist
AS 
SELECT B.ogc_fid, B.natural, B.name, B.wkb_geometry
from p220018.chennaizones as A, p220018.chennaiwaterbodies as B
where st_intersects(A.wkb_geometry,B.wkb_geometry)
DROP TABLE IF EXISTS chennaiwaterbodies CASCADE;
--
select * from p220018.chennaicoastline

DROP TABLE IF EXISTS chennaicoastlinebuffer CASCADE;
create table chennaicoastlinebuffer as 
select ogc_fid, nature, name, ST_Buffer(wkb_geometry, 0.01) as heightbuffer from
chennaicoastline

--
select * from p220018.chennaiflooddatalist
select * from p220018.chennaizones



SELECT A.id,A."zone number",A."area name",B.ogc_fid, B.area_m2
from p220018.chennaizones as A, p220018.chennaiflooddatalist as B
where st_contains(A.wkb_geometry,B.wkb_geometry)
DROP TABLE IF EXISTS chennaiwaterbodies CASCADE;

DROP TABLE IF EXISTS chennai_floodedarea CASCADE;
create table chennai_floodedarea as 
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea
from p220018.chennaizones as A, p220018.chennaiflooddatalist as B
where st_contains(A.wkb_geometry,B.wkb_geometry) 
 group by A."area name" order by total_floodedarea desc

--
select * from p220018.chennaiwaterbodieslist

DROP TABLE IF EXISTS chennai_waterareas CASCADE;
create table chennai_waterareas as 
select A."area name", st_area(st_transform(B.wkb_geometry,3112))/1000000 as total_waterarea
from p220018.chennaizones as A, p220018.chennaiwaterbodieslist as B
where st_contains(A.wkb_geometry,B.wkb_geometry) 

--
select * from p220018.chennaizones
select * from chennai_waterareas


DROP TABLE IF EXISTS chennai_waterarea CASCADE;
create table chennai_waterarea as 
select "area name", sum(total_waterarea) as total_waterarea  from chennai_waterareas
 group by "area name" order by total_waterarea desc
--
select * from chennai_floodedarea
select * from chennai_prefloodarea
--
select * from p220018.chennaiprefloodlist
DROP TABLE IF EXISTS chennai_floodedarea CASCADE;
create table chennai_prefloodarea as 
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea
from p220018.chennaizones as A, p220018.chennaiprefloodlist as B
where st_contains(A.wkb_geometry,B.wkb_geometry) 
 group by A."area name" order by total_floodedarea desc


--
select * from chennai_floodedarea
select * from p220018.chennai_prefloodarea
--
select * from p220018.chennaicoastline
select * from p220018.chennaiflooddatalist

select ST_SRID(wkb_geometry) from chennaizones
select ST_SRID(wkb_geometry) from chennaiflooddatalist

select min(DISTANCE)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(A.wkb_geometry,32630) <-> st_transform(ST_Centroid(C.wkb_geometry),32630) as DISTANCE,
	C."area name" 
from p220018.chennaicoastline as A, p220018.chennaiflooddatalist as B,
p220018.chennaizones as C
where st_contains(C.wkb_geometry,B.wkb_geometry) 
	) as getmindistancequery 
	group by "area name" order by shortestdistanceinkm
	
--
create table chennai_coastnear as 
select min(DISTANCE)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(A.wkb_geometry,32630) <-> st_transform(ST_Centroid(C.wkb_geometry),32630) as DISTANCE,
	C."area name" 
from p220018.chennaicoastline as A, p220018.chennaiflooddatalist as B,
p220018.chennaizones as C
where st_contains(C.wkb_geometry,B.wkb_geometry) 
	) as getmindistancequery 
	group by "area name" order by shortestdistanceinkm
--
select * from p220018.chennai_coastnear
select * from p220018.chennai_floodedarea
--
select A."area name", A.shortestdistanceinkm, B.total_floodedarea
from p220018.chennai_coastnear as A, p220018.chennai_floodedarea as B
where (A."area name" = B."area name") 
order by A.shortestdistanceinkm
--
select A."area name", B.total_floodedarea, A.shortestdistanceinkm
from p220018.chennai_coastnear as A, p220018.chennai_floodedarea as B
where (A."area name" = B."area name") 
order by B.total_floodedarea
--


ALTER TABLE chennaizones ADD COLUMN NumStagnationplacesDensity REAL DEFAULT 0.0;

With PolygonQuery as (
SELECT Polys.ogc_fid,Polys."area name",
count(*)/(ST_Area(ST_Transform(Polys.wkb_geometry,32629))/1000000) as PlacesPerKM2
FROM chennaizones as Polys, chennai_rainwater_stagnation as Pts
where ST_CONTAINS(Polys.wkb_geometry,Pts.geom)
GROUP BY Polys.ogc_fid
)
UPDATE chennaizones
SET NumStagnationplacesDensity = PolygonQuery.PlacesPerKM2
FROM PolygonQuery
WHERE PolygonQuery.ogc_fid = chennaizones.ogc_fid;

select * from chennaizones;



**********8
select min(DISTANCE)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(A.wkb_geometry,32630) <-> st_transform(C.wkb_geometry,32630) as DISTANCE,
	C."area name" 
from p220018.chennaicoastline as A, p220018.chennaiflooddata as B,
p220018.chennaizones as C
where st_contains(C.wkb_geometry,B.wkb_geometry) 
	) as getmindistancequery 
	group by "area name" order by shortestdistanceinkm
	
	
DROP TABLE IF EXISTS chennaicoastlinebuffer CASCADE;
create table chennaicoastlinebuffer as 
select ogc_fid, nature, name, ST_Buffer(wkb_geometry, 0.02) as heightbuffer from
chennaicoastline

DROP VIEW IF EXISTS chennai_top3mostfloodednearcoastline;
CREATE OR REPLACE VIEW
chennai_top3mostfloodednearcoastline AS
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea
from p220018.chennaizones as A, p220018.chennaiflooddata as B, p220018.chennaicoastlinebuffer as C
where st_contains(A.wkb_geometry,B.wkb_geometry) and st_intersects(B.wkb_geometry, C.heightbuffer)
 group by A."area name" order by total_floodedarea desc limit 3

DROP VIEW IF EXISTS chennai_top3mostfloodednearcoastline;
CREATE OR REPLACE VIEW
chennai_top3mostfloodednearcoastline AS

select A."area name", A.total_floodedarea, B.wkb_geometry from
top3mostfloodednearcoastline as A, chennaizones as B
where A."area name"=B."area name"


DROP TABLE IF EXISTS  chennai_floodedarea CASCADE;
create table chennai_floodedarea as 
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea, A.numstagnationplaces
from p220018.chennaizones as A, p220018.chennaiflooddata as B 
where st_contains(A.wkb_geometry,B.wkb_geometry) group by A."area name",
A.numstagnationplaces 

select * from chennai_floodedarea where 
(total_floodedarea < 0.01) and (numstagnationplaces <3);



DROP TABLE IF EXISTS  chennai_floodedarea CASCADE;
create table chennai_floodedarea as 
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea, A.numstagnationplaces
from p220018.chennaizones as A, p220018.chennaiflooddata as B 
where st_contains(A.wkb_geometry,B.wkb_geometry) group by A."area name",
A.numstagnationplaces 


select * from chennai_floodedarea where 
(total_floodedarea < 0.01) and (numstagnationplaces <3);


DROP TABLE IF EXISTS  chennaifloodedarea CASCADE;
create table chennaifloodedarea as
select *, B.wkb_geometry from
chennai_floodedarea as A, chennaizones as B
where A."area name"=B."area name"


DROP TABLE IF EXISTS  chennaifloodedarea CASCADE;
create table chennaifloodedarea as
select A."area name", A.total_floodedarea, A.numstagnationplaces, B.wkb_geometry from
p220018.chennai_floodedarea as A, chennaizones as B where A."area name"=B."area name"

SELECT * From chennaifloodedarea
WHERE (ST_Distance(
ST_Transform(wkb_geometry,32633),
ST_Transform(
ST_GeomFromText('POINT(80.1626
12.9823)',4326),32630)) <= 10000) order by total_floodedarea asc;



select min(DISTANCE)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(A.wkb_geometry,32630) <-> ST_Transform(
ST_GeomFromText('POINT(80.1626
12.9823)',4326),32633)) as DISTANCE,
	C."area name" 
from p220018.chennaifloodedarea as A, p220018.chennaiflooddata as B,
p220018.chennaizones as C
where st_contains(C.wkb_geometry,B.wkb_geometry) 
	) as getmindistancequery 
	group by "area name" order by shortestdistanceinkm	



select min(DISTANCE)/1000 as shortestdistanceinkm, "area name" from (
	select "area name", 
st_transform(wkb_geometry,32633) <-> ST_Transform(
ST_GeomFromText('POINT(80.1626
12.9823)',4326),32633) as DISTANCE from p220018.chennaifloodedarea 
	where "area name" like 'V%'
	) as getmindistancequery 
	group by "area name" order by shortestdistanceinkm	
	
select min(DistanceToBuffer)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(B.wkb_geometry,7785) <-> st_transform(A.wkb_geometry,7785) as DistanceToBuffer,
	B."area name"
from p220018.chennaicoastline as A, p220018.chennaifloodedarea as B
	where B."area name" ~* '^(V){1}.*(M){1}$'
	) as getmindistancequery group by "area name";
	
DROP TABLE IF EXISTS chennaiwaterheightbuffer CASCADE;
create table chennaiwaterheightbuffer as 
select ogc_fid, height, ST_Buffer(geom, 0.001*(height)) as heightbuffer from
chennaizoneheight




ALTER TABLE p220018.chennaiwaterheight ADD COLUMN geom geometry(Point, 4326);
UPDATE p220018.chennaiwaterheight SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

select ST_SRID(geom) from p220018.chennaiwaterheight
update p220018.chennaiwaterheight set geom = st_transform(geom, 32629)



--
**********

--
DROP VIEW IF EXISTS chennai_rainwater_stagnation;
CREATE OR REPLACE VIEW
chennai_rainwater_stagnation AS
SELECT B.ogc_fid, B.height, B.geom,B.stagnation_height_category
from p220018.chennaizones as A, p220018.rainwater_stagnation_points as B
where st_contains(A.wkb_geometry,B.geom)


ALTER TABLE rainwater_stagnation_points
ADD COLUMN stagnation_height_category VARCHAR(20); 

UPDATE rainwater_stagnation_points
SET stagnation_height_category = CASE WHEN height < 2 THEN 'Mild'
                                WHEN height >= 2 AND height < 5 THEN 'High'
                                WHEN height >= 5 THEN 'Extremely High'
                            END;

select * from rainwater_stagnation_points;


ALTER TABLE p220018.chennaizones ADD COLUMN NumStagnationplaces INTEGER DEFAULT 0;
--
SELECT Polys."area name", count(*) as NumStagnationplacesInPoly
FROM chennaizones as Polys, chennai_rainwater_stagnation as Pts
where ST_CONTAINS(Polys.wkb_geometry,Pts.geom)
GROUP BY Polys."area name";
--
With PolygonQuery as (
SELECT Polys.ogc_fid, Polys."area name", count(*) as NumStagnationplacesInPoly
FROM chennaizones as Polys, chennai_rainwater_stagnation as Pts
where ST_CONTAINS(Polys.wkb_geometry,Pts.geom)
GROUP BY Polys.ogc_fid
)
UPDATE chennaizones
SET NumStagnationplaces = PolygonQuery.NumStagnationplacesInPoly
FROM PolygonQuery
WHERE PolygonQuery.ogc_fid = chennaizones.ogc_fid;
--
select "area name", NumStagnationplaces from chennaizones order by NumStagnationplaces desc;