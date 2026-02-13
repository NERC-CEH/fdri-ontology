# Identifier Patterns

In RDF most entities are assigned an IRI identifier. This identifier *may* be resolvable to retrieve a description of the identified thing (in RDF or in a human-readable format such as HTML). This Linked Data approach is supported by a number of tools including Epimorphics' SAPI-NT tool which is currently used to deliver the FDRI Metadata API.

When publishing RDF resources as linked data, it is helpful to partition the possible set of addresses between the different classes of thing that exist in the model.

This section outlines the proposed patterns for IRI identifiers for resources that are created and managed by the FDRI Metadata Store.

## Top Level Namespaces

The top level namespace for the FDRI Metadata Store shall be `http://fdri.ceh.ac.uk/`.

> [!TODO]
> Confirm that this is the accepted top level identifier namespace. This is primarily important if the content of the FDRI Metadata Store is to be made accessible as Linked Data. It may be that a different domain is preferred (e.g. http://metadata.fdri.ceh.ac.uk/) or that the metadata should use a path under the top level domain as its root (e.g. http://fdri.ceh.ac.uk/metadata/).

Underneath that namespace we define two distinct sub-namespaces

`ref/` shall be used for the management of reference data.
`id/` shall be used for the management of all other data.

## Identifier Patterns for Reference Data

For concept schemes that are managed within the Metadata store, the identifier for a concept scheme will be `/ref/{scheme id}`, and the identifier for a concept will be `/ref/{scheme id}/{concept id}`.

> [!NOTE]
> This is a change from identifiers used in the currently deployed data which included a path element for the network to which the concepts belonged. In practice we have ended up using `common` as the network as the goal is to have a unified set of reference data across all networks. Given this aim, it then becomes redundant to include `/common/` in all of the IRIs.

Although in the initial phase of development, all concept schemes have been managed in the Metadata store, it is expected that a number of the schemes listed below may migrate to being managed under a system external to the Metadata Store and so may use a different IRI identifier scheme.

The table below lists all of the current concept and concept scheme types and the identifier patterns used for managing the scheme and its concepts in the Metadata Store.

The following table lists the concept schemes that the metadata model makes use of.

| Concept Scheme | Scheme Class | Concept Class | Identifier Root |
| --- | --- | --- | --- |
| Activity Types | fdri:ActivityTypeScheme | fdri:ActivityType | /ref/activity-type |
| Aggregations | fdri:AggregationScheme | fdri:Aggregation | /ref/aggregation |
| Method Parameters | fdri:ConfigurationParameterScheme | fdri:ConfigurationParameter | /ref/parameter |
| Configuration Properties | fdri:ConfigurationPropertyScheme | fdri:ConfigurationProperty | /ref/configuration-property
| Configuration Type | fdri:DataProcessingConfigurationTypeScheme | fdri:DataProcessingConfigurationType | /ref/configuration-type |
| Constraints | fdri:ConstraintScheme | iop:Constraint | /ref/constraint |
| Entities | fdri:EntityScheme | iop:Entity | /ref/entity |
| Environmental Domains | fdri:EnvironmentalDomainScheme | fdri:EnvironmentalDomain | /ref/environmental-domain |
| Facility Group Types | fdri:FacilityGroupTypeScheme | fdri:FacilityGroupType | /ref/facility-group-type |
| Facility Type | fdri:EnvironmentalMonitoringFacilityTypeScheme | fdri:EnvironmentalMonitoringFacilityType | /ref/facility-type |
| Measures | fdri:MeasureScheme | fdri:Measure | /ref/measure |
| Procedure Type | fdri:ProcedureTypeScheme | fdri:ProcedureType | /ref/procedure-type |
| Processing Levels | fdri:ProcessingLevelScheme | fdri:ProcessingLevel | /ref/processing-level |
| Processing Methods | fdri:DataProcessingMethodScheme | fdri:DataProcessingMethod | /ref/method
| Properties | fdri:PropertyScheme | iop:Property | /ref/property |
| Related Party Roles | fdri:RelatedPartyRoleScheme | fdri:RelatedPartyRole | /ref/related-party-role |
| Soil Types | fdri:SoilTypeScheme | fdri:SoilType | /ref/soil-type |
| Value Statistics | fdri:ValueStatisticScheme | fdri:ValueStatistic | /ref/statistic |
| System Statuses | fdri:SystemStatusScheme | fdri:SystemStatus | /ref/system-status |
| Units of Measure | fdri:UnitScheme | fdri:Unit | /ref/unit |
| Usage Roles | fdri:FacilityUsageRoleScheme | fdri:FacilityUsageRole | /ref/usage-role |
| Variables | fdri:VariableScheme | fdri:Variable | /ref/variable |

## Identifier Patterns for non-reference data

The following table lists the identifier patterns used for RDF resources that do not represent reference data or reference data concept schemes.

In a number of cases, resources of several different types may use the same identifier pattern. The types are generally related either through a subclass relationship between them or by sharing a common super-class.

In the table that follows, the identifier patters all take the form `/id/CAETGORY/{id}`. The `{id}` portion is the contextually unique identifier assigned to each resource. These identifiers should conform to the IRI production for a single path segment without any fragment identifier.

There is a special category of resources which share the `{parent}#{id}` pattern. This is used for resources that are considered to be "nested" inside their parent resource. The actual identifier would be created by concatenating the URI of the parent resource with either `#{id}` or `.{id}` - the latter being used if the parent resource itself already includes an IRI fragment (`#`).

> [!NOTE]
> These "nested" resources could also be represented in RDF as blank nodes. That is nodes that have no assigned IRI. However blank nodes are difficult to manage as their lack of identity makes it hard to update or retract statements that use them. For this reason we moved from using blank nodes in the ingestion process to using IRIs with fragment identifiers for these nested resources.

A few classes are identified as having no identifier pattern. This is reserved for classes that appear in the class hierarchy but which only serve as super-classes and which are not expected to be directly instantiated in the data.

> [!NOTE]
> The proposed identifier patterns below are not entirely the same as those currently used in the deployed metadata. Moving over to supporting this identifier scheme may result in some downstream impacts on the data processing code, but once adopted it is anticipated that future changes should only be to extend this scheme, or to remove patterns for obsoleted classes.

| Identifier Pattern | Class(es) using pattern |
| --- | --- |
| /id/activity/{id} | prov:Activity |
| /id/agent/{id} | fdri:Agent, fdri:Organization, fdri:Person , fdri:SoftwareAgent |
| /id/argument/{id} | fdri:ConfigurationArgument |
| /id/catalog/{id} | fdri:ProgrammeCatalog |
| /id/condition/{id} | fdri:Condition |
| /id/configuration-item/{id} | fdri:ConfigurationItem |
| /id/dataset/{id} | dcat:Dataset, fdri:GriddedDataset, fdri:ObservationDataset, fdri:ObservationDatasetSeries, fdri:TimeSeriesDataset |
| /id/deployment/{id} | fdri:Deployment, fdri:StaticDeployment |
| /id/distribution/{id} | dcat:Distribution, schema:MediaObject |
| /id/document/{id} | schema:DigitalDocument |
| /id/facility-group/{id} | fdri:FacilityGroup |
| /id/facility/{id} | fdri:EnvironmentalMonitoringFacility, fdri:EnvironmentalMonitoringPlatform |
| /id/fault/{id} | fdri:Fault |
| /id/feature/{id} | sosa:FeatureOfInterest, fdri:GeospatialFeatureOfInterest |
| /id/membership/{id} | fdri:FacilityGroupMembership |
| /id/monitoring-activity/{id} | fdri:EnvironmentalMonitoringActivity |
| /id/network/{id} | fdri:EnvironmentalMonitoringNetwork |
| /id/plan/{id} | fdri:DataProcessingConfiguration, fdri:ExternalDataProcessingConfiguration, fdri:InternalDataProcessingConfiguration, prov:Plan, fdri:Procedure, fdri:TimeSeriesPlan |
| /id/programme/{id} | fdri:EnvironmentalMonitoringProgramme |
| /id/site/{id} | fdri:EnvironmentalMonitoringSite |
| /id/system/{id} | fdri:EnvironmentalMonitoringSensor, fdri:EnvironmentalMonitoringSystem |
| /id/usage/{id} | fdri:FacilityUsage |
| /id/value-series/{id} | fdri:ConfigurationValueSeries, fdri:PropertyValueSeries |
| {parent}#{id} | fdri:Annotation, fdri:Array, fdri:CalibrationMethod, fdri:CalibrationValueSeries, fdri:ConfigurationArgumentList, fdri:Dimension, geos:Geometry, fdri:GriddedArrayItem, fdri:GriddedContainer, fdri:OperatingRange, dct:PeriodOfTime, schema:PropertyValue, prov:Association, prov:Usage, fdri:RelatedPartyAssociation, fdri:RelatedPartyAttribution, fdri:RelativeLocation, fdri:SurvivalRange, sys:SystemCapability, fdri:SystemProperty, fdri:TimeBoundPropertyValue |
| *No Identifier Pattern* | fdri:IndexedItem, owl:Thing, fdri:TimeSeriesDefinition |
