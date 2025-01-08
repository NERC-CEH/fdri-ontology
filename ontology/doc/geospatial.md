# Notes on Geo-spatial Resources

Several classes in the FDRI ontology represent geo-spatially located entities which are either persistent or temporary in nature. In particular `fdri:EnvironmentalMonitoringFacility`, `fdri:GeospatialFeature` and `fdri:MobileDeployment`. To facilitate a range of both machine and human access to geospatial data relating to these entities the model provides a number of distinct properties on these classes.

`geos:hasGeometry` MUST be provided and is intended to be used to provide the preferred geometry for the entity, whether this be a boundary, path or point. This property is intended to provide a consistently available property for machine processing of geospatial entities with some flexibility with regards to how the entity is described geospatially.

`fdri:hasRepresentativePoint` MUST be provided and MUST provide a POINT location for a representative point for the entity. This property is intended to provide a consistently available property for machine processing of geospatial entities as a set of point locations.

`geo:lat` and `geo:long` SHOULD be provided and SHOULD provide the WGS84 latitude and longitude of the same point as `fdri:hasRepresentativePoint`. These properties are intended to facilitate easy access to representative point information for API users.

`spatialrelations:easting` and `spatialrelations:northing` SHOULD be provided when the entity lies within the GB National Grid and SHOULD provide the easting and northing of the same point as `fdri:hasRepresentativePoint`. These properties are intended to facilitate easy access to representative point information for API users.

`geos:hasCentroid` MAY be used to provide the coordinates of a centroid point for the entity.

`geos:hasBoundingBox` MAY be used to provide the coordinates of a bounding box that contains the entity.

