# Representing Gridded Dataset Metadata

## Representing netCDF Metadata

For the FDRI project it is envisaged that gridded data in netCDF format will be provided in the form of netCDF files conforming to a version of the netCDF conventions (currently CF 1.6+). The netCDF files contain metadata describing both the dataset itself and describing the structure of the netCDF file. For the latter of these, there is a proposed ontology hosted by OGC - BALD (binary array linked data).

> NOTE
> The BALD ontology is described in the document [OGC Encoding Linked Data Graphs in NetCDF Files](https://portal.ogc.org/files/100757). This does not appear to be a published OGC document and it cannot be found in a search on https://ogc.org. While the mapping proposed by the document appears to be well thought through and documented, it does not have the force of a published OGC standard and so some consideration should be given to whether it is appropriate to adopt for FDRI.

A netCDF file's header contains both the structural information (variables and dimensions) that properly belong as a description of the netCDF distribution along with global properties a subset of which could be harvested to populate FDRI dataset metadata - especially in the case that the netCDF file is the only distribution of the dataset.

> [NOTE]
> In the document referenced above, it is stated both that `bald:Container` subclasses `dcat:Distribution` and that `bald:Container` has `dcat:distribution` properties - implying that `bald:Container` must also be a subclass of `dcat:Dataset`. The latter seems more consistent with the examples presented in the document.
> 
> At the time of writing it has not been possible to locate an OWL definition of the BALD ontology, making it difficult to determine if this is deliberate modelling or if the statement about subclassing `dcat:Distribution` is an error.
>
> This distnction is important to make as it would affect the modelling for datasets that consist of multiple netCDF files. If `bald:Container` subclasses `dcat:Dataset` then each netCDF is a separate dataset with a parent `dcat:DatasetSeries` that gathers them all together. Whereas, if `bald:Container` subclasses `dcat:Distribution` then the netCDF files would be distributions of a single parent dataset.
>
> The output of the Python tool, and the examples given in the documentation tend to indicate that the interpretation that has `bald:Container` as a subclass of `dcat:Dataset` is the intended one, as the tool output and the examples all have `dcat:distribution` properties on `bald:Container`.

## Representing Zarr Metadata

In principle the metadata of Zarr archives can be treated in the same way as netCDF files, treating the top level `.zattrs` as the global properties, and the second level `foo/.zarray` and `foo/.zattrs` as the structural metadata.

## Global Property Mapping

The following table shows the mapping of netCDF global properties to RDF properties. 

The column `Property` gives the global attribute property in the netCDF file. The list here is based on the samples provided thus far.

The column `Example Value` gives an example of a value of the property in an netCDF file. Truncated values are indicated by a trailing ellipsis.
The column `Mapped Property` gives the Compact URI for the RDF property that the netCDF property can be mapped to. Where no value is given, there is no mapping yet defined. The standard interpretation defined by the in these cases Prefixes used here are:
* dct: http://purl.org/dc/terms/

The column `Dataset?` indicates whether this property could be "lifted" to be Dataset metadata rather than Distribution metadata in the case where the dataset consists of a single netCDF file.


| Property | Example Value | Mapped Property | Dataset? | Notes
|----------|---------------|-----------------|----------|----|
| :title   |  Climate hydrology and...| dct:title       | Y        |
| :summary | Gridded daily meteorological variables... | dct:description | Y        |
| :source  | This data set has been generated... | | |
| :cdm_data_type | Grid |
| :spatial_resolution_distance| 1000. | dcat:spatialResolutionInMeters | Y | Assumes that metadata is always using meters as unit
| :spatial_resolution_unit | urn:ogc:def:uom:EPSG::9001
| :standard_name_vocabulary | CF Standard Name Table v70, http://cfconventions.org/standard-names.html
| :standard_name_url_vocabulary | NERC Vocabulary Server, https://vocab.nerc.ac.uk/standard_name/
| :geospatial_lat_min | 49.7661858106921 | | | Convert lat/long min/max to a rectangle?
| :geospatial_lat_max | 59.3996792149323
| :geospatial_lon_min | -9.01413106773813
| :geospatial_lon_max | 2.50058956720584
| :time_coverage_start | 1961-01-01 00:00:00 UTC | | | Indirect mapping to dct:temporalResolution/dcat:startDate
| :time_coverage_end | 2017-12-31 23:00:00 UTC | | | Indirect mapping to dct:temporalResolution/dcat:endDate
| :time_coverage_resolution | P1D | dcat:temporalResolution
| :time_coverage_duration | P57Y
| :history | File created on 2020-05-04.
| :keywords | Climate and climate change, Hydrology, Modelling, ... | | | Indirect mapping to dcat:keyword, splitting on comma and stripping trailing/leading whitespace.
| :references | Robinson, E. L., Blyth, E. M., Clark, D. B., Finch, J., and Rudd, A. C.: Trends in ...
| :acknowledgement | This research has been carried out... |
| :project | Climate Hydrology Ecosystem research Support System (CHESS) | | | Could be mapped to fdri:originatingProgramme?
| :date_created | 2020-05-04 | dct:modified | |
| :creator_name | Robinson, E. L. | | Y | Could indirectly map creator_* properties to an fdri:Agent resource and relate with dct:creator
| :creator_email | enquiries@ceh.ac.uk
| :creator_institution | UK Centre for Ecology & Hydrology (UKCEH)
| :contributor_name | Blyth, E. M., Clark, D. B., Comyn-Platt, E., Rudd, A. C. | | | Could be indirectly mapped to dct:contributor but without identifiers (ORCID?) no way to link
| :metadata_link | https://catalogue.ceh.ac.uk/documents/2ab15bf0-ad08-415c-ba64-831168be7293
| :licence | Licensing conditions apply: https://catalogue.ceh.ac.uk/documents/2ab15bf0-ad08-415c-ba64-831168be7293 | | | This example links to the catalog record and not to the license terms. Is this a netCDF metadata issue?
| :id | https://doi.org/10.5285/2ab15bf0-ad08-415c-ba64-831168be7293 | dct:identifier | Y | Not sure if we are expecting a DOI to be assigned at the point of submission to FDRI? Also note that another example as a GUID identifier not formatted as a URL
| :institution | UK Centre for Ecology & Hydrology (UKCEH)
| :naming_authority | DataCITE
| :publisher_name | NERC Environmental Information Data Centre (EIDC)
| :publisher_url | http://eidc.ceh.ac.uk/ | dct:publisher | Y | Assume that other publisher_* metadata is redundant?
| :publisher_email | eidc@ceh.ac.uk
| :publisher_institution | NERC Data Centre hosted at UKCEH
| :publisher_type | NERC Data Centre
| :Conventions | CF-1.7, ACDD
| :grid_mapping | crs |
| :date_created | 2014-04-14 | dcat:created
| :date_modified | 2014-04-14 | dcat:modified
| :date_issued | 2014-01-06 | dcat:issued
| :version | v1.0 | dcat:version
| :version_comment | The version number of each...| adms:versionNotes
| :comment | In line with standard UK convention... |

As can be seen from the table, only a few of the existing netCDF metadata properties are mappable to FDRI dataset metadata and of those many require some additional pre-processing. In some cases we may want to consider adding properties to the model - e.g. to support references and history notes. In other cases it may be better to push requirements upstream on the creation of netCDF metadata for FDRI - e.g. requiring ORCIDs for creators and contributors, using a controlled vocabulary for :project. In any case, it is clear that the simple direct property mapping facilities provided by the BALD specification are not sufficient for our metadata mapping needs.

## Defining FDRI metadata properties

A complementary approach to mapping global properties in existing netCDF/Zarr files would be to define properties that map more cleanly to the FDRI model and that require the use of FDRI reference data. e.g. defining  `:originatingProgramme` as a global property where the value is expected to be the identifier of an Environmental Monitoring Programme taken from the FDRI reference data. Such a specification could also make use of WKT syntax for geospatial metadata, require ORCIDs for identifying people, and controlled vocabularies for licenses. Files carrying such metadata would then be more accurately integrated into the fine-grained metadata store.

BALD provides two ways of mapping netCDF property names to URIs. The first is to use a prefix mapping so that all properties whose name starts with a given prefix (e.g. `fdri__`) map to a URI plus the part following the prefix. The alternative is to explicitly map each property name to the RDF property URI. This latter approach would be more appropriate in the FDRI case as we use RDF properties from a mix of namespaces and a direct mapping means that it isn ot necessary to expose creators of netCDF files to that level of technical detail.

By providing a single mapping that covers the subset of existing global properties that can be directly mapped to FDRI, plus the FDRI "preferred" properties, metadata creators are free to pick the most appropriate set of properties for their needs. 

Any minimum metadata requirements for FDRI (e.g. in order to fulfil minimum metadata requirements when publising to the EIDC) should also be communicated to metadata creators and validated as part of the ingestion pipeline. 

## NetCDF Structural Metadata Mapping

To support the BALD representation of netCDF structural metadata, it is necessary to extend the model to include the `bald:Container` type. 

The model should also be extended to add an explicit type for gridded datasets. This type would extend the existing `fdri:ObservationDataset` and the `bald:Container` type, allowing the dataset object to carry the structural metadata for the netCDF content.


> [NOTE]
> The tools for performing this metadata mapping are relatively thin on the ground, but there is a (Python library)[https://github.com/binary-array-ld/bald] and a [Kotlin library](https://github.com/binary-array-ld/net.binary_array_ld.bald). The Kotlin library was originally developed by Simon Oakes who is at Epimorphics. The Python library required a few minor tweaks to get running locally but otherwise appears to be usable from the cursory use we have made of it thus far. If the extraction of metadata from netCDF files is planned to be part of the FDRI processing pipeline, it is recommended that the FDRI project fork the GitHub repo and consider contributing back the changes needed to bring it up to date.

The BALD container model includes some relatively involved modelling of the dimensions of a netCDF file using a technique of "broadcasting", borrowed from the numPy toolkit (https://numpy.org/devdocs/user/basics.broadcasting.html). This technique allows mappings between related dimensions but relies on interpretation of ordred lists in RDF. There is a question about the usefulness of this metadata in the context of dataset publication - would it really be necessary for users of the data to know about these dimension relations at this level of detail before accessing the netCDF content?
