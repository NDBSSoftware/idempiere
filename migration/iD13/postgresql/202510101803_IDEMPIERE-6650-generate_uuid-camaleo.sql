-- IDEMPIERE-6650 Performance - Implement support for using the uuid postgres datatype (FHCA-7074)
-- recreate generate_uuid function to return uuid instead of varchar
-- changed to return a uuidv7 - if you want to stay with v4 then uncomment the lines at the end

DROP VIEW ecg_bpartner_export_v;

DROP VIEW ecg_obrigacaoorg_v;

DROP FUNCTION IF EXISTS Generate_UUID();

-- v7
CREATE OR REPLACE FUNCTION Generate_UUID(ts timestamp with time zone DEFAULT clock_timestamp())
RETURNS uuid AS $$
DECLARE
  unix_ts_ms bigint;
  uuid_bytes bytea;
  random_part bytea;
BEGIN
  /* NOTE: in postgresql 18 uuidv7 will be native, and you can change this script to benefit from the native function */
  -- Get timestamp in milliseconds
  unix_ts_ms = floor(extract(epoch from ts) * 1000)::bigint;
  -- Convert timestamp to 6 bytes (48 bits)
  unix_ts_ms = unix_ts_ms & x'FFFFFFFFFFFF'::bigint;
  -- Get random bytes from gen_random_uuid()
  random_part = decode(replace(gen_random_uuid()::text, '-', ''), 'hex');
  -- Construct UUID v7: 48-bit timestamp + version/variant + random
  uuid_bytes = 
    substring(int8send(unix_ts_ms) from 3 for 6) || -- 48-bit timestamp
    substring(random_part from 7 for 2) ||           -- 16-bit random (with version)
    substring(random_part from 9 for 8);             -- 64-bit random (with variant)
  -- Set version to 7 (0111)
  uuid_bytes = set_byte(uuid_bytes, 6, (get_byte(uuid_bytes, 6) & 15) | 112);
  -- Set variant to 10
  uuid_bytes = set_byte(uuid_bytes, 8, (get_byte(uuid_bytes, 8) & 63) | 128);
  RETURN encode(uuid_bytes, 'hex')::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;

/*
-- v4
CREATE FUNCTION Generate_UUID()
RETURNS uuid AS $$
  SELECT uuid_generate_v4();
$$ LANGUAGE SQL VOLATILE;
*/

CREATE OR REPLACE FUNCTION torecordid(
	p_tablename  IN 	VARCHAR,
	p_uu_value IN 	VARCHAR
)
  RETURNS INTEGER AS $body$
DECLARE
     id_column VARCHAR;
     uu_column VARCHAR;
     o_id INTEGER;
BEGIN
     SELECT a.ColumnName 
     INTO id_column
     FROM AD_Column a 
     JOIN AD_Table b ON (a.AD_Table_ID=b.AD_Table_ID) 
     WHERE a.IsActive='Y' AND a.IsKey='Y' AND  lower(b.TableName) = lower(p_tablename);

     IF (id_column IS NULL) THEN
         RAISE EXCEPTION 'ID column not found for table %', p_tablename;
     END IF;

     IF (length(p_tablename) <= 27) THEN
         uu_column = p_tablename || '_UU';
     ELSE
         SELECT a.ColumnName 
         INTO uu_column
         FROM AD_Column a 
        JOIN AD_Table b ON (a.AD_Table_ID=b.AD_Table_ID) 
         WHERE a.IsActive='Y' AND lower(ColumnName) like (lower(substring(p_tablename from 0 for 27)) || '%UU')
         AND  lower(b.TableName) = lower(p_tablename);
     END IF;
     
     IF (uu_column IS NULL) THEN
         RAISE EXCEPTION 'UUID column not found for table %', p_tablename;
     END IF;

     EXECUTE 'SELECT ' || quote_ident(lower(id_column)) || ' FROM ' || quote_ident(lower(p_tablename)) || ' WHERE ' ||  uu_column || '=$1::uuid'
     INTO STRICT o_id
     USING p_uu_value;

     RETURN o_id;
END;
$body$ LANGUAGE plpgsql;

CREATE VIEW ecg_bpartner_export_v AS
 SELECT (row_number() OVER (ORDER BY bp.ad_client_id, bp.ad_org_id, bp.c_bpartner_id) + 1000000) AS ecg_bpartner_export_v_id,
    generate_uuid() AS ecg_bpartner_export_v_uu,
    bp.c_bpartner_id,
    bp.ad_client_id,
    bp.ad_org_id,
    bp.lbr_bptypebr,
    bp.lbr_cpf,
    bp.lbr_cnpj,
    bp.name,
    bp.name2,
    bp.description,
    bp.lbr_rg,
    bp.isactive,
    bp.created,
    bp.createdby,
    bp.updated,
    bp.updatedby,
    pnd.ecg_bptipobloqueio,
    cl.address1,
    cl.address2,
    cl.address3,
    cl.address4,
    cl.postal,
    cclogra.name AS ecg_cidadelogradouro,
    ie.ecg_pn_tipoinscricaoestadual,
    ie.ecg_pn_inscricaoestadual,
    cr.name AS ecg_estadoinfest,
    ccinfmunic.name AS ecg_cidadeinfmunic,
    im.ecg_pn_inscricaomunicipal
   FROM ((((((((c_bpartner bp
     LEFT JOIN ecg_parceironegociodetalhe pnd ON ((bp.c_bpartner_id = pnd.c_bpartner_id)))
     LEFT JOIN c_bpartner_location cbl ON ((cbl.c_bpartner_id = bp.c_bpartner_id)))
     LEFT JOIN c_location cl ON ((cl.c_location_id = cbl.c_location_id)))
     LEFT JOIN c_city cclogra ON ((cclogra.c_city_id = cl.c_city_id)))
     LEFT JOIN ecg_pn_informacaoestadual ie ON ((ie.c_bpartner_id = bp.c_bpartner_id)))
     LEFT JOIN ecg_pn_informacaomunicipal im ON ((im.c_bpartner_id = bp.c_bpartner_id)))
     LEFT JOIN c_region cr ON ((cr.c_region_id = ie.c_region_id)))
     LEFT JOIN c_city ccinfmunic ON ((ccinfmunic.c_city_id = im.c_city_id)));

