-- IDEMPIERE-6196
SELECT register_migration_script('202407231647_IDEMPIERE-6196.sql') FROM dual;

SET SQLBLANKLINES ON
SET DEFINE OFF

-- Jul 23, 2024, 4:47:40 PM CEST
UPDATE AD_Column SET SeqNoSelection=30,Updated=TO_TIMESTAMP('2024-07-23 16:47:40','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=10 WHERE AD_Column_ID=103
;

-- Jul 23, 2024, 4:47:43 PM CEST
UPDATE AD_Column SET SeqNoSelection=20,Updated=TO_TIMESTAMP('2024-07-23 16:47:43','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=10 WHERE AD_Column_ID=102
;

-- Jul 23, 2024, 4:47:52 PM CEST
UPDATE AD_Column SET SeqNoSelection=10,Updated=TO_TIMESTAMP('2024-07-23 16:47:52','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=10 WHERE AD_Column_ID=107
;
