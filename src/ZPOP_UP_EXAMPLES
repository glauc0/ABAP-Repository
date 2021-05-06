* This program executes the following popup function modules, to help choosing the right one:
* 
* POPUP_WITH_TABLE_DISPLAY
* POPUP_TO_CONFIRM_STEP
* POPUP_TO_DECIDE_WITH_MESSAGE
* POPUP_TO_DECIDE
* POPUP_TO_SELECT_MONTH
* POPUP_TO_CONFIRM_WITH_VALUE
* POPUP_TO_CONFIRM_WITH_MESSAGE
* POPUP_TO_DISPLAY_TEXT
* POPUP_TO_CONFIRM
* POPUP_TO_CONTINUE_YES_NO
* POPUP_TO_CONFIRM_DATA_LOSS
* Erro ao renderizar a macro 'code': Valor especificado inválido para o parâmetro 'com.atlassian.confluence.ext.code.render.InvalidValueException'
*&---------------------------------------------------------------------*
*& Report  ZPOP_UP_EXAMPLES
*& This report helps to understand differnt types of popup in ABAP
*&---------------------------------------------------------------------*
REPORT  ZPOP_UP_EXAMPLES.
TABLES SSCRFIELDS.
SELECTION-SCREEN FUNCTION KEY 1.
PARAMETERS R1 TYPE FLAG RADIOBUTTON GROUP RB1 USER-COMMAND DIS.
DEFINE GGG.
  SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT (40) TEXT&1.
  PARAMETERS &1 TYPE FLAG RADIOBUTTON GROUP RB1.
  SELECTION-SCREEN END OF LINE.
END-OF-DEFINITION.
GGG : R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12.
DATA:ANS(8) TYPE C.
DATA R TYPE C LENGTH 12.

INITIALIZATION.
  TEXTR2 = 'POPUP_WITH_TABLE_DISPLAY'.
  TEXTR3 = 'POPUP_TO_CONFIRM_STEP'.
  TEXTR4 = 'POPUP_TO_DECIDE_WITH_MESSAGE'.
  TEXTR5 = 'POPUP_TO_DECIDE'.
  TEXTR6 = 'POPUP_TO_SELECT_MONTH'.
  TEXTR7 = 'POPUP_TO_CONFIRM_WITH_VALUE'.
  TEXTR8 = 'POPUP_TO_CONFIRM_WITH_MESSAGE'.
  TEXTR9 = 'POPUP_TO_DISPLAY_TEXT'.
  TEXTR10 = 'POPUP_TO_CONFIRM'.
  TEXTR11 = 'POPUP_TO_CONTINUE_YES_NO'.
  TEXTR12 = 'POPUP_TO_CONFIRM_DATA_LOSS'.

*AT SELECTION-SCREEN OUTPUT.
  SSCRFIELDS-FUNCTXT_01 = 'NEXT'.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      SHIFT R RIGHT BY 1 PLACES.
      DATA X TYPE I.
      DEFINE HHH.
        X = &1 - 1.
        R&1 = R+X(1).
      END-OF-DEFINITION.
      HHH : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
      IF R IS INITIAL. R = 'X'. R1 = 'X'. ENDIF.
      PERFORM PROCESS.
*    when 'EXIT'.
*    Leave program.
    WHEN 'DIS'.
      PERFORM PROCESS.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  PROCESS
*&---------------------------------------------------------------------*
FORM PROCESS.
  IF R1 EQ 'X'.
    PERFORM POPUP_TO_INFORM.
  ENDIF.
  IF R2 EQ 'X'.
    PERFORM POPUP_WITH_TABLE_DISPLAY.
  ENDIF.
  IF R3 EQ 'X'.
    PERFORM POPUP_TO_CONFIRM_STEP.
  ENDIF.
  IF R4 EQ 'X'.
*---popup_to_decide_with_message
    PERFORM POPUP_TO_DECI_WITH_MESS.
  ENDIF.
  IF R5 EQ 'X'.
*---popup_to_decide
    PERFORM POPUP_TO_DECIDE.
  ENDIF.
  IF R6 EQ 'X'.
*---popup_to_select_month
    PERFORM POPUP_TO_SELECT_MONTH.
  ENDIF.
  IF R7 EQ 'X'.
*---popup_to_confirm_with_value
    PERFORM POPUP_TO_CONFIRM_WITH_VAL.
  ENDIF.
  IF R8 EQ 'X'.
*---popup_to_confirm_with_message
    PERFORM POPUP_TO_CONFIRM_WITH_MESSAGE.
  ENDIF.
  IF R9 EQ 'X'.
*---popup to display text
    PERFORM POPUP_TO_DISPLAY_TEXT.
  ENDIF.
  IF R10 EQ 'X'.
