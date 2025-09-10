## Gridded Dataset Model

An `fdri:GriddedDataset` is an [`fdri:ObservationDataset`](time-series-dataset.md) which is distributed as multi-dimensional array data.
Formats that use this approach include netCDF and ZARR. In addition to all of the standard metadata of an `fdri:ObservationDataset`,
an `fdri:GriddedDataset` includes metadata about the structure of the multi-dimensional data.

### Gridded Dataset Structure

An `fdri:GriddedDataset` contains:
  * zero or more `fdri:GriddedContainer`s
  * zero or more `fdri:Dimension`s,
  * zero or more `fdri:Array`s, and

An `fdri:GriddedContainer` is a nested structure which may itself contain `fdri:Dimensions`, `fdri:Arrays` and other `fdri:GriddedContainer`s.

An `fdri:Dimension` can be used to provide a common definition of the extent of a dimension which is shared by many `fdri:Arrays`. The size of the dimension can be specified as an integer value using the `fdri:size` property.

An `fdri:Array` represents one multi-dimensional array in the dataset. The property `fdri:shape` can be used to define the shape of an array as an RDF list of integer values giving the size of each dimension of the array. The property `fdri:references` can be used to reference the `fdri:Dimension`s and/or `fdri:Array`s that define each of the dimensions of this array.

An `fdri:Array`, `fdri:Dimension` or `fdri:GriddedContainer` may reference the `fdri:Variable`(s) it provides values for using the `sosa:observedProperty` property, or the `fdri:Measure`(s) it provides values for using the `fdri:measure`. 
All of these types also allow annotations to be referenced using `fdri:hasAnnotation`. Annotations are the recommended way to capture additional metadata that may be encoded in the dataset such as unit of meaure, coordinates, methods used etc.

```mermaid
---
config:
    class:
        hideEmptyMembersBox: true
---
classDiagram
class ObservationDataset["fdri:ObservationDataset"]
class GriddedDataset["fdri:GriddedDataset"]
class GriddedContainer["fdri:GriddedContainer"]
class GriddedDatasetResource["fdri:GriddedDatasetResource"]
class Dimension["fdri:Dimension"] {
  fdri:size: xsd:integer
}
class Array["fdri:Array"] {
  fdri:shape: List&lt;xsd:integer&gt;
}
class Annotation["fdri:Annotation"]
class Variable["fdri:Variable"]
class Measure["fdri:Measure"]

ObservationDataset <|-- GriddedDataset
GriddedDatasetResource <|-- GriddedContainer
GriddedDatasetResource <|-- Dimension
GriddedDatasetResource <|-- Array

Array --> Dimension: fdri_references
Array --> Array: fdri_references
GriddedDataset --> GriddedDatasetResource: fdri_contains
GriddedContainer --> GriddedDatasetResource: fdri_contains
GriddedDatasetResource --> Annotation: fdri_hasAnnotation
GriddedDatasetResource --> Variable: sosa_observedProperty
GriddedDatasetResource --> Measure: fdri_measure
```

> **QUESTION**
> The current modelling does not preserve the ordering of references from an Array to its members in the `fdri:references` property, but *does* preserve the ordering of the dimensions in the `fdri:shape` property. This has been done to keep the `fdri:references` relation simple and to avoid requiring rdf:List processing to access the references. If there are use-cases for preserving the order of references in the metadata store, then either the range of `fdri:references` should be changed, or a new order-preserving property (e.g. `fdri:referenceList`?) should be introduced. 