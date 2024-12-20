CREATE TABLE TS AS FROM read_csv('./sample_data/src/TIMESERIES.csv', AUTO_DETECT=true) ;
CREATE TABLE ID AS FROM read_csv('./sample_data/src/intervalDuration.csv', AUTO_DETECT=true) ;
COPY (
    SELECT TS.*, ID.DURATION,
    CASE 
        WHEN TS.TABLE_NAME ^@ 'LEVEL1' THEN 1
        WHEN TS.TABLE_NAME ^@ 'LEVEL2' THEN 2
        WHEN TS.TABLE_NAME ^@ 'LEVEL3' THEN 3
    END as PROCESSING_LEVEL,
    FROM TS
    JOIN ID on TS.INTERVAL_ID=ID.INTERVAL_ID
) TO './build/time_series_definitions.csv'