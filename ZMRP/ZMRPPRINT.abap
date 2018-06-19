*&---------------------------------------------------------------------*
*&      Form  F_COR_LINHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_COR_LINHA.

  IF V_COR_LINHA = 'X'.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    V_COR_LINHA = ' '.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    V_COR_LINHA = 'X'.
  ENDIF.

ENDFORM.                    "F_COR_LINHA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PRINT1.

  SORT I_RESB1 BY LGORT.

  LOOP AT I_RESB1.

    PERFORM F_COR_LINHA.

    WRITE: / I_RESB1-LGORT UNDER TEXT-006,
             I_RESB1-MATNR UNDER TEXT-005,
             I_RESB1-QTDE UNDER TEXT-011.

  ENDLOOP.

ENDFORM.                               "F_PRINT1

*---------------------------------------------------------------------*
* Envia email com Log de transações
*---------------------------------------------------------------------*
FORM LOG_EMAIL .

  IF NOT MESSAGE[] IS INITIAL.

    CALL FUNCTION 'HR_FBN_GENERATE_SEND_EMAIL'
      EXPORTING
        SUBJECT               = 'Log ZM137'
        SENDER                = P_EMAIL1
        RECIPIENT             = P_EMAIL2
        FLAG_COMMIT           = 'X'
        FLAG_SEND_IMMEDIATELY = 'X'
      TABLES
        EMAIL_TEXT            = MESSAGE.

  ENDIF.

ENDFORM.                    " LOG_EMAIL

*&---------------------------------------------------------------------*
*&      Form  F_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LOG.

  LOOP AT MESSAGE.
    WRITE: / MESSAGE-MESSAGE.
  ENDLOOP.

ENDFORM.                    "F_LOG
