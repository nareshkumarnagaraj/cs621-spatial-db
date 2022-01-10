select min(DistanceToBuffer)/1000 as shortestdistanceinkm, "area name" from (
	select 
st_transform(B.wkb_geometry,7785) <-> st_transform(A.wkb_geometry,7785) as DistanceToBuffer,
	B."area name"
from p220018.chennaicoastline as A, p220018.chennaifloodedarea as B
	where B."area name" ~* '^(V){1}.*(M){1}$'
	) as getmindistancequery group by "area name";
	