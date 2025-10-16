--------------------------------------------------------
--  DDL for Procedure WEBC_USERPROP_JSON_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CATSMBAG"."WEBC_USERPROP_JSON_PROC" (DBUser    IN  nVarchar2,  
                                                       resultout OUT clob)
--  is
AuthID definer AS
    nCheck number;                  -- counter for preexisting property table entries
    sCatsInst nvarchar2(20);        -- CATS instance (CATS XXDB)
    sWssInst nvarchar2(20);         -- WSS DB (GTS XCS XX)
    sMessLevelName nvarchar2(20);   -- message level in plaintext (Warning/message/error)
    xresult clob;                   -- final result to be returned 
-- messagelog variables
    messageLogText    nVarchar2(2000);                            --  Text for the Output through the message Log
    messageLogContext nVarchar2(200) :='WEBC_USERPROP_JSON_PROC'; --  Context for the message Log Output
-- ** -- ** -- ** -- ** -- 	
-- Procedure Body Begin
-- ** -- ** -- ** -- ** -- 
begin
-- check if message level settings exist
    SELECT count(*) into nCheck from catsmbag.WEBC_USER_PROPERTIES_TBL where user_id =  DBUser;
    -- if no create them
    if nCheck = 0 then     
        -- get the default value from fcatsconstants
        SELECT JT.CATS_INSTANCE, JT.WSS_INSTANCE, JT.MESSAGE_LEVEL_NAME into sCatsInst, sWssInst, sMessLevelName
              FROM fcatsconstant fc,
              json_table(CONSTANT_VALUE, '$'
                     COLUMNS (CATS_INSTANCE VARCHAR2(20) PATH '$.CATS_INSTANCE',
                              WSS_INSTANCE  VARCHAR2(20) PATH '$.WSS_INSTANCE',
                              MESSAGE_LEVEL_NAME VARCHAR2(20) PATH '$.MESSAGE_LEVEL_NAME')) AS "JT"
                              where fc.constant_id = 'WEBC_PROPERTIES_DEF';
        -- insert the settings for the user
        insert into catsmbag.WEBC_USER_PROPERTIES_TBL (
            user_id,
            message_level_name, 
            cats_database, 
            wss_instance) 
        values (
            DBUser,
            sMessLevelName,
            sCatsInst,
            sWssInst);
    end if;
    -- assemble the user properties 
    SELECT json_object(
        key 'items' 
        value json_arrayagg(
            json_object(
            key 'message_level_name' value a.message_level_name,
            key 'cats_database' value a.cats_database,
            key 'wss_instance' value a.wss_instance,
            key 'message_class_id' value  b.message_class_id
            )
        )format json
     )
    INTO xresult 
          FROM catsmbag.WEBC_USER_PROPERTIES_TBL a inner join catsmbag.message_class b 
                  on a.message_level_name = b.message_class_name
                  WHERE a.user_id =  DBUser ;
    -- return them
    htp.p(xresult);
    resultout:= '1';
    -- commit to the insert from line 30? (why here?)
    commit;
    -- ** -- ** -- ** -- ** -- 
    -- Exceptions
    -- ** -- ** -- ** -- ** -- 
    EXCEPTION 
      when others then -- if an exception occurred output it through the message log 
        messageLogText := q'[ERR-20001 - ]' || ' user:' || DBUser || ': ' || messageLogContext  || q'[ - Oracle exception: ]' || to_char(SQLCODE) || ' | ' || to_char(SQLERRM);
        EXEC_MESSAGELOG_ERRMSG_PROC (messageLogText, messageLogContext);   
end;

/
