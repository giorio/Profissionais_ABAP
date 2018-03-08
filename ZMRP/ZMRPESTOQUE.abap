*&---------------------------------------------------------------------*
*&  Include           ZMRPESTOQUE
*&
*& Verificar estoque.
*&---------------------------------------------------------------------*
*&    O form gera uma tabela com a posição do estoque no momento da
*& execução do programa, considera o material em livre utilização,
*& bloqueados, em transferência, com pedidos firme para cada deposito.
*&---------------------------------------------------------------------*
*& Entrada:
*& >> S_MATNR
*& >> S_WERKS
*& >> S_LGORT
*&
*&---------------------------------------------------------------------*
*& Saídas:
*& << I_MARD
*& << I_ESTOQUE
*& << ZTAB
*&
*&---------------------------------------------------------------------*

FORM F_SELECT_ESTOQUE.

  SELECT MARD~MATNR
         MARD~WERKS
         MARD~LGORT
         MARD~LABST
         MARD~UMLME
         MARD~INSME
         MARD~EINME
         MARD~SPEME
         MARD~RETME
         MARD~VMLAB
         MARD~VMUML
         MARD~VMINS
         MARD~VMEIN
         MARD~VMSPE
         MARD~VMRET
         MARA~MEINS
         INTO TABLE I_MARD
         FROM MARD AS MARD
         INNER JOIN MARA AS MARA
         ON MARD~MATNR = MARA~MATNR
         WHERE MARD~MATNR IN S_MATNR AND
               MARD~WERKS IN S_WERKS AND
               MARD~LGORT IN S_LGORT.

  IF SY-SUBRC NE 0.
    MESSAGE S002(ZC).
    STOP.
  ENDIF.

  SORT I_MARD BY MATNR LGORT.

*& Inicia o prenchimento da tabela de I_ESTOQUE que irá ser
*& usada para verificar se o material está critico ou não

  REFRESH I_ESTOQUE.

  LOOP AT I_MARD WHERE LGORT = '3000' OR LGORT = '3960'.

    I_ESTOQUE-MATNR = I_MARD-MATNR.
    I_ESTOQUE-LABST = I_MARD-LABST.
    COLLECT I_ESTOQUE.

  ENDLOOP.

  I_MARDAUX[] = I_MARD[].

*& Vai buscar o estoque em pedido de compra, pedido gravado com
*& deposito de recebimento.

  LOOP AT I_MARDAUX.
    REFRESH ZTABAUX.

    CALL FUNCTION 'MB_ADD_PURCHASE_ORDER_QUANTITY'
      EXPORTING
        X_ELIKZ = SPACE
        X_LOEKZ = SPACE
        X_MATNR = I_MARDAUX-MATNR
        X_MEINS = I_MARDAUX-MEINS
      TABLES
        XTAB    = ZTABAUX
        XWERKS  = S_WERKS.

    LOOP AT ZTABAUX.
      APPEND ZTABAUX TO ZTAB.
    ENDLOOP.

  ENDLOOP.

  SORT ZTABAUX BY MATNR LGORT.

*& Incoporar o resultado da função MB_ADD_PURCHASE_ORDER_QUANTITY
*& na tabela I_MARD

  LOOP AT I_MARD.
    READ TABLE ZTABAUX WITH KEY MATNR = I_MARD-MATNR
                                WERKS = I_MARD-WERKS
                                LGORT = I_MARD-LGORT.

    IF SY-SUBRC = 0.
      I_MARD-MENGE = ZTABAUX-MENGE.
      MODIFY I_MARD.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "F_SELECT_ESTOQUE
