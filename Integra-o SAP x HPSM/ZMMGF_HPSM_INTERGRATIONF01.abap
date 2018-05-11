*&---------------------------------------------------------------------*
*&  Include           ZMMGF_HPSM_INTERGRATIONF01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  SET_RETURN_MESSAGE
*&---------------------------------------------------------------------*
*       set return parameter for output
*----------------------------------------------------------------------*
*      -->P_MESSAGE    messageid                                       *
*      -->P_VAR1       variable 1                                      *
*      -->P_VAR2       variable 2                                      *
*      -->P_VAR3       variable 3                                      *
*      -->P_VAR4       variable 4                                      *
*      <--P_RETURN     RETURN parameter                                *
*----------------------------------------------------------------------*
FORM SET_RETURN_MESSAGE USING    VALUE(P_MESSAGE) LIKE MESSAGE
                        CHANGING P_RETURN         LIKE BAPIRETURN.

  CHECK NOT MESSAGE IS INITIAL.

  CALL FUNCTION 'BALW_BAPIRETURN_GET'
    EXPORTING
      TYPE       = P_MESSAGE-MSGTY
      CL         = P_MESSAGE-MSGID
      NUMBER     = P_MESSAGE-MSGNO
      PAR1       = P_MESSAGE-MSGV1
      PAR2       = P_MESSAGE-MSGV2
      PAR3       = P_MESSAGE-MSGV3
      PAR4       = P_MESSAGE-MSGV4
*     LOG_NO     = ' '
*     LOG_MSG_NO = ' '
    IMPORTING
      BAPIRETURN = P_RETURN
    EXCEPTIONS
      OTHERS     = 1.

ENDFORM.                               " SET_RETURN_MESSAGE
