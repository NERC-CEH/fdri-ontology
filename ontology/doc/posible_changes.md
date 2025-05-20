## Remove Mobile Deployment

`MobileDeployment` is not really needed to capture activities involving mobile platforms. A better solution is proposed in the draft notes for UAV datasets where sensors are deployed to a mobile platform which then participates in Environmental Monitoring Activities.

With this change, there may then be a case for collapsing `StaticDeployment` into `Deployment`.

# DONE: Remove fdri:Agent and its subclasses

Rather than remove the FDRI ontology classes we opted to instead just root the FDRI Agent hierarhcy as a subclass of prov:Agent.

# DONE: Remove Catchment and Region types

These are now terms in a FacilityGroupType concept scheme