# Requirements for a combined API profile

These notes are a prompt for discussion on the specific query patterns that a combined data/metadata API should support. They follow on from earlier working papers on mapping to SensorThings (STA) and implementation options.

If we can identify a bounded set of query patterns that cover the main use cases then that would allows us to define a limited _profile_ of STA. That would open new options including:
1. a cheaper direct STA implementation that brokers to the metadata and data APIs/parquet files; or
2. a simple REST API that could be offered directly but also be exposed via STA profile using a shim (translating the limited query patterns to the REST form and translating the responses back to STA form).

The preliminary list below is based on:
* enumerating all the elements in the STA data model and key additional elements in FDRI
* examples in the BGS and USGS STA documentation
* queries mentioned email discussions (may have missed some)
* focussed on external use rather than driving the processing chain, since that's already catered for
* omits fault information, or is that wanted as well?
* doesn't spell out assumed common features such as
   * lists can be limited/paged
   * lists can be sorted on property to the top level resources returned
   * properties of returned resources can chosen - `$select` in STA, `_projection` in LDA/sapi-nt
   * return formats support CSV, json and geoJSON (for geo entities only)

## Preliminary list of query types

| Query | Filter/navigation | STA example | Notes |
|---|---|---|---|
| list sites | by Network, Programme, Collection, operatingPeriod, annotation | `/Things` | Assume map `Thing` to top level site [1], for STA annotations, operatingPeriod etc would be `properties` |
| list sites | by observed properties | `/Things?$filter=datastream/observedproperty eq STA-id-for-op` | [2] |
| list locations |  | `/Locations`  | In simple REST case location information is simply reported by site endpoint but STA users presumably would expect to be able list plain locations and then get sites from there, see next row |
| list sites | by geo (polygon or distance) | `/Location?$select=@iot.id` `&$filter=geo.distance(location, geography'POINT (x y)') lt d` `&$expand=Thing` | Unclear if can select nothing from Location to just get at the site |
| describe single site | | `/Things(id-for-site)` | |
| list observedProperties | by COP facet | `/ObservedProperties?$filter=properties.facet eq value` | |
| list observedProperties | for site | `/ObservedProperties?$filter=datastream/thing eq STA-id-for-site` | [2] |
| list datasets (datastreams) | by site | `/Datastreams?$filter=thing eq STA-id-for-site` | |
| list datasets (datastreams) | by feature of interest | | |
| list datasets (datastreams) | by observedProperties | `/ObservedProperties(op-id)/Datastreams` | |
| describe single dataset | | `/Datastreams(id-for-dataset)` | |
| describe single dataset | link from an observation | `/Observations(observation-id)/Datastreams` | For REST style include dataset URI in observation rows |
| list features of interest | by Network, Programme, Collection | `/FeaturesOfInterest` | |
| list features of interest | for site | `/FeaturesOfInterest?$filter=datastream/observation/featureOfInterest eq STA-id-for-site`  | |
| list sensors | by type, by site | `/Sensors` | Caveats about meaning of sensor |
| list sensors | by platform | `/Sensors?$filter=properties/platform eq uri-for-platform` | How much do end data users care about the nested platform structure? |
| list deployments | by sensor, by dataset, by time | e.g. `/Sensor?$expand=properties/deployments&$filter=...` | This would only list deployments for this logical sensor. Tracking deployments of physical sensors across sites would natively support in STA if we picked a different mapping between FDRI and STA [3] |
| list deployments | by platform | | |
| list observations (get data) | by dataset(s), by time | `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime,datastream` `&$filter=phenomenonTime gt 2021-04-01T00:00:00+00:00` | |
| list observations (get data) | by site, by time | `/Datastreams/Observations?$filter=thing eq site-id &$select=result,phenomenonTime,datastream` | |
| list observations (get data) | by sensor, by time | `/Sensors(id)/Datastreams/Observations?$select=result,phenomenonTime,datastream` | Not supported by BGS so might have to use `$expand` version |
| list observations (get data) | earliest observation for a dataset/list of datasets |  `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$orderby=phenomenonTime desc` `$top=1` | |
| list observations (get data) | latest observation for a dataset/list of datasets | `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$orderby=phenomenonTime asc` `$top=1` | |
| count observation | count observation for a dataset/list of datasets, by time period| `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$filter=phenomenonTime gt date` `&$count=true` | |
| list observations (get data) | by observedProperty, by site | `/Datastreams?` `$filter=thing eq STA-id-for-site and observedproperty eq STA-id-for-op` `&$expand=Observations($select=result,phenomenonTime,datastream)` | Could we use `/Datastreams/Observations` form but filter on the observed property of the datastream on the way through? |
| list platforms | | TBD | How much do end data users care about the nested platform structure?  |
| list calibrations | by sensor, by dataset, by time | TBD | Are all configuration and calibration items wanted for external use? |

[1] BGS treat `Thing` as the platform e.g. the data logger and use `FeatureOfInterest` for the site (e.g. borehole).

[2] To be confirmed how STA handles identities in filters. STA doesn't comply with W3C best practice for data on the web, the identity of things in STA is their index in the corresponding EntitySet and the value of `@iot.selflink` is a (version specific) API call not a stable URI. Presume filter is by the local id rather than the `@iot.selflink` URL but TBC.

[3] To avoid splitting datastreams by sensor the proposed mapping posits the notion of a virtual sensor representing a sensor of a specific type at a site, independent of serial number identity. This sort of call would return deployments of actual sensors but "out of band" of STA. If we treated STA `Sensor` as a specific numbered sensor, following the specs, and treated `Thing` as the sensor platform rather than the site then the STA machinery of HistoricalLocation could be used to track deployments of sensors to different sites in a more STA native way but at the cost of splitting datasets by sensor deployment and complicating the notion of site.

## Initial analysis

If this list is representative a relatively simple profile would be sufficient.

**Endpoints:** Primarily the core entity sets with just a few compound path cases being of interest:

* `/Things`
* `/Sensors`
* `/Location`
* `/FeaturesOfInterest`
* `/ObservedProperties`
* `/Datastreams`
* `/Observations`
* `/Datastreams(id)/Observations`
* `/ObservedProperties(id)/Datastreams`
* `/Sensors/Datastreams`

With these in some cases may need to enumerate e.g. the `Datastreams` with one call and then fetch the `Observations` for these with a separate call whereas full STA may be able to do this in one step.

**Filtering:**

* allow chained references of value to filter on (`datastream/observation/featureOfInterest`)
* basic comparison operators `eq` `ne` `gt` `ge` `lt` `le`
* only conjunctions `and`
* no arithmetic, string functions or compound expressions
* basic geo filter `geo.distance` and  `st_within`  (plus maybe `st_equals` and `st_overlaps`)

**Expansions:**

Single level only for leaf properties.

Used to include FDRI extensions (deployments, calibration/configuration, events) in responses.

May also be needed to allow filtering of intermediate values in a chain (e.g. get data by OP and site) - this needs more checking.

**Data model:**

TBD clarify extensions to STA data model via `properties` field to attach deployment, specific sensors and calibration history to `Sensors` and processing provenance information to `Datastreams`
