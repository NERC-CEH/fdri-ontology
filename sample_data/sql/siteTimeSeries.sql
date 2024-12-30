create table IF NOT EXISTS site_inst as from read_csv('./sample_data/src/SITE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
create table IF NOT EXISTS var_inst as from read_csv('./sample_data/src/VARIABLE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
create table if not exists ts_prop as from read_csv('./sample_data/build/timeSeriesProperty.csv', AUTO_DETECT=true) ;

COPY(
SELECT DISTINCT SITE_ID, var_inst.VARIABLE_NAME as VARIABLE_NAME, ts_prop.TIMESERIES_ID, ts_prop.TIMESERIES_NAME, ts_prop.PROCESSING_LEVEL, ts_prop.DURATION
 FROM site_inst 
 INNER JOIN var_inst ON site_inst.INSTRUMENT_ID=var_inst.INSTRUMENT_ID
 INNER JOIN ts_prop  ON var_inst.VARIABLE_NAME = ts_prop.VARIABLE_NAME
ORDER BY SITE_ID, VARIABLE_NAME
) TO './build/siteTimeSeries.csv' (HEADER, DELIMITER ',') ;
