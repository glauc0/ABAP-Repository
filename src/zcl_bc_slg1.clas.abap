class ZCL_BC_SLG1 definition
  public
  create public .

public section.

  methods SET_SLG1
    importing
      !I_OBJECT type BAL_S_LOG-OBJECT
      !I_SUB_OBJECT type BAL_S_LOG-SUBOBJECT
      !I_CPROG type SY-CPROG
      !I_EXTNUMBER type BAL_S_LOG-EXTNUMBER
      !IT_RETURN type BAPIRET2_T .
  methods SLG1_VIEW
    importing
      !I_EXTNUMBER type BALNREXT
      !I_OBJECT type BALHDR-OBJECT
      !I_SUB_OBJECT type BALHDR-SUBOBJECT
      !I_CPROG type SY-CPROG optional
    exceptions
      LOG_NOT_FOUND
      NO_FILTER_CRITERIA
      ERROR_NOT_FOUND .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BC_SLG1 IMPLEMENTATION.


  METHOD SET_SLG1.
    DATA: lst_log_handle TYPE balloghndl,
          lst_log_create TYPE bal_s_log,
          lst_log        TYPE bal_s_msg,
          i_handles      TYPE bal_t_logh,
          lst_handle     LIKE LINE OF i_handles.

    CHECK it_return IS NOT INITIAL.

    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = lst_log_handle
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.

    lst_log_create-object      = i_object.
    lst_log_create-subobject   = i_sub_object.
    lst_log_create-aluser      = sy-uname.
*    lst_log_create-alprog      = i_cprog.
    lst_log_create-extnumber   = i_extnumber.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = lst_log_create
      IMPORTING
        e_log_handle = lst_log_handle.

    LOOP AT it_return INTO DATA(lst_return).

      lst_log-msgty = lst_return-type.
      lst_log-msgid = lst_return-id.
      lst_log-msgno = lst_return-number.
      lst_log-msgv1 = lst_return-message_v1.
      lst_log-msgv2 = lst_return-message_v2.
      lst_log-msgv3 = lst_return-message_v3.
      lst_log-msgv4 = lst_return-message_v4.

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle = lst_log_handle
          i_s_msg      = lst_log.

    ENDLOOP.

    MOVE lst_log_handle TO lst_handle.
    APPEND lst_handle   TO i_handles.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = i_handles
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.

  ENDMETHOD.


  METHOD SLG1_VIEW.

    DATA: lst_filter     TYPE bal_s_lfil,
          lst_extern     TYPE LINE OF bal_r_extn,
          lst_alprog     TYPE LINE OF bal_r_prog,
          lst_altcode    TYPE LINE OF bal_r_tcde,
          lst_object     TYPE LINE OF bal_r_obj,
          lst_subobject  TYPE LINE OF bal_r_sub,
          lt_log_header  TYPE balhdr_t,
          lt_log_handle  TYPE TABLE OF balloghndl,
          lst_log_handle TYPE balloghndl.

    CHECK i_extnumber IS NOT INITIAL.

    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = lst_log_handle
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.

    lst_extern-sign    = 'I'.
    lst_extern-option  = 'EQ'.
    lst_extern-low    = i_extnumber.
    APPEND lst_extern TO lst_filter-extnumber.

*    lst_alprog-sign    = 'I'.
*    lst_alprog-option  = 'EQ'.
*    lst_alprog-low     = i_cprog.
*    APPEND lst_alprog TO lst_filter-alprog.

    lst_object-sign    = 'I'.
    lst_object-option  = 'EQ'.
    lst_object-low     = i_object.
    APPEND lst_object TO lst_filter-object.

    lst_subobject-sign    = 'I'.
    lst_subobject-option  = 'EQ'.
    lst_subobject-low     = i_sub_object.
    APPEND lst_subobject TO lst_filter-subobject.

* SLG1 search using the informed key
    CALL FUNCTION 'BAL_DB_SEARCH'
      EXPORTING
        i_s_log_filter     = lst_filter
      IMPORTING
        e_t_log_header     = lt_log_header[]
      EXCEPTIONS
        log_not_found      = 1
        no_filter_criteria = 2.

    IF sy-subrc = 0.

      CALL FUNCTION 'BAL_DB_LOAD'
        EXPORTING
          i_t_log_header     = lt_log_header[]
        EXCEPTIONS
          no_logs_specified  = 1
          log_not_found      = 2
          log_already_loaded = 3.

      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
        EXPORTING
          i_s_log_filter       = lst_filter
        EXCEPTIONS
          profile_inconsistent = 1
          internal_error       = 2
          no_data_available    = 3
          no_authority         = 4
          OTHERS               = 5.

    ELSE.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING log_not_found.
        WHEN 2.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING no_filter_criteria.
        WHEN OTHERS.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_not_found.
      ENDCASE.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
