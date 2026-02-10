## High Level Catalog Structure

### Catalogued Items

In addition to `dcat:Dataset` and `dcat:DataService`, a subset of assets are also treated as catalog resources.
This allows a (possibly separate) cataloguing of assets such as sensors, systems (packages of sensors), platforms (e.g. vehicles, physical infrastructure on a site). Each catalogued resource has its own catalog record, which makes it possible to distinguish between activities which affect the thing from those which affect the recorded metadata about the thing.

For example an ingest process that reads a spreadsheet list of sensors would be an activity that generates/updates the *record* of the sensor; whereas an activity of maintaining a sensor would be an activity that updates the sensor itself.

> **NOTE**
> The scope of which assets are catalogued in this way is open to discussion.

```mermaid
classDiagram
direction LR
  class ProgrammeCatalog["fdri:ProgrammeCatalog"]
  class Catalog["dcat:Catalog"]
  class CatalogRecord["dcat:CatalogRecord"]
  class CatalogResource["dcat:CatalogResource"]
  class Facility["fdri:EnvironmentalMonitoringFacility"]
  class FacilityGroup["fdri:EnvironmentalMonitoringFacilityGroup"]
  class DataService["dcat:DataService"]
  class Dataset["dcat:Dataset"]
  class Agent["fdri:Agent"]
  class Activity["fdri:EnvironmentalMonitoringActivity"]
  class DataProcessingConfiguration["fdri:DataProcessingConfiguration"]
  class Procedure["fdri:Procedure"]

  ProgrammeCatalog--|> Catalog
  Catalog --|> CatalogResource
  Catalog --> CatalogRecord : dcat_record
  CatalogRecord --> CatalogResource: foaf_hasPrimaryTopic
  CatalogResource <|-- Agent
  CatalogResource <|-- DataProcessingConfiguration
  CatalogResource <|-- Dataset
  CatalogResource <|-- DataService
  CatalogResource <|-- Activity
  CatalogResource <|-- Facility
  CatalogResource <|-- FacilityGroup
  CatalogResource <|-- Procedure
```

The types shown in the diagram above are just the top-level elements of the model.
More detail about these types can be found in the following sections of this document.

* `dcat:Dataset` - dataset metadata
* `dcat:DataService` - APIs for accessing data and metadata
* `fdri:EnvironmentalMonitoringActivity` - an activity which makes observations about properties of some object in the environment. e.g. a survey of water quality
* `fdri:EnvironmentalMonitoringFacility` - a resource which facilitates the monitoring of some aspect of the environment. Refer to [Environmental Monitoring Facility Model](emf.md) for more information.
* `fdri:EnvironmentalMonitoringFacilityGroup` - a resource which defines a geo-spatial or administrative grouping of facilities. e.g. a catchment area.
* `fdri:Agent` - an actor which participates in activities to create, modify or use some other entities. Refer to [Provenance and Activity Model](provenance-and-activity.md) for more information.
* `fdri:Procedure` - a process that is applied to an `fdri:EnvironmentalMonitoringFaciltiy`. e.g. an installation procedure, calibration procedure or maintenance procedure.
* `fdri:DataProcessingConfigiuration` - (versioned) configuration data that applies to some portion of an FDRI data processing pipeline. See [Data Processing Configurations](data-processing-configurations.md) for more information.

### Concept Types and Concept Schemes

Reference data that is not covered by more domain-specific models (such as the EMF model) is modelled using concepts from SKOS, in particular `skos:Concept` and `skos:ConceptScheme`. We use specialisations of these two classes to denote specific types of concept and to use the model to define the appropriate place(s) where these concepts can be used.

The diagram below shows a simple example of this structure. The type `fdri:EnvironmentalMonitoringFacilityType` is a `skos:Concept` that is used specifically to defined classes of environmental monitoring facility. The concept scheme that contains these definitions is typed as an `fdri:EnvironmentalMonitoringFacilityTypeScheme` which is a `skos:ConceptScheme` restricted to containing only `fdri:EnvironmentalMonitoringFacilityType` concepts.

For the FDRI model, a `skos:ConceptScheme` is treated as a `dcat:Resource` in a `dcat:Catalog` which provides facilities for recording additional metadata about each concept scheme.

```mermaid
classDiagram
class Concept["skos:Concept"]
class ConceptScheme["skos:ConceptScheme"]
class Resource["dcat:Resource"]
class EMFacilityType["fdri:EnvironmentalMonitoringFacilityType"]
class EMFacilityTypeScheme["fdri:EnvironmentalMonitoringFacilityTypeScheme"]
Resource <|-- ConceptScheme
Concept <|-- EMFacilityType
ConceptScheme <|-- EMFacilityTypeScheme
EMFacilityType --> EMFacilityTypeScheme: skos_inScheme
```

The following table lists the subclasses of `skos:Concept` which are defined in the FDRI model.

