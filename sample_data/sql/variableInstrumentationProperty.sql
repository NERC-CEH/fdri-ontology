create table IF NOT EXISTS var_inst as from read_csv('./sample_data/src/VARIABLE_INSTRUMENTATION.csv', AUTO_DETECT=true) ;
create table if not EXISTS var_prop as from read_csv('./sample_data/src/variableProperties.csv', AUTO_DETECT=true) ;
COPY(
    SELECT var_inst.*, var_prop.PROPERTY
    FROM var_inst
    LEFT JOIN var_prop
    ON var_inst.VARIABLE_NAME=var_prop.VARIABLE_NAME
) TO './build/variableInstrumentationProperty.csv' (HEADER, DELIMITER ',') ;