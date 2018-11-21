#!/bin/sh
#
# $Id: RUN_ImportIdempiere.sh,v 1.9 2005/01/22 21:59:15 jjanke Exp $

if [ $IDEMPIERE_HOME ]; then
  cd $IDEMPIERE_HOME/utils
fi
. ./myEnvironment.sh Server
echo Import idempiere - $IDEMPIERE_HOME \($ADEMPIERE_DB_NAME\)

SUFFIX=""
SYSUSER=system
if [ $ADEMPIERE_DB_PATH = "postgresql" ]
then
    SUFFIX="_pg"
    SYSUSER=postgres
fi

echo Re-Create idempiere User and import $IDEMPIERE_HOME/data/Adempiere${SUFFIX}.dmp - \($ADEMPIERE_DB_NAME\)
echo == The import will show warnings. This is OK ==
cd $IDEMPIERE_HOME/data/seed
jar xvf Adempiere${SUFFIX}.jar
cd $IDEMPIERE_HOME/utils
ls -lsa $IDEMPIERE_HOME/data/seed/Adempiere${SUFFIX}.dmp
echo "
-------------------------------------
Please note this script requires:
- in RDS a user with name SYSTEMUSER with the same parameter provided for SYSTEM user here
- locally it requires an Oracle XE installation with SYSTEM user with the same parameter provided here
-------------------------------------
"

if [ $# -ne 5 ]
then
    echo "Usage:
$0 SYSTEM_USER SYSTEM_PASSWORD ENDPOINT PORT INSTANCE
ENDPOINT must be an amazon RDS oracle instance
SYSTEM_USER must be a user with permissions to create users and grant CONNECT, DBA, RESOURCE, UNLIMITED TABLESPACE"
    exit 1
fi

echo Press enter to continue ...
read in

RDS_SYSTEM_USER="$1"
RDS_SYSTEM_PASSWORD="$2"
RDS_SYSTEM_HOST="$3"
RDS_SYSTEM_PORT="$4"
RDS_SYSTEM_DATABASE="$5"
$ADEMPIERE_DB_PATH/ImportIdempiere_RDS_FH.sh "$SYSUSER/$ADEMPIERE_DB_SYSTEM" "$ADEMPIERE_DB_USER" "$ADEMPIERE_DB_PASSWORD" "$ADEMPIERE_DB_SYSTEM" "$SUFFIX" \
    "$RDS_SYSTEM_USER" "$RDS_SYSTEM_PASSWORD" "$RDS_SYSTEM_HOST" "$RDS_SYSTEM_PORT" "$RDS_SYSTEM_DATABASE"
