DROP TABLE IF EXISTS  chennai_floodedarea CASCADE;
create table chennai_floodedarea as 
select A."area name", sum(B.area_m2)/1000000 as total_floodedarea, A.numstagnationplaces
from p220018.chennaizones as A, p220018.chennaiflooddata as B 
where st_contains(A.wkb_geometry,B.wkb_geometry) group by A."area name",
A.numstagnationplaces 

select * from chennai_floodedarea where 
(total_floodedarea < 0.01) and (numstagnationplaces <3);