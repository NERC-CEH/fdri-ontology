RECORD-SPEC=uv run record-spec

SCHEMA_BASE = samples/schema
CONTEXT_BASE = samples/context
SCHEMA_FILE = schema/fdri.recordspec.yaml

RECORDS = \
	Activity \
	Aggregation \
	ConfigurationItem \
	Condition \
	Dataset \
	Deployment \
	DigitalDocument \
	EnvironmentalMonitoringActivity \
	EnvironmentalMonitoringPlatform \
	EnvironmentalMonitoringSensor \
	EnvironmentalMonitoringSite \
	EnvironmentalMonitoringSystemType \
	ExternalDataProcessingConfiguration \
	GeospatialFeatureOfInterest \
	InternalDataProcessingConfiguration \
	Measure \
	ObservationDataset \
	OperatingRange \
	Procedure \
	StaticDeployment \
	SurvivalRange \
	SystemCapability \
	SystemProperty \
	TimeSeriesDataset \
	TimeSeriesDefinition \
	Variable

SCHEMAS = $(RECORDS:%=$(SCHEMA_BASE)/%.schema.json)
CONTEXTS = $(RECORDS:%=$(CONTEXT_BASE)/%.context.jsonld)

SCHEMAS_DIST=$(RECORDS:%=build/schema/%.schema.json)
CONTEXTS_DIST=$(RECORDS:%=build/context/%.context.jsonld)

all: validate schemas contexts modelspec rdfs

pull:
	docker pull $(IMAGE)

dist: validate doc schemas contexts modelspec
	mkdir -p build/schema
	cp doc/html/* build
	cp -R samples/* build
	cp schema/fdri.recordspec.yaml build/schema

doc: doc/html/index.html
modelspec: build/fdri.modelspec.yaml
rdfs: build/fdri-metadata.rdfs.ttl
release: build/release/doc.tar.gz build/release/fdri.recordspec.yaml build/release/fdri.modelspec.yaml build/release/fdri-metadata.ttl build/release/CHANGELOG.txt
schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)
full_validation: $(VAL)/full_report.ttl

validate: $(SCHEMA_FILE)
	$(RECORD-SPEC) validate $^

$(SCHEMA_BASE)/%.schema.json: $(SCHEMA_FILE) | $(SCHEMA_BASE)
	$(RECORD-SPEC) json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

$(CONTEXT_BASE)/%.context.jsonld: $(SCHEMA_FILE) | $(CONTEXT_BASE)
	$(RECORD-SPEC) json-ld -r $(*F) -o $@ $^

$(SHACL_BASE)/fdri_shacl.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RECORD-SPEC) shacl -o $@ $^

$(SHACL_BASE)/fdri_shacl_with_refs.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RECORD-SPEC) shacl --with-reference-type-validation -o $@ $^

clean:
	rm -f $(SCHEMA_BASE)/*.schema.json
	rm -f $(SCHEMA_BASE)/*.context.jsonld
	rm -rf build

build:
	mkdir -p build

doc/html/index.html: doc/*.md owl/fdri-metadata.ttl
	uv run make_doc.py

$(SCHEMA_BASE):
	mkdir -p $(SCHEMA_BASE)

$(CONTEXT_BASE):
	mkdir -p $(CONTEXT_BASE)

build/shacl:
	mkdir -p build/shacl

build/data:
	mkdir -p build/data

build/release/doc.tar.gz: doc/html/index.html
	mkdir -p build/release/doc
	cp doc/html/* build/release/doc
	tar -C build/release/doc -zcf build/release/doc.tar.gz .

build/release/CHANGELOG.txt: CHANGELOG.txt
	mkdir -p build/release
	cp $^ build/release

build/release/fdri.recordspec.yaml: schema/fdri.recordspec.yaml
	mkdir -p build/release
	cp $^ build/release

build/fdri.modelspec.yaml: schema/fdri.recordspec.yaml | build
	$(RECORD-SPEC) model-spec $^ -f yaml -o $@

build/release/fdri.modelspec.yaml: build/fdri.modelspec.yaml
	mkdir -p build/release
	cp $^ build/release

build/release/fdri-metadata.ttl: owl/fdri-metadata.ttl
	mkdir -p build/release
	cp $^ build/release

build/fdri-metadata.rdfs.ttl: schema/fdri.recordspec.yaml
	mkdir -p build
	$(RECORD-SPEC) rdfs -f yaml -o $@ $^