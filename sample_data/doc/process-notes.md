# Notes on sample data processing

Currently, data loading for the metadata service is implemented a GH action (in this repo) transforming checked-in CSV files to graph updates.

We plan to move to a state where updates can be applied incrementally from different source data services. 

In preparation for that these notes identify the different data sources currently represented in the store and how the future update process might work. Very much work in progress and will change as we clarify the details of these data feeds.

Note: In the current processing The overall pattern is that each processed source dataset `src/X.csv` is mapped to a `build/X.ttl` file via a transform template file `templates/X.yaml`. So the names given below are the `X` in those file names.

Note: In many cases preprocessing is performed by a SQL processing step (duckdb). These can normalise values, simplify the transformation step or perform joins. 
 
Note: we use "CV" as  an abbreviation for Controlled Vocabulary, represented as a SKOS ConceptScheme. Many of these are generated here from the source data but expected to eventually come from a vocabulary server.

## Summary table

| Data | Source | Update type | Notes and processing issues |
|---|---|---|---|
| Site reference | EIDC catalogue? | Bulk replace (by network?) | Are the full annotations included? |
| Site reference CVs | Vocab server? | Bulk replace (by CV) | Soil type, Bedrock type, Public |
| Land Cover base % | EIDC/separate reference data | Bulk replace | |
| Land Cover observations | Field reporting - asset management? | Incremental addition (2) | Non-monotonic update (1) |
| Land Cover classes | Vocab server | Bulk replace (by CV) | |
| Sensor types | Asset management? Static reference data? | Bulk replace | Either include variable mapping or have separate mapping file (3) |
| Sensor deployments | Asset management | Incremental addition (2) | Non-monotonic update (1) |
| Sensor faults | Asset management | Incremental addition | Include sensor ID so can link directly. Assume all data is relevant and not filter to deployed sensors? |
| Sensor config changes (firmware) | Asset management | Incremental additions.  (2) | Do cleansing/validation separately? |
| Processing levels CV | Vocab server | Bulk replace (by CV) | Assuming continue to track processing levels |
| Correction methods CV | Vocab server | Bulk replace (by CV) | |
| Correction factors for data pipeline | Data pipeline config? | Bulk replace (by site? by series?) | |
| Parameter ranges for data pipeline QC | Data pipeline config? | Bulk replace (by site? by series?) | |
| Variable to instrument mapping (3) | ? Where is this managed? | Bulk replace? | Cleaner data to avoid preprocessing? |
| Variable (COP) definitions | NERC + local vocab servers | Bulk replace by CV | |
| Statistics CV | NERC or local vocab servers | Bulk replace by CV | |
| Time series definitions | ? Where is this managed? | Bulk replace (grain size)? | Separate out S3 annotations? |
| S3 storage annotations for time series | Data pipeline config? | Bulk replace (grain size) | |
| Time series datasets | ? | Bulk replace (grain size?) | Should  this be automatically derived from above and site instrumentation (as present)? Or should there explicit configuration of which datasets are active at a site? |

(1) New entries close the time span of prior entries which means some non-monotonicity. Could check against live data or run a post processing update which closes all but the latest entry.

(2) When we have incremental additions can we assume that they are all new or do we also need to support a catchup mode where some of the data might have already been imported? Do we also need to support a bulk sync mode where history is replaced and rebuilt from scratch? 

## Sites, Network and related

### SITES

**What:** Core reference data on monitoring sites including geo location, description and layout.

**Preprocessing:** Sites with non-standard layout are separated out for processing by a separate template which adds a `siteVariance` property to those sites. 

**Alt-preprocessing?:** Preprocessing might be avoided by extending the mapper to support inline conditionals.

**Generates:** `EnvironmentalMonitoringSite`s with annotations and associated `GeospatialFeatureOfInterest`. Variables used in the site annotations (`site-soil-type`, `site-public` etc). Other one off reference terms (COSMOS Programme and monitoring network). Inferred CV for COSMOS regions, soil classification and bedrock classification.

**Future source:** Presume that site reference information will be mastered in the data catalog and imported from there. Testing of this process is planned. To be confirmed whether that reference data covers all the annotations here.

The dynamically generated CVs may move to the vocabulary server and be imported from there directly as RDF. 

**Update requirements:** Relatively static data, bulk replacement is fine. May want to move to separate graphs for the CVs, site data from catalog and any additional site reference annotations sourced from elsewhere.

### LAND_COVER_LCM_CLASSES

**What:** Labels for landcover classes used in landCoverLcm
**Generates:** LandCover CV
**Future source:** Vocabulary server
**Update requirements:** Replace whole CV graph when updated.

### landCoverLcm

