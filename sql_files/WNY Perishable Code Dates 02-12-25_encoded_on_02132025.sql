SELECT I.PRCRMNT_GL_CD GL, 
 I.DVSN_BYR_NUM BUYER, 
 B.DVSN_BYR_DESC BUYER_NAME, 
 CASE WHEN X.CSTMR_ITM_CD1 IS NULL THEN '' ELSE X.CSTMR_ITM_CD1 END TOPS_CODE, 
 I.ITM_NUM ITEM_CODE, 
 SSIC.SNGL_SYS_ITM_DESC DESCRIPTION,
 I.INBND_RECV_SPEC_PL_DYS QC_PULL_DAYS,
 I.INBND_RECV_SPEC_SHELF_MIN_DYS QC_MIN_DAYS,
 PLT_FILE.PLT_RCRD_CRT_DT PALLET_CREATED_DATE, 
 (SLT.AISLE_CD || '-' || SLT.BAY_CD || '-' || SLT.LCTN_CD) SLOT, 
 CASE WHEN PLT_FILE.EXPRTN_DT = '9999-12-31' THEN NULL ELSE PLT_FILE.EXPRTN_DT END EXPIRATION_DATE,
 CASE WHEN PLT_FILE.PRDTCN_DT = '9999-12-31' THEN NULL ELSE PLT_FILE.PRDTCN_DT END PRODUCTION_DATE,
 CASE WHEN PLT_FILE.PRDTCN_DT <> '9999-12-31' THEN PLT_FILE.PRDTCN_DT + I.INBND_RECV_SPEC_PL_DYS - 1 WHEN PLT_FILE.EXPRTN_DT <> '9999-12-31' THEN PLT_FILE.EXPRTN_DT - INBND_RECV_SPEC_PL_DYS - 1 ELSE NULL END LAST_SHIP_DATE ,
 CASE WHEN PLT_FILE.PRDTCN_DT <> '9999-12-31' THEN PLT_FILE.PRDTCN_DT + I.INBND_RECV_SPEC_PL_DYS WHEN PLT_FILE.EXPRTN_DT <> '9999-12-31' THEN PLT_FILE.EXPRTN_DT - INBND_RECV_SPEC_PL_DYS ELSE NULL END PULL_DATE ,
 SUM(PLT_FILE.CASE_PLT_QTY) CASES, 
 COUNT(PLT_FILE.PLT_ID) PALLETS
FROM EDW_VM.PLT_VB PLT_FILE
 LEFT OUTER JOIN EDW_VM.ITM_VB I ON (PLT_FILE.ITM_ID = I.ITM_ID)
 LEFT OUTER JOIN EDW_VM.SNGL_SYS_ITM_VB SSIC ON (I.SNGL_SYS_ITM_ID_SEQ = SSIC.SNGL_SYS_ITM_ID_SEQ)
 LEFT OUTER JOIN EDW_VM.ITM_FRCST_VB F ON F.ITM_ID=I.ITM_ID
 LEFT OUTER JOIN EDW_VM.DVSN_BYR_VB B ON B.DVSN_BYR_NUM=I.DVSN_BYR_NUM
 LEFT OUTER JOIN EDW_VM.SLOT_ADDR_VB SLT ON SLT.SLOT_ID = PLT_FILE.SLOT_ID
 LEFT OUTER JOIN (SELECT I.ITM_ID, XC.CSTMR_ITM_CD1 
 FROM EDW_VM.ITM_VB I 
 JOIN EDW_VM.CSTMR_CS_ITM_XREF_VB X ON (X.ITM_ID = I.ITM_ID)
 JOIN EDW_VM.CSTMR_ITM_VB XC ON (X.CSTMR_ITM_ID = XC.CSTMR_ITM_ID 
 AND XC.CHN_PRTY_ID =9100026) WHERE I.ITM_LCTN_NUM IN (46, 47)) X ON X.ITM_ID=I.ITM_ID 
WHERE (I.PRCRMNT_GL_CD IN (2600, 2450, 2400, 2375, 2370, 2365, 2360, 2355, 2351, 2325, 2320, 2315, 2310, 2305, 2300, 3000, 3020)
 AND I.ITM_LCTN_NUM IN (46, 47)
 AND I.END_EFCTV_DT IS NULL)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
HAVING CASES>0
ORDER BY GL, ITEM_CODE, PULL_DATE LIMIT 10