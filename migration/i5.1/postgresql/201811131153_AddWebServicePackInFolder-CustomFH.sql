-- Add web service configuration to run Apply PackIn Folder
-- Nov 13, 2018 11:38:40 AM BRST
INSERT INTO WS_WebServiceType (AD_Client_ID,AD_Org_ID,Created,CreatedBy,IsActive,WS_WebServiceType_ID,Name,Updated,UpdatedBy,Value,WS_WebService_ID,WS_WebServiceMethod_ID,WS_WebServiceType_UU) VALUES (0,0,TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'Y',nextidfunc(53258,'N'),'RunApplyPackIn',TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'RunApplyPackIn',50001,50022,'0d7a93d7-54ee-4d2b-9699-25a9d057e500')
;

-- Nov 13, 2018 11:38:40 AM BRST
INSERT INTO WS_WebService_Para (AD_Client_ID,AD_Org_ID,WS_WebServiceType_ID,WS_WebService_Para_ID,Created,CreatedBy,IsActive,Updated,UpdatedBy,ParameterName,ParameterType,ConstantValue,WS_WebService_Para_UU) VALUES (0,0,(SELECT WS_WebServiceType_ID FROM WS_WebServiceType WHERE WS_WebServiceType_UU='0d7a93d7-54ee-4d2b-9699-25a9d057e500'),nextidfunc(53259,'N'),TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'Y',TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'AD_Process_ID','C','200099','5681d3ba-d257-4037-bee4-b78e40e6442c')
;

-- Nov 13, 2018 11:38:40 AM BRST
INSERT INTO WS_WebService_Para (AD_Client_ID,AD_Org_ID,WS_WebServiceType_ID,WS_WebService_Para_ID,Created,CreatedBy,IsActive,Updated,UpdatedBy,ParameterName,ParameterType,ConstantValue,WS_WebService_Para_UU) VALUES (0,0,(SELECT WS_WebServiceType_ID FROM WS_WebServiceType WHERE WS_WebServiceType_UU='0d7a93d7-54ee-4d2b-9699-25a9d057e500'),nextidfunc(53259,'N'),TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'Y',TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'AD_Menu_ID','C','0','6da5a3bd-9eec-437c-81c9-78e5564fbb09')
;

-- Nov 13, 2018 11:38:40 AM BRST
INSERT INTO WS_WebService_Para (AD_Client_ID,AD_Org_ID,WS_WebServiceType_ID,WS_WebService_Para_ID,Created,CreatedBy,IsActive,Updated,UpdatedBy,ParameterName,ParameterType,ConstantValue,WS_WebService_Para_UU) VALUES (0,0,(SELECT WS_WebServiceType_ID FROM WS_WebServiceType WHERE WS_WebServiceType_UU='0d7a93d7-54ee-4d2b-9699-25a9d057e500'),nextidfunc(53259,'N'),TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'Y',TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'AD_Record_ID','C','0','493dc480-aad2-4028-b533-8cba0fc047d6')
;

-- Nov 13, 2018 11:38:40 AM BRST
INSERT INTO WS_WebServiceTypeAccess (AD_Client_ID,AD_Org_ID,AD_Role_ID,WS_WebServiceType_ID,Created,CreatedBy,IsActive,IsReadWrite,Updated,UpdatedBy,WS_WebServiceTypeAccess_UU) VALUES (0,0,0,(SELECT WS_WebServiceType_ID FROM WS_WebServiceType WHERE WS_WebServiceType_UU='0d7a93d7-54ee-4d2b-9699-25a9d057e500'),TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'Y','Y',TO_TIMESTAMP('2018-11-13 11:38:40','YYYY-MM-DD HH24:MI:SS'),100,'90da63a1-0e3e-477c-9453-5ba37a96ba97')
;

SELECT register_migration_script('201811131153_AddWebServicePackInFolder-CustomFH.sql') FROM dual
;

