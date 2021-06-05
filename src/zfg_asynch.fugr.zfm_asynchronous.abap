FUNCTION zfm_asynchronous.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_VALUE_B) TYPE  I OPTIONAL
*"     VALUE(IV_TIME) TYPE  I OPTIONAL
*"     VALUE(IV_VALUE_A) TYPE  I OPTIONAL
*"  EXPORTING
*"     VALUE(EV_RESULT) TYPE  I
*"----------------------------------------------------------------------

  WAIT UP TO iv_time SECONDS.
  ev_result = iv_value_a + iv_value_b.


ENDFUNCTION.
