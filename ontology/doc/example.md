# Worked Example

## High-Level Outline
```mermaid
flowchart TB
NETWORK --contains----> SITE
SITE --hasPart----> PLATFORM
PLATFORM --hosts--> PLATFORM
PLATFORM --isSampleOf--> FEATURE
SENSOR_DEPLOYMENT --deployedOnPlatform--> PLATFORM
SENSOR_DEPLOYMENT --deployedSystem--> SENSOR
SENSOR --type--> SENSOR_MAKE_MODEL
SENSOR --hadFault --> FAULT
FAULT --affectedVariable--> VARIABLE
SENSOR_MAKE_MODEL -- observes--> VARIABLE
RAW_TIME_SERIES & LEVEL2_TIME_SERIES & LEVEL3_TIME_SERIES --hasFeatureOfInterest--> FEATURE
RAW_TIME_SERIES  & LEVEL2_TIME_SERIES & LEVEL3_TIME_SERIES-- observedProperty-->VARIABLE
RAW_TIME_SERIES --wasModifiedBy--> INGEST_ACTIVITY
LEVEL2_TIME_SERIES --wasModifiedBy--> LEVEL2_ACTIVITY
LEVEL2_ACTIVITY --used--> RAW_TIME_SERIES
LEVEL3_TIME_SERIES --wasModifiedBy--> AGGREGATION_ACTIVITY
AGGREGATION_ACTIVITY --used--> LEVEL2_TIME_SERIES
```
`NETWORK` - an `EnvironmentalMonitoringNetwork` such as COSMOS.
`SITE` - a single location which hosts one or more pieces of infrastructure to which sensors may be attached
`PLATFORM` - a single piece of physical infrastructure to which one or more sensors, and/or one or more other pieces of infrastructure may be attached. 
`FEATURE` - the environmental feature which is monitored by sensors on a platform.

**QUESTION**: Should the feature be attached to the `SITE` rather than the `PLATFORM`. The implication of doing that would be that we would say that the air temperature sensor on the weather post at a site and the soil temperature sensor in the ground at the same site are monitoring the same abstract notion of the "environment at the site", rather than monitoring different "environment of the weather post" and "environment of the soil monitoring station", which I think may be a level of detail too fine-grained to be useful?

## Deployments of sensors and sensor packages

### "Simple" deployment of a single sensor to a post at a site

A single sensor is affixed to a post installed at a site.
The SENSOR_DEPLOYMENT carries metadata specifying the date range of the deployment.

The `hosts` relationship is an additional, optional relationship we might include in the metadata to make discovery of all sensors which are currently deployed to the platform easier to discover.

```mermaid
flowchart
SITE["`SITE
≪EnvironmentalMonitoringSite≫`"] --hasPart--> POST["`POST
≪EnvironmentalMonitoringPlatform≫`"]
DEPLOYMENT["`SENSOR_DEPLOYMENT
≪Deployment≫`"] --deployedSystem--> SENSOR["`SENSOR
≪EnvironmentalMonitoringSensor`"]
DEPLOYMENT --deployedOnPlatform--> POST
POST -.hosts.-> SENSOR
```

NOTE: To accomodate projects where they may not have as much available detail about structures at a site, we could also defined `EnvironmentalMonitoringSite` to be a SOSA/SSN `Platform` which would allow it to directly host sensors and sensor packages with no intervening `EnvironmentalMonitoringPlatform`. This would also allow us to use the SOSA/SSN `hosts` relationship to relate `SITE` to `POST`, rather than `hasPart` which might make for more consistent navigation?

### "Complex" deployment of a package of sensors to a site

A package consisting of two sensors is affixed to a post installed at a site.

The POST `hosts` the PACKAGE, which in turn `hosts` the two sensors. There is a deployment record for the package of sensors, as well as separate deployment records for the sensor contained in the package.

```mermaid
flowchart
SITE["`SITE
≪EnvironmentalMonitoringPlatform≫`"] --hasPart--> POST["`POST
≪EnvironmentalMonitoringPlatform≫`"]
PACKAGE["`PACKAGE
≪EnvironmentalMonitoringPlatform≫
≪EnvironmentalMonitoringSystem≫`"] --hasSubsystem--> SENSOR_1 & SENSOR_2
PACKAGE_DEPLOYMENT["`PACKAGE_DEPLOYMENT
≪Deployment≫`"] --deployedSystem--> PACKAGE
PACKAGE_DEPLOYMENT --deployedOnPlatform--> POST
SENSOR_1_DEPLOYMENT["`SENSOR_1_DEPLOYMENT
≪Deployment≫`"] -- deployedSystem--> SENSOR_1
SENSOR_1_DEPLOYMENT --deployedOnPlatform --> PACKAGE
SENSOR_2_DEPLOYMENT["`SENSOR_2_DEPLOYMENT
≪Deployment≫`"] -- deployedSystem--> SENSOR_2
SENSOR_2_DEPLOYMENT --deployedOnPlatform --> PACKAGE
PACKAGE -.hosts.-> SENSOR_1 & SENSOR_2
POST -.hosts.-> PACKAGE
```

