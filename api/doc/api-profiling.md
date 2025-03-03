# Requirements for a combined API profile

These notes are intended to start a discussion on the specific query patterns that a combined data/metadata API should support. They follow on from earlier working papers on mapping to SensorThings (STA) and implementation options.

If we can identify a bounded set of query patterns that cover the main us cases then that would allows us to profile STA. The aim being to find a profile that is cheaper to implement than full STA; either by directly implementing as a broker over the metadata and data APIs (or direct to the parquet files) or as a shim which translates the STA queries in the profile to a combined REST API and then maps the responses to the STA format,

The list below is based on:
* enumerating all the elements in the STA data model and key additional elements in FDRI
* examples in the BGS and USGS STA documentation
* queries in STA tickets and email discussions
* focussed on external use rather than driving the processing chain, since that's already catered for
* omits fault information, or is that wanted as well?
* omits some assumed common features
   * lists can be limited/paged
   * lists can be sorted on property to the top level resources returned
   * properties of returned resources can chosen - `$select` in STA, `_projection` in LDA/sapi-nt
   * return formats include CVS, json, geoJSON (for geo entities only)

## Preliminary list of query types

| Query | Filter/navigation | STA example | Notes |
|---|---|---|---|
| list sites | by Network, Programme, Collection, operatingPeriod, annotation | `/Things` | Assume map `Thing` to top level site [1], for STA annotations, operatingPeriod etc would be `properties` |
| list sites | by observed properties | `/ObservedProperties(op-id)/Datastreams?` `$select=@iot.id&$expand=Thing` or maybe `/Things?$filter=datastream/observedproperty ` `eq STA-id-for-op`| [2] |
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
| list observations (get data) | by dataset(s), by time | `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$filter=phenomenonTime gt 2021-04-01T00:00:00+00:00` | |
| list observations (get data) | by site, by time | `/Thing(site-id)/Datastreams?` `$select=@iot.id` `&$expand=Observations($select=result,phenomenonTime)` | |
| list observations (get data) | earliest observation for a dataset/list of datasets |  `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$orderby=phenomenonTime desc` `$top=1` | |
| list observations (get data) | latest observation for a dataset/list of datasets | `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$orderby=phenomenonTime asc` `$top=1` | |
| count observation | count observation for a dataset/list of datasets, by time period| `/Datastreams(dataset-id)/Observations?` `$select=result,phenomenonTime` `&$filter=phenomenonTime gt date` `&$count=true` | |
| list observations (get data) | by observedProperty, by site | `/Datastreams?` `$filter=thing eq STA-id-for-site and observedproperty eq STA-id-for-op` `&$expand=Observations($select=result,phenomenonTime,datastream)` | |
| list platforms | | TBD | How much do end data users care about the nested platform structure?  |
| list calibrations | by sensor, by dataset, by time | TBD | Are all configuration and calibration items wanted for external use? |

[1] BGS treat `Thing` as the platform e.g. the data logger and use `FeatureOfInterest` for the site (e.g. borehole).

[2] To be confirmed how STA handles identities in filters. STA doesn't comply with W3C best practice for data on the web, the identity of things in STA is their index in the corresponding EntitySet and the value of `@iot.selflink` is a (version specific) API call not a stable URI. Presume filter is by the local id rather than the `@iot.selflink` URL but TBC.

[3] To avoid splitting datastreams by sensor the proposed mapping posits the notion of a virtual sensor representing a sensor of a specific type at a site, independent of serial number identity. This sort of call would return deployments of actual sensors but "out of band" of STA. If we treated STA `Sensor` as a specific numbered sensor, following the specs, and treated `Thing` as the sensor platform rather than the site then the STA machinery of HistoricalLocation could be used to track deployments of sensors to different sites in a more STA native way but at the cost of splitting datasets by sensor deployment and complicating the notion of site.
