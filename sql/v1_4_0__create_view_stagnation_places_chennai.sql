DROP VIEW IF EXISTS chennai_rainwater_stagnation;

CREATE OR REPLACE VIEW
chennai_rainwater_stagnation AS
SELECT B.ogc_fid, B.height, B.geom,B.stagnation_height_category
from p220018.chennaizones as A, p220018.rainwater_stagnation_points as B
where st_contains(A.wkb_geometry,B.geom);