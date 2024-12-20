create table IF NOT EXISTS faults as from read_csv('./sample_data/src/SENSOR_FAULTS.csv', AUTO_DETECT=true) ;
create table IF NOT EXISTS siteInstVar as from read_csv('./build/siteInstVar.csv', AUTO_DETECT=true) ;

CREATE TEMP TABLE faultsSplit AS
SELECT 
    SITE_ID, START_DATETIME, END_DATETIME, str_split(VARIABLES_AFFECTED, ';').UNNEST() AS VARIABLE, REMOVE_DATA, DESCRIPTION_OF_ISSUE FROM faults ;

COPY(
SELECT 
faultsSplit.*, siteInstVar.INSTRUMENT_ID, siteInstVar.SERIAL_NUMBER FROM
    faultsSplit LEFT JOIN siteInstVar ON
        faultsSplit.SITE_ID == siteInstVar.SITE_ID AND
        faultsSplit.VARIABLE == siteInstVar.VARIABLE_NAME AND
        faultsSplit.START_DATETIME >= siteInstVar.START_DATETIME AND
        (siteInstVar.END_DATETIME IS NULL OR 
            (faultsSplit.END_DATETIME <= siteInstVar.END_DATETIME) OR 
            (faultsSplit.END_DATETIME IS NULL AND siteInstVar.END_DATETIME IS NULL)
        )
) TO './build/sensorFaultsSplit.csv' (HEADER, DELIMITER ',') ;

DROP TABLE faultsSplit;
