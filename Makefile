IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run --rm -v .:/data ${IMAGE}

SCHEMA_BASE = samples/schema
CONTEXT_BASE = samples/context
SCHEMA_FILE = schema/fdri.recordspec.yaml

RECORDS = \
	Variable \
	Activity \
	GeospatialFeatureOfInterest \
	EnvironmentalMonitoringPlatform \
	EnvironmentalMonitoringSensor \
	EnvironmentalMonitoringSite \
	ExternalDataProcessingConfiguration \
	InternalDataProcessingConfiguration \
	ConfigurationItem \
	StaticDeployment \
	TimeSeriesDataset \
	TimeSeriesDefinition \
	Measure

SCHEMAS = $(RECORDS:%=$(SCHEMA_BASE)/%.schema.json)
CONTEXTS = $(RECORDS:%=$(CONTEXT_BASE)/%.context.jsonld)

SCHEMAS_DIST=$(RECORDS:%=build/schema/%.schema.json)
CONTEXTS_DIST=$(RECORDS:%=build/context/%.context.jsonld)

all: validate schemas contexts

pull:
	docker pull $(IMAGE)

dist: validate doc schemas contexts
	mkdir -p build/schema
	cp doc/html/* build
	cp -R samples/* build
	cp schema/fdri.recordspec.yaml build/schema

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)
full_validation: $(VAL)/full_report.ttl

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

$(SCHEMA_BASE)/%.schema.json: $(SCHEMA_FILE) | $(SCHEMA_BASE)
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

$(CONTEXT_BASE)/%.context.jsonld: $(SCHEMA_FILE) | $(CONTEXT_BASE)
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

doc:
	python make_doc.py

$(SCHEMA_BASE):
	mkdir -p $(SCHEMA_BASE)

$(CONTEXT_BASE):
	mkdir -p $(CONTEXT_BASE)

build/shacl:
	mkdir -p build/shacl

build/data:
	mkdir -p build/data

