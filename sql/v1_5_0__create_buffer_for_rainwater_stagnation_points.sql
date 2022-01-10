DROP TABLE IF EXISTS chennai_rainwater_stagnation_buffer CASCADE;

create table chennai_rainwater_stagnation_buffer as 
select ogc_fid, height, ST_Buffer(geom, 564.0*(height/100)) as heightbuffer from 
chennai_rainwater_stagnation;