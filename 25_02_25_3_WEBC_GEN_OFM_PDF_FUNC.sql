--------------------------------------------------------
--  DDL for Function WEBC_GEN_OFM_PDF_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CATSMBAG"."WEBC_GEN_OFM_PDF_FUNC" (
    P_phase        IN VARCHAR2,
    P_instance     IN VARCHAR2,
    P_mainscenario IN VARCHAR2,
    p_user         IN VARCHAR2
) RETURN NUMBER AS
        t_query VARCHAR2(1000);
        t_query_sum VARCHAR2(1000);
        t_query_sysdate VARCHAR2(1000);
        i              INTEGER;
        v_vFileName    VARCHAR2(255);
        v_vOddColor    VARCHAR2(6) := 'd0d0d0';
        v_vHeadColor   VARCHAR2(6) := 'e0ffff';
        v_vOraDir      VARCHAR2(50) := 'PDF';
        v_vPageProc    VARCHAR2(32000);
        i_Header_hFontSize INTEGER := 8;
        c_Header_hAlignment VARCHAR2(1) := 'C';
        c_sysdate VARCHAR2(100);
        r_Fmt  webc_as_pdf3_v5_pkg.tp_columns:=webc_as_pdf3_v5_pkg.tp_columns();
        messageLogContext VARCHAR2(50) := 'WEBC_GEN_OFM_PDF_FUNC';
        messageLogText VARCHAR2(100);
        nError number;

