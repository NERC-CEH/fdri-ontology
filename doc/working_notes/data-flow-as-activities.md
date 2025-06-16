The diagram below attempts to illustrate how PROV-O Activities can be use to track the progress of processing data through a typical FDRI data pipeline. In this case the data pipeline is based on the existring data transformations which may be modified or streamlined in future, but which are assumed to be broadly representative of a future-state data processing pipeline.

In the diagram, the yellow boxes represent **Activities**, green boxes represent  **Datasets**, blue boxes represent **Configuration**, and orange boxes represent **Scripts**.

Activities generate or modify resources (typically datasets in this processing pipeline), and make use of configuration files. The execution of a scripted activity is assocaiated with the specific version of the script that is run.

In most cases, an activity will result in the generation of a *new version* of an existing datataset. Using DCAT it is possible to separate out the record for each version of a dataset from the record for the enduring dataset. It is not clear from the information we have whether it is currently the case or whether it would be desirable for it to be the case that each distinct version of a dataset corresponds to one or more physical resources (e.g. files in cloud storage), but the structure of dataset versions here makes it possible to record the location of the data for specific versions, or for the enduring dataset.

It is also possible to treate metadata as versioned using the same mechanism (in fact we would recommend considering metadata for activities to also be cataloged resources in the data catalog), so a record of an activity would then be recording that version A of the output dataset was generated from version X of the input dataset, by version Y of the script running with version Z of the configuration metadata.

The diagram below shows a discrete Activity and Dataset Version being recorded for each run of a data pipeline. Over 
time this would result in the detailed metadata store being populated with a very large number of version records, which
may become a performance issue and would certainly be difficult to manage in a meaningful way. There are therefore some
design decisions to be made regarding this approach. One simplification would be to only record a new activity and a 
new dataset version when there are changes either to the script or to the configuration metadata used to run the script.
The design decision could be different for different stages of the processing pipeline, although this then also incurs
a bit of cognitive overhead in system users if versioning is not consistently modelled through the pipeline. We could
possibly be guided by considering the persistent artefacts generated at each stage of the pipeline, and only to create
dataset versions (and by extension discrete activity records) when there is a persistent artefact produced. Finally,
it is also possible to consider approaches to periodically compressing or archiving portions of the version history as
a means of reducing the processing burden on the metadata store. 

NOTE: For simplicity in this diagram I have assumed that a single aggregtation script run produces all three aggregate forms of level 3 data. I realise that this might not actually be the case and that there would be a separate activity for each aggregate form of the level 3 data, but hopefully it is clear from this diagram that accomodating that within the proposed design would be completely straightforward.

