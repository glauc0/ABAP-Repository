SELECT matnr as key
  INTO TABLE @DATA(lt_table_main)
  FROM mara UP TO 4 ROWS.

DATA: lrg_key TYPE RANGE OF matnr.

DATA(lv_from) = 1.
DATA(lv_limit) = 2.

DATA(lt_table_aux) = lt_table_main.
SORT lt_table_aux BY key.
DELETE ADJACENT DUPLICATES FROM lt_table_aux COMPARING key.

WHILE lt_table_aux IS NOT INITIAL.
  lrg_key = VALUE #( BASE lrg_key FOR lst IN lt_table_aux FROM lv_from TO lv_limit
                      ( sign = 'I' option = 'EQ' low = lst-key )
                     ).

  DELETE lt_table_aux FROM lv_from TO lv_limit.

ENDWHILE.
