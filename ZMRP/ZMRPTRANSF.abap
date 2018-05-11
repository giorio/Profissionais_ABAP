*&---------------------------------------------------------------------*
*&  Include           ZMRPTRANSF
*&---------------------------------------------------------------------*
FORM F_CRIA_TRANSF.

  CLEAR: T_NSERI, T_NSERI[].
  CLEAR: T_SERIA, T_SERIA[].

  T_NSERI[] = I_RESB1[].
  T_SERIA[] = I_RESB1[].

* Nao Serializados --> SERNP = BRANCO, apagar todos diferentes de branco
  DELETE T_NSERI WHERE SERNP IS NOT INITIAL.
  SORT T_NSERI BY DEPOS LGORT SERNP MATNR.

* Serializados --> SERNP <> BRANCO, apagar todos os brancos
  DELETE T_SERIA WHERE SERNP IS INITIAL.
  SORT T_SERIA BY DEPOS LGORT SERNP MATNR.

* Criar reserva 913
  PERFORM F_CRIAR_RESERVA_913.

  IF NOT P_EMAIL1 IS INITIAL AND NOT P_EMAIL2 IS INITIAL.
    PERFORM LOG_EMAIL.
  ENDIF.

  PERFORM F_LOG.

ENDFORM.                    "F_CRIA_TRANSF

*&---------------------------------------------------------------------*
*&      Form  F_CRIAR_RESERVA_913
*&---------------------------------------------------------------------*
*       Form para criar a estrutura e a tabela de parâmetros da BAPI
* F_CRIAR_RESERVA_913.
*----------------------------------------------------------------------*
FORM F_CRIAR_RESERVA_913.

  IF LINES( T_NSERI ) > 0.
    T_R913[] = T_NSERI[].
  ENDIF.

  IF LINES( T_SERIA ) > 0.
    T_R913[] = T_SERIA[].
  ENDIF.

  LOOP AT T_R913.

    AT NEW LGORT.

      PERFORM CADASTRA_RESERVA.

      CLEAR: RESERVATIONHEADER, RESERVATIONITEMS.
      REFRESH: RESERVATIONITEMS.

      RESERVATIONHEADER-RES_DATE = SY-DATUM.
      RESERVATIONHEADER-CREATED_BY = SY-UNAME.
      RESERVATIONHEADER-MOVE_TYPE = '913'.
      RESERVATIONHEADER-MOVE_PLANT = '5300'.
      RESERVATIONHEADER-MOVE_STLOC = T_R913-LGORT.

    ENDAT.

    RESERVATIONITEMS-MATERIAL = T_R913-MATNR.
    RESERVATIONITEMS-PLANT = S_WERKS-LOW.
    RESERVATIONITEMS-STGE_LOC = '3000'.
    RESERVATIONITEMS-ENTRY_QNT = T_R913-QTDE.
    RESERVATIONITEMS-MOVEMENT = 'X'.
    RESERVATIONITEMS-REQ_DATE = SY-DATUM.
    RESERVATIONITEMS-ITEM_TEXT = C_TXT_ITEM.
    APPEND RESERVATIONITEMS.

    AT LAST.
      PERFORM CADASTRA_RESERVA.
    ENDAT.

  ENDLOOP.

ENDFORM.                    "F_CRIAR_RESERVA_913.

*&---------------------------------------------------------------------*
*&      Form  cadastra_reserva
*&---------------------------------------------------------------------*
*       Pega a estrutura RESERVATIONHEADER e a tabela RESERVATIONITEMS
* e chama a BAPI: BAPI_RESERVATION_CREATE1, além de criar a tabela de
* saída de mentagem.
*----------------------------------------------------------------------*
FORM CADASTRA_RESERVA.
  IF LINES( RESERVATIONITEMS ) > 0.
*      verificar se a tabela de itens está preenchida
    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        RESERVATIONHEADER          = RESERVATIONHEADER
*         TESTRUN                    =
*         ATPCHECK                   =
*         CALCHECK                   =
*         RESERVATION_EXTERNAL       =
*       IMPORTING
*         RESERVATION                =
      TABLES
        RESERVATIONITEMS           = RESERVATIONITEMS
        PROFITABILITYSEGMENT       = PROFITABILITYSEGMENT
        RETURN                     = RETURN
*             EXTENSIONIN                =
              .
    LOOP AT RETURN.
      MOVE-CORRESPONDING RETURN TO MESSAGE.
      APPEND MESSAGE.
    ENDLOOP.


    DELETE MESSAGE WHERE ID = 'BAPI'.
    SORT MESSAGE BY MESSAGE.
    DELETE ADJACENT DUPLICATES FROM MESSAGE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*       EXPORTING
*         WAIT          =
*       IMPORTING
*         RETURN        =
              .

  ENDIF.
ENDFORM.                    "cadastra_reserva

*&---------------------------------------------------------------------*
*&      Form  F_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BDC    text
*      -->P_DYNBEGIN text
*      -->P_NAME     text
*      -->P_VALUES   text
*----------------------------------------------------------------------*
FORM F_DYNPRO TABLES P_T_BDC STRUCTURE BDCDATA
            USING  P_DYNBEGIN
                   P_NAME
                   P_VALUES.

  CLEAR P_T_BDC.

  IF NOT P_DYNBEGIN IS INITIAL.
    MOVE: P_NAME     TO P_T_BDC-PROGRAM,
          P_VALUES   TO P_T_BDC-DYNPRO,
          'X'        TO P_T_BDC-DYNBEGIN.
    APPEND P_T_BDC.
  ELSE.
    MOVE: P_NAME   TO P_T_BDC-FNAM,
          P_VALUES TO P_T_BDC-FVAL.
    APPEND P_T_BDC.
  ENDIF.

ENDFORM.                    "F_DYNPRO

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
