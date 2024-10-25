## Deployments

Deployments are used when a system (a sensor or package of sensors) is deployed in the field. 
  * A `MobileDeployment` is a deployment of a system on a platform that moves along a track recorded by a track log.
  * A `StaticDeployment` is a deployment of a system at a fixed location, optionally at some height above or depth below local ground level. The fixed location may be specified either by its own geometry or relative to the geometry of the platform or site at which it is deployed.

Deployments are modelled as a sub-class of `prov:Activity` and can be given time bounds using `prov:startedAt` and `prov:endedAt`, and a location using `prov:atLocation`. 
```mermaid
classDiagram
  direction TB
  class EMPlatform["fdri:EnvironmentalMonitoringPlatform"]
  class EMSystem["fdri:EnvironmentalMonitoringSystem"]
  class EMSite["fdri:EnvironmentalMonitoringSite"]
  class Activity["prov:Activity"] {
    startedAtTime: xsd_dateTime
    endedAtTime: xsd_dateTime
  }
  class Deployment["ssn:Deployment"]
  class EMDeployment["fdri:Deployment"]
  class EMDeployment {
    dataloggerPort: xsd_string
  }
  Activity <|-- Deployment
  Deployment <|-- EMDeployment

  EMDeployment --> EMPlatform: ssn_deployedOnPlatform
  EMDeployment --> EMSystem: ssn_deployedSystem
  EMPlatform --> EMSite: fdri_atSite
```

> **TODO**
> Clarify the notion of relative site location of sensors.
> Are individual sensors that are all attached to the same station positioned at different locations (and are those positions recorded?)
> When a station / sensor is given a relative location, exactly what is that relative to? Do we need to require an "origin" property for `EnvironmentalMonitoringSite` and/or `EnvironmentalMonitoringStation` (or indeed just on any `EnvironmentalMonitoringFacility`)?

> **QUESTION**
> Are deployments equivalent to EMF Activities? If so, do we want to include that notion in the model at all?

### Static Deployments

The class `fdri:StaticDeployment`is used to represent the deployment of a sensor or a package of sensors to a static platform such as a weather station at a monitoring site. The class carries additional properties `deployedHeight` and `deployedDepth` to capture the height above or below the ground where the sensor or sensor package was deployed.

The precise location of a static deployment may be captured either as an absolute location encapsulated as a `geos:Feature` resource, or as a location relative to an origin point defined by the `fdri:EnvironmentalMonitoringPlatform` that the deployment is on.

```mermaid
classDiagram
  class Deployment["fdri:Deployment"] {
    fdri:deploymentVariance: xsd_string
  }
  class StaticDeployment["fdri:StaticDeployment"] {
    fdri:deployedHeight: xsd_decimal
    fdri:deployedDepth: xsd_decimal
    fdri:deploymentPosition: xsd_string
  }
  class RelativeLocation["fdri:RelativeLocation"] {
    fdri:offsetNorth: xsd:decimal
    fdri:offsetEast: xsd:decimal
    fdri:elevation: xsd:decimal
  }
  class Feature["geos:Feature"] {
    geos:hasGeometry: geos:Geometry
  }

Deployment <|-- StaticDeployment
  StaticDeployment --> RelativeLocation: prov_atLocation
  StaticDeployment --> Feature: prov_atLocation

```

### Mobile Deployments

The class `fdri:MobileDeployment` is used to capture the deployment of a system to a mobile platform such as a boat or a drone. In such cases, each sortie of mobile platform with the deployed system should be recorded as a separate `fdri:MobileDeployment` (e.g. when multiple flights are made by a drone with a particular package of sensors). 

The `fdri:trackLog` property should be used to reference the detailed (possibly timed) track of the sortie, but the property `geos:hasGeometry` is also provided to allow the geospatial path or the area extent of the track to be captured in a form suitable for display and/or geo-spatial query.

```mermaid
classDiagram
class Deployment["fdri:Deployment"]
class MobileDeployment["fdri:MobileDeployment"]
class MobileDeployment {
    fdri:trackLog: Resource
    geos:hasGeometry: geos:Geometry
}
Deployment <|-- MobileDeployment
```

> **QUESTION**
> Should the range of `trackLog` be more specialised? The assumption is that we don't want to try and model a flight path, but just reference it. If we are just referencing a resource do we want to use the DCAT `Distribution` class to capture information about the track log such as its format and size? 

