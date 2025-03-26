CREATE TABLE IF NOT EXISTS SI AS FROM read_csv('./sample_data/src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
CREATE TABLE IF NOT EXISTS SS AS FROM read_csv('./sample_data/src/SENSOR_SLOT_IDS.csv', AUTO_DETECT=true) ;
CREATE TABLE IF NOT EXISTS TS AS FROM read_csv('./sample_data/src/TIMESERIES_IDS.csv', AUTO_DETECT=true) ;

COPY (
    SELECT SI.*, SS.INSTRUMENT_ID, TS.PARAMETER_ID
    FROM
    SI
    LEFT JOIN SS on SI.SENSOR_SLOT_ID = SS.SENSOR_SLOT_ID
    LEFT JOIN TS on SI.SENSOR_SLOT_ID = TS.SENSOR_SLOT_ID AND SI.SITE_ID = TS.SITE_ID
) TO './build/sensor_deployments.csv' (HEADER, DELIMITER ',') ;
-- create table IF NOT EXISTS site_inst as from read_csv('./sample_data/src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
-- create table IF NOT EXISTS var_inst as from read_csv('./sample_data/src/VARIABLE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
-- create table if not EXISTS var_prop as from read_csv('./sample_data/src/variableProperties.csv', AUTO_DETECT=true) ;
-- COPY(
--     SELECT site_inst.*, var_inst.*, var_prop.PROPERTY, var_prop.INTERVAL
--     FROM site_inst
--     INNER JOIN var_inst 
--     ON site_inst.INSTRUMENT_ID=var_inst.INSTRUMENT_ID
--     LEFT JOIN var_prop
--     ON var_inst.VARIABLE_NAME=var_prop.VARIABLE_NAME
--     WHERE site_inst.INSTRUMENT_ID != 'DERIVED'
--     ORDER BY SITE_ID, site_inst.INSTRUMENT_ID, START_DATETIME
-- ) TO './build/sensor_deployments.csv' (HEADER, DELIMITER ',') ;