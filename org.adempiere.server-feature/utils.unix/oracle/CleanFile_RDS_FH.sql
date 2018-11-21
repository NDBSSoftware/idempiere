BEGIN
UTL_FILE.FREMOVE (
   location => 'DATA_PUMP_DIR',
   filename => 'Adempiere.dmp');
END;
/
EXIT
