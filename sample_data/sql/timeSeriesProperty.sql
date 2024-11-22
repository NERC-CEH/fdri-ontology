create table TIMESERIES as from read_csv('./src/TIMESERIES.csv', AUTO_DETECT=true);

COPY(
SELECT TIMESERIES_ID,
    REGEXP_REPLACE(
        TIMESERIES_ID,
        '_(RAW|LEVEL2(_MEAN)?|LEVEL3|STD|1DAY(_9TO9)?|TOTAL|SIMPLE)',
        '', 'g') AS PROPERTY_ID
FROM TIMESERIES
) TO './build/timeSeriesProperty.csv' (HEADER, DELIMITER ',') ;
