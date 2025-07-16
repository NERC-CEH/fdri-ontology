# Proposal for UAV Dataset Metadata

# High-level requirements

Datasets generated from UAV flights can be thought of more generally as being datasets generated from a monitoring activity. 

A monitoring activity may use some monitoring facilities (e.g. a drone). An agent may be related to an activity in some role, and may follow some procedure.

A monitoring activity should have a start and end date/time and may consist of a number of sub-activities each with their own separate start and end date/time and other metadata. e.g. a survey activity may consist of several drone flights across the survey area.

The datasets which result from an activity should be related to the activity in a similar way to which datasets from a monitoring facility are related to the facility. In addition to the datasets managed under the DRI system, activities may also produce other artefacts which may not be treated as datasets but which are nevertheless important to downstream users of the datasets - e.g. flight track logs.

The majority of sensor and platform related information which is required by users of drone data is already covered by the metadata that can be collected on static facilities - e.g. sensor deployment, sensor configuration and calibration. It is noted that the way in which sensors are mounted on vehicles has some additional nuances which might be better captured in structured data rather than as commentary notes - e.g. the orientation and relative positioning of a sensor on a drone.


# Proposed modelling approach

* Add EnvironmentalMonitoringActivity (subclass prov:Activity)
* Add `originatingActivity` property to `ObservationDataset` to relate the dataset to the EnvironmentalMonitoringActivity(ies) that give rise to the data.
* Use `prov:Usage` to relate activity to facility/ies used in the activity
* Use `prov:Association` to relate activity to a procedure and/or agent and role
* Use `sosa:observes` to relate an activity to the Variable(s) observed by the activity.

```mermaid
flowchart
Activity[EnvironmentalMonitoringActivity]
Programme[EnvironmentalMonitoringProgramme]
ObservationDataset-- originatingActivity -->Activity
Programme-- initiated-->Activity
Activity-- initiated -->Activity
Activity-- qualifiedAssociation -->Association
Association -- agent --> Agent
Association -- hadPlan --> Procedure
Association -- hadRole --> Concept
Activity-- qualifiedUsage -->Usage
Usage -- entity --> EnvironmentalMonitoringFacility
Usage -- hadRole --> Concept
Activity -- type --> ActivityType
Activity -- observes --> Variable
```

* A UAV is modelled as an `EnvironmentalMonitoringPlatform`
* The installation of sensors on the UAV are modelled as Deployments
* A survey is an `EnvironmentalMonitoringActivity` and each flight undertaken is a sub-activity
  
```mermaid
flowchart
Dataset["UAV Sensor Dataset
&lt;&lt;GriddedDataset>>"]
Variable["NOx Concentration
&lt;&lt;Variable>>"]
UAV["UAV #123
&lt;&lt;EMFacility>>"]
UAVModel["Some Make/Model"]
Quadcopter["Quadcopter"]
Flight1["Flight #1
&lt;&lt;EMActivity>>"]
Flight2["Flight #2
&lt;&lt;EMActivity>>"]
Survey["Survey
&lt;&lt;EMActivity>>"]
Usage1["Flight 1 use of UAV #123
&lt;&lt;Usage>>"]
Deployment["NOx Sensor Deployment
&lt;&lt;Deployment>>"]
Usage2["Flight 2 use of UAV #123
&lt;&lt;Usage>>"]
Sensor["NOx Sensor #345
&lt;&lt;EMSensor>>"]
SensorModel["Some Make / Model"]
SensorType["NOx Detector"]

UAVModel -- skos:broader --> Quadcopter
UAV -- dct:type --> UAVModel
Survey -- fdri:initiated --> Flight1
Survey -- fdri:initiated --> Flight2
Dataset -- originatingActivity --> Survey
Flight1 -- prov:qualifiedUsage --> Usage1
Usage1 -- prov:entity --> UAV
Flight2 -- prov:qualifiedUsage --> Usage2
Usage2 -- prov:entity --> UAV
Dataset -- sosa:observedProperty --> Variable
Deployment -- ssn:deployedOnPlatform --> UAV
Deployment -- ssn:deployedSystem --> Sensor
Sensor -- sosa:observedProperty --> Variable
Sensor -- dct:type --> SensorModel
SensorModel -- skos:broader --> SensorType
FlightLog1["Flight Log - Flight 1
&lt;&lt;Dataset>>"]
FlightLog1 -- dct:type --> FlightLog
FlightLog1 -- prov:wasGeneratedBy --> Flight1
FlightLog2["Flight Log - Flight 1
&lt;&lt;Dataset>>"]
FlightLog2 -- dct:type --> FlightLog
FlightLog2 -- prov:wasGeneratedBy --> Flight2
WeatherReport["Survey Weather Report
&lt;&lt;Document>>"]
WeatherReportConcept["Weather Report
&lt;&lt;Concept>>"]
SurveyUsage["Survey use of Weather Report
&lt;&lt;Usage>>"]
Survey -- prov:qualifiedUsage --> SurveyUsage
SurveyUsage -- prov:entity --> WeatherReport
SurveyUsage -- prov:hadRole --> WeatherReportConcept
```