BEGIN
   messageLogText := 'OFM Creation begins';
   MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
    t_query := 'select x_source, data_create, data_delete, data_update, data_unchanged, to_char(x_timestamp, ''dd.mm.yyyy hh24:mi:ss''), scenario_status from v_status_c_tables where x_phase = ''' || P_phase || ''' and x_instance = ''' || P_instance || ''' and x_mainscenario = ''' || P_mainscenario || '''';
    t_query_sum := 'select ''Summe'', sum(data_create), sum(data_delete), sum(data_update), sum(data_unchanged), NULL, NULL from v_status_c_tables where x_phase = ''' || P_phase || ''' and x_instance = ''' || P_instance || ''' and x_mainscenario = ''' || P_mainscenario || '''';
    t_query_sysdate := 'select  to_char(sysdate, ''dd/mm/yy hh24:mi:ss'') from dual';
    --dbms_output.put_line(t_query_sysdate);

    execute immediate t_query_sysdate into c_sysdate;
    --dbms_output.put_line(c_sysdate);
   -- messageLogText := 'OFM queries and sysdate assembled';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 

   
    webc_as_pdf3_v5_pkg.init;
    webc_as_pdf3_v5_pkg.set_page_orientation('L');
    webc_as_pdf3_v5_pkg.set_font( 'helvetica', 8 );
   --messageLogText := 'about to set package';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
webc_as_pdf3_v5_pkg.set_page_proc( q'[
begin
webc_as_pdf3_v5_pkg.set_font( 'helvetica', 8 );
webc_as_pdf3_v5_pkg.put_txt( 770, 15, 'Page #PAGE_NR# of #PAGE_COUNT#' );
webc_as_pdf3_v5_pkg.put_txt( 20, 15, ']' || c_sysdate || ' | ' || p_user || q'['); 
webc_as_pdf3_v5_pkg.set_font( 'helvetica', 'B', 15 );
webc_as_pdf3_v5_pkg.horizontal_line( 20, 560, 800);
webc_as_pdf3_v5_pkg.put_txt( 20, 540, 'Order for Migration V8 Web' );
webc_as_pdf3_v5_pkg.horizontal_line( 20, 530, 800);
webc_as_pdf3_v5_pkg.set_font( 'helvetica', 'B', 10 );
webc_as_pdf3_v5_pkg.put_txt( 250, 540, 'X_PHASE: ]' || P_phase || q'[     WSS-Inst: ]' || P_instance || q'[     Mainscenario: ]' || P_mainscenario || q'[     CATS-Inst: ]' || upper(sys_context('userenv','service_name')) || q'[' );
 webc_as_pdf3_v5_pkg.put_image( 'MY_DIR', 'amis.jpg', 500, 15 );
end;]' );
   
   begin
      r_fmt.extend(7);
      i:=1; -- (riga di rottura
      r_fmt(i).colWidth:=300;
      r_fmt(i).colLabel:='Table';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
--      r_fmt(i).hAlignVert:='T';
--      r_fmt(i).tAlignment:='L';
--      r_fmt(i).tAlignVert:='B';
--      r_fmt(i).tFontSize:=8;
--      r_fmt(i).tCHeight := 7;
--      r_fmt(i).hCHeight := 7;
--      r_fmt(i).cellRow := 1;
   -- messageLogText := 'Table Header finished';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
      i:=i+1;--2
      r_fmt(i).colWidth:=70;
      r_fmt(i).colLabel:='Create';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
--      r_fmt(i).hAlignVert:='T';
--      r_fmt(i).tAlignVert:='T';
      --r_fmt(i).offsetX := 0;
--      r_fmt(i).tCHeight := 7;
--      r_fmt(i).hCHeight := 7;
    --messageLogText := 'Create Header finished';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 

      i:=i+1;--3
      r_fmt(i).colWidth:=70;
      r_fmt(i).colLabel:='Delete';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
--      r_fmt(i).hAlignVert:='T';
--      r_fmt(i).tAlignment:='R';
--      r_fmt(i).tAlignVert:='M';
    -- messageLogText := 'Delete header finished';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 

      i:=i+1;--4
      r_fmt(i).colWidth:=70;
      r_fmt(i).colLabel:='Update';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
--      r_fmt(i).hAlignVert:='T';
--      r_fmt(i).tAlignment:='C';
--      r_fmt(i).tAlignVert:='B';
--      r_fmt(i).tBorder := webc_as_pdf3_v5_pkg.BorderType('TB');
    -- messageLogText := 'Update header finished';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 

      i:=i+1;--5
      r_fmt(i).colWidth:=70;
      r_fmt(i).colLabel:='Unchanged';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
--      r_fmt(i).hAlignVert:='T';
--      r_fmt(i).tAlignment:='C';
--      r_fmt(i).tAlignVert:='B';
-- messageLogText := 'Unchanged header finished';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
      i:=i+1;--6
      r_fmt(i).colWidth:=130;
      r_fmt(i).colLabel:='X_Timestamp';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
      r_fmt(i).hAlignVert:='T';
      r_fmt(i).tAlignment:='R';
--      r_fmt(i).tAlignVert:='B';
-- messageLogText := 'Timestamp complete';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
      i:=i+1;--7
      r_fmt(i).colWidth:=70;
      r_fmt(i).colLabel:='X_Status';
      r_fmt(i).hFontStyle:='B';
      r_fmt(i).hFontSize:=i_Header_hFontSize;
      r_fmt(i).hAlignment:=c_Header_hAlignment;
--      r_fmt(i).hAlignVert:='T';
--      r_fmt(i).tAlignment:='R';
--      r_fmt(i).tAlignVert:='B';
    end;
-- messageLogText := 'Status and OFM generally complete';
   -- MESLOG.MESSAGE_LOG_PROC ( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
--    webc_as_pdf3_v5_pkg.query2table(
--                          t_query,
--                          NULL,
--                          NULL,
--                          NULL,
--                          NULL,
--                          'pt',
--                          0,
--                          0,
--                          1,
--                          0,
--                          NULL,
--                          0
--    );
--dbms_output.put_line('t_query output: '||t_query);
   webc_as_pdf3_v5_pkg.query2table(t_query,
     r_fmt,
     webc_as_pdf3_v5_pkg.tp_colors('000000',v_vHeadColor,'000000',
                          '000000','ffffff','000000', 
                          '000000',v_vOddColor,'000000'),
                          NULL,
                          NULL,
                          'pt',
                          0,
                          0,
                          1,
                          0,
                          NULL,
                          0
    );
    r_fmt(1).tFontStyle:='B';
    r_fmt(1).tAlignment:='R';
    r_fmt(2).tFontStyle:='B';
    r_fmt(3).tFontStyle:='B';
    r_fmt(4).tFontStyle:='B';
    r_fmt(5).tFontStyle:='B';
    webc_as_pdf3_v5_pkg.query2table(t_query_sum,
     r_fmt,
     webc_as_pdf3_v5_pkg.tp_colors('000000',v_vHeadColor,'000000',
                          '000000','ffffff','000000', 
                          '000000',v_vOddColor,'000000'),
                          0,
                          NULL,
                          'pt',
                          0,
                          0,
                          1,
                          0,
                          NULL,
                          0
    );
   messageLogText := 'OFM generation has finished';
   MESLOG.MESSAGE_LOG_PROC( 3, 1, WEBC_GET_WEBCATS_VERSION_FUNC('app'), WEBC_GET_WEBCATS_VERSION_FUNC('version'), messageLogContext, null, messageLogText, 0, p_user, nError, 1); 
     --15,15, 'mm',0,1  
     --);
   
    webc_as_pdf3_v5_pkg.save_pdf_in_tab('WEBC_TEMP_PDF3_TBL', P_phase, P_instance, P_mainscenario, p_user);
    RETURN NULL;
END webc_gen_ofm_pdf_func;

/
