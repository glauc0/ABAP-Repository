class ZCL_EMAIL definition
  public
  final
  create public .

public section.

  data T_ATTACH_CONTENT_SOLIX type SOLIX_TAB .
  data LST_RECEIPIENTS type ZUIYS_IUSR .
  data V_EMAIL_SUBJECT type SO_OBJ_DES .
  data V_TEXT type SOLI-LINE .
  data V_SENT_TO_ALL type OS_BOOLEAN .
  data V_ATTACH_SIZE type SO_OBJ_LEN .
  data V_ATTACH_XSTRING type XSTRING .
  data R_SEND_EMAIL type ref to CL_BCS .
  data R_DOCUMENT type ref to CL_DOCUMENT_BCS .
  data R_RECIPENT type ref to IF_RECIPIENT_BCS .
  data C_ATTACH_TYPE_TXT type SO_OBJ_TP value 'txt' ##NO_TEXT.
  data C_ATTACH_SUBJECT type SO_OBJ_DES value 'Text_attach' ##NO_TEXT.
  data T_MESSAGE type SOLI_TAB .
  data C_ATTACH_TYPE_CSV type SO_OBJ_TP value 'csv' ##NO_TEXT.

  methods SET_SUBJECT
    importing
      !IV_EMAIL_SUBJECT type SO_OBJ_DES .
  methods SET_TEXT
    importing
      value(LT_TEXT) type STANDARD TABLE .
  methods REPLACE_TEXTS
    importing
      !IV_TARGET type STRING
      !IV_VALUE type STRING .
  methods GET_READ_TEXT
    importing
      !IV_NAME type THEAD-TDNAME
      !IV_LANGUAGE type THEAD-TDSPRAS
      !IV_OBJECT type THEAD-TDOBJECT
      !IV_ID type THEAD-TDID
    exceptions
      ERROR .
  methods SET_BODY .
  methods CONVERT_DATA_FORMAT
    importing
      !IV_ATTACH type STRING
    exceptions
      EX_DOCUMENT_BCS
      EX_SEND_REQ_BCS .
  methods ADD_RECIPIENT
    importing
      !IT_RECEIPIENT type ZUIYS_IUSR_TT
    exceptions
      EX_ADDRESS_BCS
      EX_SEND_REQ_BCS .
  methods FINALIZE_EMAIL
    exceptions
      EX_SEND_REQ_BCS .
  methods CONVERT_DATA_TO_CSV
    importing
      !IT_TEXT type ZSTRING_TT
    exceptions
      EX_DOCUMENT_BCS
      EX_SEND_REQ_BCS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_EMAIL IMPLEMENTATION.


  METHOD add_recipient.

    TRY .
        LOOP AT it_receipient INTO DATA(lst_receipient).
          me->lst_receipients-email = lst_receipient-email.
          me->r_recipent = cl_cam_address_bcs=>create_internet_address(
                             i_address_string = me->lst_receipients-email
*                         i_address_name   =
*                         i_incl_sapuser   =
                           ).
          me->r_send_email->add_recipient(
            EXPORTING
              i_recipient  = me->r_recipent " Recipient of Message
*              i_express    =                  " Send As Express Message
*              i_copy       =                  " Send Copy
*              i_blind_copy =                  " Send As Blind Copy
*              i_no_forward =                  " No Forwarding
          ).
        ENDLOOP.
      CATCH cx_send_req_bcs INTO DATA(lcx_send_req_bcs). " BCS: Send Request Exceptions
        DATA(lst_message) = lcx_send_req_bcs->get_text( ).

        MESSAGE ID lcx_send_req_bcs->msgid
        TYPE lcx_send_req_bcs->msgty
        NUMBER lcx_send_req_bcs->msgno
        WITH lcx_send_req_bcs->msgv1
             lcx_send_req_bcs->msgv2
             lcx_send_req_bcs->msgv3
             lcx_send_req_bcs->msgv4
        RAISING ex_send_req_bcs.
      CATCH cx_address_bcs INTO DATA(lcx_address_bcs). " BCS: Address Exceptions
        lst_message = lcx_address_bcs->get_text( ).

        MESSAGE ID lcx_address_bcs->msgid
        TYPE lcx_address_bcs->msgty
        NUMBER lcx_address_bcs->msgno
        WITH lcx_address_bcs->msgv1
             lcx_address_bcs->msgv2
             lcx_address_bcs->msgv3
             lcx_address_bcs->msgv4
        RAISING ex_address_bcs.
    ENDTRY.
  ENDMETHOD.


  METHOD convert_data_format.

    TRY .

