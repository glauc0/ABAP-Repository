*&---------------------------------------------------------------------*
*& Report  ZZXML_VIEWER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zzxml_viewer.

PARAMETERS id_file TYPE string LOWER CASE DEFAULT 'C:\temp\'.
DATA:
    lw_file                 TYPE localfile,
    lo_xml_doc         TYPE REF TO cl_xml_document.


   CREATE OBJECT lo_xml_doc
*    EXPORTING
*      DESCRIPTION = '<unknown>'
*      DIRECTION = space
*      ROLE   = space
*      OBJECT_TYPE = CL_XML_DOCUMENT=>C_BOR_CLASSTYPE
*      OBJECT_NAME = '<unknown>'
*      OBJECT_KEY =
      .


* XML-File von lokalem PC laden
  lw_file = id_file.
  CALL METHOD lo_xml_doc->import_from_file
    EXPORTING
      filename = lw_file
    RECEIVING
      retcode  = DATA(ld_rc).


  IF ( ld_rc = 0 ).
*   XML anzeigen
    CALL METHOD lo_xml_doc->display
*         EXPORTING
*           WITH_BDN = abap_true
        .
  ENDIF.
