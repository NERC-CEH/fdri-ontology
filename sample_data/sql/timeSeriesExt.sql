CREATE TABLE TS AS FROM read_csv('./src/TIMESERIES.csv', AUTO_DETECT=true) ;
CREATE TABLE ID AS FROM read_csv('./src/intervalDuration.csv', AUTO_DETECT=true) ;
COPY (
    SELECT TS.*, ID.DURATION FROM
    TS
    JOIN ID on TS.INTERVAL_ID=ID.INTERVAL_ID
) TO './build/timeSeriesExt.csv'