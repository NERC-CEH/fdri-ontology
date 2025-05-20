## Remove Mobile Deployment

`MobileDeployment` is not really needed to capture activities involving mobile platforms. A better solution is proposed in the draft notes for UAV datasets where sensors are deployed to a mobile platform which then participates in Environmental Monitoring Activities.

With this change, there may then be a case for collapsing `StaticDeployment` into `Deployment`.

# Remove fdri:Agent and its subclasses

The classes `fdri:Agent`, `fdri:Person`, `fdri:Organisation` and `fdri:SoftwareAgent` mirror the classes already defined by the PROV-O ontology.
The only additions made to the assertions in PROV-O are making these classes subclass of `dcat:CataloguedResource` and asserting that they can have 0+ `hasAnnotation` properties. 

The subclassing of `dcat:CataloguedResource` is not really needed in OWL and in fact we are unlikely to use that relationship.

The assertion about the `fdri:hasAnnotation` property most likely will be used but this could maybe be asserted directly against the PROV-O classes.

In the recordspec record, this simply means that the class URIs of `Agent`, `Person`, `Organization` and `SoftwareAgent` would be moved from the FDRI namespace to the PROV-O namespace.

# Remove Catchment and Region types

These are now terms in a FacilityGroupType concept scheme