DROP TABLE IF EXISTS chennaicoastlinebuffer CASCADE;
create table chennaicoastlinebuffer as 
select ogc_fid, nature, name, ST_Buffer(wkb_geometry, 2000) as heightbuffer from
chennaicoastline