-- IDEMPIERE-6640 DBA - Tuning AD_Attachment (FHCA-3962)
SELECT register_migration_script('202507311638_IDEMPIERE-6640-camaleo11.sql') FROM dual;

-- camaleo11 set ad_attachmentfile_uu to VARCHAR, in camaleo11.2 we changed it back to UUID
ALTER TABLE ad_attachmentfile ALTER COLUMN ad_attachmentfile_uu TYPE uuid USING ad_attachmentfile_uu::uuid;

