-- IDEMPIERE-5238 - Fix reference name on custom reference
SELECT register_migration_script('202303130827_IDEMPIERE-5238_FH.sql') FROM dual;

UPDATE ad_reference SET name='AD_Table Name - FH' WHERE name='AD_Table Name'
;

