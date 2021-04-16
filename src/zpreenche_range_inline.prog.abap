*&---------------------------------------------------------------------*
*& Report ZPREENCHE_RANGE_INLINE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpreenche_range_inline.
SELECT product_id AS key
  INTO TABLE @DATA(lt_table_main)
  FROM snwd_pd UP TO 4 ROWS.

DATA(lv_from) = 1.
DATA(lv_limit) = 1500. " Tamanho maximo que o range suporta (dependendendo da versão do SAP)

DATA: lrg_key TYPE RANGE OF matnr.

****************************************************************************
** Versão 1
****************************************************************************
DATA(lt_table_aux) = lt_table_main.
SORT lt_table_aux BY key.
DELETE ADJACENT DUPLICATES FROM lt_table_aux COMPARING key.

WHILE lt_table_aux IS NOT INITIAL.
  lrg_key = VALUE #( BASE lrg_key FOR lst IN lt_table_aux
                     FROM lv_from TO lv_limit
                      ( sign = 'I' option = 'EQ' low = lst-key )
                      ).
  SELECT *
    FROM snwd_pd
    APPENDING TABLE @DATA(lt_table_return)
    WHERE product_id IN @lrg_key.

  CLEAR: lrg_key.

  DELETE lt_table_aux FROM lv_from TO lv_limit.

ENDWHILE.

****************************************************************************
** Versão 2 (7.40 SP08 ou superior)
****************************************************************************

DATA: lt_table_aux2 TYPE TABLE OF snwd_product_id. " Tabela do tipo do campo que será construído o range

** Append de valores únicos
lt_table_aux2 = VALUE #(
  FOR GROUPS value OF <line> IN lt_table_main
  GROUP BY <line>-key WITHOUT MEMBERS ( value ) ).

WHILE lt_table_aux2 IS NOT INITIAL.
  lrg_key = VALUE #( BASE lrg_key FOR lst2 IN lt_table_aux2
                     FROM lv_from TO lv_limit
                     ( sign = 'I' option = 'EQ' low = lst2 )
                   ).

  SELECT *
  FROM snwd_pd
  APPENDING TABLE @DATA(lt_table_return2)
  WHERE product_id IN @lrg_key.

  CLEAR: lrg_key.

  DELETE lt_table_aux2 FROM lv_from TO lv_limit.

ENDWHILE.
