ALTER TABLE rainwater_stagnation_points
ADD COLUMN stagnation_height_category VARCHAR(20); 

UPDATE rainwater_stagnation_points
SET stagnation_height_category = CASE WHEN height < 2 THEN 'Mild'
                                WHEN height >= 2 AND height < 5 THEN 'High'
                                WHEN height >= 5 THEN 'Extremely High'
                            END;

select * from rainwater_stagnation_points;