| Concept Type | Concept Usage |
|--------------|---------------|
| `fdri:ActivityType` | The class of a `prov:Activity` or `fdri:EnvironmentalMonitoringActivity`. e.g. "flowstick survey"
| `fdri:Aggregation` | A statistical aggregation applied to a set of values to produce a single value result. e.g. "minimum"
| `fdri:ConfigurationParameter` | A parameter that may be passed to an `fdri:DataProcessingMethod` as part of a data processing configuration. See [Data Processing Configurations](data-processing-configurations.md).
| `fdri:ConfigurationProperty` | A property of an environmental monitoring system which can be configured with different values (e.g. installed firmware version) |
| `fdri:DataProcessingConfigurationType` | A type of data processing configuration. e.g. "QC Configuration" |
| `fdri:DataProcessingMethod` | A data processing method or procedure that may be invoked as part of a data processing configuration. |
| `iop:Entity` | An object or process that has a role in an observation. |
| `fdri:EnvironmentalDomain` | The domain of the environment that an `EnvironmentalMonitoringFacility` monitors. |
| `fdri:EnvironmentalMonitoringFacilityType` | The class of an `EnvironmentalMonitoringFacility`. Direct instances of this class are intended to apply to `EnvironmentalMonitoringSite` and `EnvironmentalMonitoringPlatform`. |
| `fdri:EnvironmentalMonitoringSystemType` | The class of an `EnvironmentalMonitoringSystem`. This is defined as a subclass of `EnvironmentalMonitoringFacilityType` but is intended to capture sensor package types, broad categories of sensor and individual sensor models. |
| `fdri:FacilityGroupType` | The type or nature of a grouping of environmental monitoring facilities. e.g. "Catchment" |
| `fdri:FacilityUsageRole` | The way in which an `fdri:EnvironmentalMonitoringFacility` is used in an `fdri:EnvironmentalMonitoringActivity` - e.g. "measuring sensor", "vehicle" |
| `fdri:Measure` | The measurement of an `fdri:Variable` using a specified unit of measure, and optionally with aggregation of the observed values over some specified period of time. |
| `fdri:ProcedureType` | The category of process that is applied to or carried out on an `EnvironmentalMonitoringSystem` (e.g. installation, calibration) |
| `fdri:ProcessingLevel` | The level of processing applied to the measurements in an `ObservationDataset` |
| `iop:Property` | A type of a characteristic of an `iop:ObjectOfInterest` |
| `fdri:RelatedPartyRole` | The role that some agent (and individual or organisation) plays in relation to an `EnvironmentalMonitoringFacility`. |
| `fdri:SoilType` | The category of soil type at an `EnvironmentalMonitoringSite` |
| `fdri:SystemStatus` | The operational status of an `EnvironmentalMonitoringSystem` |
| `fdri:Unit` | A unit of measure. |
| `fdir:ValueStatistic` | The category of aggregation applied to a set of values in order to produce an aggregate dataset e.g. mean, min, max etc. |
| `fdri:Variable` | A faceted type describing the properties of some `EnvironmentalDomain` which can be observed by an `EnvironmentalMonitoringSystem`. |

> **NOTE**
> There are still a number of classes where instances are used as reference data that are currently neither a `dcat:Resource` nor a `skos:Concept`. Do we need to partition these remaining classes along these lines?
> * fdri:EnvironmentalMonitoringProgramme
> * fdri:GeospatialFeatureOfInterest

### Basic Dataset Metadata

Core dataset metadata is modelled using concepts from DCAT with some extensions to capture FDRI-specific dataset types. The base type for these datasets is `fdri:ObservationDataset` which extends the DCAT definition with properties to capture metadata about the observable properties recorded in the dataset, the feature(s) of interest that the observations relate to etc. The type `fdri:TimeSeriesDataset` is specifically intended for datasets that capture a single measure over time for a single feature of interest. The type `fdri:GriddedDataset` provides additional metadata for navigating datasets that are constructed with a multi-dimensional array structure such as netCDF and zarr. For more information about these specific subclasses please refer to [Time-Series Datasets](time-series-dataset.md) and [Gridded Data]("gridded-data.md")

Quality metrics over datasets are modelled as `sosa:Observation` instances with a `sosa:hasFeatureOfInterest` of the `dcat:Dataset`. This means that quality metric definitions can be managed as a subset of the observed properties for FDRI. Metrics that cover a time slice of the dataset (e.g. daily data availability metrics) can be modelled as `sosa:Observation` with a `sosa:phenomenonTime` specified as a `time:Interval` which defines the bounds of the slice.

Related datasets are gathered together using the DCAT `fdri:ObservationDatasetSeries` type to represent the group of datasets and the `dcat:inSeries` relation to relate a dataset to the series that it is a part of. A dataset may be in multiple series - e.g. a time-series of air temperature measurements from an FDRI weather station may be a member of a series of all measurements from that station (which may in turn be a member of a series of all measurements from the site), and may also be a member of a series of all air temperature time series from all stations in the FDRI network. Dataset series should be soft-typed with `dct:type` using a taxonomy of series types to be defined by the project to make it easy to distinguish between different types of dataset series (e.g. StationDatasetSeries, SiteDatasetSeries, NetworkDatasetSeries, NetworkVariableDatasetSeries). 

