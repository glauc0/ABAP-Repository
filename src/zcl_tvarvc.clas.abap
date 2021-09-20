*----------------------------------------------------------------------*
*       CLASS ZCL_TVARVC DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_TVARVC definition
  public
  final
  create public .

public section.

  constants TYPE_PARAM_SIMPLE type ZPARAM_TYPE value 'P' ##NO_TEXT.
  constants TYPE_PARAM_MULTIPLE type ZPARAM_TYPE value 'S' ##NO_TEXT.
  constants TYPE_PARAM_BOTH type ZPARAM_TYPE value '0' ##NO_TEXT.

  class-methods GET_PARAM
    importing
      value(IV_NAME) type RSRPARAMETERID
      value(IV_TYPE) type ZPARAM_TYPE
    exporting
      value(EV_PARAM_SIMPLE) type RVARI_VAL_255
      value(EV_PARAM_MULTIPLE) type SCSM_RANGE_TT
    exceptions
      TYPE_INVALID .
  class-methods GET_PARAM_SIMPLE
    importing
      value(IV_NAME) type RSRPARAMETERID
    returning
      value(RV_PARAM_SIMPLE) type RVARI_VAL_255 .
  class-methods GET_PARAM_MULTIPLE
    importing
      value(IV_NAME) type RSRPARAMETERID
    returning
      value(RT_PARAM_MULTIPLE) type SCSM_RANGE_TT .
  class-methods GET_PARAM_SIMPLE_GENERIC
    importing
      value(IV_NAME) type RSRPARAMETERID
    returning
      value(RV_PARAM_SIMPLE) type RVARI_VAL_255 .
  class-methods GET_PARAM_MULTIPLE_GENERIC
    importing
      value(IV_NAME) type RSRPARAMETERID
    returning
      value(RT_PARAM_MULTIPLE) type SCSM_RANGE_TT .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TVARVC IMPLEMENTATION.


  METHOD get_param.
    TYPES: type_type TYPE RANGE OF tvarvc-type.
    DATA: r_type  TYPE type_type,
          ls_type TYPE LINE OF type_type.
    DATA: lw_tvarvc TYPE TABLE OF tvarvc,
          ls_tvarvc TYPE tvarvc.
    DATA: ls_param_multiple TYPE scsm_range.

    CLEAR ev_param_simple.
    REFRESH: ev_param_multiple.

    IF iv_type = zcl_tvarvc=>type_param_simple.
      CLEAR ls_type.
      ls_type-sign = 'I'.
      ls_type-option = 'EQ'.
      ls_type-low = 'P'. " PARAMATER
      APPEND ls_type TO r_type.

    ELSEIF iv_type = zcl_tvarvc=>type_param_multiple.
      CLEAR ls_type.
      ls_type-sign = 'I'.
      ls_type-option = 'EQ'.
      ls_type-low = 'S'. " SELECT-OPTIONS
      APPEND ls_type TO r_type.

    ELSEIF iv_type = zcl_tvarvc=>type_param_both.
      CLEAR ls_type.
      ls_type-sign = 'I'.
      ls_type-option = 'EQ'.
      ls_type-low = 'P'. " PARAMATER
      APPEND ls_type TO r_type.
      CLEAR ls_type.
      ls_type-sign = 'I'.
      ls_type-option = 'EQ'.
      ls_type-low = 'S'. " SELECT-OPTIONS
      APPEND ls_type TO r_type.

    ELSE.
      RAISE type_invalid.
    ENDIF.

    SELECT *
      INTO TABLE lw_tvarvc
    FROM tvarvc
    WHERE name = iv_name
      AND type IN r_type.

    IF iv_type = zcl_tvarvc=>type_param_simple.
      READ TABLE lw_tvarvc INTO ls_tvarvc INDEX 1.
      IF sy-subrc = 0.
        ev_param_simple = ls_tvarvc-low.
      ENDIF.

    ELSEIF iv_type = zcl_tvarvc=>type_param_multiple.
      LOOP AT lw_tvarvc INTO ls_tvarvc.
        CLEAR ls_param_multiple.
        ls_param_multiple-sign = ls_tvarvc-sign.
        IF ls_param_multiple-sign IS INITIAL.
          ls_param_multiple-sign = 'I'.
        ENDIF.
        ls_param_multiple-option = ls_tvarvc-opti.
        IF ls_param_multiple-option IS INITIAL.
          ls_param_multiple-option = 'EQ'.
        ENDIF.
        ls_param_multiple-low = ls_tvarvc-low.
        ls_param_multiple-high = ls_tvarvc-high.
        APPEND ls_param_multiple TO ev_param_multiple.
      ENDLOOP.

    ELSEIF iv_type = zcl_tvarvc=>type_param_both.
      READ TABLE lw_tvarvc INTO ls_tvarvc WITH KEY type = 'P'.
      IF sy-subrc = 0.
        CLEAR ls_param_multiple.
        ls_param_multiple-sign = 'I'.
        ls_param_multiple-option = 'EQ'.
        ls_param_multiple-low = ls_tvarvc-low.
        APPEND ls_param_multiple TO ev_param_multiple.
      ENDIF.

      LOOP AT lw_tvarvc INTO ls_tvarvc WHERE type = 'S'.
        CLEAR ls_param_multiple.
        ls_param_multiple-sign = ls_tvarvc-sign.
        IF ls_param_multiple-sign IS INITIAL.
          ls_param_multiple-sign = 'I'.
        ENDIF.
        ls_param_multiple-option = ls_tvarvc-opti.
        IF ls_param_multiple-option IS INITIAL.
          ls_param_multiple-option = 'EQ'.
        ENDIF.
        ls_param_multiple-low = ls_tvarvc-low.
        ls_param_multiple-high = ls_tvarvc-high.
        APPEND ls_param_multiple TO ev_param_multiple.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.                    "GET_PARAM


  METHOD get_param_multiple.

    CLEAR rt_param_multiple.

    zcl_tvarvc=>get_param( EXPORTING
                            iv_name = iv_name
                            iv_type = zcl_tvarvc=>type_param_multiple
                          IMPORTING
                            ev_param_multiple = rt_param_multiple ).

  ENDMETHOD.                    "GET_PARAM_MULTIPLE


  METHOD GET_PARAM_MULTIPLE_GENERIC.

    CLEAR rt_param_multiple.

    zcl_tvarvc=>get_param( EXPORTING
                            iv_name = iv_name
                            iv_type = zcl_tvarvc=>type_param_multiple
                          IMPORTING
                            ev_param_multiple = rt_param_multiple ).

  ENDMETHOD.                    "GET_PARAM_MULTIPLE


  METHOD get_param_simple.

    CLEAR rv_param_simple.

    zcl_tvarvc=>get_param( EXPORTING
                            iv_name = iv_name
                            iv_type = zcl_tvarvc=>type_param_simple
                          IMPORTING
                            ev_param_simple = rv_param_simple ).

  ENDMETHOD.                    "GET_PARAM_SIMPLE


  METHOD get_param_simple_generic.

    CLEAR rv_param_simple.

    zcl_tvarvc=>get_param( EXPORTING
                            iv_name = iv_name
                            iv_type = zcl_tvarvc=>type_param_simple
                          IMPORTING
                            ev_param_simple = rv_param_simple ).

  ENDMETHOD.                    "GET_PARAM_SIMPLE
ENDCLASS.
