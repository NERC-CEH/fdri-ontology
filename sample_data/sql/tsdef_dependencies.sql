CREATE TABLE DEP_ARRAY AS FROM read_json('./sample_data/src/TIMESERIES_DEF_DEPENDENCIES_ARRAY.json', auto_detect=true, format=auto);
COPY (
    SELECT key as TIMESERIES_DEF, unnest(value.depends_on) as DEPENDS_ON from DEP_ARRAY
) TO './build/tsdef_dependencies.csv' (HEADER, DELIMITER ',') ;