*---popup_to_confirm
    PERFORM POPUP_TO_CONFIRM.
  ENDIF.
  IF R11 EQ 'X'.
*---popup_to_continue_yes_no
    PERFORM POPUP_TO_CONT_YES_NO.
  ENDIF.
  IF R12 EQ 'X'.
*---popup_to_confirm_data_loss
    PERFORM POPUP_TO_CONFIRM_DATA_LOSS.
  ENDIF.
ENDFORM.                    "process
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_INFORM
*&---------------------------------------------------------------------*
FORM POPUP_TO_INFORM .
  CALL FUNCTION 'POPUP_TO_INFORM'
    EXPORTING
      TITEL = 'Title Information'
      TXT1  = 'Use of'
      TXT2  = 'POPUP_TO_INFORM'
      TXT3  = 'Text 3'
      TXT4  = 'Text 4'.
ENDFORM.                    " POPUP_TO_INFORM
*&---------------------------------------------------------------------*
*&      Form  POPUP_WITH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
FORM POPUP_WITH_TABLE_DISPLAY .
  DATA: BEGIN OF ITAB OCCURS 0,
        NAME(10)     TYPE C,
        TEL_NO(12)   TYPE C ,
        MOB_NO(12)   TYPE C,
        END OF ITAB.
  ITAB-NAME    = 'Jitender'.
  ITAB-TEL_NO  = '0114556654' .
  ITAB-MOB_NO  = '981145'.
  APPEND ITAB .
  CLEAR ITAB.
  ITAB-NAME    = 'Narender'.
  ITAB-TEL_NO  = '0114588954' .
  ITAB-MOB_NO  = '987745'.
  APPEND ITAB .
  CLEAR ITAB.
  ITAB-NAME    = 'Priyank'.
  ITAB-TEL_NO  = '0118996654' .
  ITAB-MOB_NO  = '984545'.
  APPEND ITAB .
  CLEAR ITAB.
  CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
    EXPORTING
      ENDPOS_COL         = 80
      ENDPOS_ROW         = 25
      STARTPOS_COL       = 1
      STARTPOS_ROW       = 1
      TITLETEXT          = 'Title POPUP_WITH_TABLE_DISPLAY'
*   IMPORTING
*     CHOISE             =
    TABLES
      VALUETAB           = ITAB
   EXCEPTIONS
     BREAK_OFF          = 1
     OTHERS             = 2
            .
ENDFORM.                    " POPUP_WITH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP .
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
 EXPORTING
  DEFAULTOPTION       = 'Y'
  TEXTLINE1           = 'Title Line1'
  TEXTLINE2           = 'Title Line2'
   TITEL              = 'Title POPUP_TO_CONFIRM_STEP'
  START_COLUMN        = 25
  START_ROW           = 6
  CANCEL_DISPLAY      = ' '
*---if you want to display the cancel button put X in above
 IMPORTING
  ANSWER              = ANS      .
  IF ANS = 'J' .
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed Yes'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ELSE.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed No'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ENDIF.
ENDFORM.                    " POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_DECI_WITH_MESS
*&---------------------------------------------------------------------*
FORM POPUP_TO_DECI_WITH_MESS .
  CALL FUNCTION 'POPUP_TO_DECIDE_WITH_MESSAGE'
    EXPORTING
     DEFAULTOPTION           = '1'
      DIAGNOSETEXT1          = 'this is text1'
     DIAGNOSETEXT2           = 'this is text2 '
     DIAGNOSETEXT3           = 'this is text3 '
      TEXTLINE1              = 'this is test4'
     TEXTLINE2               = 'this is text5 '
     TEXTLINE3               = 'this is text6 '
      TEXT_OPTION1           = 'YES'
      TEXT_OPTION2           = 'NO'
     ICON_TEXT_OPTION1       = 'icon_okay'
     ICON_TEXT_OPTION2       = 'icon_cancel'
      TITEL                   = 'Title POPUP_TO_DECIDE_WITH_MESSAGE'
     START_COLUMN            = 25
     START_ROW               = 6
*----for the display of cancel button  do like this.
     CANCEL_DISPLAY          = ' '
   IMPORTING
     ANSWER                  = ANS
            .
  IF ANS = '1' .
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed Yes'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ELSE.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed No'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ENDIF.
ENDFORM.                    " POPUP_TO_DECI_WITH_MESS
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_DECIDE
*&---------------------------------------------------------------------*
FORM POPUP_TO_DECIDE .
  CALL FUNCTION 'POPUP_TO_DECIDE'
  EXPORTING
   DEFAULTOPTION           = '1'
    TEXTLINE1              = 'this is text1'
   TEXTLINE2               = 'this is text2'
   TEXTLINE3               = 'this is text3'
    TEXT_OPTION1           = 'YES'
    TEXT_OPTION2           = 'NO'
   ICON_TEXT_OPTION1       = 'icon_okay'
   ICON_TEXT_OPTION2       = 'icon_cancel '
    TITEL                   = 'Title POPUP_TO_DECIDE'
   START_COLUMN            = 30
   START_ROW               = 7