```mermaid
flowchart BT
    ti("`fa:fa-cog **Telemetry Ingest**
        startedAtTime: ...
        endAtTime: ...
        receivedFrom: ...
    `"):::activity
    ds1("`fa:fa-table **Level -1 Data**
    distribution: ...`"):::dataset
    ds1 --wasGeneratedBy--> ti
    pp("`fa:fa-cog **Pre-process**
        startedAtTime: ...
        endedAtTime: ...
    `"):::activity
    ppm("`fa:fa-scroll **Pre-process Metadata**
        distribution: ...
    `"):::document
    pps("`fa:fa-code **Pre-process Script v1.1**`"):::script
    pp --used--> ds1 & ppm
    pp --wasAssociatedWith--> pps
    ds2vds("`fa:fa-table **Level 0 Data**`"):::dataset
    ds2vds --hasVersion--> ds2.99
    ds2vds --hasVersion--> ds2.100
    ds2vds --hasCurrentVersion--> ds2.100
    ds2.100("`fa:fa-table **Level 0 Data v. 100**`"):::dataset
    ds2.99("`fa:fa-table **Level 0 Data v. 99**`"):::dataset
    ds2.100 --previousVersion--> ds2.99
    ds2.100 --wasGeneratedBy--> pp
    vc("`fa:fa-cog **Visual Check**
        startedAtTime: ...
        endedAtTime: ...
    `"):::activity
    qcfm("`fa:fa-scroll **Basic QC Fault Metadata**
    distribution: ...`"):::document
    qcm("`fa:fa-scroll **Basic QC Metadata**
    distribution: ...`"):::document
    qcs("`fa:fa-code **Basic QC Script v2.2**
    distribution: ...`"):::script
    qcfm --wasUpdatedBy --> vc
    vc --used--> ds2.100
    basicqc("`fa:fa-cog **Basic QC**
        startedAtTime: ...
        endedAtTime: ....
    `"):::activity
    basicqc --used--> ds2.100 & qcfm & qcm
    basicqc --wasAssociatedWith--> qcs
    ds3("`fa:fa-table **Level 1 Data + Basic QC Flags**
    distribution: ...
    servedBy: ...`"):::dataset
    ds3 --wasGeneratedBy--> basicqc
    mlp("`fa:fa-cog **ML Prediction**
        startedAtTime: ....
        endedAtTime: ....
    `"):::activity
    mlpm("`fa:fa-scroll **ML Model Params**
      distribution: ....
    `"):::document
    mlps("`fa:fa-code **ML Script v1.2**`"):::script
    ds4("`fa:fa-table **Level 1 Prediction**`"):::dataset
    mlp --wasAssociatedWith--> mlps
    mlp --used--> mlpm & ds3
    ds4 --wasGeneratedBy--> mlp
    pc("`fa:fa-cog **Prediction Comparison**`"):::activity
    ds5("`fa:fa-table **Level 1 + ML Flags**`"):::dataset
    pc --used--> ds4 & ds3
    ds5 --wasGeneratedBy--> pc
    ds6("`fa:fa-table **Level 2 Data**`"):::dataset
    ds6.99("`fa:fa-table **Level 2 Data v.100**`"):::dataset
    ds6.100("`fa:fa-table **Level 2 Data v.100**`"):::dataset
    gf("`fa:fa-cog **Gap Filling**`"):::activity
    gfm("`fa:fa-scroll **Gap Filling Metadata**`"):::document
    gfs("`fa:fa-code **Gap Filling Script**`"):::script
    gf --used--> ds5 &  gfm
    gf --wasAssociatedWith--> gfs
    ds6 --hasVersion--> ds6.99
    ds6 --hasVersion--> ds6.100
    ds6 --hasCurrentVersion--> ds6.100
    ds6.100 --previousVersion--> ds6.99
    ds6.100 --wasGeneratedBy--> gf
    l3p("`fa:fa-cog **Level 3 Processing**`"):::activity
    l3pm("`fa:fa-scroll **Level 3 Processing Metadata**`"):::document
    l3ps("`fa:fa-code **Level 3 Processing Script**`"):::script
    ds7.100("`fa:fa-table **Level 3 Data v.100**`"):::dataset
    l3p --used--> ds6.100 & l3pm
    l3p --wasAssociatedWith--> l3ps
    ds7.100 --wasGeneratedBy --> l3p
    ds8("`fa:fa-table **Level 3 - 1 min**`"):::dataset
    ds8.99("`fa:fa-table **Level 3 - 1 min v.99**`"):::dataset
    ds8.100("`fa:fa-table **Level 3 - 1 min v.100**`"):::dataset
    ds9("`fa:fa-table **Level 3 - 15 min**`"):::dataset
    ds9.99("`fa:fa-table **Level 3 - 15 min v.99**`"):::dataset
    ds9.100("`fa:fa-table **Level 3 - 15 min v.100**`"):::dataset
    ds10("`fa:fa-table **Level 3 - daily**`"):::dataset
    ds10.99("`fa:fa-table **Level 3 - daily v.99**`"):::dataset
    ds10.100("`fa:fa-table **Level 3 - daily v.100**`"):::dataset
    agg("`fa:fa-cog **Aggregation**`"):::activity
    aggm("`fa:fa-scroll **Aggregation Metadata**`"):::document
    aggs("`fa:fa-code **Aggregation Script**`"):::script
    agg --used--> ds7.100 & aggm
    agg --wasAssociatedWith--> aggs
    ds8.100 --previousVersion--> ds8.99
    ds8.100 --wasGeneratedBy--> agg
    ds8 --hasVersion--> ds8.99
    ds8 --hasVersion--> ds8.100
    ds8 --hasCurrentVersion--> ds8.100
    ds9.100 --previousVersion--> ds9.99
    ds9.100 --wasGeneratedBy--> agg
    ds9 --hasVersion--> ds9.99
    ds9 --hasVersion--> ds9.100
    ds9 --hasCurrentVersion--> ds9.100
    ds10.100 --wasGeneratedBy--> agg
    ds10.100 --previousVersion--> ds10.99
    ds10 --hasVersion--> ds10.100
    ds10 --hasCurrentVersion--> ds10.100
    ds10 --hasVersion--> ds10.99
    ds9.99~~~agg
    ds9.100~~~ds9.99
    ds10.99~~~agg
    ds10.100~~~ds10.99

    classDef activity stroke:#f50, fill:#f6d700
    classDef dataset stroke:#030,fill:#83d204
    classDef document stroke:#003, fill: #9CF
    classDef script stroke:#f50, fill: #f98700
```