*        IF iv_attach IS NOT INITIAL.

        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = iv_attach
*           MIMETYPE       = ' '
*           ENCODING       =
          IMPORTING
            buffer = me->v_attach_xstring
**     EXCEPTIONS
**       FAILED         = 1
**       OTHERS         = 2
          .

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ELSE.
          me->t_attach_content_solix = cl_document_bcs=>xstring_to_solix( ip_xstring = me->v_attach_xstring ).
          me->v_attach_size = xstrlen( me->v_attach_xstring ).

          me->r_document->add_attachment(
            EXPORTING
              i_attachment_type     = me->c_attach_type_txt " Document Class for Attachment
              i_attachment_subject  = me->c_attach_subject " Attachment Title
              i_attachment_size     = me->v_attach_size " Size of Document Content
*          i_attachment_language = space            " Language in Which Attachment Is Created
*          i_att_content_text    =                  " Content (Text-Like)
              i_att_content_hex     = me->t_attach_content_solix " Content (Binary)
*          i_attachment_header   =                  " Attachment Header Data
*          iv_vsi_profile        =                  " Virus Scan Profile
          ).

          me->r_send_email->set_document( i_document = me->r_document ).

        ENDIF.
*        ENDIF.

      CATCH cx_document_bcs INTO DATA(lcx_document_bcs). " BCS: Document Exceptions
        DATA(lst_message) = lcx_document_bcs->get_text( ).

        MESSAGE ID lcx_document_bcs->msgid
        TYPE lcx_document_bcs->msgty
        NUMBER lcx_document_bcs->msgno
        WITH lcx_document_bcs->msgv1
             lcx_document_bcs->msgv2
             lcx_document_bcs->msgv3
             lcx_document_bcs->msgv4
        RAISING ex_document_bcs.

      CATCH cx_send_req_bcs INTO DATA(lcx_send_req_bcs). " BCS: Send Request Exceptions
        lst_message = lcx_send_req_bcs->get_text( ).

        MESSAGE ID lcx_send_req_bcs->msgid
        TYPE lcx_send_req_bcs->msgty
        NUMBER lcx_send_req_bcs->msgno
        WITH lcx_send_req_bcs->msgv1
             lcx_send_req_bcs->msgv2
             lcx_send_req_bcs->msgv3
             lcx_send_req_bcs->msgv4
        RAISING ex_send_req_bcs.
    ENDTRY.
  ENDMETHOD.


  METHOD convert_data_to_csv.
    CONSTANTS:
      gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
      gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

    DATA(lv_string) = ``.

    TRY .

*        IF iv_attach IS NOT INITIAL.

        LOOP AT it_text INTO DATA(lst_text) .
          CASE sy-tabix.
            WHEN 1.
              CONCATENATE lst_text gc_crlf INTO lv_string .
            WHEN OTHERS.
              CONCATENATE lv_string lst_text gc_crlf INTO lv_string .
          ENDCASE.
        ENDLOOP.

* --------------------------------------------------------------
* convert the text string into UTF-16LE binary data including
* byte-order-mark. Mircosoft Excel prefers these settings
* all this is done by new class cl_bcs_convert (see note 1151257)

        TRY.
            cl_bcs_convert=>string_to_solix(
              EXPORTING
                iv_string   = lv_string
*                iv_codepage = '4103'  "suitable for MS Excel, leave empty
                iv_add_bom  = 'X'     "for other doc types
              IMPORTING
                et_solix  = me->t_attach_content_solix
                ev_size   = me->v_attach_size ).
          CATCH cx_bcs.
            MESSAGE e445(so).
        ENDTRY.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ELSE.
*          me->t_attach_content_solix = cl_document_bcs=>xstring_to_solix( ip_xstring = me->v_attach_xstring ).
*          me->v_attach_size = xstrlen( me->v_attach_xstring ).

          me->r_document->add_attachment(
            EXPORTING
              i_attachment_type     = me->c_attach_type_csv " Document Class for Attachment
              i_attachment_subject  = me->c_attach_subject " Attachment Title
              i_attachment_size     = me->v_attach_size " Size of Document Content
*          i_attachment_language = space            " Language in Which Attachment Is Created
*          i_att_content_text    =                  " Content (Text-Like)
              i_att_content_hex     = me->t_attach_content_solix " Content (Binary)
*          i_attachment_header   =                  " Attachment Header Data
*          iv_vsi_profile        =                  " Virus Scan Profile
          ).

          me->r_send_email->set_document( i_document = me->r_document ).

        ENDIF.
