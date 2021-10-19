*&---------------------------------------------------------------------*
*& Report ZDROPDOWNLIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdropdownlist.

TYPE-POOLS: vrm.

DATA: li_list  TYPE vrm_values,
      lv_value LIKE LINE OF li_list.

PARAMETERS: p_car(10) AS LISTBOX VISIBLE LENGTH 15.

AT SELECTION-SCREEN OUTPUT.

  lv_value-key = '1'.
  lv_value-text = 'Nissan'.
  APPEND lv_value TO li_list.

  lv_value-key = '2'.
  lv_value-text = 'Honda'.
  APPEND lv_value TO li_list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_CAR'
      values = li_list.

START-OF-SELECTION.
  READ TABLE li_list INTO DATA(ls) WITH KEY key = p_car.

  WRITE ls.
