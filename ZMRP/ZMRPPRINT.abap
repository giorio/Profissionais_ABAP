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

  LOOP AT I_RESB1.

    PERFORM F_COR_LINHA.

    WRITE: / I_RESB1-LGORT UNDER TEXT-006,
             I_RESB1-MATNR UNDER TEXT-005,
             I_RESB1-QTDE UNDER TEXT-011.

  ENDLOOP.

ENDFORM.                               "F_PRINT1