**What:** Landcover class and area by site and year, with percentages for different types, uses landcover class codes from LAND_COVER_LCM_CLASSES. Derived from the LC maps and not updated.

**Preprocessing:** Convert cover from % to (rounded) fraction, map year to a date. 

**Alt-preprocessing?:** Could extend mapper to support functional transforms like this.

**Generates:** Time bounded annotations on given landcover ratio for each site. Together with definition for the ratio variable.

**Future source:** Is this in site reference data in the catalogue or a separate part of onboarding new sites?

**Update requirements:** If not part of site reference then seems likely to be a bulk replace. 

### landCoverObservations

**What:** What the footprint of land cover at site is deemed to be from direct observation. Single value per site, and includes records of changes. Uses text labels rather than Landcover classes.

**Preprocessing:** Determine end date for observation rows where there's a newer observation. Map text labels to landcover class codes.

**Alt-preprocessing?:** If supplied incrementally end dates could be set as replacement data arrives. Reconciliation (of labels to codes) is supported in the mapper if suitable endpoint can be provided.

**Generates:** Time bounded annotations on sites giving observed land cover, themselves annotated with source and comments. Together with definitions for the annotation variables.

**Future source:** ? Presume some field reporting system would be used to report new site observations that would arrive over time.

**Update requirements:** Incremental, non-monotonic updates. If we assume access to current metadata state then the update can check if the observation is different from the existing one and if so close the date for the previous observation and start a new one. Assign each update a separate graph timestamped so it can be backed out if there's a data problem.

## Deployments and sensors

### INSTRUMENTATION

**What:** List of sensor types used.

**Generates:** EnvironmentalMonitoringSystemType definitions with name and comment (as scope note).

**Future source:** Reference data set on sensor types? From asset system or vocab server?

**Update requirements:** Bulk replacement?

### instrumentationVariables and variableProperties

**What:** Mapping from variable name to instrument type (instrumentationVariables) and descriptions of variables (variableProperties)

**Preprocessing:** Join on variable name to give table of instrument type and variable descriptions.

**Generates:** `EnvironmentalMonitoringSystemType` concepts in a scheme with `fdri:observes` links to observed properties.

**Future source:** Reference data on variable configuration including sensor types. Where mastered?

**Update requirements:** Bulk replacement

### sensor_deployments from SITE_INSTRUMENTATION, VARIABLE_INSTRUMENTATION and variableProperties

**What:** `SITE_INSTRUMENTATION` gives history of sensor deployments at sites with instrument id and serial number. `VARIABLE_INSTRUMENTATION` maps instrument id to variable name as given in `variableProperties`.

**Preprocessing:** Join first two on instrument id and then join to variable details on variable name. Join need for later fault processing?

**Generates:** `EnvironmentalMonitoringSensor` and `Deployment` information.

**Future source:** Presume deployment information would be extracted from the future asset management system.

**Update requirements:** Incremental record updates as deployments change.

> [!NOTE]
> **_Internal question:_** Is the join needed here? The sensor_deployments template only seems to use values from SITE_INSTRUMENTATION? Can see that the file is needed for sensor_faults later so maybe this is just a convenient intermediate?

### sensor_faults from SENSOR_FAULTS, PARAMETERS and sensor_deployments

**What:** SENSOR_FAULTS gives list of time periods of faults on specific sensors with comments, includes the affected variables (could be multiple `;`-separated affected variables per fault). PARAMETERS gives readable label for the variables.

**Preprocessing:** Splits faults to single row per variable and then checks fault for match to a deployed sensor with overlapping time periods. To test that, we need mapping from variable to sensor from `sensor_deployments` intermediate.

> [!NOTE]
> **_Internal question:_** Is the join to PARAMETERS used here any more? Doesn't seem to be included in the exported table.

**Generates:** `Fault` records with descriptions for sensor (or station if sensor not known) with link to affected varaibles.

**Future source:** Presume faults will be reported via the asset management system but there may be a delay so faults may still refer to a prior deployment. Preferable if the fault information includes a sensor ID so these can be linked directly instead of indirectly via variable.

**_Question for CEH:_**  Will the asset management system know about the variables affected or will there need to be separate processing to create those links?

**Update requirements:** Incremental fault additions, assume sensor ID is included in the update (and if not fault applies to site) and variable(s) explicit in update. May need to check if fault with matching timestamp exists to make updates idempotent.

**_Question for CEH:_** Could these fault records have an ID to avoid duplicate updates?

### sensor_firmware_configurations from Firmware_history

**What:** Time bounded records of firmware versions for instrument id.

**Preprocessing:** Cleansing to handle missing start dates and end dates (if two entries for same instrument have different start dates but no end date assume first started was ended when newer one was started). Format dates to ISO.

