create table IF NOT EXISTS inst_var as from read_csv('./sample_data/src/instrumentation_variables.csv', AUTO_DETECT=true) ;
create table if not EXISTS var_prop as from read_csv('./sample_data/src/variableProperties.csv', AUTO_DETECT=true) ;
COPY(
    SELECT inst_var.*, var_prop.PROPERTY
    FROM inst_var
    LEFT JOIN var_prop
    ON inst_var.VARIABLE_NAME=var_prop.VARIABLE_NAME
) TO './build/instrumentationVariablesProperties.csv' (HEADER, DELIMITER ',') ;