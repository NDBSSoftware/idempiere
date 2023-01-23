-- LBR modified views rv_payment and rv_allocation and the script 202111282319_IDEMPIERE-5059.sql is failing because of that
-- this script drops the views before to solve the problem

DROP VIEW rv_payment;

DROP VIEW rv_allocation;

SELECT register_migration_script('202111282318_FixLBR_For_IDEMPIERE-5059.sql') FROM dual
;

