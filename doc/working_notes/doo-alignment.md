# Notes on DOO ontology alignment

The following notes are based on a review of version 0.3.0 of DOO at https://nerc-ceh.github.io/digital-objects-ontology/

In the following document *DRI ontology* refers to the OWL ontology defined in this repository (currently named the FDRI ontology). *DRI schema* refers to the recordspec schema which defines a set of more prescriptive record types from the classes and properties of the DRI ontology. In general the DRI schema is used for validation whereas the DRI ontology is intended for semantic exchange.

## Agent

DOO imports prov:Agent and foaf:Agent but does not declare any equivalence between them. The current DRI ontology declares fdri:Agent as a subclass of both prov:Agent and foaf:Agent. DOO provides object properties to relate a foaf:Agent as a member of a foaf:Organisation and to a role held.

### Actions

At this stage it does not look like any action is needed. In future we may want to consider extending the DRI schema to allow the capture of the member relationships and roles held by agents.

## Environmental Monitoring Programme

Both the DRI Onotolgy and the DOO ontology define a `Environmental Monitoring Programme` class. Both ontologies define a `utilises` property with a domain of `Environmental Monitoring Programme` and a range of `Environmental Monitoring Facility or Environmental Monitoring Network`.

The DOO ontology adds `dct:hasPart` with a domain and range of `Environmental Monitoring Programme`.

The DRI ontology defines a property `initiated` which can be used to relate an `Environmental Monitoring Programme` to an `Environmental Monitoring Activity` carried out as part of that programme. The DOO ontology defines a semantically equivalent property `doo:triggers`.

### Actions

Make `fdri:EnvironmentalMonitoringProgramme` a subclass of `doo:EnvironmentalMonitoringProgramme` in the DRI ontology.

Replace `fdri:utilises` with `doo:utilises` in the DRI ontology and update the property URI in the DRI schema.

Replace `fdri:initiated` with `doo:triggers` in the DRI ontology and replace the `initiated` property with a new `triggers` property in the DRI schema.

Add a `hasPart` property to the DRI schema as an optional, repeatable property.

### Expected Impact

There will be an minor impact on downstream users due to the replacement of the `initiated` property in the schema with a `triggers` property. At present there are relatively few Environmental Monitoring Activities in the metadata store so impact will be limited.

Ingest templates and the Metadata API schema will need to be updated to use `doo:utilises` in place of `fdri:utilises`, and `doo:triggers` in place of `fdri:initiated`.

## Environmental Monitoring Activity

Both ontologies define an `Environmental Monitoring Activity` class. DOO defines no properties for this class.

### Actions

Make `fdri:EnvironmentalMonitoringActivity` a subclass of `doo:EnvironmentalMonitoringActivity` in the DRI ontology.

No changes are needed to the DRI schema.

### Expected Impact

There should be no impact from this change.

## Environmental Monitoring Facility

Both ontologies define an `Environmental Monitoring Facility` type with a semantically equivalent definition.

Both the DOO ontology and the DRI ontology define a `dct:hasPart` property to relate a parent facility to its child facilities.

Both ontologies use `dct:hasType` to relate a facility to a concept that defines the facility type. In the DOO ontology the range of this property is `skos:Concept` in the DRI ontology the range is `fdri:EnvironmentalMonitoringFacilityType` which is a subclass of `skos:Concept`.

The DOO ontology defines an equivalence between `doo:EnvironmentalMonitoringFacility` and `doo:EnvironmentalMonitoringFeature`. This latter is a subclass of `dcat:Resource`. In the DRI ontology, `fdri:EnvironmentalMonitoringFacility` is a subclass of `dcat:Resource` (which provides the `dct:type` and `dct:hasPart` properties as part of its constraints, as well as other useful properties such as `dct:identifier` used to capture facility identifiers).

### Actions

* Make `fdri:EnvironmentalMonitoringFacility` a subclass of `doo:EnvironmentalMonitoringFacility`. There should not be any inconsistency with the differing approaches to subclassing `dcat:Resource` so it is not necessary to change the inheritance hierarch of the FDRI ontology in this regard.

### Expected Impact

There should be no impact on the users of the metadata API.

There should be no impact on ingest templates or on the Metdata API endpoint and view definitions.

## Environmental Monitoring Network

Both ontologies define an `Environmmental Monitoring Network` type with a semantically equivalent definition.

The DOO ontology uses `doo:contains` to represent the relation between a network and the facilities that make up the network. The DRI ontology uses `fdri:contains` for the same purpose.

The DOO ontology uses `dct:hasPart` to relate networks in a parent/child hierarchy. There is no equivalent property in the DRI ontology.

### Actions

* Make `fdri:EnvironmentalMonitoringNetwork` a subclass of `doo:EnvironmentalMonitoringNetwork`.
* Use `doo:contains` to relate an `fdri:EnvironmentalMonitoringNetwork` to the `fdri:EnvironmentalMonitoringFacility` that it provides. Update the type of the `contains` property of the `EnvironmentalMonitoringNetwork` record in the DRI schema.
* Update the `fdri:contains` property to only apply to `fdri:GriddedContainer` and `fdri:GriddedDataset`, as this is a sematically distinct usage.
* Add a `hasPart` property to the schema for `EnvironmentalMonitoringNetwork` in the DRI schema as an optional repeatable property with a range of `EnvironmentalMonitoringNetwork`.

### Expected Impact

There should be no impact on users of the Metadata API as the record and property names remain unchanged.

The Metadata API and ingest templates will need to be updated to use `doo:contains` in place of `fdri:contains` on resources of type `fdri:EnvironmentalMonitoringNework`. Templates and views for `fdri:GriddedContainer` and `fdri:GriddedDataset` should not be changed.
