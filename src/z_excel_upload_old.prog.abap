*&---------------------------------------------------------------------*
*& Report Z_EXCEL_UPLOAD_OLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_excel_upload_old.

TYPES:
      BEGIN OF gty_structure,
        request   TYPE e070-trkorr,
        create_at TYPE e070-as4date,
        uname     TYPE e070-as4user,
      END OF gty_structure,

      tt_data TYPE STANDARD TABLE OF gty_structure.
DATA: t_data  TYPE tt_data,
      lst_data TYPE gty_structure.
*
PARAMETERS : p_file TYPE string OBLIGATORY LOWER CASE DEFAULT 'C:\Temp\Spreadsheet.xlsx'.

START-OF-SELECTION.
  DATA: lo_uploader TYPE REF TO zcl_excel_uploader_600.

  CREATE OBJECT lo_uploader
    EXPORTING
      ist_structure = lst_data.

*  lo_uploader->gv_max_rows = 10.
  lo_uploader->gv_filename = p_file.
  lo_uploader->gv_header_rows_count = 1.
  lo_uploader->upload( CHANGING ct_data = t_data ).

  DATA lo_alv TYPE REF TO cl_salv_table.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   = lo_alv
    CHANGING
      t_table        = t_data
  ).

  lo_alv->display( ).