CREATE VIEW ecg_obrigacaoorg_v AS
 WITH obrigacao_org AS (
         SELECT (row_number() OVER (ORDER BY tborg.ad_client_id, tborg.ad_org_id, tbobrig.ecg_obrigacao_id) + 1000000) AS ecg_obrigacaoorg_v_id,
            generate_uuid() AS ecg_obrigacaoorg_v_uu,
            tborg.ad_client_id,
            cli.name AS ecg_clientname,
            tborg.ad_org_id,
            tborg.value AS ecg_identificationcode,
            tborg.description AS ecg_companyname,
            tborg.name AS ecg_tradingname,
            tborg.isactive AS ecg_isorgativa,
            tborginfo.parent_org_id AS ecg_parentorg,
            tbobrig.ecg_obrigacao_id AS ecg_obrigacaoid,
            tbobrig.name AS ecg_obrigacaonome,
            tbobrig.value AS ecg_obrigacaovalue,
            tbobrig.ecg_requercertificado,
            tbobrig.ecg_responsavelentrega,
            tbobrig.ecg_obrigacaotipo_id,
            tbobrig.ecg_requerconfiguracao,
            tbobrig.help AS ecg_obrigacaoajuda,
            tbobrigtipo.value AS ecg_obrigtipovalue
           FROM (ecg_obrigacao tbobrig
             JOIN ecg_obrigacaotipo tbobrigtipo ON ((tbobrig.ecg_obrigacaotipo_id = tbobrigtipo.ecg_obrigacaotipo_id))),
            ((ad_org tborg
             JOIN ad_orginfo tborginfo ON ((tborg.ad_org_id = tborginfo.ad_org_id)))
             JOIN ad_client cli ON ((tborg.ad_client_id = cli.ad_client_id)))
          WHERE (tborg.isactive = 'Y'::bpchar)
        )
 SELECT obrigacao_org.ecg_obrigacaoorg_v_id,
    obrigacao_org.ecg_obrigacaoorg_v_uu,
    obrigacao_org.ad_client_id,
    obrigacao_org.ecg_clientname,
    obrigacao_org.ad_org_id,
    obrigacao_org.ecg_identificationcode,
    obrigacao_org.ecg_companyname,
    obrigacao_org.ecg_tradingname,
    obrigacao_org.ecg_isorgativa,
    obrigacao_org.ecg_parentorg,
    obrigacao_org.ecg_obrigacaoid,
    obrigacao_org.ecg_obrigacaonome,
    obrigacao_org.ecg_obrigacaovalue,
    obrigacao_org.ecg_requercertificado,
    obrigacao_org.ecg_responsavelentrega,
    obrigacao_org.ecg_obrigacaotipo_id,
    obrigacao_org.ecg_requerconfiguracao,
    obrigacao_org.ecg_obrigacaoajuda,
    obrigacao_org.ecg_obrigtipovalue,
    tbobrigcli.ad_user_id AS ecg_usuarioid,
    usuario.name AS ecg_usuarionome,
    tbobrigcli.lbr_digitalcertificate_id,
        CASE
            WHEN (tbobrigcli.isactive IS NULL) THEN 'N'::bpchar
            ELSE tbobrigcli.isactive
        END AS ecg_iscliobrigactive,
        CASE
            WHEN (tbobrigcli.isprocessing = 'Y'::bpchar) THEN 1
            WHEN (tbobrigcli.iserror = 'Y'::bpchar) THEN 2
            ELSE 0
        END AS ecg_situacao,
    tbobrigcli.ecg_obrigacaocli_id,
    tbobrigcli.msgtext AS ecg_msgprocessamento
   FROM ((obrigacao_org
     LEFT JOIN ecg_obrigacaocli tbobrigcli ON (((tbobrigcli.ad_client_id = obrigacao_org.ad_client_id) AND (tbobrigcli.ad_org_id = obrigacao_org.ad_org_id) AND (tbobrigcli.ecg_obrigacao_id = obrigacao_org.ecg_obrigacaoid))))
     LEFT JOIN ad_user usuario ON ((usuario.ad_user_id = tbobrigcli.ad_user_id)))
  WHERE ((obrigacao_org.ecg_requerconfiguracao = 'Y'::bpchar) AND ((obrigacao_org.ecg_requercertificado = 'Y'::bpchar) OR (EXISTS ( SELECT n.ecg_obrigacaonotificacao_id
           FROM ecg_obrigacaonotificacao n
          WHERE (obrigacao_org.ecg_obrigacaoid = n.ecg_obrigacao_id))) OR (EXISTS ( SELECT p.ecg_obrigacaoparam_id
           FROM ecg_obrigacaoparam p
          WHERE (p.ecg_obrigacao_id = obrigacao_org.ecg_obrigacaoid)))))
  ORDER BY obrigacao_org.ad_client_id, obrigacao_org.ad_org_id, obrigacao_org.ecg_obrigacaoid;

SELECT register_migration_script('202510101803_IDEMPIERE-6650-generate_uuid-camaleo.sql') FROM dual;

