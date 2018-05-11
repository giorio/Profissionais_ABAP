*&---------------------------------------------------------------------*
*&  Include           ZMRPNECESTRANSF
*&
*& Verifica a necessidade de Tranferencia
*&---------------------------------------------------------------------*
*&    O form gera uma tabela com as necessidades de transferêcias para
*& os materiais.
*&---------------------------------------------------------------------*
*& Entrada:
*& >> I_RESB1
*& >> I_MARD
*& >> ZTAB
*&
*&---------------------------------------------------------------------*
*& Saídas:
*& << I_RESB1
*&
*&
*&
*&---------------------------------------------------------------------*

FORM F_SELEC_TRANSF.

  LOOP AT I_RESB1.

    CLEAR: V_ESTOQUE, V_NECES, V_ESTOQUEPEDIDO.

*Lê os estoques do material no depósito
    READ TABLE I_MARD WITH KEY MATNR = I_RESB1-MATNR
                               LGORT = I_RESB1-LGORT.
    IF SY-SUBRC = 0.
      V_ESTOQUE = I_MARD-LABST + I_MARD-UMLME.
    ENDIF.

*Lê estoque em pedido
    READ TABLE ZTAB WITH KEY LGORT = I_RESB1-LGORT
                             MATNR = I_RESB1-MATNR.

    IF SY-SUBRC = 0.
      V_ESTOQUEPEDIDO = ZTAB-MENGE.
    ENDIF.

*Calcula a necessidade para gerar transferência
    I_RESB1-NECES = I_RESB1-BDMNG - ( V_ESTOQUE + I_RESB1-BDMNS + V_ESTOQUEPEDIDO ).
    MODIFY I_RESB1.
    V_NECES = I_RESB1-NECES.

* Modificação 04/09/2012

* Início
    CLEAR: MARC-BSTRF,
           V_ARRED,
           V_REST.
    SELECT SINGLE BSTRF
    FROM MARC
    INTO MARC-BSTRF
    WHERE MATNR = I_RESB1-MATNR AND
          WERKS IN S_WERKS.

    IF SY-SUBRC = 0.
      IF NOT MARC-BSTRF IS INITIAL.
        V_ARRED = V_NECES DIV MARC-BSTRF .
        V_REST =  V_NECES MOD MARC-BSTRF .
        IF V_REST <> 0.
          V_NECES = ( V_ARRED * MARC-BSTRF ) + MARC-BSTRF.
        ENDIF.
      ENDIF.
    ENDIF.

* fim

*Deleta itens da tabela que tem material suficiente
    IF V_NECES LE 0.
      DELETE I_RESB1.
    ELSE.

*Busca o grupo do material - (poste - 54)
      READ TABLE I_MARA WITH KEY MATNR = I_RESB1-MATNR.

      IF I_MARA-MATKL EQ '5409' OR I_MARA-MATKL EQ '5410' OR I_MARA-MATKL EQ '5411' OR I_MARA-MATKL EQ '5412' OR
         I_MARA-MATKL EQ '5414' OR I_MARA-MATKL EQ '5510'.

*Busca o CDP que abastecerá o dep. empreiteiro
        READ TABLE I_ZM0007 WITH KEY LGORT = I_RESB1-LGORT.
        I_RESB1-DEPOS = I_ZM0007-UMLGO.
      ELSE.
        I_RESB1-DEPOS = '3000'.
      ENDIF.

      I_RESB1-QTDE = V_NECES .
      MODIFY I_RESB1.
    ENDIF.

  ENDLOOP.

  SORT I_RESB1 BY DEPOS LGORT SERNP MATNR.

ENDFORM.                    "F_SELEC_TRANSF
