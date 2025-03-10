CREATE TABLE IF NOT EXISTS TS AS FROM read_csv('./sample_data/src/TIMESERIES.csv', AUTO_DETECT=true) ;
CREATE TABLE IF NOT EXISTS PR AS FROM read_csv('./sample_data/src/PARAMETER_RANGES_QC.csv', AUTO_DETECT=true) ;

COPY(
    SELECT PR.* FROM
        TS LEFT JOIN PR ON
            PR.TIMESERIES_ID == TS.TIMESERIES_ID
        WHERE
            SITE_ID IS NOT NULL
) TO './build/parameter_ranges.csv'