--------------------------------------------------------
--  DDL for Procedure WEBC_CALL_GEN_OFM_PDF_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CATSMBAG"."WEBC_CALL_GEN_OFM_PDF_PROC" (p_phase in nvarchar2,         -- x_phase
                                              p_instance  in nvarchar2,     -- x_instance 
                                              p_mainscenario in nvarchar2,  -- x_mainscenario
                                              p_user in nvarchar2, --User_id
                                              retNum out number)            -- Number returns from function 
                                                 
-- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- **
-- Description:   This Procedure calls the function webc_gen_ofm_pdf_func
-- Author:         	TCHATZI
-- Created date:    11.12.2023
-- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** 
as
-- ** -- ** -- ** -- ** -- 
-- Variable Declaration 
-- ** -- ** -- ** -- ** --
	messageLogText    NVARCHAR2(2000); -- text that gets written into the message log
	messageLogContext NVARCHAR2(200) := 'WEBC_CALL_GEN_OFM_PDF_PROC'; -- where we are
    n1 number;      -- out parameter of the message log (notifies if everything went ok)
    DBUser NVARCHAR2(50); -- the user that called this procedure

BEGIN
    -- log that we're about to start
     messageLogText := 'OFM Call begins';
     MESLOG.MESSAGE_LOG_PROC(1,  1,  WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'),    messageLogContext, null, 'Phase:' || p_phase || ' | Scen:' || p_mainscenario || ' | Inst: ' || p_instance , 0,   nvl(p_user, DBUser) , n1, 0);
 
    -- check if we have a user, if no query the system context for it
    if p_user is null or p_user = '' then
        SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER') into DBUser FROM DUAL;
    else -- if we do have a user, keep it
        DBUser := p_user;
    end if;
    -- log that we're about to begin
    MESLOG.MESSAGE_LOG_PROC(1,  1,  WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'),    messageLogContext, null, 'Phase:' || p_phase || ' | Scen:' || p_mainscenario || ' | Inst: ' || p_instance , 0,   nvl(p_user, DBUser) , n1, 0);
    -- call the generation of the PDF and return how it went
    retNum := webc_gen_ofm_pdf_func (p_phase, p_instance, p_mainscenario, DBUser);
    
    -- ** -- ** -- ** -- ** -- 
    -- Exception Handling
    -- ** -- ** -- ** -- ** --
    EXCEPTION
    when others then-- if anything out of the ordinary occured, log it
        messageLogText := q'[ERR-20001 - ]' || messageLogContext  || q'[ - Oracle exception: ]' || to_char(SQLCODE) || ' | ' || to_char(SQLERRM);
        EXEC_MESSAGELOG_ERRMSG_PROC (messageLogText, messageLogContext);
end;

/

  GRANT EXECUTE ON "CATSMBAG"."WEBC_CALL_GEN_OFM_PDF_PROC" TO PUBLIC;
  / "asdasdasdasdas"
