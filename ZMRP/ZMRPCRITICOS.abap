*&---------------------------------------------------------------------*
*&  Include           ZMRPCRITICOS
*&
*& Programa para analise de criticidade do material
*&---------------------------------------------------------------------*
*&    O programa irá analisar e tratar os materiais criticos.
*&    O material é considerado critico quando houver mais quantidades
*& reservadas total do que quantidade em livre utilização no deposito
*& 3000.
*&---------------------------------------------------------------------*
*& Entrada:
*& >> I_RESB1
*& >> I_ESTOQUE
*&
*&
*&---------------------------------------------------------------------*
*& Saídas:
*& << I_ESTOQUE
*& << I_RESB1
*&
*&
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_ANALISECRITICO
*&---------------------------------------------------------------------*
*&    O Form vai complementar a tabela I_ESTOQUE e flegar o campo CRIT
*& caso entre na condição de ter mais reservas do que material habilitado
*& para transferência.
*----------------------------------------------------------------------*

FORM f_analiseestoque.

  SORT i_resb1 BY matnr.

  LOOP AT i_resb1.
    READ TABLE i_estoque WITH KEY matnr = i_resb1-matnr.

    IF sy-subrc = 0.
      ADD i_resb1-qtde TO i_estoque-qtde.
      MODIFY i_estoque TRANSPORTING qtde WHERE matnr = i_resb1-matnr.
      ADD i_resb1-neces TO i_estoque-neces.
      MODIFY i_estoque TRANSPORTING neces WHERE matnr = i_resb1-matnr.
      IF i_estoque-labst <= i_estoque-qtde.
        i_estoque-crit = 'X'.
        MODIFY i_estoque TRANSPORTING crit WHERE matnr = i_resb1-matnr.
        MESSAGE  ID 'ZC'
                 TYPE 'E'
                 NUMBER '420'
                 INTO message-message
                 WITH i_estoque-matnr.
        message-id = 'ZC'.
        message-number = 420.
        message-type = 'E'.
        APPEND message.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "F_ANALISEESTOQUE

*&---------------------------------------------------------------------*
*&      Form  F_ANALISECRITICO
*&---------------------------------------------------------------------*
*&    O Form irá alterar a quantidade apurada na I_RESB1, garantindo a
*& a que todos os depositos recebam as mercadoria de forma proporcional
*& a quantidade reservada.
*----------------------------------------------------------------------*
FORM f_analisecritico.

  DATA: v_depos TYPE bdmng.

  LOOP AT i_estoque.
    CLEAR: v_neces, v_disp, v_depos.

    IF i_estoque-crit = 'X'.

      IF ( i_estoque-neces < i_estoque-labst ).
        v_disp = i_estoque-neces.
      ELSE.
        v_disp = i_estoque-labst.
      ENDIF.

      LOOP AT i_resb1 WHERE matnr = i_estoque-matnr.

        READ TABLE i_estoque WITH KEY matnr = i_resb1-matnr.

        IF sy-subrc = 0.

          v_neces = ( i_resb1-neces / i_estoque-neces * v_disp ).
          IF ( v_neces - trunc( v_neces )  <  ( 1 / 2 ) ).
            v_neces = trunc( v_neces ).
          ELSE.
            v_neces = trunc( v_neces ) + 1.
          ENDIF.
        ENDIF.

        i_resb1-qtde = v_neces.
        i_resb1-atend = ( i_resb1-qtde / i_resb1-neces ) * 100.
        MODIFY i_resb1 TRANSPORTING qtde atend.
        v_depos = v_depos + v_neces.
      ENDLOOP.

      WHILE v_depos < i_estoque-labst.
        PERFORM f_distribui_1 USING i_estoque-matnr.
        ADD 1 TO v_depos.
      ENDWHILE.

    ENDIF.

  ENDLOOP.

  DELETE i_resb1 WHERE qtde = 0.

ENDFORM.                    "F_AnaliseCritico

*&---------------------------------------------------------------------*
*&      Form  F_DISTRIBUI_1
*&---------------------------------------------------------------------*
*   Esse subprograma irá acrescentar sempre 1 unidade no deposito com menor
* taxa de atendimento, i_resb-atend, até o valor v_depos seja igual ao
* i_estoque-las.
*----------------------------------------------------------------------*
*      -->P_I_ESTOQUE_MATNR  text
*----------------------------------------------------------------------*
FORM f_distribui_1  USING    p_i_estoque_matnr.

  SORT i_resb1 BY matnr atend ASCENDING.

  LOOP AT i_resb1 WHERE matnr = p_i_estoque_matnr AND atend > 0.

    ADD 1 TO i_resb1-qtde.
    MODIFY i_resb1 TRANSPORTING qtde.
    EXIT.

  ENDLOOP.



ENDFORM.                    " F_DISTRIBUI_1