When SENSOR_1  in PACKAGE is replaced by SENSOR_3, the deployment of SENSOR_1 ends, and the deployment of SENSOR_3 starts. The `hosts`, and `hasSubsystem` relationships between the PACKAGE and SENSOR_1 would have to be removed as it is no longer a current part of the PACKAGE, but the historic record of the use of SENSOR_1 by PACKAGE is still recorded in the SENSOR_1_DEPLOYMENT.

```mermaid
flowchart
SITE["`SITE
≪EnvironmentalMonitoringSite≫`"] --hasPart--> POST["`POST
≪EnvironmentalMonitoringPlatform≫`"]
PACKAGE["`PACKAGE
≪EnvironmentalMonitoringPlatform≫
≪EnvironmentalMonitoringSystem≫`"] --hasSubsystem--> SENSOR_2 & SENSOR_3
PACKAGE_DEPLOYMENT["`PACKAGE_DEPLOYMENT
≪Deployment≫`"] --deployedSystem--> PACKAGE
PACKAGE_DEPLOYMENT --deployedOnPlatform--> POST
SENSOR_1_DEPLOYMENT["`SENSOR_1_DEPLOYMENT
≪Deployment≫
startedAt: 2020-01-01
endedAt: 2024-11-28`"] -- deployedSystem--> SENSOR_1
SENSOR_1_DEPLOYMENT --deployedOnPlatform --> PACKAGE
SENSOR_2_DEPLOYMENT["`SENSOR_2_DEPLOYMENT
≪Deployment≫
startedAt: 2020-01-01
`"] -- deployedSystem--> SENSOR_2
SENSOR_2_DEPLOYMENT --deployedOnPlatform --> PACKAGE
SENSOR_3_DEPLOYMENT["`SENSOR_3_DEPLOYMENT
≪Deployment≫
startedAt: 2024-11-28
`"] -- deployedSystem--> SENSOR_3
SENSOR_3_DEPLOYMENT --deployedOnPlatform --> PACKAGE
PACKAGE -.hosts.-> SENSOR_2 & SENSOR_3
POST -.hosts.-> PACKAGE
```

## COSMOS station at Alice Holt
```mermaid
flowchart TB
subgraph network["Network Hierarchy"]
COSMOS["`COSMOS
≪EnvironmentalMonitoringNetwork≫`"]--contains-->SITE_ALIC1
SITE_ALIC1["`Alice Holt Site
≪EnvironmentalMonitoringSite≫`"]--hasPart-->PLATFORM_ALIC1
PLATFORM_ALIC1["`**Alice Holt Station**
≪EnvironmentalMonitoringPlatform≫`"]
end
subgraph siteAnn["Site Annotations"]
SITE_ALIC1--hasAnnotation-->SOIL_TYPE_ANN
SOIL_TYPE_ANN--property-->SOIL_TYPE
SOIL_TYPE_ANN--hasValue-->X[" "]
X--hasValueReference-->MINERAL_SOIL
end
subgraph platformAnn["Platform Annotations"]
PLATFORM_ALIC1--hasAnnotation-->TDT_ARRAY_ANN
TDT_ARRAY_ANN--property-->SITE_FULL_TDT_ARRAY
TDT_ARRAY_ANN--hasValue-->FALSE["value = false"]
end
```

## Automatic Weather Station at Alice Holt

An automatic weather station with serial number 13210003 was installed at Alice Holt between 06/03/2015 and 29/01/2020.

Amongst the variables the AWS reports are Absolute Humidity (Q) and Relative Humidity (RH). For clarity, other variables also reported by the system are omitted.

At the time of writing, there have been three different Automatic Weather Stations installed at Alice Holt, the most recent installation would be represented by a deployment with no `endedAtTime` value.

```mermaid
flowchart TB
PLATFORM_ALIC1["`**Alice Holt Station**
≪EnvironmentalMonitoringPlatform≫`"]
AWS_1["`**Deployment of AWS 13210003 at Alice Holt**
≪Deployment≫
startedAtTime: 2015-03-06T13:30:00
endedAtTime: 2020-01-29T00:00:00
`"]
AWS_1 --deployedOnPlatform--> PLATFORM_ALIC1
AWS_1 --deployedSystem--> AWS_13210003
AWS_13210003["`**AWS 13210003**
≪EnvironmentalMonitoringSystem≫`"]--type-->AWS
AWS["`**Automatic Weather Station**
≪EnvironmentalMonitoringSystemType≫`"]-- observes -->Q & RH
Q["`**Absolute Humidity**
≪ComplexObservableProperty≫`"]
RH["`**Relative Humidity**
≪ComplexObservableProperty≫`"]
Q -- hasProperty -->ABS_HUMID
RH -- hasProperty -->REL_HUMID
Q & RH -- hasObjectOfInterest --> AIR
Q -- hasUnit --> GM-3
RH -- hasUnit --> PERCENT
```

