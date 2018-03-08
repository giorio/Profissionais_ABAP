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

  REFRESH: IT_MESSAGE.

* Processar Nao Serializados
  PERFORM F_PROCESSAR_NAO_SERIALIZADOS.

* Processar Serializados
  PERFORM F_PROCESSAR_SERIALIZADOS.

  IF NOT P_EMAIL1 IS INITIAL AND NOT P_EMAIL2 IS INITIAL.
    PERFORM LOG_EMAIL.
  ENDIF.

ENDFORM.                    "F_CRIA_TRANSF

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSAR_NAO_SERIALIZADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESSAR_NAO_SERIALIZADOS.

  LOOP AT T_NSERI.

    AT NEW LGORT.

      PERFORM CADASTRA_RESERVA.

      CLEAR: RESERVATIONHEADER, RESERVATIONITEMS.
      REFRESH: RESERVATIONITEMS.

      RESERVATIONHEADER-RES_DATE = SY-DATUM.
      RESERVATIONHEADER-MOVE_TYPE = '913'.
      RESERVATIONHEADER-MOVE_PLANT = '5300'.
      RESERVATIONHEADER-MOVE_STLOC = T_NSERI-LGORT.

    ENDAT.

    RESERVATIONITEMS-MATERIAL = T_NSERI-MATNR.
    RESERVATIONITEMS-PLANT = S_WERKS-LOW.
    RESERVATIONITEMS-STGE_LOC = '3000'.
    RESERVATIONITEMS-ENTRY_QNT = T_NSERI-QTDE.
    RESERVATIONITEMS-MOVEMENT = 'X'.
    RESERVATIONITEMS-REQ_DATE = SY-DATUM.
    APPEND RESERVATIONITEMS.

    AT LAST.
      PERFORM CADASTRA_RESERVA.
    ENDAT.

  ENDLOOP.

ENDFORM.                    "F_PROCESSAR_NAO_SERIALIZADOS

*&---------------------------------------------------------------------*
*&      Form  cadastra_reserva
*&---------------------------------------------------------------------*
*       text
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
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*       EXPORTING
*         WAIT          =
*       IMPORTING
*         RETURN        =
              .

  ENDIF.
ENDFORM.                    "cadastra_reserva

*&---------------------------------------------------------------------*
*&      Form  f_processar_nao_serializados
*&---------------------------------------------------------------------*
*FORM F_PROCESSAR_NAO_SERIALIZADOS.
*
*  LOOP AT T_NSERI.
*
*    MOVE T_NSERI-MATNR+12(6) TO V_MATERIAL.
*    WRITE T_NSERI-QTDE       TO V_QUANT.
*    CLEAR V_TIMES.
*    CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO V_DATUM.
*    V_DATA = SY-DATUM.
*
**MB21
**   Criar reservas separadas por deposito
*    AT NEW LGORT.
*
*      PERFORM F_MB21 USING T_NSERI-LGORT
*                           T_NSERI-DEPOS.
*
*      WHILE V_TIMES = 'X'.
*
*        ADD 7 TO V_DATA.
*
*        CONCATENATE V_DATA+6(2) V_DATA+4(2) V_DATA(4) INTO V_DATUM.
*
*        PERFORM F_MB21 USING T_NSERI-LGORT
*                             T_NSERI-DEPOS.
*
*      ENDWHILE.
*
*      CONTINUE.
*
*    ENDAT.
*
**MB22
*
*    PERFORM F_MB22 USING T_NSERI-DEPOS.
*
*    WHILE V_TIMES = 'X'.
*
*      ADD 7 TO V_DATA.
*
*      CONCATENATE V_DATA+6(2) V_DATA+4(2) V_DATA(4) INTO V_DATUM.
*
*      PERFORM F_MB22 USING T_NSERI-DEPOS.
*
*    ENDWHILE.
*  ENDLOOP.
*ENDFORM.                    "f_processar_nao_serializados

*&---------------------------------------------------------------------*
*&      Form  f_processar_serializados
*&---------------------------------------------------------------------*
FORM F_PROCESSAR_SERIALIZADOS.

  LOOP AT T_SERIA.

    MOVE T_SERIA-MATNR+12(6) TO V_MATERIAL.
    WRITE T_SERIA-QTDE       TO V_QUANT.
    CLEAR V_TIMES.
    CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO V_DATUM.
    V_DATA = SY-DATUM.

