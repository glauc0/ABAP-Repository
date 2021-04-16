*&---------------------------------------------------------------------*
*& Report ZSEND_EMAIL_SPOOL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsend_email_spool.
PARAMETERS p_jobnam LIKE tbtcp-jobname.

DATA send_request  TYPE REF TO cl_bcs.
DATA document      TYPE REF TO cl_document_bcs.
DATA recipient     TYPE REF TO if_recipient_bcs.
DATA bcs_exception TYPE REF TO cx_bcs.
DATA sent_to_all   TYPE os_boolean.
DATA pdf_size      TYPE so_obj_len.
DATA pdf_content   TYPE solix_tab.
DATA pdf_xstring   TYPE xstring.
DATA lm_dist       TYPE so_obj_nam.
DATA rqident       TYPE tsp01-rqident.
DATA v_spoolid     TYPE tsp01-rqident.
DATA subline       TYPE so_obj_des.

DATA: wa_tbtcp           TYPE tbtcp,
      it_tbtcp           TYPE STANDARD TABLE OF tbtcp,
*      wa_varsub     type zvarsub,
*      it_varsub     type standard table of zvarsub.

      start-of-selection.

* Get spool number for the job
*PERFORM get_spool_for_job.
*
** Get varinat details for the job.
*PERFORM get_var_details.

*LOOP AT it_tbtcp INTO wa_tbtcp.
  rqident = p_jobnam."wa_tbtcp-listident.

  PERFORM create_pdf.

  PERFORM send_mail.

  CLEAR wa_tbtcp.

*ENDLOOP.


*&---------------------------------------------------------------------*
*&      Form  GET_VAR_DETAILS
*&---------------------------------------------------------------------*
*       Fetch Distribution list and Subject for the variants
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_var_details .

*  select * from zvarsub into table it_varsub.

ENDFORM.                    " GET_VAR_DETAILS
*&---------------------------------------------------------------------*
*&      Form  GET_SPOOL_FOR_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_spool_for_job .

* get the job and spool information from table
  SELECT * FROM tbtcp INTO TABLE it_tbtcp WHERE jobname = p_jobnam.

* sort table to get latest spool ID.
  SORT it_tbtcp DESCENDING BY sdldate jobcount.

* read first line to get jobcount id.
  READ TABLE it_tbtcp INTO wa_tbtcp INDEX 1.

* Delete items from table which are not required
  DELETE it_tbtcp WHERE jobcount NE wa_tbtcp-jobcount.

  CLEAR wa_tbtcp.

ENDFORM.                    " GET_SPOOL_FOR_JOB

*&---------------------------------------------------------------------*
*&      Form  create_pdf
*&---------------------------------------------------------------------*
* Create PDF Content
* 1) get attributes of spool request
* 2) convert spool request to PDF dependent on document type
*----------------------------------------------------------------------*
FORM create_pdf.

  DATA rq       TYPE tsp01.
  DATA bin_size TYPE i.
  DATA dummy    TYPE TABLE OF rspoattr.

  CLEAR: rq, bin_size, dummy, pdf_xstring, pdf_size.

*   ------------ get attributes of spool request ---------------------
  CALL FUNCTION 'RSPO_GET_ATTRIBUTES_SPOOLJOB'
    EXPORTING
      rqident     = rqident
    IMPORTING
      rq          = rq
    TABLES
      attributes  = dummy
    EXCEPTIONS
      no_such_job = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE e126(po) WITH rqident.
  ENDIF.

*   --- convert spool request into PDF, dependent on document type ---

  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = rqident
      no_dialog                = 'X'
      pdf_destination          = 'X'
      no_background            = 'X'
    IMPORTING
      pdf_bytecount            = bin_size
      bin_file                 = pdf_xstring
    EXCEPTIONS
      err_no_abap_spooljob     = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_destdevice       = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.
  IF sy-subrc <> 0.
    MESSAGE e712(po) WITH sy-subrc 'CONVERT_ABAPSPOOLJOB_2_PDF'.
  ENDIF.

  pdf_size = bin_size.
ENDFORM.                    "create_pdf

*&---------------------------------------------------------------------*
*&      Form  send Email with PDF attachment
*&---------------------------------------------------------------------*
FORM send_mail.

  TRY.

*     -------- create persistent send request ------------------------
      send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document -------------------------------
      pdf_content = cl_document_bcs=>xstring_to_solix( pdf_xstring ).

*      clear wa_varsub.

*  get distribution list and subject line for the varinats.

*      read table it_varsub into wa_varsub with key variant = wa_tbtcp-variant.
*
*      if wa_varsub is initial.
*       write: 'There is no varinat maintained in the zvarsub table'.
*       exit.
*      else.
*       clear: subline, lm_dist.
*
      subline = 'wa_varsub-subject'.
      lm_dist = 'wa_varsub-distlist'.
*      endif.

*  create PDF document.
      document = cl_document_bcs=>create_document(
            i_type    = 'PDF'
            i_hex     = pdf_content
            i_length  = pdf_size
            i_subject = subline ).                          "#EC NOTEXT

*     add document object to send request
      send_request->set_document( document ).

*     --------- add recipient (e-mail address) -----------------------
*     create recipient object
*      recipient = cl_cam_address_bcs=>create_internet_address( mailto ).
      recipient = cl_distributionlist_bcs=>getu_persistent(
                  i_dliname = lm_dist
                  i_private = space ).

*     add recipient object to send request
      send_request->add_recipient( recipient ).

* Set that you don't need a Return Status E-mail

      send_request->set_status_attributes(
                    i_requested_status = 'E' ).

* set send immediately flag

      send_request->set_send_immediately( 'X' ).
*     ---------- send document ---------------------------------------
      sent_to_all = send_request->send( i_with_error_screen = 'X' ).

      COMMIT WORK.

      IF sent_to_all IS INITIAL.
        MESSAGE i500(sbcoms) WITH lm_dist.
      ELSE.
        MESSAGE s022(so).
      ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
    CATCH cx_bcs INTO bcs_exception.
      MESSAGE i865(so) WITH bcs_exception->error_type.
  ENDTRY.

ENDFORM.                    "send
