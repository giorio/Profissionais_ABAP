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

FORM f_selec_transf.

  LOOP AT i_resb1.

    CLEAR: v_estoque, v_neces, v_estoquepedido.

*Lê os estoques do material no depósito
    READ TABLE i_mard WITH KEY matnr = i_resb1-matnr
                               lgort = i_resb1-lgort.
    IF sy-subrc = 0.
      v_estoque = i_mard-labst + i_mard-umlme.
    ENDIF.

*Lê estoque em pedido
    READ TABLE ztab WITH KEY lgort = i_resb1-lgort
                             matnr = i_resb1-matnr.

    IF sy-subrc = 0.
      v_estoquepedido = ztab-menge.
    ENDIF.

*Calcula a necessidade para gerar transferência
    i_resb1-neces = i_resb1-bdmng - ( v_estoque + i_resb1-bdmns + v_estoquepedido ).
    MODIFY i_resb1 TRANSPORTING neces.
    v_neces = i_resb1-neces.

* Modificação 04/09/2012

* Início
    CLEAR: marc-bstrf,
           v_arred,
           v_rest.
    SELECT SINGLE bstrf
    FROM marc
    INTO marc-bstrf
    WHERE matnr = i_resb1-matnr AND
          werks IN s_werks.

    IF sy-subrc = 0.
      IF NOT marc-bstrf IS INITIAL.
        v_arred = v_neces DIV marc-bstrf .
        v_rest =  v_neces MOD marc-bstrf .
        IF v_rest <> 0.
          v_neces = ( v_arred * marc-bstrf ) + marc-bstrf.
        ENDIF.
      ELSE.
        v_neces = trunc( v_neces ) + 1.
      ENDIF.
    ENDIF.

* fim

*Deleta itens da tabela que tem material suficiente
    IF v_neces LE 0.
      DELETE i_resb1.
    ELSE.

*Busca o grupo do material - (poste - 54)
      READ TABLE i_mara WITH KEY matnr = i_resb1-matnr.

      IF i_mara-matkl EQ '5409' OR i_mara-matkl EQ '5410' OR i_mara-matkl EQ '5411' OR i_mara-matkl EQ '5412' OR
         i_mara-matkl EQ '5414' OR i_mara-matkl EQ '5510'.

*Busca o CDP que abastecerá o dep. empreiteiro
        READ TABLE i_zm0007 WITH KEY lgort = i_resb1-lgort.
        i_resb1-depos = i_zm0007-umlgo.
      ELSE.
        i_resb1-depos = '3000'.
      ENDIF.

      i_resb1-qtde = v_neces .
      MODIFY i_resb1 TRANSPORTING depos qtde.
    ENDIF.

  ENDLOOP.

  SORT i_resb1 BY depos lgort sernp matnr.

ENDFORM.                    "F_SELEC_TRANSF