## Analysis of UAV Dataset Metadata Recommendations

The following sections review the [UAV data management handbook](https://nora.nerc.ac.uk/id/eprint/536392/) to analyse how the metadata fields recommended in that document could map to the FDRI data model with the changes proposed in the preceding section.

### The UAV platform and its sensor type 

| Metadata Field | Supported? | Comments
|----------------|------------|-----------|
RPAS Type | Y | Captured as the broader concept of the concept that denotes the make/model of the EnvironmentalMonitoringFacility (or indirectly via skos:broader)
RPAS Make/Model | Y | Captured using dct:type on EnvironmentalMonitoringFacility
RPAS Payload Types | N | **TODO** - need to qualify what this refers to. If it refers to a pre-defined sensor package type, then this is just a reference to a concept used to type an EnvironmentalMonitoringSystem.
Camera Type/Model, Sensor Type/Model | Y | The sensors/sensor systems installed on the UAV are captured via Deployment(s). The types of those sensors/systems are captured via the dct:type property of the sensor/system resource. 
Sensor Calibration Specification | Y | Sensor calibration can be captured as an Activity that uses the sensor and generates a calibration specification.
Sensor Sampling Rate & Sensor Measurement Capability | Requires changes | These properties of a sensor can be captured using the SOSA System Capabilities module. This is currently included in the OWL version of the FDRI model but has not yet been added to the FDRI schema.
Sensor Location on Drone | May require Changes | See notes below
Sensor mount and orientation | May require changes | See notes below
Sensor firmware and version | Y | These are already captured as configuration information for the sensor.

**Sensor Location, Mount, and Orientation**

All three of these properties could be captured simply as part of the comments field already present on the Deployment type. This may be sufficient for reqiurements if it is only needed to allow an interested user to understand detailed information about how the data was captured.

If these fields are required for reporting, aggregation or filtering then a more structured approach would be required, and there are two potential options.

The first option would be to provide specific (optional) text fields for this information on the Deployment class (possibly in a subclass). This provides some more limited text search options but unless there is a structured approach to data entry the fields would still provide little benefit for filtering, reporting or aggregation.

The second option would be to define controlled vocabularies to use for these properties. It may also be the case that sensor location and orientation could be defined as coordinates and rotation/pitch relative to an origin coordinate on the body of the drone.

The third option would be to provide a detailed model of each drone's mounts, modelling the mount as a sub-platform of the drone. These mounts would still require relative positioning information (which can be captured using the existing model) as well as orientation details (which would still need to be added to the model).

It should be noted that in the survey in the [NERC report](https://nora.nerc.ac.uk/id/eprint/536398/) although there was a sizeable minority of users who expressed a desire to see this metadata (as a MUST or SHOULD), there is not any detail in that report as to how the information might be used. It should also be noted that a majority of respondents see this data as optional or irrelevant.

### The UAV survey 

| Metadata Field | Supported? | Comments
|----------------|------------|-----------|
| Geographic extent | Requires Changes | Would be supported by adding a spatialExtent property to EnvironmentalMonitoringActivity. Note that this property is intended to capture the size of the area covered so should be an Area or Volume property.
| Flight pattern type | Requires Changes | Requires a property and controlled vocabulary for values. Could be made more generic so as to refer to any sortie pattern rather than specifically to flights.
| Weather report | Y | A weather report can be captured as a document or data entity which is related to the activity by a prov:qualifiedUsage with the role of "weather report"
| Flight date and time | Y | Assuming that individual flights are modeled as spearate activities, flight time can be recorded as the activity start and end time.
| Sensing target | Y | The information about which observable property (in FDRI terms "Variable") is measured by a survey is captured as the sosa:observes of the EnvironmentalMonitoringActivity.
| Mission planning software | Y | The software used for mission planning can be captured as an entity related to the activity by a prov:qualifiedUsage with the role of "mission planning software"

### The sortie

| Metadata Field | Supported? | Comments
|----------------|------------|-----------|
flight log | Partial | A flight log file can be associated with a flight activity as an entity generated by the EnvironmentalMonitorinActivity that represents the flight. It is assumed that the details of the flight log such as duration and individual points in the flight log would not be accessible directly via the metadata store. 

**QUESTION** Are there flight log formats that should be captured as metadata? 

**QUESTION** Is there any value in capturing the duration of the flight log?

**NOTE** Currently the FDRI model does not have a generic "Document" resource type with associated Distributions. This sort of model might be useful not only for providing a means to associate metadata with a flight log, but also for specifying distribution formats and locations for other files (e.g. sensor certifications)

## Analysis of ADCP metadata

ADCP provides metadata regarding measurements taken from boats and other water-craft. The proposed metadata fields for an ADCP survey are summarised in the following table.

| Field Name | Core Field? | Description/Notes |
|------------|-------------|----------|
| DateTime   | Y | Date/time of survey |
| Site Name  | Y | Location of survey. Some surveys may take place in ad-hoc locations.
| lat        | Y | Lat of first GPS point in sortie |
| lon        | Y| Long of first GPS point in sortie |
| Station Number| Y | Identifies the sub-site where the activity took place using a controlled identifier
| Location   | Y | Identifies the sub-site where the activity took place using a site qualifier string (could be standardised)
| Party      | Y | List of the operatives who participated in the survey. Operatives are identified only by their initials. |
| Boat/Motor | Y | The type of craft used for the survey |
| Measurement Number | Y | Not currently clearly defined |
| Comments   | Y | Text notes regarding the activity, e.g. "proximity to bridge causing compass interference" |
| System Type | Y | **TO CHECK**: The type/model of craft (or is it of sensor) used in the activity |
| Serial Number | Y | **TO CHECK**: The serial number of the craft (or sensor?) used in the activity |
| Firmware Version | N | **TO CHECK**: The version of firmware installed on the craft (or sensor?) |
| Transducer Depth (m) | N | **TO CHECK**: Not sure what this refers to
| Screening Distance (m) | N | Ignored for this analysis
| Salinity (PSS-78) | N | Ignored for this analyss
| Magnetic Declination (deg) | N | Ignored for this analysis
| Distance   | N | Unit of measure 
| Velocity   | N | Unit of measure 
| Area       | N | Unit of measure  
| Discharge  | N | Unit of measure 
| Temperature | N | Unit of measure
| Track Reference | N | Ignored for this analysis
| Bottom Fit Type | N | Ignored for this analysis
| Left Method | N | Ignored for this analysis
| Depth Reference | N | Ignored for this analysis
| Top Fit Type | N | Ignored for this analysis
| Right Method | N | Ignored for this analysis
| Coordinate System | N | Ignored for this analysis
| Width (m) | Y | Width of the spatial coverage of this survey
| Area (mÂ²) | N | Area of the spatial coverage of this survey
| Mean Speed (m/s) | N | Ignored for this analysis
| % Measured (%) | Y  | **TO CHECK** - not sure what this is a ratio of
| Total Q (mÂ³/s) | Y | **TO CHECK** - is this is a measure of confidence in the observations?
| Total number of transects | Y | Number of transects undertaken - i.e. number of individual sorties performed in this activity.
| Number of transects used | Y | **TO CHECK** - Number of transects that contributed to the data?
| Mean Samples Per Transect | Y | Mean number of observations recorded in each sortie
| Maximum Speed (m/s) | N | Ignored for this analysis
| Mean Depth (m) | Y | **TO CHECK** mean depth at which observations were made? or mean depth of water on transect?
| Maximum Depth (m) | Y | **TO CHECK** maximum depth at which observations were made? or max depth of water?