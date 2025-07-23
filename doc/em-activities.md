## Environmental Monitoring Activity Model

### Environmental Monitoring Activity

The class `fdri:EnvironmentalMonitoringActivity` represents some activity which is used to gather observations about some feature of interest in the environment.

An `fdri:EnvironmentalMonitoringActivity` has the following properties:

  * `dct:type` relates the activity to an `fdri:ActivityType` concept which qualifies the kind of activity (e.g. UAV survey)
  * `sosa:observes` relates the activity to one or more `fdri:Variable`s that are measured during the activity
  * `fdri:measures` relates the activity to the specific `fdri:Measures` that are used when observing the variables
  * `fdri:facilityUsage` relates the activity to a `fdri:FacilityUsage` that combines an `fdri:EnvironmentalMonitoringFacility` (via `prov:entity`) used in the activity, and an `fdri:FacilityUsageRole` (via `prov:hadRole`) that indicates the relationship between the activity and the facility (e.g. craft). Any `fdri:EnvironmentalMonitoringFacility` may be used by an activity including sites, platforms, sensor packages and individual sensors.
  * `prov:qualifiedAssociation` relates the activity to a `prov:Association` which combines:
    * An optional `fdri:Procedure` followed by any number of `prov:Agent`s in the execution of the activity (via `prov:hadPlan`).
    * Any number of `prov:Agent`s involved in the activity (via `prov:agent`)
    * An optional `skos:Concept` representing the role played by the agents in activity when they executed that procedure.
  * `prov:startedAtTime` and `prov:endedAtTime` properties may be used to capture the start and end timestamps for the activity.

An `fdri:EnvironmentalMonitoringActivity` may be initiated (`fdri:initiated`) by either an `fdri:EnvironmentalMonitoringProgramme` or by another `fdri:EnvironmentalMonitoringActivity`.

As `fdri:EnvironmentalMonitoringActivity` is a sub-class of `prov:Activity` it can also be related to entities that it generates or modifies (`prov:wasGeneratedBy`, `fdri:wasModifiedBy`). 
It is recommended that `prov:wasGeneratedBy` should be used only for those resources which are a direct result of the activity (e.g. a GPS track log for a UAV flight or a raw sensor log file).
An `fdri:EnvironmentalMonitoringActivity` generates data which contributes to any number of `fdri:ObservationDataset`s.
The property `fdri:originatingActivity` which should be used to relate an `fdri:ObservationDataset` to the `fdri:EnvironmentalMonitoringActivity` (or activities) which produced the data contained in the dataset.

```mermaid
---
config:
    class:
        hideEmptyMembersBox: true
---
classDiagram
  direction LR
class Activity["prov:Activity"] {
  startedAtTime: xsd:dateTime
  endedAtTime: xsd:dateTime
}
class EMActivity["fdri:EnvironmentalMonitoringActivity"]
class EMProgramme["fdri:EnvironmentalMonitoringProgramme"]
class ObservationDataset["fdri:ObservationDataset"]
class Agent["prov:Agent"]
class Variable["fdri:Variable"]
class Measure["fdri:Measure"]
class Association["fdri:RelatedPartyAssociation"]
class Concept["skos:Concept"]
class FacilityUsage["fdri:FacilityUsage"]
class FoI["fdri:GeospatialFeatureOfInterest"]
class ActivityType["fdri:ActivityType"]
class Procedure["fdri:Procedure"]
class RelatedPartyRole["fdri:RelatedPartyRole"]
class EMFacility["fdri:EnvironmentalMonitoringFacility"]

Activity <|-- EMActivity
EMActivity --> EMActivity: fdri_initiated
EMActivity --> ActivityType: dct_type
EMProgramme --> EMActivity: fdri_initiated
ObservationDataset --> EMActivity: fdri_originatingActivity
EMActivity --> Variable: sosa_observes
EMActivity --> Measure: fdri_measures
EMActivity --> FoI: sosa_hasFeatureOfInterest
EMActivity --> Association: prov_qualifiedAssociation
Association --> Agent: prov_agent
Association --> Procedure: prov_hadPlan
Association --> RelatedPartyRole: prov_hadRole
EMActivity --> FacilityUsage: fdri_facilityUsage
FacilityUsage --> EMFacility: prov_used
FacilityUsage --> FacilityUsageRole: prov_hadRole
FacilityUsageRole --|> Concept
RelatedPartyRole --|> Concept
```

