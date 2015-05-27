#!/bin/sh

PROJECT_NAME=gearpump

#get directory for this script
GEARPUMP_CM_HOME=`readlink -f $0`
GEARPUMP_CM_HOME=`dirname $GEARPUMP_CM_HOME`
echo $GEARPUMP_CM_HOME

#find correct gearpump project directory
GEARPUMP_HOME=`pwd`
while [ ! -f $GEARPUMP_HOME/$PROJECT_NAME/version.sbt ]
do
     GEARPUMP_HOME=`readlink -f $GEARPUMP_HOME/..`
     if [ "$GEARPUMP_HOME" = "/" ]; then
        echo "Can't find gearpump project directory in parent directories. Exit with error!"
        exit 1
     fi
done
GEARPUMP_HOME=$GEARPUMP_HOME/$PROJECT_NAME
echo $GEARPUMP_HOME

#clean old build
rm -rf $GEARPUMP_CM_HOME/output

#build Gearpump
cd $GEARPUMP_HOME/
sbt clean assembly pack

#get version
GEARPUMP_VERSION=`cat $GEARPUMP_HOME/version.sbt |cut -d'"' -f2`
echo "Gearpump version is $GEARPUMP_VERSION"

CLOUDERA_TOPDIR=$GEARPUMP_CM_HOME/output
CLOUDERA_PARCELDIR=$CLOUDERA_TOPDIR/parcel
mkdir -p $CLOUDERA_PARCELDIR
cp -r $GEARPUMP_HOME/output/target/pack $CLOUDERA_PARCELDIR
cp -r $GEARPUMP_CM_HOME/parcel $CLOUDERA_PARCELDIR/pack
cd $CLOUDERA_PARCELDIR/pack
mv parcel meta
#replace version string in meta files
cd $CLOUDERA_PARCELDIR/pack/meta/
metalist=`ls .`
for f in $metalist
do
  echo "##################3 replace $f"
  sed -i "s/{version}/$GEARPUMP_VERSION/" $f
done

#package
PACKAGE_NAME=gearpump-${GEARPUMP_VERSION}
cd $CLOUDERA_PARCELDIR
mv pack $PACKAGE_NAME
tar zcvf ${PACKAGE_NAME}-el6.parcel $PACKAGE_NAME --owner=root --group=root
for suffix in el5 sles11 lucid precise squeeze wheezy
do
	ln -s ${PACKAGE_NAME}-el6.parcel ${PACKAGE_NAME}-${suffix}.parcel
done
rm $CLOUDERA_PARCELDIR/$PACKAGE_NAME -rf

#create manifest
cd /tmp
git clone https://github.com/cloudera/cm_ext.git
cd $CLOUDERA_PARCELDIR
python /tmp/cm_ext/make_manifest/make_manifest.py
rm -rf /tmp/cm_ext


cd $GEARPUMP_CM_HOME/csd
mvn package
CLOUDERA_CSDDIR=$CLOUDERA_TOPDIR/csd
mkdir -p $CLOUDERA_CSDDIR
cp $GEARPUMP_CM_HOME/csd/target/*.jar $CLOUDERA_CSDDIR

echo ""
echo ""
echo ""
echo "#######################################################"
echo "Gearpump parcels are built under $CLOUDERA_PARCELDIR."
echo "Gearpump CSD is under $CLOUDERA_CSDDIR."
echo "You can find installation guide at http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_mc_addon_services.html"
echo "#######################################################"
