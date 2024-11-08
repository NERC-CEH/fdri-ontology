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
	StaticDeployment \
	TimeSeriesDataset

SAMPLES = \
	build/sites.ttl \
	build/siteVariance.ttl \
	build/LAND_COVER_LCM_CLASSES.ttl

SCHEMAS = $(RECORDS:%=$(SCHEMA_BASE)/%.schema.json)

CONTEXTS = $(SCHEMAS:.schema.json=.context.jsonld)

all: validate schemas contexts samples

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

%.schema.json: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

%.context.jsonld: $(SCHEMA_FILE) 
	$(RUN) record-spec-cmd json-ld -r $(*F) -o $@ $^

clean:
	rm -f $(SCHEMA_BASE)/*.schema.json
	rm -f $(SCHEMA_BASE)/*.context.jsonld
	rm -f build/*

build:
	mkdir -p build

build/siteVariance.csv: src/SITES.csv sql/siteLayout.sql build
	$(RUN) /bin/bash -c "duckdb < sql/siteLayout.sql"

build/sites.ttl: src/SITES.csv templates/sites.yaml templates/namespaces.yaml build
	$(RUN) mapper templates/sites.yaml src/SITES.csv $@

build/siteVariance.ttl: templates/siteVariance.yaml templates/namespaces.yaml build/siteVariance.csv build
	$(RUN) mapper templates/siteVariance.yaml build/siteVariance.csv $@

build/%.ttl: build templates/namespaces.yaml templates/%.yaml src/%.csv
	$(RUN) mapper templates/$*.yaml src/$*.csv $@
