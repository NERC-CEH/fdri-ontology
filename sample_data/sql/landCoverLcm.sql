CREATE TABLE LC AS FROM read_csv('./sample_data/src/LAND_COVER_LCM.csv', AUTO_DETECT=true) ;
COPY (
    SELECT *,
    ROUND(FOOTPRINT / 100, 3) as AREA_RATIO,
    make_date(CAST(YEAR AS INT), 1, 1) AS START_DATE
    FROM LC
) TO './build/landCoverLcm.csv' (HEADER, DELIMITER ',') ;