*        ENDIF.

      CATCH cx_document_bcs INTO DATA(lcx_document_bcs). " BCS: Document Exceptions
        DATA(lst_message) = lcx_document_bcs->get_text( ).

        MESSAGE ID lcx_document_bcs->msgid
        TYPE lcx_document_bcs->msgty
        NUMBER lcx_document_bcs->msgno
        WITH lcx_document_bcs->msgv1
             lcx_document_bcs->msgv2
             lcx_document_bcs->msgv3
             lcx_document_bcs->msgv4
        RAISING ex_document_bcs.

      CATCH cx_send_req_bcs INTO DATA(lcx_send_req_bcs). " BCS: Send Request Exceptions
        lst_message = lcx_send_req_bcs->get_text( ).

        MESSAGE ID lcx_send_req_bcs->msgid
        TYPE lcx_send_req_bcs->msgty
        NUMBER lcx_send_req_bcs->msgno
        WITH lcx_send_req_bcs->msgv1
             lcx_send_req_bcs->msgv2
             lcx_send_req_bcs->msgv3
             lcx_send_req_bcs->msgv4
        RAISING ex_send_req_bcs.
    ENDTRY.
  ENDMETHOD.


  METHOD finalize_email.
    TRY.
        me->v_sent_to_all = me->r_send_email->send(
                            ).
        COMMIT WORK.

      CATCH cx_send_req_bcs INTO DATA(lcx_send_req_bcs). " BCS: Send Request Exceptions
        DATA(lst_message) = lcx_send_req_bcs->get_text( ).

        MESSAGE ID lcx_send_req_bcs->msgid
        TYPE lcx_send_req_bcs->msgty
        NUMBER lcx_send_req_bcs->msgno
        WITH lcx_send_req_bcs->msgv1
             lcx_send_req_bcs->msgv2
             lcx_send_req_bcs->msgv3
             lcx_send_req_bcs->msgv4
        RAISING ex_send_req_bcs.
    ENDTRY.
  ENDMETHOD.


  METHOD get_read_text.
    DATA: lt_lines    TYPE TABLE OF tline,
          lst_message TYPE soli.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = iv_id
        language                = iv_language
        name                    = iv_name
        object                  = iv_object
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*     IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error.
    ELSE.
      LOOP AT lt_lines INTO DATA(lst_lines).
        lst_message-line = lst_lines-tdline.
        APPEND lst_message TO me->t_message.
        CLEAR: lst_message.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD replace_texts.
    LOOP AT me->t_message ASSIGNING FIELD-SYMBOL(<lfs_message>).
      IF <lfs_message> CA iv_target.
        REPLACE ALL OCCURRENCES OF iv_target IN <lfs_message> WITH iv_value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_body.

    me->r_send_email = cl_bcs=>create_persistent( ).
*                       CATCH cx_send_req_bcs. " BCS: Send Request Exceptions

    me->r_document = cl_document_bcs=>create_document(
      i_type = 'HTM'
      i_subject = me->v_email_subject
      i_text = me->t_message
    ).
  ENDMETHOD.


  method SET_SUBJECT.
    CHECK iv_email_subject IS NOT INITIAL.

    v_email_subject = iv_email_subject.
  endmethod.


  METHOD SET_TEXT.
    DATA: lst_dref TYPE REF TO data,
          lst_message TYPE soli,
          lo_structdescr TYPE REF TO cl_abap_structdescr.

    CREATE DATA lst_dref LIKE LINE OF lt_text.
    ASSIGN lst_dref->* TO FIELD-SYMBOL(<lfs_text_tab>).

    lo_structdescr ?= cl_abap_structdescr=>describe_by_data( <lfs_text_tab> ).

    LOOP AT lo_structdescr->components
        ASSIGNING FIELD-SYMBOL(<lfs_components>).
      APPEND lst_message TO me->t_message.
      CLEAR: lst_message.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