The property `fdri:originatingFacility` can be used to reference the `EnvironmentalMonitoringFacility` from which observations contained in the dataset have come. The choice of facility should be a facility  permanently associated with the observations in the dataset, so prefer the site at which the sensor equipment is located over sensors or packages which may be replaced without starting a new dataset. This property may also be used with `fdri:ObservationDatasetSeries` in which case the referenced facility should be the `EnvironmentalMonitoringSite` for a series soft-typed as `SiteDatasetSeries`, or the `EnvironmentalMonitoringStation` for series soft-typed as `StationDatasetSeries`.

The property `fdri:originatingProgramme` can be used to reference the `EnvironmentalMonitoringProgramme` from which observations contained in the dataset have come. This provides a more direct way to group datasets from the same programme than going via the `fdri:ProgrammeCatalog`

> **NOTE**
> The use of dataset-level quality metric observations can be reserved for aggregate metrics such as data availability metrics. Row-level metrics could (and arguably should) be managed in the underlying data store.

```mermaid
---
  config:
    class:
      hideEmptyMembersBox: true
---
  classDiagram
  direction LR
  class CatalogResource["dcat:CatalogResource"]
  class Concept["skos:Concept"]
  class ConceptScheme["skos:ConceptScheme"]
  class ObservedProperty["iop:Variable"]
  class Measure["fdri:Measure"]
  class Program["fdri:EnvironmentalMonitoringProgramme"]
  class Facility["fdri:EnvironmentalMonitoringFacility"]
  class Site["fdri:EnvironmentalMonitoringSite"]
  class Activity["fdri:EnvironmentalMonitoringActivity"]
  class Agent["fdri:Agent"]
  class GeospatialFeatureOfInterest["frdi:GeospatialFeatureOfInterest"]
  class QualityObservation["fdri:QualityObservation"]
  class Dataset["dcat:Dataset"]
  class ObservationDataset["fdri:ObservationDataset"]
  class ObservationDatasetSeries["fdri:ObservationDatasetSeries"]
  class GriddedDataset["fdri:GriddedDataset"]
  class TimeSeriesDataset["fdri:TimeSeriesDataset"]
  class DatasetSeries["dcat:DatasetSeries"]
  class ProcessingLevel["fdri:ProcessingLevel"]
  class Dataset {
    dct_accrualPeriodicity: dcterms:Frequency
    dct_temporal: dct:PeriodOfTime
    dct_temporalResolution: xsd:duration
  }
  class CatalogResource {
    dct:title: rdf:langString
    dct:description: rdf:langString

    dct:accessRights: dct:RightsStatement
    dct:license: dct:LicenseDocument
    dct:rights dct:RightsStatement

    dct:conformsTo: dct:Standard
    dct:contactPoint: vcard:Kind
    dct:issued: xsd:dateTime
    dct:modified: xsd:dateTime
    dct:language: xsd:anyURI
    dct:identifier: rdfs:Literal

    dct:version: rdfs:Literal
    adms:versionNotes: rdfs:Literal
  }

  CatalogResource <|-- Dataset
  Concept --> ConceptScheme: skos_inScheme
  Concept <|-- ProcessingLevel
  ObservationDataset --> GeospatialFeatureOfInterest : dct_spatial
  Dataset <|-- ObservationDataset
  DatasetSeries <|-- ObservationDatasetSeries
  ObservationDataset <|-- ObservationDatasetSeries
  ObservationDataset <|-- TimeSeriesDataset
  ObservationDataset <|-- GriddedDataset
  CatalogResource --> Concept: dct_theme
  ObservationDataset --> ObservedProperty: sosa_observedProperty
  ObservationDataset --> Measure: fdri_measure
  ObservationDataset --> Activity: fdri_originatingActivity
  ObservationDataset --> Facility: fdri_originatingFacility
  ObservationDataset --> Site: fdri_originatingSite
  ObservationDataset --> Program: fdri_originatingProgramme
  ObservationDataset --> ProcessingLevel: processingLevel
  CatalogResource --> Agent: dct_creator
  CatalogResource --> Agent: dct_publisher
  DatasetSeries --|> Dataset
  Dataset --> DatasetSeries: dcat_inSeries
  CatalogResource --> Concept: dct_type
  QualityObservation --|> Observation
  QualityObservation --> Dataset: sosa_hasFeatureOfInterest
```

> **QUESTION**
> Do we need a cleaner separation between geospatial regions/points and abstract features of interest.

> **QUESTION**
> Given the grouping by programme provided here and the current approach to reference data involves programmes sharing a common set of reference data, is the notion of a `ProgrammeCatalog` obsolete? Should we instead just have one catalog of all dataset records regardless of source programme?
