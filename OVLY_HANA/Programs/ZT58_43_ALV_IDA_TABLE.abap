*&---------------------------------------------------------------------*
*& Report ZT58_43_ALV_IDA_TABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zt58_43_alv_ida_table.

DATA: gv_table TYPE dd02l-tabname.

SELECT-OPTIONS s_tab FOR gv_table NO INTERVALS NO-EXTENSION.

TRY .
  cl_salv_gui_table_ida=>create(
    EXPORTING
      iv_table_name         = s_tab-low
*      io_gui_container      =
*      io_calc_field_handler =
    RECEIVING
      ro_alv_gui_table_ida  = DATA(lo_alv)
  ).
  CATCH cx_salv_db_connection.
  CATCH cx_salv_db_table_not_supported.
  CATCH cx_salv_ida_contract_violation.

ENDTRY.

lo_alv->display_options( )->set_title( iv_title = conv #( s_tab-low ) ).

lo_alv->fullscreen( )->display( ).
