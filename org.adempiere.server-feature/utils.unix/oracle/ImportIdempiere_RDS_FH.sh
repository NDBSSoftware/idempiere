#!/bin/sh

# $Id: ImportAdempiere.sh,v 1.10 2005/12/20 07:12:17 jjanke Exp $
echo	idempiere Database Import		$Revision: 1.10 $

echo	Importing idempiere DB from $IDEMPIERE_HOME/data/seed/Adempiere.dmp

if [ $# -le 2 ]
  then
    echo "Usage:		$0 <systemAccount> <AdempiereID> <AdempierePWD>"
    echo "Example:	$0 system/manager idempiere idempiere"
    exit 1
fi
if [ "$IDEMPIERE_HOME" = "" -o  "$ADEMPIERE_DB_NAME" = "" ]
  then
    echo "Please make sure that the environment variables are set correctly:"
    echo "	IDEMPIERE_HOME	e.g. /idempiere"
    echo "	ADEMPIERE_DB_NAME	e.g. adempiere.adempiere.org"
    exit 1
fi

RDS_SYSTEM_USER="$6"
RDS_SYSTEM_PASSWORD="$7"
RDS_SYSTEM_HOST="$8"
RDS_SYSTEM_PORT="$9"
RDS_SYSTEM_DATABASE="${10}"

ISAMAZONRDS=N
if echo "$RDS_SYSTEM_HOST" | grep 'rds.amazonaws.com$' > /dev/null
then
    ISAMAZONRDS=Y
    RDS_SYSTEM_USER=systemuser
else
    echo "
-------------------------------------
This script is just intended to upload and import the iDempiere seed to amazon oracle RDS
for normal installation please use RUN_ImportIdempiere.sh
-------------------------------------
"
    exit 1
fi

echo -------------------------------------
echo Re-Create DB user
echo -------------------------------------
echo "sqlplus ${RDS_SYSTEM_USER}/${RDS_SYSTEM_PASSWORD}@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/CreateUser.sql $2 $3"
sqlplus ${RDS_SYSTEM_USER}/${RDS_SYSTEM_PASSWORD}@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/CreateUser.sql $2 $3

echo -------------------------------------
echo Re-Create DataPump directory - in local oracle XE
echo -------------------------------------
echo "sqlplus $1@$ADEMPIERE_DB_SERVER:$ADEMPIERE_DB_PORT/$ADEMPIERE_DB_NAME @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/CreateDataPumpDir.sql $IDEMPIERE_HOME/data/seed"
sqlplus $1@$ADEMPIERE_DB_SERVER:$ADEMPIERE_DB_PORT/$ADEMPIERE_DB_NAME @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/CreateDataPumpDir.sql $IDEMPIERE_HOME/data/seed
# Note the user running this script must be member of dba group:  usermod -G dba idempiere
chgrp dba $IDEMPIERE_HOME/data
chmod 770 $IDEMPIERE_HOME/data
chgrp dba $IDEMPIERE_HOME/data/seed
chmod 770 $IDEMPIERE_HOME/data/seed
chgrp dba $IDEMPIERE_HOME/data/seed/Adempiere.dmp
chmod 640 $IDEMPIERE_HOME/data/seed/Adempiere.dmp

echo -------------------------------------
echo Copy Adempiere.dmp file from local Oracle-XE to remote RDS
echo -------------------------------------
echo "sqlplus $1@$ADEMPIERE_DB_SERVER:$ADEMPIERE_DB_PORT/$ADEMPIERE_DB_NAME @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/PutFile_RDS_FH.sql ${RDS_SYSTEM_USER} ${RDS_SYSTEM_PASSWORD} ${RDS_SYSTEM_HOST}:${RDS_SYSTEM_PORT}/${RDS_SYSTEM_DATABASE}"
sqlplus $1@$ADEMPIERE_DB_SERVER:$ADEMPIERE_DB_PORT/$ADEMPIERE_DB_NAME @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/PutFile_RDS_FH.sql ${RDS_SYSTEM_USER} ${RDS_SYSTEM_PASSWORD} ${RDS_SYSTEM_HOST}:${RDS_SYSTEM_PORT}/${RDS_SYSTEM_DATABASE}

echo -------------------------------------
echo Import Adempiere.dmp into remote RDS
echo -------------------------------------
echo "impdp $2/$3@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE DIRECTORY=DATA_PUMP_DIR DUMPFILE=Adempiere.dmp REMAP_SCHEMA=reference:$2"
impdp $2/$3@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE DIRECTORY=DATA_PUMP_DIR DUMPFILE=Adempiere.dmp REMAP_SCHEMA=reference:$2

echo -------------------------------------
echo Clean Adempiere.dmp on remote RDS
echo -------------------------------------
echo "sqlplus ${RDS_SYSTEM_USER}/${RDS_SYSTEM_PASSWORD}@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/CleanFile_RDS_FH.sql"
sqlplus ${RDS_SYSTEM_USER}/${RDS_SYSTEM_PASSWORD}@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/CleanFile_RDS_FH.sql

echo -------------------------------------
echo Check System
echo Import may show some warnings. This is OK as long as the following does not show errors
echo -------------------------------------
echo "sqlplus $2/$3@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/AfterImport.sql"
sqlplus $2/$3@$RDS_SYSTEM_HOST:$RDS_SYSTEM_PORT/$RDS_SYSTEM_DATABASE @$IDEMPIERE_HOME/utils/$ADEMPIERE_DB_PATH/AfterImport.sql
