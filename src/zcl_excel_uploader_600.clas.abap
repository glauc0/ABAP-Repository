CLASS zcl_excel_uploader_600 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF gty_alsmex_tabline,
        row   TYPE numc4,
        col   TYPE numc4,
        value TYPE char50,
      END OF gty_alsmex_tabline .

    DATA gv_header_rows_count TYPE i .
    DATA gv_max_rows TYPE i .
    DATA gv_filename TYPE localfile .
    DATA gv_special_columns_ok TYPE c .
    DATA:
      grg_row_d_type TYPE RANGE OF i .
    DATA:
      gsg_row_d_type LIKE LINE OF grg_row_d_type .
    DATA:
      grg_row_p_type TYPE RANGE OF i .      " Currency value
    DATA:                                   " Date
      gsg_row_p_type LIKE LINE OF grg_row_p_type .
    DATA go_strucdescr TYPE REF TO cl_abap_structdescr .

    METHODS constructor
      IMPORTING
        !ist_structure TYPE any .
    METHODS upload
      CHANGING
        !ct_data TYPE ANY TABLE .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_tot_components TYPE int4 .

    METHODS do_upload
      IMPORTING
        !iv_begin TYPE int4
        !iv_end   TYPE int4
      EXPORTING
        !rv_empty TYPE flag
      CHANGING
        !ct_data  TYPE STANDARD TABLE .
    METHODS date_convert
      IMPORTING
        !iv_date_string TYPE string
      CHANGING
        !cv_date        TYPE datum .
ENDCLASS.



CLASS ZCL_EXCEL_UPLOADER_600 IMPLEMENTATION.


  METHOD constructor.
    gv_max_rows = 9999.
    me->go_strucdescr ?= cl_abap_typedescr=>describe_by_data( ist_structure ).
  ENDMETHOD.


  METHOD date_convert.

    DATA: lv_convert_date(10) TYPE c.

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

      " date format DD/MM/YYYY
      FIND REGEX '^\d{1,2}[/|-]\d{1,2}[/|-]\d{4}$' IN lv_convert_date.
      IF sy-subrc = 0.
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
      ENDIF.

    ENDIF.

    IF sy-subrc = 0.
      cv_date = lv_convert_date .
    ENDIF.
  ENDMETHOD.


  METHOD do_upload.
    TYPES: BEGIN OF lty_index_field,
             index     TYPE i,
             fieldname TYPE string,
           END OF lty_index_field.

    DATA: lt_exceldata         TYPE STANDARD TABLE OF gty_alsmex_tabline,
          lst_exceldata        LIKE LINE OF lt_exceldata,
          lst_components       TYPE abap_compdescr,
          lv_tot_rows          TYPE i,
          lv_packet            TYPE i,
          lv_numberofcolumns   TYPE i,
          lv_date_string       TYPE string,
          lv_target_date_field TYPE datum.

    FIELD-SYMBOLS: <struc>           TYPE any,
                   <field>           TYPE any,
                   <ls_data>         TYPE any,
                   <lv_field>        TYPE any,
                   <lfs_field_saida> TYPE any.

*   Upload this packet
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        gv_filename             = gv_filename
        i_begin_col             = 1
        i_begin_row             = iv_begin
        i_end_col               = gv_tot_components
        i_end_row               = iv_end
      TABLES
        intern                  = lt_exceldata
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
*   something wrong, exit
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      rv_empty = 'X'.
      EXIT.
    ENDIF.

*   No rows uploaded, exit
    IF lt_exceldata IS INITIAL.
      rv_empty = 'X'.
      EXIT.
    ENDIF.

    IF gv_special_columns_ok IS INITIAL.

      "you could find out number of columns dynamically from table <gt_data>
      DESCRIBE TABLE go_strucdescr->components LINES lv_numberofcolumns.

      " Prepare special columns like Date and Currency values
      LOOP AT go_strucdescr->components INTO lst_components.
        gv_special_columns_ok = 'X'.

        CASE lst_components-type_kind.
          WHEN 'D'.
            gsg_row_d_type = 'IEQ'.
            gsg_row_d_type-low = sy-tabix.

            APPEND gsg_row_d_type TO grg_row_d_type.
            CLEAR: gsg_row_d_type.

          WHEN 'P'.
            gsg_row_p_type = 'IEQ'.
            gsg_row_p_type-low = sy-tabix.

            APPEND gsg_row_p_type TO grg_row_p_type.
            CLEAR: gsg_row_p_type.
          WHEN OTHERS.
        ENDCASE.

      ENDLOOP.
    ENDIF.

*   Move from Row, Col to Flat Structure
    LOOP AT lt_exceldata INTO lst_exceldata.
      " Append new row
      AT NEW row.
        APPEND INITIAL LINE TO ct_data ASSIGNING <struc>.
      ENDAT.

      " component and its value
      ASSIGN COMPONENT lst_exceldata-col OF STRUCTURE <struc> TO <field>.
      IF sy-subrc EQ 0.
        IF lst_exceldata-col IN grg_row_d_type AND
           grg_row_d_type IS NOT INITIAL.

          lv_date_string = lst_exceldata-value.

          me->date_convert(
            EXPORTING
              iv_date_string = lv_date_string
            CHANGING
              cv_date        = lv_target_date_field
          ).

          <field> = lv_target_date_field.

        ELSEIF lst_exceldata-col IN grg_row_p_type AND
               grg_row_p_type IS NOT INITIAL.

          <field> = lst_exceldata-value. "If needed to display according currency, adapt that code

        ELSE.
          <field> = lst_exceldata-value .

        ENDIF.
      ENDIF.

      " add the row count
      AT END OF row.
        IF <struc> IS NOT INITIAL.
          lv_tot_rows = lv_tot_rows + 1.
        ENDIF.
      ENDAT.
    ENDLOOP.

*   packet has more rows than uploaded rows,
*   no more packet left. Thus exit
    lv_packet = iv_end - iv_begin.
    IF lv_tot_rows LT lv_packet.
      rv_empty = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD upload.
    DATA: lo_struct TYPE REF TO cl_abap_structdescr,
          lo_table  TYPE REF TO cl_abap_tabledescr,
          lt_comp   TYPE cl_abap_structdescr=>component_table.

    lo_table ?= cl_abap_structdescr=>describe_by_data( ct_data ).
    lo_struct ?= lo_table->get_table_line_type( ).
    lt_comp    = lo_struct->get_components( ).
*
    gv_tot_components = lines( lt_comp ).
*
    DATA: lv_empty TYPE flag,
          lv_begin TYPE i,
          lv_end   TYPE i.
*
    lv_begin = gv_header_rows_count + 1.
    lv_end   = gv_max_rows.

    WHILE lv_empty IS INITIAL.
      do_upload(
        EXPORTING
            iv_begin = lv_begin
            iv_end   = lv_end
        IMPORTING
            rv_empty = lv_empty
        CHANGING
            ct_data  = ct_data
      ).
      lv_begin = lv_end + 1.
      lv_end   = lv_begin + gv_max_rows.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
