*&---------------------------------------------------------------------*
*& Report Z_SELECT_OPTIONS_HIDE_OR_NOT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_select_options_hide_or_not.

* Include type pool SSCR
TYPE-POOLS sscr.

* Define the object to be passed to the RESTRICTION parameter
DATA lst_restrict TYPE sscr_restrict.

* Auxiliary objects for filling RESTRICT
DATA lst_opt_list TYPE sscr_opt_list.
DATA lst_ass      TYPE sscr_ass.

* Define the selection screen objects
* First block: 3 SELECT-OPTIONS
SELECTION-SCREEN BEGIN OF BLOCK block_0 WITH FRAME TITLE text-bl0.
SELECT-OPTIONS sel_0_0 FOR sy-tvar0.
*  SELECT-OPTIONS SEL_0_0 FOR SY-TVAR0 NO INTERVALS.
SELECT-OPTIONS sel_0_1 FOR sy-tvar1.
SELECT-OPTIONS sel_0_2 FOR sy-tvar2.
SELECT-OPTIONS sel_0_3 FOR sy-tvar3 NO INTERVALS.
SELECTION-SCREEN END   OF BLOCK block_0.

* Second block: 2 SELECT-OPTIONS
SELECTION-SCREEN BEGIN OF BLOCK block_1 WITH FRAME TITLE text-bl1.
SELECT-OPTIONS sel_1_0 FOR sy-subrc.
SELECT-OPTIONS sel_1_1 FOR sy-repid.
SELECTION-SCREEN END   OF BLOCK block_1.

INITIALIZATION.

* Define the option list

* ALL: All options allowed
  MOVE 'ALL'        TO lst_opt_list-name.
  MOVE 'X' TO: lst_opt_list-options-bt,
               lst_opt_list-options-cp,
               lst_opt_list-options-eq,
               lst_opt_list-options-ge,
               lst_opt_list-options-gt,
               lst_opt_list-options-le,
               lst_opt_list-options-lt,
               lst_opt_list-options-nb,
               lst_opt_list-options-ne,
               lst_opt_list-options-np.
  APPEND lst_opt_list TO lst_restrict-opt_list_tab.

* NOPATTERN: CP and NP not allowed
  CLEAR lst_opt_list.
  MOVE 'NOPATTERN'  TO lst_opt_list-name.
  MOVE 'X' TO: lst_opt_list-options-bt,
               lst_opt_list-options-eq,
               lst_opt_list-options-ge,
               lst_opt_list-options-gt,
               lst_opt_list-options-le,
               lst_opt_list-options-lt,
               lst_opt_list-options-nb,
               lst_opt_list-options-ne.
  APPEND lst_opt_list TO lst_restrict-opt_list_tab.

* NOINTERVLS: BT and NB not allowed
  CLEAR lst_opt_list.
  MOVE 'NOINTERVLS' TO lst_opt_list-name.
  MOVE 'X' TO: lst_opt_list-options-cp,
               lst_opt_list-options-eq,
               lst_opt_list-options-ge,
               lst_opt_list-options-gt,
               lst_opt_list-options-le,
               lst_opt_list-options-lt,
               lst_opt_list-options-ne,
               lst_opt_list-options-np.
  APPEND lst_opt_list TO lst_restrict-opt_list_tab.

* EQ_AND_CP: only EQ and CP allowed
  CLEAR lst_opt_list.
  MOVE 'EQ_AND_CP'  TO lst_opt_list-name.
  MOVE 'X' TO: lst_opt_list-options-cp,
               lst_opt_list-options-eq.
  APPEND lst_opt_list TO lst_restrict-opt_list_tab.

* JUST_EQ: Only EQ allowed
  CLEAR lst_opt_list.
  MOVE 'JUST_EQ' TO lst_opt_list-name.
  MOVE 'X' TO lst_opt_list-options-eq.
  APPEND lst_opt_list TO lst_restrict-opt_list_tab.

* Assign selection screen objects to option list and sign

* KIND = 'A': applies to all SELECT-OPTIONS
  MOVE: 'A'          TO lst_ass-kind,
        '*'          TO lst_ass-sg_main,
        'NOPATTERN'  TO lst_ass-op_main,
        'NOINTERVLS' TO lst_ass-op_addy.
  APPEND lst_ass TO lst_restrict-ass_tab.

* KIND = 'B': applies to all SELECT-OPTIONS in block BLOCK_0,
*             that is, SEL_0_0, SEL_0_1, SEL_0_2
  CLEAR lst_ass.
  MOVE: 'B'          TO lst_ass-kind,
        'BLOCK_0'    TO lst_ass-name,
        'I'          TO lst_ass-sg_main,
        '*'          TO lst_ass-sg_addy,
        'NOINTERVLS' TO lst_ass-op_main.
  APPEND lst_ass TO lst_restrict-ass_tab.

* KIND = 'S': applies to SELECT-OPTION SEL-0-2
  CLEAR lst_ass.
  MOVE: 'S'          TO lst_ass-kind,
        'SEL_0_2'    TO lst_ass-name,
        'I'          TO lst_ass-sg_main,
        '*'          TO lst_ass-sg_addy,
        'EQ_AND_CP'  TO lst_ass-op_main,
        'ALL'        TO lst_ass-op_addy.
  APPEND lst_ass TO lst_restrict-ass_tab.

* KIND = 'S': Applies to SELECT-OPTION SEL_0_3
  CLEAR lst_ass.
  MOVE: 'S'        TO lst_ass-kind,
        'SEL_0_3'  TO lst_ass-name,
        'I'        TO lst_ass-sg_main,
        ' '        TO lst_ass-sg_addy,
        'JUST_EQ'  TO lst_ass-op_main,
        'JUST_EQ'  TO lst_ass-op_addy.
  APPEND lst_ass TO lst_restrict-ass_tab.

* Call function module
  CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
       EXPORTING
             restriction                = lst_restrict
*           DB                          = ' '
       EXCEPTIONS
             too_late                   = 1
             repeated                   = 2
             not_during_submit          = 3
            db_call_after_report_call  = 4
            selopt_without_options     = 5
             selopt_without_signs       = 6
             invalid_sign               = 7
            report_call_after_db_error = 8
              empty_option_list          = 9
             invalid_kind               = 10
             repeated_kind_a            = 11
             OTHERS                     = 12.

* Exception handling
  IF sy-subrc NE 0.
    ...
  ENDIF.
