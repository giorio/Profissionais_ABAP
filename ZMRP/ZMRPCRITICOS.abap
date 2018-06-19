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
      ADD I_RESB1-NECES TO I_ESTOQUE-NECES.
      MODIFY I_ESTOQUE TRANSPORTING NECES WHERE MATNR = I_RESB1-MATNR.
      IF I_ESTOQUE-LABST <= I_ESTOQUE-QTDE.
        I_ESTOQUE-CRIT = 'X'.
        MODIFY I_ESTOQUE TRANSPORTING CRIT WHERE MATNR = I_RESB1-MATNR.
        MESSAGE  ID 'ZC'
                 TYPE 'E'
                 NUMBER '420'
                 INTO MESSAGE-MESSAGE
                 WITH I_ESTOQUE-MATNR.
        MESSAGE-ID = 'ZC'.
        MESSAGE-NUMBER = 420.
        MESSAGE-TYPE = 'E'.
        APPEND MESSAGE.
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
    CLEAR: V_NECES, V_DISP.

    IF I_ESTOQUE-CRIT = 'X'.

      IF ( I_ESTOQUE-NECES < I_ESTOQUE-LABST ).
        V_DISP = I_ESTOQUE-NECES.
      ELSE.
        V_DISP = I_ESTOQUE-LABST.
      ENDIF.

      LOOP AT I_RESB1 WHERE MATNR = I_ESTOQUE-MATNR.

        READ TABLE I_ESTOQUE WITH KEY MATNR = I_RESB1-MATNR.

        IF SY-SUBRC = 0.

          V_NECES = ( I_RESB1-NECES / I_ESTOQUE-NECES * V_DISP ).
          IF ( V_NECES - TRUNC( V_NECES )  <  ( 1 / 2 ) ).
            V_NECES = TRUNC( V_NECES ).
          ELSE.
            V_NECES = TRUNC( V_NECES ) + 1.
          ENDIF.
        ENDIF.

        I_RESB1-QTDE = V_NECES.
        MODIFY I_RESB1 TRANSPORTING QTDE.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  DELETE I_RESB1 WHERE QTDE = 0.

ENDFORM.                    "F_AnaliseCritico