*MB21
*   Criar reservas separadas por deposito
    AT NEW LGORT.

      PERFORM F_MB21 USING T_SERIA-LGORT
                           T_SERIA-DEPOS.

      WHILE V_TIMES = 'X'.

        ADD 7 TO V_DATA.

        CONCATENATE V_DATA+6(2) V_DATA+4(2) V_DATA(4) INTO V_DATUM.

        PERFORM F_MB21 USING T_SERIA-LGORT
                             T_SERIA-DEPOS.

      ENDWHILE.

      CONTINUE.

    ENDAT.

*MB22

    PERFORM F_MB22 USING T_SERIA-DEPOS.

    WHILE V_TIMES = 'X'.

      ADD 7 TO V_DATA.

      CONCATENATE V_DATA+6(2) V_DATA+4(2) V_DATA(4) INTO V_DATUM.

      PERFORM F_MB22 USING T_SERIA-DEPOS.

    ENDWHILE.
  ENDLOOP.
ENDFORM.                    "f_processar_serializados
*&---------------------------------------------------------------------*
*&      Form  F_MB21
*&---------------------------------------------------------------------*
FORM F_MB21 USING P_LGORT
                  P_DEPOS.

  CLEAR  : I_BDC, IT_MESSAGE. ">>D60K935029
  REFRESH: I_BDC, IT_MESSAGE. ">>D60K935029

  PERFORM F_DYNPRO TABLES I_BDC USING:
           'X'   'SAPMM07R'                   '0500',
           ' '   'BDC_OKCODE'                 '/00',
*           ' '   'BDC_CURSOR'                'XFULL',
           ' '   'RM07M-RSDAT'                 V_DATUM,
           ' '   'RM07M-XCALE'                'X',
           ' '   'RM07M-BWART'                '913',
           ' '   'RM07M-WERKS'                '5300'.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                 'X'   'SAPMM07R'             '0521',
                 ' '   'BDC_OKCODE'           '=BU',
*                ' '   'BDC_CURSOR'           'RESB-LGORT(01)',
                 ' '   'RKPF-WEMPF'           ' ',
*                 ' '   'RKPF-UMLGO'           i_resb1-lgort,
                 ' '   'RKPF-UMLGO'           P_LGORT,
                 ' '   'RESB-MATNR(01)'       V_MATERIAL,
                 ' '   'RESB-ERFMG(01)'       V_QUANT,
*                 ' '   'RESB-LGORT(01)'       i_resb1-depos.
                 ' '   'RESB-LGORT(01)'       P_DEPOS.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                   'X'   'SAPMM07R'           '0510',
                   ' '   'BDC_OKCODE'         '/00',
                   ' '   'RESB-WERKS'         '5300',
                   ' '   'RESB-MATNR'         V_MATERIAL,
*                   ' '   'RESB-LGORT'         i_resb1-depos,
                   ' '   'RESB-LGORT'         P_DEPOS,
                   ' '   'RESB-ERFMG'         V_QUANT,
                   ' '   'RESB-BDTER'         V_DATUM,
                   ' '   'RESB-XWAOK'         'X',
                   ' '   'RKPF-WEMPF'         ' '.



  CALL TRANSACTION 'MB21'
        USING I_BDC
        OPTIONS FROM I_OPTIONS
        MESSAGES INTO IT_MESSAGE.

  LOOP AT IT_MESSAGE.

    MESSAGE ID IT_MESSAGE-MSGID
    TYPE       IT_MESSAGE-MSGTYP
    NUMBER     IT_MESSAGE-MSGNR
    WITH       IT_MESSAGE-MSGV1
               IT_MESSAGE-MSGV2
               IT_MESSAGE-MSGV3
               IT_MESSAGE-MSGV4
    INTO       V_MESSAGE.

    IF IT_MESSAGE-MSGNR = 181.
      V_TIMES = 'X'.
    ELSE.
      V_TIMES = SPACE.
    ENDIF.

*Busca o número da reserva gerada
*    read table IT_MESSAGE index 1.
    IF IT_MESSAGE-MSGNR = '060'.
      MOVE IT_MESSAGE-MSGV1   TO V_RESER .
    ENDIF.

    IF IT_MESSAGE-MSGTYP EQ 'E' AND NOT IT_MESSAGE-MSGNR = 181.

      MOVE: V_MATERIAL          TO IT_MSG-MATNR,
            I_RESB1-LGORT       TO IT_MSG-LGORT,
            S_WERKS             TO IT_MSG-WERKS,
            V_MESSAGE           TO IT_MSG-MESSAGE,
            IT_MESSAGE-TCODE    TO IT_MSG-TCODE.
      APPEND IT_MSG.

    ENDIF.
  ENDLOOP.
ENDFORM.                                                    "F_MB21

