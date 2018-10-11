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

FORM f_select_estoque.

*   Recupera a posição de estoque de todos os materiais nos
* depositos informados.

  SELECT mard~matnr
         mard~werks
         mard~lgort
         mard~labst
         mard~umlme
         mara~meins
         INTO TABLE i_mard
         FROM mard AS mard
         INNER JOIN mara AS mara
         ON mard~matnr = mara~matnr
         WHERE mard~matnr IN s_matnr
         AND mard~werks IN s_werks
         AND (
              mard~lgort IN s_lgort
              OR
               mard~lgort IN s_depos
              ).

  IF sy-subrc NE 0.
    MESSAGE s002(zc).
    STOP.
  ENDIF.

  SORT i_mard BY matnr lgort.
  DELETE i_mard WHERE matnr NOT IN rg_matnr.

*& Inicia o prenchimento da tabela de I_ESTOQUE que irá ser
*& usada para verificar se o material está critico ou não

  FREE i_estoque.

  LOOP AT i_mard WHERE lgort IN s_depos.

    i_estoque-matnr = i_mard-matnr.
    i_estoque-labst = i_mard-labst.

    COLLECT i_estoque.

  ENDLOOP.

*   A variavel V_MES vai serve para consultar a tabela ZMARAH.
* Ela é preenchida com o mês atual -1, para pegar o sempre o
* o último registro valido do material. Uma vez que apenas materiais
* ERSA e HIBE com status N* tem relevancia para o log.

  v_mes = sy-datum+4(2) - 1.

  FREE: i_mardaux1.
  SELECT matnr
         INTO TABLE i_mardaux1
         FROM zmarah
         WHERE gjahr = sy-datum(4)
         AND  lfmon = v_mes
         AND werks IN s_werks.

  SORT i_mardaux1 BY matnr.

  LOOP AT i_estoque.

*   Materiais com estoque 0 recebem inicialmente o campo I_ESTOQUE-CRIT a letra
* 'S', caso o material esteja contido no tabela I_MARDAUX1, resultado do select
* da ZMARAH ele troca para 'Z' e irá gerar a mensagem de estoque zerado.

    IF i_estoque-labst = 0.
      i_estoque-crit = 'S'.
      MODIFY i_estoque TRANSPORTING crit.
    ENDIF.

    READ TABLE i_mardaux1 WITH KEY matnr = i_estoque-matnr.

    IF sy-subrc = 0.
      IF i_estoque-labst = 0.
        i_estoque-crit = 'Z'.
        MODIFY i_estoque TRANSPORTING crit.
*   Pega todos os materiais com marcado com 'Z' e grava na tabela de log a mensagem
* ZC421
        MESSAGE ID 'ZC'
              TYPE 'E'
              NUMBER '421'
              INTO message-message
              WITH i_estoque-matnr.
        message-id = 'ZC'.
        message-number = 421.
        message-type = 'E'.
        APPEND message.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT i_mard.
    READ TABLE i_estoque WITH KEY matnr = i_mard-matnr.

*   Exclui o material que estiver zerado nos estoques supridores, não gerando assim
* as reservas para eles. O programa não irá consultar nenhum outro dados.

    IF sy-subrc = 0.
      IF i_estoque-labst = 0.
        DELETE i_mard.
      ENDIF.

    ENDIF.

  ENDLOOP.

  DELETE i_mard WHERE lgort IN s_depos.

*& Vai buscar o estoque em pedido de compra, pedido gravado com
*& deposito de recebimento.

  i_mardaux[] = i_mard[].

  LOOP AT i_mardaux.
    FREE: ztabaux.

    CALL FUNCTION 'MB_ADD_PURCHASE_ORDER_QUANTITY'
      EXPORTING
        x_elikz = space
        x_loekz = space
        x_matnr = i_mardaux-matnr
        x_meins = i_mardaux-meins
      TABLES
        xtab    = ztabaux
        xwerks  = s_werks.

    LOOP AT ztabaux.
      APPEND ztabaux TO ztab.
    ENDLOOP.

  ENDLOOP.

  SORT ztab BY matnr lgort.

*& Incoporar o resultado da função MB_ADD_PURCHASE_ORDER_QUANTITY
*& na tabela I_MARD

  LOOP AT i_mard.
    READ TABLE ztab WITH KEY matnr = i_mard-matnr
                             werks = i_mard-werks
                             lgort = i_mard-lgort.

    IF sy-subrc = 0.
      i_mard-menge = ztab-menge.
      MODIFY i_mard TRANSPORTING menge.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "F_SELECT_ESTOQUE