*----for the display of cancel button  do like this.
   CANCEL_DISPLAY          = ' '
 IMPORTING
   ANSWER                  = ANS.
  IF ANS = 1 .
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed Yes'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ELSE.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed No'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ENDIF.
ENDFORM.                    " POPUP_TO_DECIDE
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_SELECT_MONTH
*&---------------------------------------------------------------------*
FORM POPUP_TO_SELECT_MONTH .
  DATA: SEL_MON TYPE ISELLIST-MONTH .
  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = '200812'
    IMPORTING
      SELECTED_MONTH = SEL_MON.
  CALL FUNCTION 'POPUP_TO_INFORM'
    EXPORTING
      TITEL = 'Information'
      TXT1  = 'Month'
      TXT2  = SEL_MON+4(2)
      TXT3  = 'Year'
      TXT4  = SEL_MON+0(4).
ENDFORM.                    " POPUP_TO_SELECT_MONTH
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM_WITH_VAL
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_WITH_VAL .
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_VALUE'
EXPORTING
 DEFAULTOPTION         = 'Y'
  OBJECTVALUE          = '10000000'
 TEXT_AFTER            = 'This is after the value '
  TEXT_BEFORE          = 'This is before the value '
  TITEL                = 'Title POPUP_TO_CONFIRM_WITH_VALUE'
 START_COLUMN          = 25
 START_ROW             = 6
*----for the display of cancel button  do like this.
 CANCEL_DISPLAY       = ' '
IMPORTING
 ANSWER               = ANS
EXCEPTIONS
 TEXT_TOO_LONG        = 1
 OTHERS               = 2
        .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF ANS = 'J' .
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed Yes'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ELSE.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Information'
        TXT1  = 'You have pressed No'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ENDIF.
ENDFORM.                    " POPUP_TO_CONFIRM_WITH_VAL
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM_WITH_MESSAGE
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_WITH_MESSAGE .
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
 EXPORTING
  DEFAULTOPTION        = 'Y'
   DIAGNOSETEXT1        = 'This is Testing'
  DIAGNOSETEXT2        = ' '
  DIAGNOSETEXT3        = ' '
  TEXTLINE1            = 'Do You want to Exit'
  TEXTLINE2            = ' '
   TITEL                = 'POPUP_TO_CONFIRM_WITH_MESSAGE'
  START_COLUMN         = 25
  START_ROW            = 6
*----for the display of cancel button  do like this.
  CANCEL_DISPLAY       = ' '
IMPORTING
  ANSWER               = ANS
         .
  IF ANS = 'J' .
*---put code on selecting yes
  ELSE.
*---put code on selecting no
  ENDIF.
ENDFORM.                    " POPUP_TO_CONFIRM_WITH_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_DISPLAY_TEXT
*&---------------------------------------------------------------------*
FORM POPUP_TO_DISPLAY_TEXT .
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL        = 'Title POPUP_TO_DISPLAY_TEXT'
      TEXTLINE1    = 'Message to display'
      TEXTLINE2    = ' '
      START_COLUMN = 25
      START_ROW    = 6.
ENDFORM.                    " POPUP_TO_DISPLAY_TEXT
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM .
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Title POPUP_TO_CONFIRM'
      TEXT_QUESTION         = 'Click Cancel to Exit'
      TEXT_BUTTON_1         = 'OK'
      ICON_BUTTON_1         = 'ICON_CHECKED'
      TEXT_BUTTON_2         = 'CANCEL'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DISPLAY_CANCEL_BUTTON = ' '
      POPUP_TYPE            = 'ICON_MESSAGE_ERROR'
    IMPORTING
      ANSWER                = ANS.
  IF ANS = 2.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONT_YES_NO
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONT_YES_NO .
  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      TEXTLINE1 = 'Click OK to leave program'
      TITEL     = 'POPUP_CONTINUE_YES_NO'
    IMPORTING
      ANSWER    = ANS.
  IF ANS = 'J'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " POPUP_TO_CONT_YES_NO
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM_DATA_LOSS
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_DATA_LOSS .
  CALL FUNCTION 'POPUP_TO_CONFIRM_DATA_LOSS'
EXPORTING
           DEFAULTOPTION       = 'J'
  TITEL               = 'CONFIRMATION'
*               START_COLUMN        = 25
*               START_ROW           = 6
IMPORTING
  ANSWER              = ANS.
  IF ANS = 'J'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " POPUP_TO_CONFIRM_DATA_LOSS
