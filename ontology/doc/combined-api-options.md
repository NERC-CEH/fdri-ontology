# Options for combined data and metadata APIs

## Goals

* Single service able to return both data and metadata
* Primary audience is downstream data users
* Support for visualization tooling and general client data access
* Support discovery of datasets via the metadata
* Encourage data users to download associated provenance metadata
* Facilitate data exchange with other relevant institutions including federated access, ideally via shared API standards
* Easy to use
* Initially supports timeseries data but extensible to user data types

> [!NOTE]
> These are just assumptions based on discussion so far and need review and prioritisation.

## High level options

We outline a few high level options and check them against three core requirements:

1. Combined access to full metadata and data
2. Good linking between the two to encourage metadata use
3. Conformance with standards used in this domain, especially by partner organisations

### 1. Extend metadata API with data endpoints

#### Outline

This is the approach taken in the DEFRA Hydrology service and flood-monitoring API.

Each time series dataset would provide an associated endpoint which can stream data values (in JSON and CSV format) with support for ordering, paging and filter by time interval. This could both follow REST conventions (e.g. https://ceh-dev.epimorphics.net/id/dataset/cosmos-lulln-lwin-series/data) and be explicitly included in the metadata as an accessURL on the dataset distribution.

In addition an endpoint for each dataseries and for the whole collection of dataseries would enable download of data from across multiple series, with optional filters on e.g. observed property, site or originating facility.

The return from the data endpoints should follow linked data best practice and include the URI of the dataset in the payload so that downloaded data directly links back to the associated metadata. If this is done at the row level (as in DEFRA Hydrology service) this allows multiple observed properties or properties across multiple sites to be downloaded in the same stream while maintaining unambiguous links to the metadata and thus provenance of the data.

#### Summary analysis

Meets 1.  Users can navigate the metadata API to discover data sets and data series related to observed properties, sites and features of interest. From there they can access both the detailed metadata (including provenance activities and details of sensor deployments) and the data streams for the datasets and dataseries.

Arguably meets 2. While the actual metadata isn't included in every data download the inclusion of (dereferenceable) URIs in the data makes for easy traceback and in a way that will work even if the data is downloaded in e.g. CSV format.

Fails 3. Conforms to generic standards such as OpenAPIv3 but doesn't comply with any domain specific API standards.

#### Implementation options

1. Metadata API extension. The sapi-nt framework already supports streaming delivery of data from alternative backends including Postgres and Apache Cassandra. A backend could be added to either directly query the Parquet files in S3 or broker data requests to the current data API, or some extension of it. To meet (2) the data format would need to be extended to include the relevant dataset URIs but that could be done either in the data API (if brokering) or as a streaming transformation in the sapi-nt implementation.<br /><br />
2. Data API extension. Conversely the implementation approach used in the existing API, which already brokers requests to the metdata API, could be extended to provide a more complete mirror of the metadata API and to include the link URIs in the returned payload.

### 2. Integrated data and metadata in download packages

Another way to meet requirement (2) is to deliver API results as a package of metadata files and data files - thus ensuring that the full relevant metadata is always included in the download. Various standardized approaches for this have been proposed, including "Frictionless Data" now [Data Packages](https://datapackage.org/) as used by _Our World in Data_. This is supported by tools in data science-friendly languages such as R and python.

A similar community standard is [RO-CRATE](https://www.researchobject.org/ro-crate/) which uses json-ld for the metadata file with a standardised vocabulary, partly drawn from scheme.org. UKCEH have already launched support for this early this year and it would be easy to extend this to at least pre-prepared FDRI data packages. 

In principle approach (1) could be extended so that a data query could optionally return a zipped file stream combining the requested data segments and a standardized capture of all the relevant metadata with a Data Package or RO-CRATE type wrapper.

This is mentioned for completeness, since it is more an embellishment on option 1 and doesn't address the issue of compliance with a domain-relevant standard.

### 3. SensorThings 

#### Outline

OGC SensorThings 1.1 (Sensing) defines a relevant data model and API standard. While the standard includes the full range of CRUD operations to support data publishing a read-only implementation would largely meet the criteria.

The FDRI data model can be largely mapped to the SensorThings data model (see [ogc-sensor-things.md]). The primary difficulty, the limitation of a single sensor per `Datastream`, can be finessed if we augment the metadata with the notion of a virtual sensor for a site/platform x sensor type (whether manifested in the model or dynamically created in the API).

The detailed metadata on provenance activities, sensor details, fault history and deployment history are all missing from the SensorThings model. However, each EntitySet in SensorThings allows an optional `properties` keyword whose value is an arbitrary json object. So some fixed projection of the relevant fine grain metadata could be attached that way. 

The SensorThings API provides rich capabilities to query both the metadata and data (Datastreams of Observations). It makes no separation between data and metadata. While simple use of the API will deliver information on each class of data (EntitySet) separately it allows queries to request information spanning multiple EntitySets (via the `$expand` keyword) thus giving the option to combine data and metadata in one payload, while not requiring it. 

#### Summary analysis

Somewhat meets 1. The query capabilities over data and the supported metadata elements is richer than either existing API, however all the metadata classes outside the SensorThings model can only be return as a fixed `properties` package. They could not be selectively returned or filtered on unless we extend the SensorThings model to support additional EntitySets corresponding to these classes or allow query into `properties`.

Largely meets 2. A user is not _required_ to formulate queries to return the metadata along with the data but this is possible and could be encouraged through documentation, outreach and tool support. The SensorThings model includes a link from each Observation row to its Datastream which, by default, would be returned in the payload. 

Largely meets 3. SensorThings seems to have growing momentum within relevant groups. The key concern is that without any standardisation of the richer metadata payload on provenance the standards compliance is not really addressing the core concerns. 

#### Implementation

SensorThings, or rather the OData 4 API specification it builds on, is a very complex API which is not well supported outside of the Microsoft tool chain that it originates from. This leads to a number of challenges.

**Lack of library support.** In terms of relevant libraries to build on there are:
   * _Apache Olingo_ a java library for OData including OData 4. This is not a very active project but is being minimally maintained. It is a complex package to drive but could provide at least query parsing and a framework to base an implementation on.
   * _Fraunhofer FROST server_. This is a full java implementation of SensorThings which does not build on Olingo but provides it's own implementation of query parsing. FROST assumes a Postgresql backend which it has complete control over. However, there is a `PersistenceManager` interface and a generic `Query` object definition. So it may be possible to extract a minimal framework from FROST-Core to provide at least query parsing against the SensorThings model but then replace the `PersistenceManager#get` operation with an implementation that brokers out to either the metadata API or a data query as required.
   * There are no python implementations for OData serving at all, that we can find. Though if the only support we can actually get from the libraries is query parsing then the query grammar is published as ABNF. So in principle Lark, or similar, could be used to generate a compliant query parser that could be the basis for a python query broker implementation. Though the grammar is generic so captures none of the SensorThings specific data model, at least out of the box. In any case, while complex, the query parsing is the the hardest part of the implementation.

**Query expressivity.** OData allows queries to include arbitrarily nested expressions include arithmetic, function calls and full boolean combinators. Furthermore, a different set of filters, sort, paging and projection operations can be applied to multiple elements in the path of a single query - for example using one set to select some Datastreams and a different set to select and order the Observations within the Datastream, to be returned in one payload. This expressivity is well beyond that supported by the existing metadata API which does not support arbitrary boolean combinations of filters and no arithmetic or function operators. 

In addition, SensorThings specifies a set of functions that queries have to support that go beyond OData, including geo functions based on the DI-9IM model which is a close match to postgis but different from the topological model supported by e.g. Geosparql. In the sapi-nt framework we do have some support for query to a postgis index alongside the Fuseki but out-of-the-box this only supports proximity queries and polygon filtering.

To build a query broker for SensorThings over the metadata API then options include:
* Break compound queries down into separate subqueries for each EntitySet, and combine the results in the broker. Doing this streaming style would be complex, but the metadata elements might be assembled in memory and then the bulk Observation results embedded as a stream.
* For the complex subqueries "push down" those elements of the filtering that the metadata API can perform natively and then filter the results with an in-memory implementation of the full OData expression language. Depending on the specific queries this could result in poor performance for those queries that can't be pushed down but would offer more complete coverage. No such OData filter implementation exists that we can find so this would need to be developed.
* Alternatively, extend the sapi-nt framework to support a fuller subset of OData expressions natively since most of the expression language could be translated to Sparql and the missing functions can be added (at least in Apache Jena) as either property functions or using Jena's general javascript function call option.
* Define a profile of SensorThings that does not support the full range of OData complexity. This could be combined with the above techniques to achieve coverage of the key retrieval use cases, if those can be identified. 

An alternative to a query broker would be to export the entire metadata store, prune and transform it to match the SensorThings datamodel in a relational style and load that into a postgresql + postgis backend which could then implement the full range of OData queries into the store. If the data was also loaded to the store, and supporting the fine grain metadata is not required, then could run a read-only FROST installation to obtain a complete SensorThings implementation. However, if not loading the data as well then a broker or a custom SensorThings implementation would still be needed and FROST does not provide obvious hooks for that.

## Conclusions

1. Before making any real decisions the goals need clarifying. There is a tradeoff between support for/encouraging access to the fine grain metadata and compliance with SensorThings. There's also a tension between ease of implementation and use v.s. standards compliance. It would help greatly to have some specific use cases from which we could infer the specific query patterns to support, especially if we want to profile SensorThings. Knowing about any delivery time constraints would also help to guide the choices.<br /><br />
2. The quickest route to getting something usable up would be a simple REST API (option 1). <br /><br />
3. The quickest route to getting a SensorThings compliant API would be to develop an export mechanism to mirror all the data and metadata to a postgresql+postgis store in a format compatible with FROST and use the FROST server. However, this feels like the wrong solution long term.<br /><br />
4. The best approach, if standards compliance is an important goal, would seem to be a broker API implementing a profile of SensorThings (guided by the target use cases) and with an extension to the ST datamodel to allow query into the key provenance metadata classes. If Epimorphics were to implement this alone we would use kotlin and expect to build upon either Olingo or FROST-Core (though these options would need evaluation first). For a joint Epimorphics/UKCEH build we would expect python to be the preferred implementation language in which case we would build on FastAPI and start from scratch on the OData machinery. Depending on the use cases, and thus API profile, the query parsing may be generateable from a tailored version of the OData ABNF grammar or might be hand crafted.

## Appendix: Working Notes on SensorThings

Additional notes on SensorThings investigations.

### Mapping Observations

[ogc-sensor-things.md] provides a partial mapping from the FDRI metadata model to the SensorThings data model.

Here we note the additional mapping needed for the data itself. In SensorThings the data is carried by an EntitySet containing `Observation`s. With the following properties and relations:

| Property                     | What                                                                     | Cardinality | Handling and comments                                                                                                                                                              |
| ---------------------------- | ------------------------------------------------------------------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `phenomenonTime`             | The time instant or period of when the Observation happens               | 1           | Timestamp from the data row                                                                                                                                                        |
| `resultTime`                 | The time of the Observation’s result was generated.                      | 1           | Even though mandatory allows NULL (which is odd). Suggest making this the same as `phenonmenonTime`                                                                                |
| `result`                     | The estimated value of an ObservedProperty from the Observation.         | 1           | The measurement value. Allows for categorical as well as numeric results                                                                                                           |
| `resultQuality`              | Describes the quality of the result.                                     | 0..n        | Not adequately defined by the spec[1](https://github.com/opengeospatial/sensorthings/issues/68). Either ignore or introduce FDRI specific encoding of quality flags when available |
| `validTime`                  | The time period during which the result may be used.                     | 0..1        | Optional, ignore                                                                                                                                                                   |
| `parameters`                 | Key-value pairs showing the environmental conditions during measurement. | 0..1        | Optional, ignore                                                                                                                                                                   |
| `Datastream` relation        | Link to owning Data Stream                                               | 1           | URI of the TimeSeries Dataset or OData navigation link URI                                                                                                                         |
| `FeatureOfInterest` relation | Link to feature of interest observed                                     | 1           | URI of `hasFeatureOfInterest` of the Timeseries Dataset (or OData navigation link URI)                                                                                             |

While this data model makes observations rather bulky the API allows users to request just a subset of the properties (e.g. `$select=phenomenonTime,result`).

### Data model extensions

The ([now withdrawn](https://labs.waterdata.usgs.gov/docs/sensorthings/about-sensor-things-api-sample-queries/)) USGS implementation of SensorThings permitted queries to select and filter within the `properties` fields and treated nested property fields as if they were relations to other EntitySets. It is not clear from the OGC specification whether this is a sanctioned interpretation but it seems like a natural usage of OData that would permit us to encode finer gain metadata on the `properties` extension property and still be able to select and filter on them while staying within the spec. This is likely to be less disruptive than revising the SensorThings datamodel itself.

In [ogc-sensor-things.md] we proposed using `properties` to carry a full json-ld description of the mapped class. In addition, if we want to support query and filter over these OData style, we may need to define OData relations to connect yo EntitySets that are relevant for the query use cases.  Candidates for that are:

| Base Entity        | Base FDRI Class                   | Extension classes to link to | Comments                                                                                                                                       |
| ------------------ | --------------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `Thing`            | `EnvironmentalMonitoringFacility` | `Program`, `Network`         | To allow filtering of data to specific networks                                                                                                |
| "                  | "                                 | `partOf`/`hasSubSystem`      | Depending on what level we link datastreams to, showing the decomposition of EMF at a site into subsystems and sensor packages might be wanted |
| `Location`         | location of EMF                   |                              |                                                                                                                                                |
| `Sensor`           | virtual sensor (of type at site)  | `Deployments`                | Link notional sensor to history of deployments of actual sensors with serial numbers etc                                                       |
| "                  | "                                 | `SensorType`                 |                                                                                                                                                |
| "                  | "                                 | `Fault`                      | _If_ we want to expose fault history                                                                                                           |
| `DataStream`       | `TimeSeriesDataset`               | `FeatureOfInterest`          | While SensorThings links this to Observations may be convenient to replicate here so can filter and retrieve at this level                     |
| "                  | "                                 | `DatasetSeries`              | To allow filter of Datastreams by series                                                                                                       |
| "                  | "                                 | `Activity`                   | If wish to expose how datasets are derived from other datasets [*]                                                                             |
| `ObservedProperty` | `Variable`                        | broader variable             | To allow discovery of specific variables using generalisation hierarchy                                                                        |

[*] Lots of details would need working through here depending on what level of provenance is to be exposed. We imagine that intermediate raw datasets would not be exposed and so activites like infill would not be included but datasets derived other included datasets could reasonably be represented.

### SensorThings 2?

There has been mention of work on a v2 for SensorThings. Does this affect any of the above?

We can find no formal documents related to a v2. However, this [GitHub Issue](https://github.com/opengeospatial/sensorthings/issues/167) provides some possible insights.

If the UML diagrams there are to be believed then the v2 extensions are largely compatible with the FDRI modelling and would enable some, but not all, of the relevant fine grained metadata to exposed in a more standardised way. Specifically:

* New link from Datastream directly to FeatureOfInterest (`UltimateFeatureOfInterest`) which would make it easier to map to that and avoid the link on every Observation.
* New `RelatedDataStream` links would allow derivation relations between datasets to be exposed.
* New `RelatedThing` links would allow us to expose the decomposition of sites into platforms and sub-systems.
* New `Deployments` EntitySet _may_ enable us to expose change of Sensor at a site. However, the assumption that a datastream is from just a single sensor remains and would block a natural use of that. Maybe the sensor instance information could be carried on the `properties` of the deployment but link to the continuing "virtual" sensor fo the site?

Note that v2 will not be backward compatible with v1. So users of v1 would need to change all their queries into to work with a v2 service.

### API capabilities and implementation challenges

SensorThings requires the following query options for EntitySets which are superficially mappable to the metadata API (sapi-nt list endpoints):

| SensorThings                        | Metadata API  | Notes                                                                              |
| ----------------------------------- | ------------- | ---------------------------------------------------------------------------------- |
| `$top`                              | `_limit`      |                                                                                    |
| `$skip`                             | `_offset`     |                                                                                    |
| `$count`                            | `_count=@id`  | In ST `$count` is returned as well as any selected items, in sapi-nt it is instead |
| `$orderby`                          | `_sort`       |                                                                                    |
| `$select`                           | `_projection` | Syntax for deeper nesting differs but capability is similar                        |
| `$expand`                           | `_projection` | "                                                                                  |
| `$filter=p eq v`                    | `p=v`         |                                                                                    |
| `$filter=p lt v`                    | `max-p=v`     | Similar support for `le`, `gt`, `ge`  but not `ne`                                 |
| `$filter=(p eq v1) or (p eq v2)`    | `p=v1&p=v2`   | Repeated filters on same property are disjunctions                                 |
| `$filter=(p1 eq v1) and (p2 eq v2)` | `p1=v1&p2=v2` | Filters on distinct properties are conjunctions                                    |

Elements not directly supported are:
* `not`
* arbitrary boolean combinations with precedence grouping
* arithmetic - `add`, `sub`, `mul`, `div`, `mod`
* builtin functions - various string, date, maths and geospatial functions are all required for ST
* filters/counts/pagination within nested queries

To illustrate the latter, a valid ST query is:

```
https://labs.waterdata.usgs.gov/sta/v1.1/Things('USGS-09380000')
	?$select=@iot.id,description
	&$expand=Datastreams(
		$select=@iot.id,description;
		$expand=Observations(
			$select=result,phenomenonTime;
			$orderby=phenomenonTime desc;
			$top=1;
			$count=true
		)
	)
   ```

   This starts from a specific Thing (a site), expands that into all linked Datastreams and then expands those to call the observations. But within the observations it applies both a count, and `$orderby/$top` to find the single most recent observation and returns both. In this case the count and top would be routed to the data API and the rest of the nesting is supportable by a nested `_projection`. In similar cases where the nested filtering also applies to metadata resources then it would be necessary to break the queries into separate subqueries which can be expressed in the metadata API.

A simple example of the use the arithmetic operators is:

```
https://labs.waterdata.usgs.gov/sta/v1.1/ObservedProperties('00060')/Datastreams?
$expand=Observations(
	$select=phenomenonTime,result,parameters;
	$filter=phenomenonTime gt now() sub duration'P2D';
  $orderby=phenomenonTime asc;$top=1000)
&$top=1000
```

This again is a filter on observations, looking for ones within the last two days. The data API supports selecting by concrete dates and a broker could translate `now() sub duration'P2D'` to a timestamp. However, expressions can be arbitrarily complex and in general would either need to pushed down into the database or apply a post-query filter to the stream returned from the database.
FROST, since it assumes a full postgresql backend, will likely translate the entire expression to SQL and push that down relying on the database query planner to handle it all.