### Example: UAV dataset using Environmental Monitoring Activities

As an example of the use of `fdri:EnvironmentalMonitoringActivity`, take the case of a dataset derived from a survey performed using a drone. The drone is piloted over a site, taking readings of the concentration of nitrogen oxide (NOx) in the atmosphere. The survey consists of multiple individual sorties, and the data from each of the sorties is then combined into a single dataset.

#### Survey and Sorties as nested activities

Both the survey, and each sortie in the survey can be modelled as an `fdri:EnvironmentalMonitoringActivity`. With the sortie activities being intiated by the survey activity, and the survey activity being initiated by the `fdri:EnvironmentalMonitoringProgramme` that the survey is part of.

```mermaid
flowchart
Programme["Programme
&lt;&lt;fdri:EnvironmentalMonitoringProgramme>>"]
Survey["Survey
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>
startedAtTime: 2025-06-21T09:00:00Z
endedAtTime: 2025-06-21T11:00:00Z"]
Flight1["Flight 1
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>
startedAtTime: 2025-06-21T09:15:00Z
endedAtTime: 2025-06-21T09:45:00Z"]
Flight2["Flight 2
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>
startedAtTime: 2025-06-21T10:15:00Z
endedAtTime: 2025-06-21T10:45:00Z"]
Programme -- fdri:initiated --> Survey
Survey -- fdri:initiated --> Flight1
Survey -- fdri:initiated --> Flight2
```

#### Site of the survey

The site over which the sorties are flown can be modelled as the feature of interest of the activities. In this case the sorties treated as having the same feature of interest as the survey and so the relationship does not need to be repeated.

As the site is an `fdri:GeospatialFeatureOfInterest` it can have geospatial co-ordinates and/or boundaries associated with it to locate the survey in geospatial terms. In this case only the latitude and longitude of a representative point for the survey site is given.

> **NOTE:**
> This is a very simple example of providing geospatial information for an activity. In more detailed modelling it would be possible to use `sosa:hasFeatureOfInterest` to denote the geometry of each individual sortie as well as the bounding geometry of all sorties at the survey level.
```mermaid
flowchart
Survey["Survey
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>"]
Site["SOME_SITE
&lt;&lt;fdri:GeospatialFeatureOfInterest>>
geo:lat: 51.48199
geo:long: -2.76973"]
Survey -- sosa:hasFeatureOfInterest --> Site
```

#### Platform and Sensor Usage

The drone used in the survey is an `fdri:EnvironmentalMonitoringPlatform` that is used in the role of `PilotedCraft`

There is an `fdri:Deployment` of the sensor to the drone for the duration of the survey. In some cases a sensor or package of sensors may be more permanently affixed to a craft, in which case the time span for the `fdri:Deployment` may be much broader than the time span of any `fdri:EnvironmentalMonitoringActivity` that makes use of the drone.

As the same drone is used for the same purpose in each survey, the metadata about the use of the drone can be captured at the survey level.

