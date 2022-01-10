select "area name" from chennaizones;

--------------------------------------------------------------------------------------

select * from chennaipreflooddata;

--------------------------------------------------------------------------------------

select * from chennaiflooddata;

--------------------------------------------------------------------------------------

ALTER TABLE rainwater_stagnation_points
ADD COLUMN stagnation_height_category VARCHAR(20); 

UPDATE rainwater_stagnation_points
SET stagnation_height_category = CASE WHEN height < 2 THEN 'Mild'
                                WHEN height >= 2 AND height < 5 THEN 'High'
                                WHEN height >= 5 THEN 'Extremely High'
                            END;

select * from rainwater_stagnation_points;

--------------------------------------------------------------------------------------

DROP VIEW IF EXISTS chennai_rainwater_stagnation;

CREATE OR REPLACE VIEW
chennai_rainwater_stagnation AS
SELECT B.ogc_fid, B.height, B.geom,B.stagnation_height_category
from p220018.chennaizones as A, p220018.rainwater_stagnation_points as B
where st_contains(A.wkb_geometry,B.geom);

--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS chennai_rainwater_stagnation_buffer CASCADE;

create table chennai_rainwater_stagnation_buffer as 
select ogc_fid, height, ST_Buffer(geom, 564.0*(height/100)) as heightbuffer from 
chennai_rainwater_stagnation;

--------------------------------------------------------------------------------------

ALTER TABLE CS621Week7OffalyEastPoly ADD COLUMN NumStagnationplaces INTEGER DEFAULT 0;

With PolygonQuery as (
SELECT Polys.ogc_fid,Polys."area name", count(*) as NumStagnationplacesInPoly
FROM chennaizones as Polys, chennai_rainwater_stagnation as Pts
where ST_CONTAINS(Polys.wkb_geometry,Pts.geom)
GROUP BY Polys.ogc_fid
)
UPDATE CS621Week7OffalyEastPoly
SET NumCases = PolygonQuery.NumPtsInPoly
FROM PolygonQuery
WHERE PolygonQuery.pkid = CS621Week7OffalyEastPoly.pkid;

--------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------
	
DROP TABLE IF EXISTS chennaicoastlinebuffer CASCADE;
create table chennaicoastlinebuffer as 
select ogc_fid, nature, name, ST_Buffer(wkb_geometry, 2000) as heightbuffer from
chennaicoastline

--------------------------------------------------------------------------------------

DROP VIEW IF EXISTS chennai_top3mostfloodednearcoastline;
CREATE OR REPLACE VIEW
chennai_top3mostfloodednearcoastline AS
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea
from p220018.chennaizones as A, p220018.chennaiflooddata as B, p220018.chennaicoastlinebuffer as C
where st_contains(A.wkb_geometry,B.wkb_geometry) and st_intersects(B.wkb_geometry, C.heightbuffer)
 group by A."area name" order by total_floodedarea desc limit 3
 
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS  chennai_floodedarea CASCADE;
create table chennai_floodedarea as 
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea, A.numstagnationplaces
from p220018.chennaizones as A, p220018.chennaiflooddata as B 
where st_contains(A.wkb_geometry,B.wkb_geometry) group by A."area name",
A.numstagnationplaces 

select * from chennai_floodedarea where 
(total_floodedarea < 0.01) and (numstagnationplaces <3);

--------------------------------------------------------------------------------------

SELECT * from chennaifloodarea
where (ST_Distance(
ST_Transform(wkb_geometry,7785),
ST_Transform(
ST_GeomFromText('POINT(80.1626
12.9823)',4326,7785))<=5000) order by total_floodedarea asc;

--------------------------------------------------------------------------------------

select min(DistanceToBuffer)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(B.wkb_geometry,7785) <-> st_transform(A.wkb_geometry,7785) as DistanceToBuffer,
	B."area name"
from p220018.chennaicoastline as A, p220018.chennaifloodedarea as B
	where B."area name" ~* '^(V){1}.*(M){1}$'
	) as getmindistancequery group by "area name";
	
--------------------------------------------------------------------------------------