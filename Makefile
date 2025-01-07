IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run --rm -v .:/data ${IMAGE}

SCHEMA_BASE = sample_data/build/schema
SRC = sample_data/src
SQL = sample_data/sql
VAL = build/validation
TPL = sample_data/templates
TTL_BASE = build/data
SHACL_BASE = build/shacl
SCHEMA_FILE = sample_data/schema/fdri.recordspec.yaml

RECORDS = \
	Variable \
	DataProcessingActivity \
	GeospatialFeatureOfInterest \
	EnvironmentalMonitoringPlatform \
	EnvironmentalMonitoringSensor \
	EnvironmentalMonitoringSite \
	ExternalDataProcessingConfiguration \
	InternalDataProcessingConfiguration \
	StaticDeployment \
	TimeSeriesDataset \
	TimeSeriesDefinition

SAMPLES = \
	$(TTL_BASE)/correction_configurations.ttl \
	$(TTL_BASE)/CORRECTION_METHODS.ttl \
	$(TTL_BASE)/INSTRUMENTATION.ttl \
	$(TTL_BASE)/instrumentationVariablesProperties.ttl \
	$(TTL_BASE)/LAND_COVER_LCM_CLASSES.ttl \
	$(TTL_BASE)/landCoverLcm.ttl \
	$(TTL_BASE)/landCoverObservations.ttl \
	$(TTL_BASE)/monitoring_system_variables.ttl \
	$(TTL_BASE)/parameterProperties.ttl \
	$(TTL_BASE)/processingLevels.ttl \
	$(TTL_BASE)/qc_range_configuration_items.ttl \
	$(TTL_BASE)/sensor_deployments.ttl \
	$(TTL_BASE)/sensor_faults.ttl \
	$(TTL_BASE)/sensor_firmware_configurations.ttl \
	$(TTL_BASE)/SITES.ttl \
	$(TTL_BASE)/siteVariance.ttl \
	$(TTL_BASE)/STATISTICS.ttl \
	$(TTL_BASE)/time_series_datasets.ttl \
	$(TTL_BASE)/time_series_definitions.ttl

SCHEMAS = $(RECORDS:%=build/schema/%.schema.json)

CONTEXTS = $(RECORDS:%=build/context/%.context.jsonld)

REPORTS = $(SAMPLES:$(TTL_BASE)/%.ttl=$(VAL)/%.ttl)

all: validate schemas contexts reports full_validation

pull:
	docker pull $(IMAGE)

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)
full_validation: $(VAL)/full_report.ttl

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

build/schema/%.schema.json: $(SCHEMA_FILE) | build/schema
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

build/context/%.context.jsonld: $(SCHEMA_FILE) | build/context
	$(RUN) record-spec-cmd json-ld -r $(*F) -o $@ $^

$(SHACL_BASE)/fdri_shacl.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RUN) record-spec-cmd shacl -o $@ $^

$(SHACL_BASE)/fdri_shacl_with_refs.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RUN) record-spec-cmd shacl --with-reference-type-validation -o $@ $^

clean:
	rm -f $(SCHEMA_BASE)/*.schema.json
	rm -f $(SCHEMA_BASE)/*.context.jsonld
	rm -rf build

build:
	mkdir -p build

build/schema:
	mkdir -p build/schema

build/context:
	mkdir -p build/context

build/validation:
	mkdir -p build/validation

build/shacl:
	mkdir -p build/shacl

build/data:
	mkdir -p build/data

build/correction_configurations.csv: build/time_series_datasets.csv $(SRC)/CORRECTION_FACTORS.csv $(SQL)/correction_configurations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/correction_configurations.sql"

build/instrumentationVariablesProperties.csv: $(SRC)/instrumentation_variables.csv $(SRC)/variableProperties.csv $(SQL)/instrumentationVariablesProperties.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/instrumentationVariablesProperties.sql"

build/landCoverLcm.csv: $(SRC)/LAND_COVER_LCM.csv $(SQL)/landCoverLcm.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/landCoverLcm.sql"

build/landCoverObservations.csv: $(SRC)/LAND_COVER_OBSERVED.csv $(SQL)/landCoverObservations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/landCoverObservations.sql"

build/monitoring_system_variables.csv: $(SRC)/VARIABLE_INSTRUMENTATION.csv $(SRC)/TIMESERIES.csv $(SQL)/monitoring_system_variables.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/monitoring_system_variables.sql"

build/qc_range_configuration_items.csv: $(SRC)/PARAMETER_RANGES_QC.csv build/time_series_datasets.csv $(SQL)/qc_range_configuration_items.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/qc_range_configuration_items.sql"

build/sensor_deployments.csv: $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/VARIABLE_INSTRUMENTATION.csv $(SRC)/variableProperties.csv $(SQL)/sensor_deployments.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_deployments.sql"

build/sensor_faults.csv: $(SRC)/SENSOR_FAULTS.csv $(SRC)/PARAMETERS.csv build/sensor_deployments.csv $(SQL)/sensor_faults.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_faults.sql"

build/sensor_firmware_configurations.csv: $(SRC)/Firmware_history.csv $(SQL)/sensor_firmware_configurations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_firmware_configurations.sql"

build/siteVariance.csv: $(SRC)/SITES.csv $(SQL)/siteLayout.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/siteLayout.sql"

build/time_series_datasets.csv: build/time_series_definitions.csv $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/VARIABLE_INSTRUMENTATION.csv $(SQL)/time_series_datasets.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/time_series_datasets.sql"

build/time_series_definitions.csv: $(SRC)/TIMESERIES.csv $(SRC)/intervalDuration.csv $(SQL)/time_series_definitions.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/time_series_definitions.sql"

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml $(SRC)/%.csv | build/data
	$(RUN) mapper $(TPL)/$*.yaml $(SRC)/$*.csv $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml build/%.csv | build/data
	$(RUN) mapper $(TPL)/$*.yaml build/$*.csv $@

$(VAL)/%.ttl: $(TTL_BASE)/%.ttl $(SHACL_BASE)/fdri_shacl.ttl  | build/validation
	$(RUN) /bin/bash -c "shacl v -d $(TTL_BASE)/$*.ttl -s $(SHACL_BASE)/fdri_shacl.ttl > $@"

$(VAL)/data.ttl: $(SAMPLES) ontology/owl/fdri-metadata.ttl | build/validation 
	$(RUN) riot --output=ttl $^ > $@

$(VAL)/full_report.ttl: $(VAL)/data.ttl $(SHACL_BASE)/fdri_shacl_with_refs.ttl | build/validation
	$(RUN) shacl v -d $(VAL)/data.ttl -s $(SHACL_BASE)/fdri_shacl_with_refs.ttl > $@
