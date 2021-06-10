*&---------------------------------------------------------------------*
*& Report  ZCHECK_ICON_INTERNAL_NAME
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZCHECK_ICON_INTERNAL_NAME.

TABLES icon.

DATA :
  gs_icon TYPE ICON,
  gt_icon TYPE TABLE OF ICON.

SELECT-OPTIONS s_name FOR icon-name.

SELECT *
  FROM icon
  INTO TABLE gt_icon
 WHERE name IN s_name.

LOOP AT gt_icon INTO gs_icon.

  WRITE :/
    gs_icon-name,
    33 '@',
    34 gs_icon-id+1(2),
    36 '@',
    40 gs_icon-id.

ENDLOOP.
