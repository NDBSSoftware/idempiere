-- IDEMPIERE-6640 DBA - Tuning AD_Attachment (FHCA-3962)
SELECT register_migration_script('202507311637_IDEMPIERE-6640-camaleo11.sql') FROM dual;

-- camaleo11 still requires the ad_attachmentfile_uu to be VARCHAR, in camaleo11.2 will be changed back to UUID
ALTER TABLE ad_attachmentfile ALTER COLUMN ad_attachmentfile_uu TYPE varchar(36) USING ad_attachmentfile_uu::varchar(36);

