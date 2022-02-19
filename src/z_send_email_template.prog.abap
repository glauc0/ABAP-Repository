*&---------------------------------------------------------------------*
*& Report Z_SEND_EMAIL_TEMPLATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_send_email_template.

DATA: lo_email TYPE REF TO zcl_email,
      lt_text  TYPE TABLE OF string.

PARAMETERS p_attach TYPE string.
PARAMETERS p_so10 TYPE tdobname DEFAULT 'ZEMAIL_TESTE'.

CREATE OBJECT lo_email.

lo_email->set_subject( iv_email_subject =  'Teste' ).

lo_email->get_read_text(
  EXPORTING
    iv_name     = p_so10                 " Name
    iv_language = sy-langu                 " Language Key
    iv_object   = 'TEXT'                 " Texts: application object
    iv_id   = 'ST'                 " Texts: application object
  EXCEPTIONS
    OTHERS = 99
).

IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ELSE.
  DATA(lv_value) = CONV string( sy-uname ).
  lo_email->replace_texts(
    EXPORTING
      iv_target = '<sy-uname>'
      iv_value  = lv_value
  ).

  lv_value = CONV string( sy-datum ).
  lo_email->replace_texts(
    EXPORTING
      iv_target = '<sy-datum>'
      iv_value  = lv_value
  ).
ENDIF.

lo_email->set_body( ).

DATA: lst_text LIKE LINE OF lt_text.

lst_text = `Name;LastName`.
APPEND lst_text TO lt_text.

lst_text = `Glauco;Silva`.
APPEND lst_text TO lt_text.

lst_text = `Natalia;Valenzuela`.
APPEND lst_text TO lt_text.

lo_email->convert_data_to_csv(
  EXPORTING
    it_text         = lt_text                 " String table
  EXCEPTIONS
    ex_document_bcs = 1                " ex_document_bcs
    ex_send_req_bcs = 2                " ex_send_req_bcs
    OTHERS          = 3
).
IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

DATA: lt_receipient  TYPE zuiys_iusr_tt,
      lst_receipient LIKE LINE OF lt_receipient.

lst_receipient-email = 'glauco.ernesto@gmail.com'.
APPEND lst_receipient TO lt_receipient.

lst_receipient-email = 'glauco.silva@gmail.com'.
APPEND lst_receipient TO lt_receipient.

lo_email->add_recipient(
  EXPORTING
    it_receipient  = lt_receipient " Receipient list
  EXCEPTIONS
    ex_address_bcs = 1                " ex_address_bcs
    OTHERS         = 2
).
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

lo_email->finalize_email(
  EXCEPTIONS
    ex_send_req_bcs = 1                " ex_send_req_bcs
    OTHERS          = 2
).
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
*
*  TYPES BEGIN OF ty_gs_data_key.
*  TYPES   name  TYPE string.
*  TYPES   value TYPE string.
*  TYPES END   OF ty_gs_data_key.
*  TYPES ty_gt_data_key TYPE STANDARD TABLE OF ty_gs_data_key WITH EMPTY KEY.
*
*PARAMETERS p_rec TYPE adr6-smtp_addr DEFAULT 'glauco.ernesto@gmail.com'.
*PARAMETERS p_em_id TYPE smtg_tmpl_id DEFAULT 'ZEMAIL'.
*PARAMETERS p_vbeln TYPE sy-uname DEFAULT 'DEVELOPER'.
*
*DATA(lo_email_api) = cl_smtg_email_api=>get_instance( iv_template_id = p_em_id  ).
**Create instance of class CL_BCS.
*DATA(lo_bcs) = cl_bcs=>create_persistent( ).
**Prepare CDS view Key table with Key Field name and value.
*DATA(lt_cds_key) = VALUE ty_gt_data_key( ( name = 'Uname' value = p_vbeln ) ).
**Integrate E-Mail subject and body with email instance
*lo_email_api->render_bcs( io_bcs = lo_bcs iv_language = sy-langu it_data_key = lt_cds_key ).
**Set Sender, receiver and send the email.
*  " Set Email Sender
*  DATA(lo_sender) = cl_sapuser_bcs=>create( sy-uname ).
*
*  lo_bcs->set_sender( i_sender = lo_sender ).
*
*  " Set Email Receiver(s)
*  DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address( p_rec ).
*  lo_bcs->add_recipient( EXPORTING i_recipient = lo_recipient ).
*
*  " Send Email
*  lo_bcs->send( ).
