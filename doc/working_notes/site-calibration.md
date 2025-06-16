# Site Calibration Properties


Working notes

1. Site calibration details are recorded as annotation on a site. The Annotation structure provides the facility for recording a current value as well as historical values for any given property.
*What about calibration provenance information, when performed, what method was used? Requires an activity associated with each annotation value? Can use time-bound property values to associate each value with an active date range perhaps?*
1. Recorded as observations against a site as the feature of interest. Provides a way to record the time of the calibration (resultTime) vs the time of the sampling (phenomenonTime) and the method used (procedure), but not a way to differentiate between active and inactive calibration values, unless you simply always take the most recent (by resultTime) observation for a given property
2. Some specialisation of one of the above structures to support any missing properties. Specialisation of observation may be appropriate?
   
Possibly worth noting that it may be the case that some / all of this calibration information is actually specific to a sensor and not to the site as a whole. There isn't really enough information in the source data we have to be sure about that.

Note from Matt:

> For this soil calibration info, I would see the raw soil sampling data as a dataset for the site, rather than a calibration. It's a more complex set of data though and we may want to store that outside the time series system.
> 
> The calibration info (in the csv file) resulting values from this soil moisture sampling is then used to calculate soil moisture from the COSMOS counts time series, but it wouldn't need to be automatically derived in the system from the soil sampling data. So really these values should become part of a processing config, separate from the soil sampling data, and manually edited in the case another set of soil sampling is undertaken.

## Source data columns

* REF_SOIL_MOISTURE
* REF_BULKDENSITY
* REF_LATTICEWATER
* REF_Q0
* REF_C0
* REF_CTS_MOD_CORR
* REF_CTS_MOD2_CORR
* REF_CTS_BARE_CORR
* REF_CTS_SNOW_CORR
* N0_MOD
* N0_MOD2
* N0_BARE
* N0_SNOW
* COSMOS_FACTOR_PROBE_MOD
* COSMOS_FACTOR_PROBE_MOD2
* COSMOS_FACTOR_PROBE_BARE
* COSMOS_FACTOR_PROBE_SNOW
* THETA_MIN
* THETA_MAX
* THETA_MIN_DATE
* THETA_MAX_DATE
* REF_SOC
* CALIBRATION_COMMENT
* PROBE_EFFDEPTH
* N_MIN
* METHOD
* SOIL_COMMENT
* N_MAX
* L
* ACTIVE
* REF_BULKDENSITY_STD
* REF_LATTICEWATER_STD
* REF_SOC_STD

Column descriptions are in `calibration_info_columns.csv`