drop public database link remoterds
/
create public database link remoterds connect to &1 identified by "&2" using '&3'
/
BEGIN
  DBMS_FILE_TRANSFER.put_file(
   source_directory_object      => 'ADEMPIERE_DATA_PUMP_DIR',
   source_file_name             => 'Adempiere.dmp',
   destination_database         => 'remoterds',
   destination_directory_object => 'DATA_PUMP_DIR',
   destination_file_name        => 'Adempiere.dmp');
END;
/
drop public database link remoterds
/
EXIT
