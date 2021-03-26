*&---------------------------------------------------------------------*
*& Report ZT58_43_ABAP_SQL_SELECT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zt58_43_abap_sql_select.

DATA vg_pais TYPE snwd_ad-country.

SELECT-OPTIONS p_pais FOR vg_pais NO INTERVALS NO-EXTENSION.

SELECT emp~node_key,
       employee_id,
       first_name && ' ' && last_name AS Nome,
       country,
       CASE sex
         WHEN 'F' THEN 'Mulher'
         WHEN 'M' THEN 'Homem'
         ELSE '?'
       END AS Gender,
       1 AS um,
       'Dois' AS dois,
       1 + 2 AS tres,
       upper( ad~city ) AS city,
       dats_days_between( DATS_ADD_DAYS( @sy-datum, 3 ), @sy-datum ) AS diff_days
  FROM snwd_employees AS emp
  LEFT OUTER JOIN snwd_company AS comp
    ON emp~parent_key EQ comp~node_key
    INNER JOIN snwd_ad AS ad
    ON emp~pr_address_guid EQ ad~node_key
  WHERE ad~country IN @p_pais
  INTO TABLE @DATA(lt_employees).

  IF lt_employees IS INITIAL.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   = DATA(lo_alv)
    CHANGING
      t_table        = lt_employees
  ).

  lo_alv->display( ).
