*&---------------------------------------------------------------------*
*& Report Z_SELECT_OPTIONS_LIKE_PARAMETERS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_SELECT_OPTIONS_LIKE_PARAMETERS.

* Include type pool SSCR
TYPE-POOLS sscr.

* Define the object to be passed to the RESTRICTION parameter
DATA restrict TYPE sscr_restrict.

* Auxiliary objects for filling RESTRICT
DATA opt_list TYPE sscr_opt_list.
DATA ass      TYPE sscr_ass.

* Define the selection screen objects
* First block: 3 SELECT-OPTIONS
SELECTION-SCREEN BEGIN OF BLOCK block_0 WITH FRAME TITLE TEXT-bl0.
  SELECT-OPTIONS sel_0_0 FOR sy-tvar0.
*  SELECT-OPTIONS SEL_0_0 FOR SY-TVAR0 NO INTERVALS.
  SELECT-OPTIONS sel_0_1 FOR sy-tvar1.
  SELECT-OPTIONS sel_0_2 FOR sy-tvar2.
  SELECT-OPTIONS sel_0_3 FOR sy-tvar3 NO INTERVALS.
SELECTION-SCREEN END   OF BLOCK block_0.

* Second block: 2 SELECT-OPTIONS
SELECTION-SCREEN BEGIN OF BLOCK block_1 WITH FRAME TITLE TEXT-bl1.
  SELECT-OPTIONS sel_1_0 FOR sy-subrc.
  SELECT-OPTIONS sel_1_1 FOR sy-repid.
SELECTION-SCREEN END   OF BLOCK block_1.

INITIALIZATION.

* Define the option list

* ALL: All options allowed
  MOVE 'ALL'        TO opt_list-name.
  MOVE 'X' TO: opt_list-options-bt,
               opt_list-options-cp,
               opt_list-options-eq,
               opt_list-options-ge,
               opt_list-options-gt,
               opt_list-options-le,
               opt_list-options-lt,
               opt_list-options-nb,
               opt_list-options-ne,
               opt_list-options-np.
  APPEND opt_list TO restrict-opt_list_tab.

* NOPATTERN: CP and NP not allowed
  CLEAR opt_list.
  MOVE 'NOPATTERN'  TO opt_list-name.
  MOVE 'X' TO: opt_list-options-bt,
               opt_list-options-eq,
               opt_list-options-ge,
               opt_list-options-gt,
               opt_list-options-le,
               opt_list-options-lt,
               opt_list-options-nb,
               opt_list-options-ne.
  APPEND opt_list TO restrict-opt_list_tab.

* NOINTERVLS: BT and NB not allowed
  CLEAR opt_list.
  MOVE 'NOINTERVLS' TO opt_list-name.
  MOVE 'X' TO: opt_list-options-cp,
               opt_list-options-eq,
               opt_list-options-ge,
               opt_list-options-gt,
               opt_list-options-le,
               opt_list-options-lt.
*               opt_list-options-ne,
*               opt_list-options-np.
  APPEND opt_list TO restrict-opt_list_tab.

* EQ_AND_CP: only EQ and CP allowed
  CLEAR opt_list.
  MOVE 'EQ_AND_CP'  TO opt_list-name.
  MOVE 'X' TO: opt_list-options-cp,
               opt_list-options-eq.
  APPEND opt_list TO restrict-opt_list_tab.

* JUST_EQ: Only EQ allowed
  CLEAR opt_list.
  MOVE 'JUST_EQ' TO opt_list-name.
  MOVE 'X' TO opt_list-options-eq.
  APPEND opt_list TO restrict-opt_list_tab.

* Assign selection screen objects to option list and sign

* KIND = 'A': applies to all SELECT-OPTIONS
  MOVE: 'A'          TO ass-kind,
        '*'          TO ass-sg_main,
        'NOPATTERN'  TO ass-op_main,
        'NOINTERVLS' TO ass-op_addy.
  APPEND ass TO restrict-ass_tab.

* KIND = 'B': applies to all SELECT-OPTIONS in block BLOCK_0,
*             that is, SEL_0_0, SEL_0_1, SEL_0_2
  CLEAR ass.
  MOVE: 'B'          TO ass-kind,
        'BLOCK_0'    TO ass-name,
        'I'          TO ass-sg_main,
        '*'          TO ass-sg_addy,
        'NOINTERVLS' TO ass-op_main.
  APPEND ass TO restrict-ass_tab.

* KIND = 'S': applies to SELECT-OPTION SEL-0-2
  CLEAR ass.
  MOVE: 'S'          TO ass-kind,
        'SEL_0_2'    TO ass-name,
        'I'          TO ass-sg_main,
        '*'          TO ass-sg_addy,
        'EQ_AND_CP'  TO ass-op_main,
        'ALL'        TO ass-op_addy.
  APPEND ass TO restrict-ass_tab.

* KIND = 'S': Applies to SELECT-OPTION SEL_0_3
  CLEAR ass.
  MOVE: 'S'        TO ass-kind,
        'SEL_0_3'  TO ass-name,
        'I'        TO ass-sg_main,
        ' '        TO ass-sg_addy,
        'JUST_EQ'  TO ass-op_main,
        'JUST_EQ'  TO ass-op_addy.
  APPEND ass TO restrict-ass_tab.

* Call function module
  CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
       EXPORTING
             restriction                = restrict
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
