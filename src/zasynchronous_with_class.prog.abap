*&---------------------------------------------------------------------*
*& Report ZASYNCHRONOUS_WITH_CLASS
*&---------------------------------------------------------------------*
*& This is an example of how to use RFC IN STARTING NEW TASK with a
*& method like receiver
*&---------------------------------------------------------------------*
REPORT zasynchronous_with_class.

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.

    METHODS
      execute.

    METHODS
      call_start_new_task
        IMPORTING
          iv_destination TYPE rfcdest
          iv_time        TYPE i
          iv_value_a     TYPE i
          iv_value_b     TYPE i
          iv_task_name   TYPE char20.

    METHODS
      return_start_new_task
        IMPORTING
          p_task TYPE clike. " The method meth must be public, and can have only one non-optional input parameter p_task of type clike.

    METHODS
      set_result
        IMPORTING
          iv_result TYPE i.
*  PUBLIC SECTION -> End

  PROTECTED SECTION.
*  PROTECTED SECTION -> End

  PRIVATE SECTION.
    CLASS-DATA gv_result TYPE i.
*  PRIVATE SECTION -> End


ENDCLASS. "lcl_main

START-OF-SELECTION.

  DATA(lo_obj) = NEW lcl_main( ).
  lo_obj->execute( ).

END-OF-SELECTION.

CLASS lcl_main IMPLEMENTATION.
  METHOD execute.
    DATA lv_value_a TYPE i VALUE 1.
    DATA lv_value_b TYPE i VALUE 2.
    DATA lv_time TYPE i VALUE 2.

    me->call_start_new_task(
      EXPORTING
        iv_destination = 'NONE'
        iv_time        = lv_time
        iv_value_a     = lv_value_a
        iv_value_b     = lv_value_b
        iv_task_name   = 'NEW_TASK'
    ).

    WRITE: 'Waiting for the function to return...', /.
    DATA(lv_seconds) = 0.

    DO lv_time TIMES.
      ADD 1 TO lv_seconds.
      WRITE: lv_seconds, ' second(s)',  /.
      WAIT UP TO 1 SECONDS.
    ENDDO.


    WAIT UNTIL lcl_main=>gv_result NE 0.
    WRITE: 'Return of function...', /.

    DATA(lv_msg_str) = ``.
    DATA(lv_value_a_str) = CONV string( lv_value_a ).
    CONDENSE lv_value_a_str.
    DATA(lv_value_b_str) = CONV string( lv_value_b ).
    CONDENSE lv_value_b_str.
    DATA(lv_result_str) = CONV string( gv_result ).
    CONDENSE lv_result_str.

    CONCATENATE: 'Result of sum'
                 lv_value_a_str
                 '+'
                 lv_value_b_str
                 'is'
                 lv_result_str
           INTO lv_msg_str
           SEPARATED BY space.

    WRITE: lv_msg_str.
  ENDMETHOD. "execute

  METHOD call_start_new_task.

    CALL FUNCTION 'ZFM_ASYNCHRONOUS'
      STARTING NEW TASK iv_task_name
      DESTINATION iv_destination "IN GROUP DEFAULT
      CALLING me->return_start_new_task ON END OF TASK
      EXPORTING
        iv_time    = iv_time
        iv_value_a = iv_value_a
        iv_value_b = iv_value_b.

  ENDMETHOD. "call_start_new_task

  METHOD return_start_new_task.
    DATA lv_result TYPE i.

    " The Receive results can be exporting or changing variables, structures, tables. And return expections too.
    RECEIVE RESULTS FROM FUNCTION 'ZFM_ASYNCHRONOUS'
      IMPORTING
        ev_result = lv_result
        EXCEPTIONS
            resource_failure      = 1
            system_failure        = 2
            communication_failure = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid
        TYPE sy-msgty
        NUMBER sy-msgno
        WITH sy-msgv1
             sy-msgv2
             sy-msgv3
             sy-msgv4.
    ELSE.
      " If is successful. The return can be used in variables or call some method to get what you need.
      me->set_result( iv_result = lv_result ).
    ENDIF.

  ENDMETHOD. "return_start_new_task

  METHOD set_result.
    " Private variable
    lcl_main=>gv_result = iv_result.
  ENDMETHOD. " set_result
ENDCLASS. "lcl_main
