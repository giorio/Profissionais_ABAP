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
*& >> S_DEPOS
*&---------------------------------------------------------------------*
*& Saídas:
*& << I_MARD
*& << I_ESTOQUE
*& << ZTAB
*&
*&---------------------------------------------------------------------*

FORM F_SELECT_ESTOQUE.

*   Recupera a posição de estoque de todos os materiais nos
* depositos informados.

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
               MARD~LGORT IN S_LGORT OR
               MARD~MATNR IN S_MATNR AND
               MARD~WERKS IN S_WERKS AND
               MARD~LGORT IN S_DEPOS.

  IF SY-SUBRC NE 0.
    MESSAGE S002(ZC).
    STOP.
  ENDIF.

  SORT I_MARD BY MATNR LGORT.

*& Inicia o prenchimento da tabela de I_ESTOQUE que irá ser
*& usada para verificar se o material está critico ou não

  FREE I_ESTOQUE.

  LOOP AT I_MARD WHERE LGORT IN S_DEPOS.

    I_ESTOQUE-MATNR = I_MARD-MATNR.
    I_ESTOQUE-LABST = I_MARD-LABST.

    COLLECT I_ESTOQUE.

  ENDLOOP.

*   A variavel V_MES vai serve para consultar a tabela ZMARAH.
* Ela é preenchida com o mês atual -1, para pegar o sempre o
* o último registro valido do material. Uma vez que apenas materiais
* ERSA e HIBE com status N* tem relevancia para o log.

  V_MES = SY-DATUM+4(2) - 1.

  FREE: I_MARDAUX1.
  SELECT MATNR
         INTO TABLE I_MARDAUX1
         FROM ZMARAH
         WHERE GJAHR = SY-DATUM(4)
         AND  LFMON = V_MES
         AND WERKS IN S_WERKS.

  SORT I_MARDAUX1 BY MATNR.

  LOOP AT I_ESTOQUE.

*   Materiais com estoque 0 recebem inicialmente o campo I_ESTOQUE-CRIT a letra
* 'S', caso o material esteja contido no tabela I_MARDAUX1, resultado do select
* da ZMARAH ele troca para 'Z' e irá gerar a mensagem de estoque zerado.

    IF I_ESTOQUE-LABST = 0.
      I_ESTOQUE-CRIT = 'S'.
      MODIFY I_ESTOQUE.
    ENDIF.

    READ TABLE I_MARDAUX1 WITH KEY MATNR = I_ESTOQUE-MATNR.

    IF SY-SUBRC = 0.
      IF I_ESTOQUE-LABST = 0.
        I_ESTOQUE-CRIT = 'Z'.
        MODIFY I_ESTOQUE.
      ENDIF.
    ENDIF.

*   Pega todos os materiais com marcado com 'Z' e grava na tabela de log a mensagem
* ZC421

    IF I_ESTOQUE-CRIT = 'Z'.
      MESSAGE ID 'ZC'
              TYPE 'E'
              NUMBER '421'
              INTO MESSAGE-MESSAGE
              WITH I_ESTOQUE-MATNR.
      MESSAGE-ID = 'ZC'.
      MESSAGE-NUMBER = 421.
      MESSAGE-TYPE = 'E'.
      APPEND MESSAGE.
    ENDIF.

  ENDLOOP.

  LOOP AT I_MARD.
    READ TABLE I_ESTOQUE WITH KEY MATNR = I_MARD-MATNR.

*   Exclui o material que estiver zerado nos estoques supridores, não gerando assim
* as reservas para eles. O programa não irá consultar nenhum outro dados.

    IF SY-SUBRC = 0.
      IF I_ESTOQUE-LABST = 0.
        DELETE I_MARD.
      ENDIF.

    ENDIF.

  ENDLOOP.

  DELETE I_MARD WHERE LGORT IN S_DEPOS.

*& Vai buscar o estoque em pedido de compra, pedido gravado com
*& deposito de recebimento.

  I_MARDAUX[] = I_MARD[].

  LOOP AT I_MARDAUX.
    FREE: ZTABAUX.

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

  SORT ZTAB BY MATNR LGORT.

*& Incoporar o resultado da função MB_ADD_PURCHASE_ORDER_QUANTITY
*& na tabela I_MARD

  LOOP AT I_MARD.
    READ TABLE ZTAB WITH KEY MATNR = I_MARD-MATNR
                             WERKS = I_MARD-WERKS
                             LGORT = I_MARD-LGORT.

    IF SY-SUBRC = 0.
      I_MARD-MENGE = ZTAB-MENGE.
      MODIFY I_MARD.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "F_SELECT_ESTOQUE