## Raw Absolute Humidity Time Series from Alice Holt

Each variable reported from a station is treated as a separate time series. The Raw time series represents the structured, but unprocessed observation values for the variable.

To aid in navigation of the time series datasets, the time series for this single variable is part of several dataset series:
  * all raw variable time series from the same site
  * all raw absolute humidity measures from sites in the same network
  * all absolute humidity time series from the same site (raw, infilled, aggregated)

**NOTE**: These collections are for illustrative purposes only. Other ways of partitioning the collection of datasets could be accomodated by the same model.

```mermaid
flowchart TB
PLATFORM_ALIC1["`**Alice Holt Station**
≪EnvironmentalMonitoringPlatform≫`"]
subgraph time-series
RH_RAW["`**Raw Time Series for RH at Alice Holt**
≪TimeSeriesDataset≫`"]
end
subgraph metadata
RH_RAW-- observedProperty -->RH["`**Relative Humidity**
≪ComplexObservableProperty≫`"]
RH_RAW-- hasFeatureOfInterest -->FEATURE_ALIC1
FEATURE_ALIC1 --isSampleOf --> PLATFORM_ALIC1
PLATFORM_ALIC1 --hasSample --> FEATURE_ALIC1
FEATURE_ALIC1["`**Environment at Alice Holt Station**
≪FeatureOfInterest≫`"]
RH_RAW--temporal-->X["`≪PeriodOfTime≫
startDate: 2015-03-06
endDate: 2024-11-27`"]
RH_RAW--processingLevel-->RAW
RH_RAW--inSeries-->ALIC1_RAW["`**All Raw Time Series from Alice Holt**
≪DatasetSeries≫`"]
RH_RAW--inSeries-->COSMOS_RH_RAW["`**All Raw Relative Humidity Time Series from the COSMOS network**
≪DatasetSeries≫`"]
RH_RAW--inSeries-->ALIC1_RH["`**All Relative Humidity Series from Alice Holt**
≪DatasetSeries≫`"]
end
subgraph provenance
RH_RAW--wasGeneratedBy-->ACT1["`Ingest Activity A
≪Activity≫
startedAt: 2024-11-01T00:00:00Z
endedAt: 2024-11-20T00:00:00Z`"]
RH_RAW--wasModifiedBy-->ACT2["`Ingest Activity B
≪Activity≫
startedAt: 2024-11-20T00:00:00Z`"]
end
```

## Level 2 Absolute Humidity Time Series

```mermaid
flowchart TB
RH_RAW["`**Raw Time Series for RH at Alice Holt**
≪TimeSeriesDataset≫`"]
subgraph time-series
RH_2["`**Level 2 Time Series for RH at Alice Holt**
≪TimeSeriesDataset≫`"]
end
ACT["`**Data Processing Activity 1**
≪DataProcessingActivity≫`"]
QA1["`**Pre-processing**
≪Association≫`"]
QA2["`**QC Checks**
≪Association≫`"]
QA3["`**In-fill**
≪Association≫`"]

AGENT1["`**Pre-Processing Agent**
≪SoftwareAgent≫
repository: https://github.com/...
repositoryPath: /src/preproc`"]
AGENT2["`**QC Agent**
≪SoftwareAgent≫
repository: https://github.com/...
repositoryPath: /src/qc`"]
AGENT3["`**Infill Agent**
≪SoftwareAgent≫
repository: https://github.com/...
repositoryPath: /src/infill`"]

CONFIG1["`**Pre-Processing Configuration for RH at Alice Holt**
≪DataProcessingConfiguration≫`"]
CONFIG2["`**QC Configuration for RH at Alice Holt**
≪DataProcessingConfiguration≫`"]
CONFIG3["`**Infill Configuration for RH at Alice Holt**
≪DataProcessingConfiguration≫`"]

subgraph prov
RH_2 -- wasModifiedBy --> ACT
ACT -- used --> RH_RAW
ACT -- qualifiedAssociation --> QA1 & QA2 & QA3
QA1 -- agent --> AGENT1
QA1 -- hadPlan --> CONFIG1
QA2 -- agent --> AGENT2
QA2 -- hadPlan --> CONFIG2
QA3 -- agent --> AGENT3
QA3 -- hadPlan --> CONFIG3
end
subgraph metadata
RH_2--temporal-->X["`≪PeriodOfTime≫
startDate: 2015-03-06
endDate: 2024-11-27`"]
RH_2--processingLevel-->LEVEL2
RH_2--inSeries-->ALIC1_LEVEL2["`**All Level 2 Time Series from Alice Holt**
≪DatasetSeries≫`"]
RH_2--inSeries-->COSMOS_RH_2["`**All Level 2 Relative Humidity Time Series from the COSMOS network**
≪DatasetSeries≫`"]
RH_2--inSeries-->ALIC1_RH["`**All Relative Humidity Series from Alice Holt**
≪DatasetSeries≫`"]
end
```

