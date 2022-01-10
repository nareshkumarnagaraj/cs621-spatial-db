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