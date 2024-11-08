CREATE TABLE LCO AS FROM read_csv('./src/LAND_COVER_OBSERVED.csv', AUTO_DETECT=true) ;
CREATE TABLE LCC AS FROM read_csv('./src/LAND_COVER_LCM_CLASSES.csv', AUTO_DETECT=true) ;

COPY (
    SELECT *, 
        (
            SELECT START_DATE
            FROM LCO as next
            WHERE next.SITE_ID==prev.SITE_ID AND next.START_DATE > prev.START_DATE
            ORDER BY next.START_DATE
            LIMIT 1
        ) as END_DATE
    FROM LCO as prev
    LEFT JOIN LCC ON LCC.DESCRIPTION == prev.LAND_COVER_OBSERVED
) TO './build/landCoverObservations.csv' (HEADER, DELIMITER ',') ;