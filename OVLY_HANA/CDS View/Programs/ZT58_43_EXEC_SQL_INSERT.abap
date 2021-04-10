*&---------------------------------------------------------------------*
*& Report ZT58_43_EXEC_SQL_INSERT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zt58_43_exec_sql_insert.

PARAMETERS p_nome TYPE snwd_company-company_name.

TRY .

*  EXEC SQL.
*    CONNECT TO 'DB_FABIO'
*  ENDEXEC.

  EXEC SQL.

     INSERT INTO SAPHANADB.SNWD_COMPANY
      (
        CLIENT,
        NODE_KEY,
        COMPANY_NAME
      )
      VALUES
      (
        :sy-mandt,
        SYSUUID,
        :p_nome
      )


  ENDEXEC.

  IF sy-subrc IS INITIAL.
    WRITE 'OK'.
  ENDIF.

*  EXEC SQL.
*    DISCONNECT 'DB_FABIO'
*  ENDEXEC.

CATCH cx_root INTO DATA(lr_root).
  cl_demo_output=>display_text( text = lr_root->get_text( ) ).
  STOP.
ENDTRY.
