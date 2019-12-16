SET SQLBLANKLINES ON
SET DEFINE OFF

-- Dec 10, 2019, 7:14:05 PM CET
ALTER TABLE T_Selection MODIFY ViewID VARCHAR2(2000)
;

-- table doesn't exist in camaleo2
--ALTER TABLE T_Selection_InfoWindow MODIFY ViewID VARCHAR2(2000)
--;

SELECT register_migration_script('201912101913_IDEMPIERE-4129.sql') FROM dual
;

