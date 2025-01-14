# OGC SensorThings API Specification and FDRI Model

## Introduction

This section discusses how the FDRI model might be aligned with the data model proposed by the [OGC SensorThings API Part 1: Sensing Version 1.1](http://www.opengis.net/doc/is/sensorthings/1.1).

The SensorThings API specificiation is divided into two parts. Part 1 covers Sensing, Part 2 covers Tasking. The Sensing part is intended to address managing and retrieving observations and metadata from heterogeneous IoT sensor systems, and so is the part which FDRI might most simply align. In the following discussion, a reference to "SensorThings" or the "SensorThings API" should be taken to refer specifically to the Sensing part of the SensorThings API specification. 

## Type Mappings

![Sensor Things Entity Types diagram](sensor-things-types.png)

The diagram above shows the 9 types of entity defined by SensorThings.

### Datastream

The SensorThings `Datastream` has a partial mapping to the FDRI `TimeSeriesDataset` class. The mapping is partial because the modelling of the SensorThings `Datastream` assumes that a `Datastream` is the result of observations from a single sensor, whereas the FDRI model makes no such assumption and the relation between an FDRI `TimeSeriesDataset` and the sensor (or sensors) which produced the observations contained in the dataset is indirect. Thus an accurate mapping will only be possible for `TimeSeriesDataset` instances which are restricted to observations of a single property of a single feature of interest made by a single sensor.

**Property Mappings**

name
: Maps to `dct:title` - SensorThings allows only a single value, FDRI allows multiple language tagged strings.

description
: Maps to `dct:description` -  SensorThings allows only a single value, FDRI allows multiple language tagged strings.

observationType
: There is no direct equivalent to this property in FDRI. A default of `OM_Observation` could be used, or an additional mapping property could be added to the FDRI `Variable` type to allow the value type to be specified using the same controlled vocabulary as SensorThings (O&M conceptual model)

unitOfMeasurement
: This is a structured value in SensorThings. The fields of the structure can be mapped to subproperties of an FDRI Variable as follows:
  * name - maps to the SKOS prefLabel of the unit of the FDRI Variable
  * symbol - maps to the unitName of the FDRI Variable
  * definition - maps to the IRI identifier of the FDRI Variable

observedArea
: This property can be mapped if either the dct:spatial property, or the sosa:hasFeatureOfInterest property of the FDRI TimeSeriesDataset has at least one boundary geometry. The SensorThings API uses GeoJSON as the format for the boundary information which may require some translation from the WKT format preferred in FDRI.

phenomenonTime
: This property does not have a direct mapping in the current FDRI model.

resultTime
: This property can be mapped to the dct:temporal property of the FDRI TimeSeriesDataset.

**Relationship Mappings**

sensor
: The SensorThings API makes an assumption that a Datastream contains results from only a single sensor. This is not a constraint in the FDRI model and so it may not be possible to accurately map sensor relations. Under the current FDRI model one must traverse the SPARQL property path `fdri:originatingFacility/^ssn:deployedOnPlatform/ssn:deployedSystem` from the FDRI TimeSeriesDataset and filter to include only those `fdri:EnvironmentalMonitoringSystem`s where the `sosa:observes` property is the Variable as is captured by the Datastream. In programme data such as COSMOS where a TimeSeriesDataset is site-specific and not sensor-specific, there may be multiple sensors that match this filter, the API mapping could choose to return only the currently deployed sensor in this case.

observedProperty
: This relation maps to the `sosa:observedProperty` property of the FDRI TimeSeriesDataset

observations
: This relationship has no mapping as FDRI does not manage observation data or row-level metadata on observations.

thing
: In the SensorThings API this relation is to a Thing in an IOT network. In the FDRI model this could be considered to be the EnvironmentalMonitoringFacility from which the TimeSeriesDataset originates. If this interpretation holds, then this relationship maps to the property `fdri:originatingFacility` on the FDRI TimeSeriesDataset.

### Thing

In the SensorThings API the "Thing" is the physical element of the IOT infrastructure that holds one or more sensors. This maps to the FDRI concept of the EnvironmentalMonitoringFaciltiy and in particular to the sub-classes of EnvironmentalMonitoringSite and EnvironmentalMonitoringPlatform.

**Property Mappings**

name
: Maps to the `rdfs:label` property

description
: Maps to the `rdf:comment` property


**Relationship Mappings**

Location
: Maps to the geos:hasGeometry property. For a mobile facility there may be no meaningful value to record.

HistoricalLocation
: Under the interpretation of a Thing as an EnvironmentalMonitoringFacility there is currently no equivalent to this property. This property may be used when considering drone / UAV data.

Datastream
: Maps to those TimeSeriesDatasets with an `fdri:originatingFacility` of this facility or one of its parts. 

### Location

**Property Mappings**
name
: maps to the rdfs:label of the FDRI class that is mapped to the Thing that has this location

description
: maps to the rdf:comment of the FDRI class that is mapped to the Thing that has this location

encodingType
: to align with SensorThings, this should map to GeoJSON (application/geo+json)

location
: maps to the geos:hasGeometry/geos:asWKT property converted to a GeoJSON object.

**NOTE** As an alternative to mapping WKT strings to GeoJSON, the API mapping could depart from the OGC specification and use WKT as the encoding type.

**Relationship Mappings**
things
: Maps back to the EnvironmentalMonitoringFacility instance that has this location.

### Sensor

Sensor maps to the FDRI EnvironmentalMonitoringSystem type (and its sub-class EnvironmentalMonitoringSensor). 

**NOTE** The SensorThings API requires that all sensors are associated with a detailed description in the form of a datasheet or SensorML metadata block. This is not a requirement in the FDRI model and so such mappings may only be partial if we are to stick to this requirement. Alternatively we could treat the FDRI EnvironmentalMonitoringSystem resources itself as the primary source of sensor metadata.

**Property Mapping**

name
: maps to the rdfs:label of the EnvironmentalMonitoringSystem
description
: maps to the rdf:comment of the EnvironmentalMonitoringSystem
encodingType
: FDRI
metadata
: The IRI of the EnvironmentalMonnitoringSystem resource

**Relationship Mapping**

Datastream
: The Datastreams mapped from the TimeSeriesDataset(s) with an fdri:originatingFacility which hosts a (current) deployment of this EnvironmentalMonitoringSystem

### ObservedProperty

ObservedProperty maps to Variable in the FDRI model.

**Property Mapping**

name
: maps to the skos:prefLabel of the Variable

description
: maps to the skos:scopNote of the Variable (if any), otherwise the skos:prefLabel of the Variable

definition
: the IRI of the Variable resource

**Relationship mapping**

Datastream
: The Datastreams mapped from those TimeSeriesDataset(s) with a sosa:observedProperty of this Variable.

### HistoricalLocation

This entity is not mapped to any FDRI class and is unused under the FDRI to SensorThibgs mapping

### Observation

This entity is not mapped to any FDRI class as the FDRI data model does not cover row-level observation metadata.

### FeatureOfInterest

This entity is not mapped to any FDRI class as it is only used in relation to the unmapped Observation class.