```mermaid
flowchart
Survey["Survey
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>"]
Drone["Drone 123
&lt;lt;fdri:EnvironmentalMonitoringPlatform"]
DroneModel["Some Make/Model"]
Quadcopter["Quadcopter"]
Sensor["NOx Sensor #345
&lt;&lt;EMSensor>>"]
SensorModel["Some Make / Model"]
SensorType["NOx Detector"]
Variable["NOx Concentration
&lt;&lt;Variable>>"]
Deployment["NOx Sensor Deployment
&lt;&lt;Deployment>>
startedAtTime: 2025-06-21T09:00:00Z
endedAtTime: 2025-06-21T11:00:00Z"]
FacilityUsage["Use of Drone 123 in Survey
&lt;&lt;fdri:FacilityUsage>>"]
Craft["Piloted Craft
&lt;&lt;fdri:FacilityUsageRole>>"]

DroneModel -- skos:broader --> Quadcopter
Drone -- dct:type --> DroneModel
Sensor -- sosa:observedProperty --> Variable
Sensor -- dct:type --> SensorModel
SensorModel -- skos:broader --> SensorType
Deployment -- ssn:deployedOnPlatform --> Drone
Deployment -- ssn:deployedSystem --> Sensor
Survey -- fdri:facilityUsage --> FacilityUsage
FacilityUsage -- prov:entity --> Drone
FacilityUsage -- prov:hadRole --> Craft
```

#### Piloting of the drone

The pilot of the drone is an `fdri:Agent` who follows an `fdri:Procedure` in the execution of each sortie. In this case the procedure used relates to the piloting of the craft on a single sortie and so the relationship is expressed against each of the sortie activities as an `fdri:RelatedPartyAssociation`.

```mermaid
flowchart
Flight1["Flight 1
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>"]
Flight2["Flight 2
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>"]
Piloting["Piloting of Sortie
&lt;&lt;fdri:RelatedPartyAssociation>>"]
JohnSmith["John Smith
&lt;&lt;fdri:Agent>>"]
Pilot["Pilot
&lt;&lt;fdri:RelatedPartyRole>>"]
SortieProcedure["Sortie Procedure
&lt;&lt;fdri:Procedure>>"]
Flight1 -- prov:qualifiedAssociation --> Piloting
Flight2 -- prov:qualifiedAssociation --> Piloting
Piloting -- prov:agent --> JohnSmith
Piloting -- prov:hadPlan --> SortieProcedure
Piloting -- prov:hadRole --> Pilot
```

#### Outputs generated by each sortie

A raw flight log is produced for each sortie. These are the directly generated data files which are then processed in conjunction with the sensor logs to produce the dataset. These files could be modelled as `prov:wasGeneratedBy` each sortie.

```mermaid
flowchart
Flight1["Flight 1
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>"]
Flight2["Flight 2
&lt;&lt;fdri:EnvironmentalMonitoringActivity>>"]
FlightLog1["Flight Log - Flight 1
&lt;&lt;Dataset>>"]
FlightLog1 -- dct:type --> FlightLog
FlightLog1 -- prov:wasGeneratedBy --> Flight1
FlightLog2["Flight Log - Flight 1
&lt;&lt;Dataset>>"]
FlightLog2 -- dct:type --> FlightLog
FlightLog2 -- prov:wasGeneratedBy --> Flight2

```

#### Dataset created from the survey

The survey data is compiled into a gridded dataset. The metadata for this dataset uses `fdri:originatingActivity` to reference the survey activity, `fdri:originatingFacility` to reference the drone used in the survey, and `sosa:observes` to reference the variable measured.

```mermaid
flowchart
Dataset["UAV Sensor Dataset
&lt;&lt;GriddedDataset>>"]
Variable["NOx Concentration
&lt;&lt;Variable>>"]
UAV["Drone #123
&lt;&lt;EnvironmentalMonitoringFacility>>"]
UAVModel["Some Make/Model"]
Quadcopter["Quadcopter"]
Survey["Survey
&lt;&lt;EnvironmentalMonitoringActivity>>"]

UAVModel -- skos:broader --> Quadcopter
UAV -- dct:type --> UAVModel
Dataset -- originatingActivity --> Survey
Dataset -- originatingFacility --> UAV
Dataset -- sosa:observedProperty --> Variable
```