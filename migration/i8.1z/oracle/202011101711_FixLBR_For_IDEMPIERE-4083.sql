-- LBR modified view c_payment_v and the script 202011101712_IDEMPIERE-4083.sql is failing because of that
-- this script restores the idempiere original view to solve the problem

SET SQLBLANKLINES ON
SET DEFINE OFF

DROP VIEW rv_bpartneropen;

DROP VIEW c_payment_v;

CREATE OR REPLACE VIEW c_payment_v
AS
  SELECT c_payment.c_payment_id,
         c_payment.ad_client_id,
         c_payment.ad_org_id,
         c_payment.isactive,
         c_payment.created,
         c_payment.createdby,
         c_payment.updated,
         c_payment.updatedby,
         c_payment.documentno,
         c_payment.datetrx,
         c_payment.isreceipt,
         c_payment.c_doctype_id,
         c_payment.trxtype,
         c_payment.c_bankaccount_id,
         c_payment.c_bpartner_id,
         c_payment.c_invoice_id,
         c_payment.c_bp_bankaccount_id,
         c_payment.c_paymentbatch_id,
         c_payment.tendertype,
         c_payment.creditcardtype,
         c_payment.creditcardnumber,
         c_payment.creditcardvv,
         c_payment.creditcardexpmm,
         c_payment.creditcardexpyy,
         c_payment.micr,
         c_payment.routingno,
         c_payment.accountno,
         c_payment.checkno,
         c_payment.a_name,
         c_payment.a_street,
         c_payment.a_city,
         c_payment.a_state,
         c_payment.a_zip,
         c_payment.a_ident_dl,
         c_payment.a_ident_ssn,
         c_payment.a_email,
         c_payment.voiceauthcode,
         c_payment.orig_trxid,
         c_payment.ponum,
         c_payment.c_currency_id,
         c_payment.c_conversiontype_id,
         CASE c_payment.isreceipt
           WHEN 'Y' THEN c_payment.payamt
           ELSE c_payment.payamt * ( -1 )
         END AS payamt,
         CASE c_payment.isreceipt
           WHEN 'Y' THEN c_payment.discountamt
           ELSE c_payment.discountamt * ( -1 )
         END AS discountamt,
         CASE c_payment.isreceipt
           WHEN 'Y' THEN c_payment.writeoffamt
           ELSE c_payment.writeoffamt * ( -1 )
         END AS writeoffamt,
         CASE c_payment.isreceipt
           WHEN 'Y' THEN c_payment.taxamt
           ELSE c_payment.taxamt * ( -1 )
         END AS taxamt,
         CASE c_payment.isreceipt
           WHEN 'Y' THEN c_payment.overunderamt
           ELSE c_payment.overunderamt * ( -1 )
         END AS overunderamt,
         CASE c_payment.isreceipt
           WHEN 'Y' THEN 1
           ELSE ( -1 )
         END AS multiplierap,
         c_payment.isoverunderpayment,
         c_payment.isapproved,
         c_payment.r_pnref,
         c_payment.r_result,
         c_payment.r_respmsg,
         c_payment.r_authcode,
         c_payment.r_avsaddr,
         c_payment.r_avszip,
         c_payment.r_info,
         c_payment.processing,
         c_payment.oprocessing,
         c_payment.docstatus,
         c_payment.docaction,
         c_payment.isprepayment,
         c_payment.c_charge_id,
         c_payment.isreconciled,
         c_payment.isallocated,
         c_payment.isonline,
         c_payment.processed,
         c_payment.posted,
         c_payment.c_campaign_id,
         c_payment.c_project_id,
         c_payment.c_activity_id,
         c_payment.ad_orgtrx_id,
         c_payment.chargeamt,
         c_payment.c_order_id,
         c_payment.dateacct,
         c_payment.description,
         c_payment.isselfservice,
         c_payment.processedon,
         c_payment.reversal_id
  FROM   c_payment
;

CREATE OR REPLACE VIEW rv_bpartneropen
AS
  SELECT i.ad_client_id,
         i.ad_org_id,
         i.isactive,
         i.created,
         i.createdby,
         i.updated,
         i.updatedby,
         i.c_bpartner_id,
         i.c_currency_id,
         i.grandtotal * i.multiplierap                                                                                    AS amt,
         invoiceopen(i.c_invoice_id, i.c_invoicepayschedule_id) * i.multiplierap                                          AS openamt,
         i.dateinvoiced                                                                                                   AS datedoc,
         COALESCE(daysbetween(getdate(), ips.duedate), paymenttermduedays(i.c_paymentterm_id, i.dateinvoiced, getdate())) AS daysdue,
         i.c_campaign_id,
         i.c_project_id,
         i.c_activity_id,
         i.ad_orgtrx_id,
         i.c_charge_id,
         i.c_conversiontype_id,
         i.c_doctype_id,
         i.chargeamt,
         i.c_invoice_id,
         i.c_order_id,
         i.c_payment_id,
         i.dateacct,
         i.description,
         i.docstatus,
         i.documentno,
         i.isapproved,
         i.isselfservice,
         i.posted,
         i.processedon,
         i.reversal_id
  FROM   c_invoice_v i
         LEFT JOIN c_invoicepayschedule ips
                ON i.c_invoicepayschedule_id = ips.c_invoicepayschedule_id
  WHERE  i.ispaid = 'N'
         AND i.docstatus IN ( 'CO', 'CL' )
  UNION
  SELECT p.ad_client_id,
         p.ad_org_id,
         p.isactive,
         p.created,
         p.createdby,
         p.updated,
         p.updatedby,
         p.c_bpartner_id,
         p.c_currency_id,
         p.payamt * p.multiplierap * ( -1 )                         AS amt,
         paymentavailable(p.c_payment_id) * p.multiplierap * ( -1 ) AS openamt,
         p.datetrx                                                  AS datedoc,
         NULL                                                       AS daysdue,
         p.c_campaign_id,
         p.c_project_id,
         p.c_activity_id,
         p.ad_orgtrx_id,
         p.c_charge_id,
         p.c_conversiontype_id,
         p.c_doctype_id,
         p.chargeamt,
         p.c_invoice_id,
         p.c_order_id,
         p.c_payment_id,
         p.dateacct,
         p.description,
         p.docstatus,
         p.documentno,
         p.isapproved,
         p.isselfservice,
         p.posted,
         p.processedon,
         p.reversal_id
  FROM   c_payment_v p
  WHERE  p.isallocated = 'N'
         AND p.c_bpartner_id IS NOT NULL
         AND p.docstatus IN ( 'CO', 'CL' )
;

SELECT register_migration_script('202011101711_FixLBR_For_IDEMPIERE-4083.sql') FROM dual
;

