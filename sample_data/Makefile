IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run -v .:/data ${IMAGE}

SCHEMA_BASE = schema
SCHEMA_FILE = $(SCHEMA_BASE)/fdri.recordspec.yaml

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
	build/data/SITES.ttl \
	build/data/siteVariance.ttl \
	build/data/LAND_COVER_LCM_CLASSES.ttl \
	build/data/landCoverObservations.ttl \
	build/data/landCoverLcm.ttl \
	build/data/instrumentationVariablesProperties.ttl \
	build/data/STATISTICS.ttl \
	build/data/time_series_datasets.ttl \
	build/data/INSTRUMENTATION.ttl \
	build/data/variableInstrumentationProperty.ttl \
	build/data/time_series_definitions.ttl \
	build/data/parameterProperties.ttl \
	build/data/CORRECTION_FACTORS.ttl \
	build/data/CORRECTION_METHODS.ttl \
	build/data/qc_range_configuration_items.ttl \
	build/data/Firmware_history.ttl \
	build/data/sensorFaultsSplit.ttl \
	build/data/processingLevels.ttl

SCHEMAS = $(RECORDS:%=build/schema/%.schema.json)

CONTEXTS = $(RECORDS:%=build/context/%.context.jsonld)

REPORTS = $(SAMPLES:build/data/%.ttl=build/validation/%.ttl)

all: validate schemas contexts reports full_validation

pull:
	docker pull $(IMAGE)

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)
full_validation: build/validation/full_report.ttl

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

build/schema/%.schema.json: $(SCHEMA_FILE) | build/schema
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

build/context/%.context.jsonld: $(SCHEMA_FILE) | build/context
	$(RUN) record-spec-cmd json-ld -r $(*F) -o $@ $^

build/shacl/fdri_shacl.ttl: $(SCHEMA_FILE) | build/shacl
	$(RUN) record-spec-cmd shacl -o $@ $^

build/shacl/fdri_shacl_with_refs.ttl: $(SCHEMA_FILE) | build/shacl
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

build/instrumentationVariablesProperties.csv: src/instrumentation_variables.csv src/variableProperties.csv sql/instrumentationVariablesProperties.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/instrumentationVariablesProperties.sql"


build/landCoverObservations.csv: src/LAND_COVER_OBSERVED.csv sql/landCoverObservations.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/landCoverObservations.sql"

build/siteVariance.csv: src/SITES.csv sql/siteLayout.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/siteLayout.sql"

build/landCoverLcm.csv: src/LAND_COVER_LCM.csv sql/landCoverLcm.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/landCoverLcm.sql"

build/qc_range_configuration_items.csv: src/PARAMETER_RANGES_QC.csv src/PARAMETERS.csv sql/qc_range_configuration_items.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/qc_range_configuration_items.sql"

build/time_series_definitions.csv: src/TIMESERIES.csv src/intervalDuration.csv sql/time_series_definitions.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/time_series_definitions.sql"

build/time_series_datasets.csv: build/time_series_definitions.csv src/SITE_INSTRUMENTATION.csv src/VARIABLE_INSTRUMENTATION.csv sql/time_series_datasets.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/time_series_datasets.sql"

build/siteInstVar.csv: src/SITE_INSTRUMENTATION.csv src/VARIABLE_INSTRUMENTATION.csv src/variableProperties.csv build/timeSeriesProperty.csv sql/siteInstVar.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/siteInstVar.sql"

build/timeSeriesProperty.csv: src/TIMESERIES.csv sql/timeSeriesProperty.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/timeSeriesProperty.sql"

build/variableInstrumentationProperty.csv: src/VARIABLE_INSTRUMENTATION.csv src/variableProperties.csv sql/variableInstrumentationProperty.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/variableInstrumentationProperty.sql"

build/sensorFaultsSplit.csv: src/SENSOR_FAULTS.csv build/siteInstVar.csv sql/sensorFaultsSplit.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/sensorFaultsSplit.sql"

build/data/%.ttl: templates/namespaces.yaml templates/%.yaml src/%.csv | build/data
	$(RUN) mapper templates/$*.yaml src/$*.csv $@

build/data/%.ttl: templates/namespaces.yaml templates/%.yaml build/%.csv | build/data
	$(RUN) mapper templates/$*.yaml build/$*.csv $@

build/validation/%.ttl: build/data/%.ttl build/shacl/fdri_shacl.ttl  | build/validation
	$(RUN) /bin/bash -c "shacl v -d build/data/$*.ttl -s build/shacl/fdri_shacl.ttl > $@"

build/validation/data.ttl: $(SAMPLES) | build/validation 
	$(RUN) riot --output=ttl $^ > $@

build/validation/full_report.ttl: build/validation/data.ttl build/shacl/fdri_shacl_with_refs.ttl | build/validation
	$(RUN) shacl v -d build/validation/data.ttl -s build/shacl/fdri_shacl_with_refs.ttl > $@
