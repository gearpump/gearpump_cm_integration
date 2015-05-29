# gearpump_cm_integration

This is the project to integration Gearpump into Cloudera Manager. Basically, This project will build parcels and csd for Gearpump.

To make the build, you shall

1. Put gearpump project and gearpump_cm_integration (this project) under the same parent directory.
2. run build.sh to make the build

To install built parcel and csds, you shall follow the instruction from [Cloudera Guide](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_mc_addon_services.html).

Basically, the steps are:

1. host the built parcels under gearpump_cm_integration/output/parcel under a web server or a ftp server
2. copy the built GEARPUMP-1.0.jar (the built csd) under /opt/cloudera/csd directory of the CM node. 
3. restart CM and CM agent services
4. add parcel repository address defined in step 1 to CM.
5. deploy parcels using CM.
6. add a Gearpump service in CM and configure roles and provison the service.

