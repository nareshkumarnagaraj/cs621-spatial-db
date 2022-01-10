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