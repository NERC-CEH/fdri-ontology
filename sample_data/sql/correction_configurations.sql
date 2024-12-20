create table if not exists PARAMETERS as from read_csv('./sample_data/src/PARAMETERS.csv') ;
create table if not exists CORRECTION_FACTORS as from read_csv('./sample_data/src/CORRECTION_FACTORS.csv') ;

COPY(
    SELECT CORRECTION_FACTORS.* 
    FROM CORRECTION_FACTORS 
    INNER JOIN PARAMETERS ON CORRECTION_FACTORS.VARIABLE=PARAMETERS.PARAMETER_ID
) TO './build/correction_configurations.csv' (HEADER, DELIMITER ',') ;