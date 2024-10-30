IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
CMD=docker run -v .:/data -it ${IMAGE} record-spec-cmd

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

SCHEMAS = $(RECORDS:%=$(SCHEMA_BASE)/%.schema.json)

CONTEXTS = $(SCHEMAS:.schema.json=.context.jsonld)

all: validate schemas contexts

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)

validate: $(SCHEMA_FILE)
	$(CMD) validate $^

%.schema.json: $(SCHEMA_FILE)
	$(CMD) json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

%.context.jsonld: $(SCHEMA_FILE) 
	$(CMD) json-ld -r $(*F) -o $@ $^


clean:
	rm -f $(SCHEMA_BASE)/*.schema.json
	rm -f $(SCHEMA_BASE)/*.context.jsonld