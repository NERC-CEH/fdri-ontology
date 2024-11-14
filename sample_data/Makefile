IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run -v .:/data ${IMAGE}

SCHEMA_BASE = schema
SCHEMA_FILE = $(SCHEMA_BASE)/fdri.recordspec.yaml

RECORDS = \
	ComplexObservableProperty \
	DataProcessingActivity \
	EnvironmentalFeatureOfInterest \
	EnvironmentalMonitoringPlatform \
	EnvironmentalMonitoringSensor \
	EnvironmentalMonitoringSite \
	ExternalDataProcessingConfiguration \
	InternalDataProcessingConfiguration \
	StaticDeployment \
	TimeSeriesDataset

SAMPLES = \
	build/SITES.ttl \
	build/siteVariance.ttl \
	build/LAND_COVER_LCM_CLASSES.ttl \
	build/landCoverObservations.ttl \
	build/landCoverLcm.ttl \
	build/instrumentation_variables.ttl \
	build/STATISTICS.ttl

SCHEMAS = $(RECORDS:%=build/schema/%.schema.json)

CONTEXTS = $(RECORDS:%=build/context/%.context.jsonld)

REPORTS = $(SAMPLES:build/%.ttl=build/validation/%.ttl)

all: validate schemas contexts reports

pull:
	docker pull $(IMAGE)

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

build/schema/%.schema.json: $(SCHEMA_FILE) | build/schema
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

build/context/%.context.jsonld: $(SCHEMA_FILE) | build/context
	$(RUN) record-spec-cmd json-ld -r $(*F) -o $@ $^

build/fdri_shacl.ttl: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd shacl -o $@ $^

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

build/landCoverObservations.csv: src/LAND_COVER_OBSERVED.csv sql/landCoverObservations.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/landCoverObservations.sql"

build/siteVariance.csv: src/SITES.csv sql/siteLayout.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/siteLayout.sql"

build/landCoverLcm.csv: src/LAND_COVER_LCM.csv sql/landCoverLcm.sql | build
	$(RUN) /bin/bash -c "duckdb < sql/landCoverLcm.sql"

build/%.ttl: templates/namespaces.yaml templates/%.yaml src/%.csv | build
	$(RUN) mapper templates/$*.yaml src/$*.csv $@

build/%.ttl: templates/namespaces.yaml templates/%.yaml build/%.csv | build
	$(RUN) mapper templates/$*.yaml build/$*.csv $@

build/validation/%.ttl: build/%.ttl build/fdri_shacl.ttl  | build/validation
	$(RUN) /bin/bash -c "shacl v -d build/$*.ttl -s build/fdri_shacl.ttl > $@"
