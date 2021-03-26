*&---------------------------------------------------------------------*
*& Report zt58_31_alv_ida_parceiros
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zt58_31_alv_ida_parceiros.



DATA lv_bp_role TYPE zhd_partners2-role.
DATA lv_legal_form TYPE zhd_partners2-legal_form.

PARAMETERS: p_name TYPE zhd_partners2-name LOWER CASE MATCHCODE OBJECT zhd_company_name.
SELECT-OPTIONS s_role FOR lv_bp_role.
SELECT-OPTIONS s_legal FOR lv_legal_form MATCHCODE OBJECT zhd_legal_form.


START-OF-SELECTION.

  DATA r_alv TYPE REF TO if_salv_gui_table_ida.
  DATA r_ranges TYPE REF TO cl_salv_range_tab_collector.

  DATA t_ranges TYPE if_salv_service_types=>yt_named_ranges.
  TRY.

      r_alv = cl_salv_gui_table_ida=>create_for_cds_view(
        EXPORTING
          iv_cds_view_name      = 'ZT58_31_IDA_PARCEIROS_C'
      ).

      r_ranges = NEW #( ).

      r_ranges->add_ranges_for_name(
        EXPORTING
          iv_name   = 'ROLE'
          it_ranges = s_role[]
      ).

      r_ranges->add_ranges_for_name(
        EXPORTING
          iv_name   = 'LEGAL_FORM'
          it_ranges = s_legal[]
      ).

      r_ranges->get_collected_ranges(
           IMPORTING
             et_named_ranges = t_ranges
         ).

      r_alv->set_select_options(
       EXPORTING
         it_ranges    = t_ranges
*            io_condition =
   ).


      IF p_name IS NOT INITIAL.

        r_alv->text_search( )->set_field_similarity( iv_field_similarity = '0.7' ).
        r_alv->text_search( )->set_search_term( |{ p_name }| ).
        r_alv->text_search( )->set_search_scope(
             its_field_names = VALUE #(
                  ( |PARTNER_NAME| )
              ) ).

      ENDIF.

      r_alv->field_catalog( )->set_available_fields(
        its_field_names = VALUE #(
         ( |PARTNER_ID| )
         ( |ROLE| )
         ( |PARTNER_NAME| )
         ( |EMAIL_ADDRESS| )
         ( |CITY| )
         ( |COUNTRY_NAME| )
         )
      ).

      r_alv->fullscreen( )->display( ).

    CATCH cx_salv_db_connection.
    CATCH cx_salv_db_table_not_supported.
    CATCH cx_salv_ida_associate_invalid.
    CATCH cx_salv_ida_contract_violation.
    CATCH cx_salv_function_not_supported.
  ENDTRY.