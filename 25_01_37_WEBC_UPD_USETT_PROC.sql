--------------------------------------------------------
--  DDL for Procedure WEBC_UPD_USETT_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CATSMBAG"."WEBC_UPD_USETT_PROC" (pUsr nvarchar2, pTab nvarchar2, pJson nvarchar2, pFilt nvarchar2 := '')
is 
-- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- **   
-- Author:          BRUENIL
-- Created date:    2024-07-02
-- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- **   

-- ** -- ** -- ** -- ** -- 
-- Variable Declaration  
-- ** -- ** -- ** -- ** -- 

    nDebugLevel pls_integer;      -- debug level
    sCommand    nvarchar2(2000);  --stores to be executed sql code
-- messagelog variables
    n1 pls_integer; -- necessary as placeholder in message_log_proc
    mLogText    nvarchar2(2000);  -- Text thats supposed to be logged
    mLogContext nvarchar2(200) := 'WebC_upd_uSett_Proc';  -- where we are
-- ** -- ** -- ** -- ** -- 	
-- Procedure Body Begin
-- ** -- ** -- ** -- ** -- 
begin

    nDebugLevel        :=  WebC_Get_Debug_Level();
    sCommand  := 'alter session set global_names = false';
    execute immediate sCommand;

    if (nDebugLevel > 0) then
      mLogText :=  '[ ' || pUsr || ' | ' || pTab || ' ]';
      --                    info usr  app        appVersion                                context      clob   text      id   user   err?  lev.
      MESLOG.MESSAGE_LOG_PROC(1,  1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), mLogContext, pJson, mLogText, 0,  'sysprcss', n1, 0);
    end if;

    MERGE INTO CATSMBAG.webc_user_settings_tbl d 
    USING (SELECT lower(pUsr) as c1, lower(pTab) as c2 from dual) s  
       ON ((lower(d.sett_user)  = s.c1) 
      and  (lower(d.sett_obj)   = s.c2)
      and  (lower(d.sett_group) = 'col_sequences'))
     WHEN     MATCHED THEN UPDATE SET d.sett_prop = pJson,
                                      d.sett_filt = pFilt,
                                      d.sett_dati = sysdate
     WHEN NOT MATCHED THEN INSERT (sett_user, sett_obj, sett_group,  sett_prop, sett_filt, sett_dati) 
                           VALUES (s.c1,      s.c2, 'col_sequences', pJson,     pFilt,     sysdate);
    commit; 

-- ** -- ** -- ** -- ** -- 
-- Exceptions
-- ** -- ** -- ** -- ** -- 
EXCEPTION
  when others then -- if an exception occurred output it through the message log
    mLogText := '[ERR-20001 - ] ' || mLogContext  || ' [ - Oracle exception: ] ' || to_char(SQLCODE) || ' | ' || to_char(SQLERRM);
    EXEC_MESSAGELOG_ERRMSG_PROC (mLogText, mLogContext);
end;

/

  GRANT EXECUTE ON "CATSMBAG"."WEBC_UPD_USETT_PROC" TO "SSOLOOK";
  GRANT EXECUTE ON "CATSMBAG"."WEBC_UPD_USETT_PROC" TO "MBAG_READ_ALL";