**Alt preprocessing:** The data formatting could be moved to the transformer. For future support might want to validate data to just reject entries with no start date?

**Generates:** `ConfigurationValueSeries` for the sensor, with `TimeBoundPropertyValue` for each entry a current value.

**Future source:** Assume incremental record updates from asset management system for new firmware versions. Or might be bulk export. Or might need to support both (incremental normally but )

**Update requirements:** If bulk export then process as now, replacing whole history. If incremental then check if version as actually changed and if so close off current value and set new current value. Maintaining the current value is non-monotonic so need a SPARQL Update, though that could be a general run which replaces a current value graph.

## Processing pipeline

### CORRECTION_METHODS
**What:** Definitions for the correction methods use to apply the correction factors.
**Generates:** CV for correction methods.
**Future source:** Vocabulary server?
**Update requirements:** Replace whole graph when CV updated.

### CORRECTION_FACTORS
**What:** Time bounded correction factors by site and time series.

**Generates:** `InternalDataProcessingConfiguration` for the timeseries, `ConfigurationItem`s for each entry with interval, observation interval affected and link to correction method and dummy plan. Each item is link as `hasCurrentConfiguration` to the `InternalDataProcessingConfiguration`.

> [!NOTE]
> **_Internal question_:** Presume the `hadPlan` with `-1234` is a dummy to illustrate how that would look?

**Future source:** ?? 

**Update requirements:** ?? Bulk replacement but what grain size (all/site/series)?

### PARAMETER_RANGES_QC
**What:** Legal ranges for variables by site.
**Generates:** `InternalDataProcessingConfiguration` with `ConfigurationItem` for each range. One off definitions for the parameter and config type.
**Future source:** ??
**Update requirements:** ?? Bulk replacement but what grain size (all/site/series)?

> [!NOTE]
> For last two the one off definitions of parameters and config types could be a pre-prepared base load.

### processingLevels
**What:** Labels and ids for the processing levels
**Generates:** CV for processing levels
**Future source:** Vocab server
**Update requirements:** Bulk update on CV change

## Datasets and variables

### monitoring_system_variables from VARIABLE_INSTRUMENTATION and TIMESERIES
**What:** Map from variable ID to sensor (instrument ID)
**Preprocessing:** Join to filter to just those PARAMETER_IDs in referenced in timeseries and then extract the distinct variable name to instrument IDs.
**Generates:** Annotates each instrument with the variable (COP) it observes.
**Future source:** ?? 
**Update requirements:** Bulk replace (largely fixed reference data)

### parameterProperties
**What:** Maps variable ids and names to COP elements (property, unit, domain, context).
**Generates:** Variable (COP) definitions in a Concept scheme with associated CVs for contexts, domains and parameters.
**Future source:** NERC vocab server plus local vocab server for cases of only local interest?
**Update requirements:** Bulk replace when CVs change.

### STATISTICS
**What:** Id, label and definition for statistic (MEAN_PREC, INST etc).
**Generates:** CV for statistics
**Future source:** Vocab server
**Update requirements:** Bulk update on CV change

### time_series_definitions from TIMESERIES, TIMESERIES_S3_MAP_REFINED, and intervalDuration

**What:** Definitions of time series with id, label, statistic, unit, processing level

**Preprocessing:** Most data is from TIMESERIES but SQL script maps interval to xsd Duration notation, maps levels to level IDs to match processingLevels CV and then joins in S3 bucket information using timeseries id.

**Alt preprocessing:** Duration and processing level normalisation could be moved to templates. The S3 data could be a separate supply and rely on time-series URI to do the join.

**Generates:** `TimeSeriesDefinition` for all timeseries datasets (which are then common across individual series)

**Future source:** ?? 

**Update requirements:** Bulk replace (large static configuration data)? But at what grain size?

### time_series_datasets from SITE_INSTRUMENTATION, PARAMETERS_INSTRUMENTS, PARAMETERS, TIMESERIES_S3_MAP_REFINED and above time_series_definitions

**What:** Clean definition of all time timeseries datasets for each site with variable, processing level, period and start date.

**Preprocessing:** Complicated. To work out which series are available which sites needs to use SITE_INSTRUMENTATION (which is given in terms of instrument id) which has to be mapped to the variable (parameter) reference in the time series definitions. Those mappings then need the PARAMETERS_INSTRUMENTS and PARAMETERS lookup tables. The data can include some duplications so the preprocessing does some grouped aggregations to pick the earliest start date and highest duration and processing level from the duplicates.

**Generates:** TimeSeriesDatasets collected int a series for each site and a series for each site/variable (across processing levels).

**Future source:** ??

**Update requirements:** Bulk replace (large static configuration data)? But at what grain size?

## Data not currently represented

Processing runs.
