# AMS Integration

## Key metadata entities to retrieve from AMS

The class diagram below shows the sub-set of the FDRI metadata data model that touches on the entities we expect to retrieve data about from the AMS.

```mermaid
classDiagram
    class Fault {
        ams_id: string
        startedAt: datetime
        resolvedAt: datetime?
        description: string
        removeData: boolean
    }
    class Sensor {
    }
    class Facility {
        ams_id: string
        fdri_id: string
        dateCommissioned: datetime?
        dateDecommissioned: datetime?
        location: geospatialPoint
    }
    class Site {
        altitude: decimal?
        siteVariance: string?
    }
    class System {
        operationalStatus: StatusEnum
        serialNumber: string
        calibrationDue: datetime?
        maintenanceDue: datetime?
        certification: url
        dateOfPurchase: date
        retirementDate: date
        dateOfDisposal: date
        storageLocation: string
    }
    class SensorType
    class SensorModel {
        manufacturer: string
        model: string
    }
    class FacilityType
    class Activity {
        ams_id: string
        startedAt: datetime
        endedAt: datetime?
        description: string?
    }
    class Agent {
        ams_id: string
        name: string
    }
    class ActivityType
    class Deployment {
        ams_id: string
        startedAt: datetime
        endedAt: datetime
        deployedHeight: decimal
        deployedDepth: decimal
        offsetNorth: decimal
        offsetEast: decimal
    }
    class Variable
    class PropertyValueSeries {
        hasCurrentValue: TimeBoundPropertyValue
        hadValue: TimeBoundPropertyValue*
    }
    class ConfigurationValueSeries
    class CalibrationValueSeries
    class OperatingRange {
        minValue: any
        maxValue: any
        value: any
    }
    class SurvivalRange
    class SystemCapability
    class Condition
    Facility <|-- System
    System <|-- Sensor
    Facility <|-- Site
    Agent <|-- Person
    Agent <|-- Organisation
    PropertyValueSeries <|-- CalibrationValueSeries
    PropertyValueSeries <|-- ConfigurationValueSeries
    Fault --> "0..*" Facility: affectedFacility
    Fault --> "0..*" Variable: affectedVariable
    Facility --> "1" FacilityType: type
    Facility --> "0..1" Facility: isPartOf
    Sensor --> "1" SensorType: type
    Sensor --> "1" SensorModel: model
    SensorModel --> "1..*" Variable: measures
    Activity --> "1" ActivityType: type
    Deployment --> "1..*" Sensor: deployedSystem
    Deployment --> "1" Facility: deployedOnPlatform
    System --> "0..*" System: subsystem
    Activity --> "0..*" Facility: affectedFacility
    Activity --> "0..*" Agent: performedBy
    CalibrationValueSeries --> "0..1" Variable: appliesToVariable
    OperatingRange --> "1" Variable: operatingProperty
    OperatingRange --> "1..*" Condition: inCondition
    SurvivalRange --> "1" Variable: survivalProperty
    SurvivalRange --> "1..*" Condition: inCondition
    SystemCapability --> "0..*" Variable: forProperty
    SystemCapability --> "0..*" SystemProperty: hasSystemProperty
    SystemCapability --> "1..*" Condition: inCondition
    SystemProperty --> "1" Variable: property
    SystemProperty --> "1" Unit: unit

```

## Fault

We would expect most fault data to be pulled from the AMS.
Faults that are reported via the SOD would still be pulled from the AMS rather than implementing a separate ingestion path for them.

Ideally we would be able to bulk retrieve fault entities which have been created or updated within a given time period.

The AMS-assigned identifier would be used to correlate the metadata record with the fault record. It is assumed that all updates to a fault status would modify the fault record.

* AMS identifier
* Description
* Affected system(s)
* Affected measurement variables
* Start timestamp
* End timestamp

## Facilities

In the metadata model a Facility is the base class for many of the categories of physical asset. The primary subclasses we are interested in are Sites, Platforms and Systems/Sensors. A Site is a location which may host several platforms, each platform hosts Systems or Sensors. A System is a physical package containing one or more sensors.

Sites, Platforms, Systems and Sensors are all "soft-typed" with a category. e.g "Weather Station" for a platform, "Anemometer" for a sensor.

We need sufficient typing of assets to be able to determine which asset records fall into which categories, and from that we would be able to determine the asset type. There are also likely to be a significant number of assets that we would not reflect in the metadata store such as consumables, assets which are part of infrastructure but do not directly or indirectly host sensors etc.

For Sites (and Platforms?) we would expect to be able to retrieve both the AMS identifier and the Site Vocab DB identifier from the AMS along with additional metadata as outlined below.

* Common Metadata
  * AMS identifier
  * Operating period

* Sites
  * Name
  * Site type
  * Network that the site belongs to
  * Site Vocab DB Identifier
  * Geospatial coordinates
  * Altitude
  * Description
  * Land usage
  * Soil type
  * Bedrock type
  * Layout variation notes
  * Public access
  * Site owner category
  * Other network-specific site metadata

* Platforms
  * Location relative to site
  * Platform type

* Systems/Sensors
  * System Type
  * Model
  * Serial Number
  * Date calibration is due
  * Date maintenance is due

* Sensor Models
  * Variables Measured
  * Capabilities: Sensitivity, Accuracy etc.
  * Operational Range
  * Survival Range (e.g battery lifetime)

NOTE: capabilities, operational ranges and survival ranges can all be qualified by a condition (e.g. an standard operating temperature range)

We could retrieve each of these types of entity in separate batch requests, using the record last modified date as a filter so as to only retrieve records that were modified since the last ingest.

## Deployments

Represents the period during which a sensor or system is deployed on a platform.

* start timestamp
* end timestamp
* deployed position (height, depth, offset from platform)

NOTE: A deployment may be associated with a number of activities - an installation activity, any number of on-site maintenance activities and a deinstallation activity.

At this stage we are not sure if the the AMS treats deployments as first-class entities. Ideally this would be the case, allowing us to ingest them without having to infer deployments from these individual activities. If that is not the case we need to have a clear understanding of which activity type(s) infer the start and end of a deployment.

## Activities

The SOD metadata store is primarily interested in activities that affect deployed sensors/systems and the facilities where they are deployed.

As the metadata for activities is intended to be used publicly, we would want to avoid including PII in this data. Hence the suggestion that where there are individuals associated with an activity, it would be preferable if we can just retrieve their organisation.

At this stage it is not clear if it would be better to be able to retrieve activities with the data for the affected entity or as a separate batch request. The former may be more easily processed, but then we would need to include the update of the activity stream for an asset as part of the determination of whether an asset record has been modified since the last request. If we retrieve activity records as a batch it would be best if it were possible to filter by affected asset type and to group activities by the affected asset so that all recent activities affecting one asset can be processed together.

* Type (e.g. deployment, removal, maintenance, calibration, configuration)
* Start and end timestamp of activity
* Responsible actor(s) - or their organisation
* Deployment information
  * Deployment position, height, depth
* Calibration information
  * Calibration values
  * The variable(s) affected by the calibration
* Configuration information
  * Configuration values/configuration file reference

### Configuration and Calibration Values

NOTE: It is not clear yet whether this information would be retrieved from the AMS or some other system.

The SOD metadata includes both current and historic configuration and calibration property values. There is/will be a controlled vocabulary of the properties. Calibration property values may be additionally scoped by the variable(s) affected by the calibration. As values can be changed over time, every value should be associated with a start timestamp and (if historic) an end timestamp.

Some configuration is in the form of files, in such cases the configuration value should be a reference to (ideally the URL of) the configuration.
