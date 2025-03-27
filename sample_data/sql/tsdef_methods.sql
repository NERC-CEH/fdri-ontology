CREATE TABLE DEP_ARRAY AS FROM read_json('./sample_data/src/TIMESERIES_DEF_DEPENDENCIES_ARRAY.json', auto_detect=true, format=auto);
COPY (
    SELECT key as TIMESERIES_DEF, value.* from DEP_ARRAY
) TO './build/tsdef_methods.csv' (HEADER, DELIMITER ',') ;