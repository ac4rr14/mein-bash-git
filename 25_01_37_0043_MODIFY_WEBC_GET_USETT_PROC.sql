--------------------------------------------------------
--  DDL for Procedure WEBC_GET_USETT_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CATSMBAG"."WEBC_GET_USETT_PROC" (DBUser   IN nVarchar2,  
                                                xTable  IN nVarchar2,  
                                                xProp   OUT nVarchar2,
                                                xFilt   OUT nvarchar2)
--	is
AuthID definer AS
-- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** 	
-- Description:    Returns the settings/active Filter of a given User for a given table
-- Author:         	
-- Created date:    23.10.2024
-- Updated version also outputs rowcount, column names and datatype
-- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** -- ** 	

    userHasSettings   pls_integer;
    sCols             nVarChar2(4000);
    sColsDataType     nVarChar2(4000);
    nEntriesInTable   number;
    sCmd              clob; --stores to be executed sql code
-- messagelog variables
    messageLogText    nVarchar2(2000);                      --  Text for the Output through the message Log
    messageLogContext nVarchar2(200) := 'WEBC_GET_USETT_PROC';   --  Context for the message Log Output
-- ** -- ** -- ** -- ** -- 	
-- Procedure Body Begin
-- ** -- ** -- ** -- ** -- 
begin
-- count the number of rows of the current table
sCmd:='select count(*) from '|| xTable;
 execute immediate sCmd into nEntriesInTable;

-- check if there are usersettings saved in the corresponding table
  select count(*) into userHasSettings
    from catsmbag.webc_user_settings_tbl 
   where lower(sett_user)  =  lower(DBUser) 
     and lower(sett_obj)   =  lower(xTable)
     and lower(sett_group) = 'col_sequences';
-- if there are settings, get the properties and filter settings
  if (userHasSettings > 0) then
    select sett_prop, sett_filt into xProp, xFilt
      from catsmbag.webc_user_settings_tbl 
     where lower(sett_user)  =  lower(DBUser) 
       and lower(sett_obj)   =  lower(xTable)
       and lower(sett_group) = 'col_sequences';       
 --   htp.p('{');  
 --   htp.prn(' "sett_prop" :');                            
    htp.prn(substr(xProp, 0, length(xProp) -1));

    if xFilt is not null then
        htp.prn(', "sett_filt" : "');
        htp.prn( xFilt);
        htp.prn( '" ');
    end if;
    
  else  
    catsmbag.WEBC_USETT_GET_DEFAULT_PROC(DBUser, xTable, xFilt);
   --old default value:  xProp := '"--"';
  end if;
-- output the count last 
   htp.prn(', "numrows" : "');
   htp.prn( nEntriesInTable);
   htp.prn( '"');
   htp.prn('}'); -- close the json at the end
-- ** -- ** -- ** -- ** -- 
-- Exceptions
-- ** -- ** -- ** -- ** -- 
EXCEPTION 
  when others then -- if an exception occurred output it through the message log 
    messageLogText := q'[ERR-20001 - ]' || ' user:' || DBUser || ' Proc: ' || messageLogContext  || q'[ - Oracle exception: ]' || to_char(SQLCODE) || ' | ' || to_char(SQLERRM);
    EXEC_MESSAGELOG_ERRMSG_PROC (messageLogText, messageLogContext);   
end;

/
