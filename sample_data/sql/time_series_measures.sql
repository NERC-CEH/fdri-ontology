create table TS as from read_csv('./sample_data/src/TIMESERIES.csv', AUTO_DETECT=true);
CREATE TABLE PP aS FROM read_csv('./sample_data/src/parameterProperties.csv', AUTO_DETECT=true) ;
CREATE TABLE ID AS FROM read_csv('./sample_data/src/intervalDuration.csv', AUTO_DETECT=true);

COPY(
SELECT TIMESERIES_ID,
    TS.PARAMETER_ID,
    TS.INTERVAL_ID,
    DURATION,
    STATISTIC_ID,
    UNIT,
    QUDT_UNIT,
    UNIT_NAME
FROM TS
JOIN PP on TS.PARAMETER_ID=PP.PARAMETER_ID
JOIN ID on TS.INTERVAL_ID=ID.INTERVAL_ID
WHERE UNIT IS NOT NULL
) TO './build/time_series_measures.csv' (HEADER, DELIMITER ',') ;
