*&---------------------------------------------------------------------*
*& Report Z_EXCEL_UPLOAD_NEW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_excel_upload_new.

TYPES: BEGIN OF lty_structure,
         request   TYPE e070-trkorr,
         create_at TYPE e070-as4date,
         uname     TYPE e070-as4user,
       END OF lty_structure.

FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .
DATA: gt_saida  TYPE TABLE OF lty_structure.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
PARAMETERS : p_file TYPE string OBLIGATORY LOWER CASE DEFAULT 'C:\Temp\Spreadsheet.xlsx'.
SELECTION-SCREEN END OF BLOCK b1 .

*--------------------------------------------------------------------*
* at selection screen
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA: lv_rc TYPE i.
  DATA: lt_file_table TYPE filetable,
        ls_file_table TYPE file_table.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Select a file'
    CHANGING
      file_table   = lt_file_table
      rc           = lv_rc.

  IF sy-subrc = 0.
    READ TABLE lt_file_table INTO ls_file_table INDEX 1.
    p_file = ls_file_table-filename.
  ENDIF.

START-OF-SELECTION .

  PERFORM read_file .
  PERFORM process_file.

*---------------------------------------------------------------------*
* Form READ_FILE
*---------------------------------------------------------------------*
FORM read_file .

  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.

  lv_filename = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid
          TYPE 'S'
        NUMBER sy-msgno
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4
       DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
  "convert binary data to xstring
  "if you are using cl_fdt_xl_spreadsheet in odata then skips this step
  "as excel file will already be in xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc NE 0.
    "Implement suitable error handling here
    MESSAGE ID sy-msgid
          TYPE 'S'
        NUMBER sy-msgno
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4
       DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                              document_name = lv_filename
                              xdocument     = lv_headerxstring ) .
    CATCH cx_fdt_excel_core INTO DATA(lst_error).
      "Implement suitable error handling here
    MESSAGE ID sy-msgid
          TYPE 'S'
        NUMBER sy-msgno
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4
       DISPLAY LIKE 'E'.
    STOP.
  ENDTRY .

  "Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  IF NOT lt_worksheets IS INITIAL.
    READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

    DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                             lv_woksheetname ).
    "now you have excel work sheet data in dyanmic internal table
    ASSIGN lo_data_ref->* TO <gt_data>.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Form PROCESS_FILE
*---------------------------------------------------------------------*
FORM process_file .
  TYPES: BEGIN OF lty_index_field,
           index     TYPE i,
           fieldname TYPE string,
         END OF lty_index_field.
  DATA: lt_index_field  TYPE TABLE OF lty_index_field,
        lst_index_field LIKE LINE OF lt_index_field,
        lst_saida       LIKE LINE OF gt_saida.

  DATA : lv_numberofcolumns   TYPE i,
         lv_date_string       TYPE string,
         lv_target_date_field TYPE datum.


  FIELD-SYMBOLS : <ls_data>  TYPE any,
                  <lv_field> TYPE any.

  DATA: ls_components TYPE abap_compdescr.
  DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.
  DATA: lst_structure TYPE lty_structure.

  lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( lst_structure ).

  DATA lrg_row_d_type TYPE RANGE OF i. " Date
  DATA lrg_row_p_type TYPE RANGE OF i. " Currency value

  "you could find out number of columns dynamically from table <gt_data>
  DESCRIBE TABLE lo_strucdescr->components LINES lv_numberofcolumns.

  " Prepare special columns like Date and Currency values
  LOOP AT lo_strucdescr->components INTO DATA(lst_components).

    lst_index_field-index = sy-tabix.
    lst_index_field-fieldname = lst_components-name.
    APPEND lst_index_field TO lt_index_field.
    CLEAR: lst_index_field.

    CASE lst_components-type_kind.
      WHEN 'D'.
        APPEND VALUE #( sign = 'I'
                        option = 'EQ'
                        low = sy-tabix ) TO lrg_row_d_type.
      WHEN 'P'.
        APPEND VALUE #( sign = 'I'
                        option = 'EQ'
                        low = sy-tabix ) TO lrg_row_p_type.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

  LOOP AT <gt_data> ASSIGNING <ls_data> FROM 2.

    "processing columns
    DO lv_numberofcolumns TIMES.
      READ TABLE lt_index_field INTO lst_index_field WITH KEY index = sy-index.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT lst_index_field-fieldname OF STRUCTURE lst_saida TO FIELD-SYMBOL(<lfs_field_saida>).
      ENDIF.

      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <lv_field> .
      IF sy-subrc = 0 .

        IF sy-index IN lrg_row_d_type.
          lv_date_string = <lv_field> .
          PERFORM date_convert USING lv_date_string CHANGING lv_target_date_field .
          <lfs_field_saida> = lv_target_date_field.

        ELSEIF sy-index IN lrg_row_p_type.
          <lfs_field_saida> = <lv_field>.

        ELSE.
          <lfs_field_saida> = <lv_field> .

        ENDIF.

      ENDIF.
    ENDDO .

    APPEND lst_saida TO gt_saida.
    CLEAR: lst_saida.
  ENDLOOP .

  cl_salv_table=>factory( IMPORTING  r_salv_table   = DATA(alv)
                                CHANGING   t_table        = gt_saida  ).

  alv->display( ).
