*&---------------------------------------------------------------------*
*& Report  ZMMR076
*& Flegar Registro Final em Massa
*&---------------------------------------------------------------------*
*& Desenvolvedor: Gustavo Di Iório - E208747
*& Versão: 1
*& Desenvolvido em: 27/12/2017
*& Mudança Original: C123398
*&---------------------------------------------------------------------*
*& Alterações
*& Mudança:
*& Data:
*& Desenvolvedor:
*&---------------------------------------------------------------------*

REPORT ZMMR076
  NO STANDARD PAGE HEADING.                  "Não mostra o cabeçalho padrão SAP

*Tabelas---------------------------------------------------------------*
TABLES:
  resb.                                      "itens da reserva

*Estrutura
TYPES: BEGIN OF T_resb,
  rsnum type resb-rsnum,
    END OF t_resb.

DATA: i_resb TYPE TABLE OF t_resb,
      w_resb TYPE T_resb.

*Estrutura de Tela-----------------------------------------------------*
SELECT-OPTIONS: s_rsnum for resb-rsnum,
  S_MATNR for resb-MATNR,
  S_WERKS for resb-WERKS OBLIGATORY,
  S_LGORT for resb-LGORT OBLIGATORY,
" S_BWART for resb-BWART OBLIGATORY,         "Previsão de melhorias futuras
  S_BDTER for resb-BDTER.


START-OF-SELECTION.

  PERFORM select_resb.
  PERFORM set_kzear.
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
    into table i_resb
  WHERE BWART = 913
    AND KZEAR = space
    AND XLOEK = space
    AND MATNR in S_MATNR
    AND BDTER in S_BDTER
    AND LGORT in S_LGORT
    AND WERKS in S_WERKS
    AND RSNUM IN S_RSNUM.

  SORT i_resb by rsnum.
  DELETE ADJACENT DUPLICATES FROM i_resb COMPARING rsnum.
  DESCRIBE TABLE i_resb LINES D_LINE.
  IF D_LINE = 0.
    WRITE / 'Não foram localizadas reservas em aberto que atendam os parametros informados'.
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

  LOOP AT i_resb INTO w_resb.
    CALL FUNCTION 'MD_SET_KZEAR_RESB'
      EXPORTING
        RSNUM = w_resb-rsnum
*       OMDVM =
      .
    IF sy-subrc = 0.
      WRITE: / w_resb-RSNUM, 'S'.
      COMMIT WORK.
    ELSE.
      WRITE: / w_resb-RSNUM, 'E'.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " SET_KZEAR
