INITIALIZATION.
  gv_variant = sy-uname.

  CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
    EXPORTING
      report               = sy-repid
      variant              = gv_variant
    EXCEPTIONS
      variant_not_existent = 01
      variant_obsolete     = 02.
  IF sy-subrc NE 0.
    CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
      EXPORTING
        report               = sy-repid
        variant              = 'DEFAULT'
      EXCEPTIONS
        variant_not_existent = 01
        variant_obsolete     = 02.
  ENDIF.

  PERFORM alv_init CHANGING p_varia.
*----------------------------------------------------------------------*
FORM alv_init CHANGING pv_varia.
*----------------------------------------------------------------------*
*
  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.

  ls_variant-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = ls_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    pv_varia = ls_variant-variant.
  ENDIF.
*
ENDFORM.                    " ALV_INIT
