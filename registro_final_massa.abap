*&---------------------------------------------------------------------*
*& Report  ZMMR076
*& Flegar Registro Final em Massa
*&---------------------------------------------------------------------*
*& Desenvolvedor: Gustavo Di Iório - E208747
*& Versão: 1
*& Desenvolvido em: 27/12/2017
*& Mudança Original: C123398
*& Documentação: MM.02.05.028 EST Flegar Registro Final em Massa - Reserva
*&---------------------------------------------------------------------*
*& Alterações
*& Mudança:
*& Data:
*& Desenvolvedor:
*&---------------------------------------------------------------------*

REPORT ZMMR076
  NO STANDARD PAGE HEADING                    "Não mostra o cabeçalho padrão SAP
  MESSAGE-ID ZC.                              "Classe de Mensagens - CEMIG

*Tabelas---------------------------------------------------------------*
TABLES:
  RESB.                                       "itens da reserva

*Estrutura
TYPES: BEGIN OF T_RESB,
  RSNUM TYPE RESB-RSNUM,
    END OF T_RESB.

DATA: I_RESB TYPE TABLE OF T_RESB,
      W_RESB TYPE T_RESB.

*Estrutura de Tela-----------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK A0 WITH FRAME TITLE TEXT-A00.
SELECT-OPTIONS: S_RSNUM FOR RESB-RSNUM,
  S_WERKS FOR RESB-WERKS OBLIGATORY,
  S_UMLGO FOR RESB-UMLGO OBLIGATORY,
  S_BDTER FOR RESB-BDTER.
SELECTION-SCREEN END OF BLOCK A0.


START-OF-SELECTION.

  PERFORM SELECT_RESB.
  PERFORM SET_KZEAR.
*&---------------------------------------------------------------------*
*&      Form  SELECT_RESB
*&---------------------------------------------------------------------*
*& Pega as reservas com itens não eliminados e não flegados registro
*& final
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_RESB .

  DATA: D_LINE TYPE I.

  SELECT RSNUM FROM RESB
    INTO TABLE I_RESB
  WHERE BWART = '913'
    AND KZEAR = SPACE
    AND XLOEK = SPACE
    AND BDTER IN S_BDTER
    AND UMLGO IN S_UMLGO
    AND WERKS IN S_WERKS
    AND RSNUM IN S_RSNUM.

  SORT I_RESB BY RSNUM.
  DELETE ADJACENT DUPLICATES FROM I_RESB COMPARING RSNUM.
  DESCRIBE TABLE I_RESB LINES D_LINE.
  IF D_LINE = 0.
    MESSAGE E002.
    STOP.
  ENDIF.

ENDFORM.                    " SELECT_RESB
*&---------------------------------------------------------------------*
*&      Form  SET_KZEAR
*&---------------------------------------------------------------------*
*& Pega o resultado do form "SELECT_RESB" e chama a função
*& 'MD_SET_KZEAR_RESB'
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_KZEAR .

  LOOP AT I_RESB INTO W_RESB.
    CALL FUNCTION 'MD_SET_KZEAR_RESB'
      EXPORTING
        RSNUM = W_RESB-RSNUM
*       OMDVM =
      .
    IF SY-SUBRC = 0.
      WRITE: / 'A reserva ', W_RESB-RSNUM,' foi marcada com registro final em todos os itens.'.
      COMMIT WORK.
    ELSE.
      WRITE: / W_RESB-RSNUM, 'E'.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " SET_KZEAR
