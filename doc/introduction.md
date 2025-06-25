## Introduction

This document has been created to further discussion on the design of the model for the FDRI metadata store.
It outlines a model designed to make use of existing standards such as DCAT, PROV-O, SOSA/SSN and i-Adopt as far as is practical.

DCAT provides the concepts of Dataset, DataService and a catalog consisting of records of resources which are managed separate from the resources they describe.
PROV-O provides a model of activities that create, modify and use entities and that are associated with Agents (both human and non-human) who perform or otherwise participate in those activities.
SOSA/SSN provides the notions of observable properties as things that can be measured by sensors against some feature of interest.
i-Adopt provides the foudation for structuring the definition of observable properties.

### GitHub Repository

The FDRI ontology and its documentation are maintained at https://github.com/NERC-CEH/fdri-ontology

The latest releases are available at https://github.com/NERC-CEH/fdri-ontology/releases and include the OWL ontology (`fdri-metadata.ttl`), and the version of this documentation that goes with the release as a zipped package (`doc.tar.gz`).

### Note on diagrams

UML class diagrams have been used extensively to document model design. Familiarity with UML class diagram notation is assumed. Examples of how the model is intended to be used are diagrammed in a simpler flowchart notation.

Due to a limitation with MermaidJS which is used to render the diagrams, the names of properties on relations in UML diagrams are written with an underscore between the prefix and the local part of the identifier rather than the traditional colon character.

### Namespaces Used

This document uses the following namespaces:

| Prefix | URI    | Source |
|--------|--------|--------|
| adms | http://www.w3.org/ns/adms# |	[Asset Description Metadata Schema](https://www.w3.org/TR/vocab-adms/)
| dcat | http://www.w3.org/ns/dcat#	| [Data Catalog Vocabulary (DCAT) - Version 3](https://www.w3.org/TR/vocab-dcat-3/)
| dct  | http://purl.org/dc/terms/	| [DCMI Metadata Terms](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/)
| iop  | https://w3id.org/iadopt/ont/ | [i-ADOPT Framework Ontology](https://w3id.org/iadopt/ont/)
| prov | http://www.w3.org/ns/prov#	| [PROV-O: The PROV Ontolog](https://www.w3.org/TR/prov-o/)
| foaf | http://xmlns.com/foaf/0.1/	| [FOAF Vocabulary Specification 0.99 (Paddington Edition)](http://xmlns.com/foaf/spec)
| rdf  | http://www.w3.org/1999/02/22-rdf-syntax-ns#	| [RDF 1.1 XML Syntax](https://www.w3.org/TR/rdf-syntax-grammar/)
| rdfs | http://www.w3.org/2000/01/rdf-schema# | [RDF Schema 1.1](https://www.w3.org/TR/rdf-schema/)
| sosa | http://www.w3.org/ns/sosa/ | [Semantic Sensor Network Ontology](https://www.w3.org/TR/vocab-ssn/)
| ssn  | http://www.w3.org/ns/ssn/ | [Semantic Sensor Network Ontology](https://www.w3.org/TR/vocab-ssn/)
| time | http://www.w3.org/2006/time#	| [Time Ontology in OWL](https://www.w3.org/TR/owl-time/)
| vcard | http://www.w3.org/2006/vcard/ns# | [vCard Ontology - for describing People and Organizations](https://www.w3.org/TR/vcard-rdf/)
| xsd | http://www.w3.org/2001/XMLSchema#	| [W3C XML Schema Definition Language (XSD) 1.1 Part 2: Datatypes](http://www.w3.org/TR/xmlschema11-2/)

In addition the prefix `fdri` is used to refer to the namespace for the FDRI metadata model. This namespace has not yet been assigned.