*&---------------------------------------------------------------------*
*&      Form  F_MB22
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_MB22 USING P_DEPOS.

  CLEAR  : I_BDC, IT_MESSAGE. ">>D60K935029
  REFRESH: I_BDC, IT_MESSAGE. ">>D60K935029

  PERFORM F_DYNPRO TABLES I_BDC USING:
           'X'   'SAPMM07R'                   '0560',
           ' '   'BDC_OKCODE'                 '/00',
           ' '   'RM07M-RSNUM'                V_RESER,
           ' '   'RM07M-RSPOS'                ' '.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                 'X'   'SAPMM07R'             '0521',
                 ' '   'BDC_CURSOR'           'RESB-ERFMG(01)',
                 ' '   'BDC_OKCODE'           '=NLR',
                 ' '   'RKPF-WEMPF'           ' ',
                ' '   'BDC_SUBSCR'           'SAPLKACB 0001BLOCK'.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                   'X'   'SAPMM07R'            '1502',
                   ' '   'BDC_OKCODE'          '=OK',
                   ' '   'RM07M-BDTER'         V_DATUM,
                   ' '   'RM07M-WERKS'         '5300'.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                     'X'   'SAPMM07R'             '0521',
                     ' '   'BDC_OKCODE'           '=BU',
                     ' '   'RKPF-WEMPF'           ' ',
                     ' '   'RESB-MATNR(01)'       V_MATERIAL,
                     ' '   'RESB-ERFMG(01)'       V_QUANT,
*                     ' '   'RESB-LGORT(01)'       i_resb1-depos.
                     ' '   'RESB-LGORT(01)'       P_DEPOS.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                     'X'   'SAPLKACB'             '0002',
                     ' '   'BDC_OKCODE'           '=ENTE'.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                   'X'   'SAPMM07R'            '0510',
                   ' '   'BDC_OKCODE'          '/00',
                   ' '   'RESB-WERKS'          '5300',
                   ' '   'RESB-MATNR'          V_MATERIAL,
*                   ' '   'RESB-LGORT'          i_resb1-depos,
                   ' '   'RESB-LGORT'          P_DEPOS,
                   ' '   'RESB-ERFMG'          V_QUANT,
                   ' '   'RESB-ERFME'          ' ',
                   ' '   'RESB-BDTER'          V_DATUM,
                   ' '   'RESB-XWAOK'          'X',
                   ' '   'RKPF-WEMPF'          ' '.

  PERFORM F_DYNPRO TABLES I_BDC USING:
                    'X'   'SAPLKACB'             '0002',
                    ' '   'BDC_OKCODE'           '=ENTE'.



  CALL TRANSACTION 'MB22'
       USING I_BDC
       OPTIONS FROM I_OPTIONS
       MESSAGES INTO IT_MESSAGE.

  CLEAR V_MESSAGE.

  LOOP AT IT_MESSAGE.

    IT_MESSAGE-FLDNAME = 'MB22'.
    MODIFY IT_MESSAGE.

    MESSAGE ID IT_MESSAGE-MSGID
    TYPE       IT_MESSAGE-MSGTYP
    NUMBER     IT_MESSAGE-MSGNR
    WITH       IT_MESSAGE-MSGV1
               IT_MESSAGE-MSGV2
               IT_MESSAGE-MSGV3
               IT_MESSAGE-MSGV4
    INTO       V_MESSAGE.

    IF IT_MESSAGE-MSGNR = 181.
      V_TIMES = 'X'.
    ELSE.
      V_TIMES = SPACE.
    ENDIF.

    IF IT_MESSAGE-MSGTYP EQ 'E' AND NOT IT_MESSAGE-MSGNR = 181.

      MOVE: V_MATERIAL          TO IT_MSG-MATNR,
            I_RESB1-LGORT       TO IT_MSG-LGORT,
            S_WERKS             TO IT_MSG-WERKS,
            V_MESSAGE           TO IT_MSG-MESSAGE,
            IT_MESSAGE-TCODE    TO IT_MSG-TCODE.
      APPEND IT_MSG.

    ENDIF.

  ENDLOOP.

ENDFORM.                    "F_MB22

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
*----------------------------------------------------------------------*
FORM LOG_EMAIL .

  IF NOT IT_MSG[] IS INITIAL.

    CALL FUNCTION 'HR_FBN_GENERATE_SEND_EMAIL'
      EXPORTING
        SUBJECT               = 'Log ZM137'
        SENDER                = P_EMAIL1
        RECIPIENT             = P_EMAIL2
        FLAG_COMMIT           = 'X'
        FLAG_SEND_IMMEDIATELY = 'X'
      TABLES
        EMAIL_TEXT            = IT_MSG.

  ENDIF.

ENDFORM.                    " LOG_EMAIL
