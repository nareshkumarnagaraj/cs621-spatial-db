DROP VIEW IF EXISTS chennai_top3mostfloodednearcoastline;
CREATE OR REPLACE VIEW
chennai_top3mostfloodednearcoastline AS
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea
from p220018.chennaizones as A, p220018.chennaiflooddata as B, p220018.chennaicoastlinebuffer as C
where st_contains(A.wkb_geometry,B.wkb_geometry) and st_intersects(B.wkb_geometry, C.heightbuffer)
 group by A."area name" order by total_floodedarea desc limit 3