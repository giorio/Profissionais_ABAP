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

FORM F_ANALISEESTOQUE.

  SORT I_RESB1 BY MATNR.

  LOOP AT I_RESB1.
    READ TABLE I_ESTOQUE WITH KEY MATNR = I_RESB1-MATNR.

    IF SY-SUBRC = 0.
      ADD I_RESB1-QTDE TO I_ESTOQUE-QTDE.
      MODIFY I_ESTOQUE TRANSPORTING QTDE WHERE MATNR = I_RESB1-MATNR.
      IF I_ESTOQUE-LABST LE I_ESTOQUE-QTDE.
        I_ESTOQUE-CRIT = 'X'.
        MODIFY I_ESTOQUE TRANSPORTING CRIT WHERE MATNR = I_RESB1-MATNR.
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
FORM F_ANALISECRITICO.

  LOOP AT I_ESTOQUE.
    CLEAR: V_NECES.

    IF I_ESTOQUE-CRIT = 'X'.

      LOOP AT I_RESB1 WHERE MATNR = I_ESTOQUE-MATNR.

        READ TABLE I_ESTOQUE WITH KEY MATNR = I_RESB1-MATNR.

        IF SY-SUBRC = 0.
          V_NECES = ( I_RESB1-QTDE / I_ESTOQUE-QTDE * I_ESTOQUE-LABST ).
          CLEAR: MARC-BSTRF,
                 V_ARRED,
                 V_REST.

          SELECT SINGLE BSTRF
                        FROM MARC
                        INTO MARC-BSTRF
                        WHERE MATNR = I_RESB1-MATNR
                        AND WERKS IN S_WERKS.

          IF SY-SUBRC = 0.
            IF V_NECES LE 1.
              V_NECES = 1.
            ELSEIF NOT MARC-BSTRF IS INITIAL.
              V_ARRED = V_NECES DIV MARC-BSTRF.
              V_REST =  V_NECES MOD MARC-BSTRF.

              IF V_REST <> 0.
                V_NECES = ( V_ARRED * MARC-BSTRF ) + MARC-BSTRF.
              ENDIF.

            ENDIF.
          ENDIF.

          I_RESB1-QTDE = V_NECES.
          MODIFY I_RESB1.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.                    "F_AnaliseCritico
