*&---------------------------------------------------------------------*
*&  Include           ZMRPCRIAR913
*&---------------------------------------------------------------------*
FORM F_CRIA_TRANSF.

  CLEAR: T_NSERI, T_NSERI[].
  CLEAR: T_SERIA, T_SERIA[].

  T_NSERI[] = I_RESB1[].
  T_SERIA[] = I_RESB1[].

* Nao Serializados --> SERNP = BRANCO, apagar todos diferentes de branco
  DELETE T_NSERI WHERE SERNP IS NOT INITIAL.
  SORT T_NSERI BY DEPOS LGORT SERNP MATNR.
  PERFORM F_CRIAR_RESERVA_913.                    "Criar reserva 913

* Serializados --> SERNP <> BRANCO, apagar todos os brancos
  DELETE T_SERIA WHERE SERNP IS INITIAL.
  SORT T_SERIA BY DEPOS LGORT SERNP MATNR.
  PERFORM F_CRIAR_RESERVA_913.                    "Criar reserva 913


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

  SORT T_R913 BY LGORT.

  LOOP AT T_R913.

    CLEAR: RESERVATIONHEADER, RESERVATIONITEMS.
    REFRESH: RESERVATIONITEMS.

    AT NEW LGORT.

      RESERVATIONHEADER-RES_DATE = SY-DATUM.
      RESERVATIONHEADER-CREATED_BY = SY-UNAME.
      RESERVATIONHEADER-MOVE_TYPE = '913'.
      RESERVATIONHEADER-MOVE_PLANT = '5300'.
      RESERVATIONHEADER-MOVE_STLOC = T_R913-LGORT.

      LOOP AT T_R913 WHERE LGORT = RESERVATIONHEADER-MOVE_STLOC.
        RESERVATIONITEMS-MATERIAL = T_R913-MATNR.
        RESERVATIONITEMS-PLANT = S_WERKS-LOW.
        RESERVATIONITEMS-STGE_LOC = '3000'.
        RESERVATIONITEMS-ENTRY_QNT = T_R913-QTDE.
        RESERVATIONITEMS-MOVEMENT = 'X'.
        RESERVATIONITEMS-REQ_DATE = SY-DATUM.
        RESERVATIONITEMS-ITEM_TEXT = C_TXT_ITEM.
        APPEND RESERVATIONITEMS.
      ENDLOOP.

    ENDAT.

    PERFORM CADASTRA_RESERVA.

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