ENDFORM.

*---------------------------------------------------------------------*
* Form DATE_CONVERT
*---------------------------------------------------------------------*
FORM date_convert USING iv_date_string TYPE string CHANGING cv_date TYPE datum .

  DATA: lv_convert_date(10) TYPE c.

  "The field in the excel file must be in some date format (mm/dd/yyyy or mm-dd-yyyy or any other formats)
  lv_convert_date = iv_date_string .

  "date format YYYY/MM/DD
  FIND REGEX '^\d{4}[/|-]\d{1,2}[/|-]\d{1,2}$' IN lv_convert_date.
  IF sy-subrc = 0.
    CALL FUNCTION '/SAPDMC/LSM_DATE_CONVERT'
      EXPORTING
        date_in             = lv_convert_date
        date_format_in      = 'DYMD'
        to_output_format    = ' '
        to_internal_format  = 'X'
      IMPORTING
        date_out            = lv_convert_date
      EXCEPTIONS
        illegal_date        = 1
        illegal_date_format = 2
        no_user_date_format = 3
        OTHERS              = 4.
  ELSE.

    FIND REGEX '^\d{1,2}[/|-]\d{1,2}[/|-]\d{4}$' IN lv_convert_date.
    IF sy-subrc = 0.
      " date format DD/MM/YYYY
      CALL FUNCTION '/SAPDMC/LSM_DATE_CONVERT'
        EXPORTING
          date_in             = lv_convert_date
          date_format_in      = 'DDMY'
          to_output_format    = ' '
          to_internal_format  = 'X'
        IMPORTING
          date_out            = lv_convert_date
        EXCEPTIONS
          illegal_date        = 1
          illegal_date_format = 2
          no_user_date_format = 3
          OTHERS              = 4.

      IF sy-subrc <> 0.
        " date format MM/DD/YYYY
        CALL FUNCTION '/SAPDMC/LSM_DATE_CONVERT'
          EXPORTING
            date_in             = lv_convert_date
            date_format_in      = 'MDDY'
            to_output_format    = ' '
            to_internal_format  = 'X'
          IMPORTING
            date_out            = lv_convert_date
          EXCEPTIONS
            illegal_date        = 1
            illegal_date_format = 2
            no_user_date_format = 3
            OTHERS              = 4.
      ENDIF.
    ENDIF.

  ENDIF.

  IF sy-subrc = 0.
    cv_date = lv_convert_date .
  ENDIF.

ENDFORM .
