*&---------------------------------------------------------------------*
*& Report ZPREENCHE_RANGE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpreenche_range.

SELECT product_id AS key
  INTO TABLE @DATA(lt_table_main)
  FROM snwd_pd UP TO 4 ROWS.

DATA(lv_loop) = abap_true.
DATA(lv_count) = 0.
DATA(lv_limit) = 15000.  " Tamanho maximo que o range suporta (dependendendo da versão do SAP)

DATA(lt_aux) = lt_table_main.
SORT: lt_aux BY key.
DELETE ADJACENT DUPLICATES FROM lt_aux COMPARING key.

DATA: lrg_aux TYPE RANGE OF snwd_product_id,
      lsg_aux LIKE LINE OF lrg_aux.

WHILE lv_loop EQ abap_true.

  LOOP AT lt_aux INTO DATA(lst_aux).

    DATA(lv_tabix) = sy-tabix.

    lsg_aux-sign = 'I'.
    lsg_aux-option = 'EQ'.
    lsg_aux-low = lst_aux-key.

    APPEND lsg_aux TO lrg_aux.
    CLEAR: lsg_aux.

    DELETE lt_aux INDEX lv_tabix.

    ADD 1 TO lv_count.

    IF lv_count GE lv_limit.
      CLEAR: lv_count.
      EXIT.
    ENDIF.

  ENDLOOP.

*  SELECT *
*  APPENDING TABLE lt_table_return
*  FROM snwd_pd
*  WHERE field IN lrg_aux.

  CLEAR: lrg_aux.

  IF lt_aux IS INITIAL.
    lv_loop = abap_false.
  ENDIF.
ENDWHILE.
