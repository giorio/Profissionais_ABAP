*&---------------------------------------------------------------------*
*& Report  ZMMR077
*&
*&---------------------------------------------------------------------*
*&    Programa para carga da tabela ZMARAH
*&
*&    Finalidade da ZMARAH é guardar o historico da modificações de
*& status e classe ABC dos materias. A tabela irá guardar os dados por
*& anos.
*&    É obrigatório a passagem de paramentros para evitar a carga de
*& dados não usaveis.
*&---------------------------------------------------------------------*
*&    Documentação
*&
*& RDM: C124552
*& ESF: Não há - Tratado como Ordem Técnica
*& EST: MM.02.01.016 EST Carga Historico MARA e MARC
*& TES: Não há - Tratado como Ordem Técnica
*& EVI: MM.02.01.016 EVI Carga Historico MARA e MARC
*&---------------------------------------------------------------------*
*&    Dados de seleção
*&
*& WERKS -> Centro
*& MTART -> Tipo de Material
*& MSTAE -> Stat.mat.todos cent.
*& MAABC -> Código ABC
*&---------------------------------------------------------------------*

REPORT: ZMMR077
        NO STANDARD PAGE HEADING              "retira o cabeçalho padrão
        MESSAGE-ID ZC.                        "Classe de mensagem

**********************************************************************
* Tabelas
**********************************************************************
TABLES: MARA,                                 "Dados gerais de material
        MARC,                                 "Dados de centro para material
        ZMARAH.                               "Tabela para dados historicos de Status e Classe ABC

**********************************************************************
* Estruturas
**********************************************************************

TYPES: BEGIN OF E_ZMARAH,
       MANDT TYPE MANDT,                      "Mandante
       MATNR TYPE MATNR,                      "Código do Material
       GJAHR TYPE GJAHR,                      "Ano
       LFMON TYPE MONAT,                      "Periodo
       WERKS TYPE WERKS_D,                    "Centro
       MSTAE TYPE MMSTA,                      "Stat.mat.todos cent.
       MAABC TYPE MAABC,                      "Código ABC
END OF E_ZMARAH.

**********************************************************************
* Tabelas Internas
**********************************************************************

DATA: IT_ZMARAH TYPE TABLE OF E_ZMARAH WITH HEADER LINE.

**********************************************************************
* Variavel
**********************************************************************

DATA: V_ANO TYPE GJAHR,                       "Ano
      V_MES TYPE MONAT,                       "Periodo
      V_VALID TYPE GJAHR.                     "Limite superior para deleção

**********************************************************************
* Tele de Seleção
**********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_WERKS FOR MARC-WERKS NO INTERVALS
                                       NO-EXTENSION
                                       OBLIGATORY
                                       DEFAULT '5300',
                S_MTART FOR MARA-MTART OBLIGATORY,
                S_MSTAE FOR MARA-MSTAE OBLIGATORY,
                S_MAABC FOR MARC-MAABC.
SELECTION-SCREEN END OF BLOCK A1.

SELECTION-SCREEN BEGIN OF BLOCK A2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_INCL RADIOBUTTON GROUP AC1,
            P_EXCL RADIOBUTTON GROUP AC1.
SELECTION-SCREEN END OF BLOCK A2.

**********************************************************************
START-OF-SELECTION.
**********************************************************************

  IF P_INCL = 'X'.
    PERFORM F_INCLUIR.
  ENDIF.

  IF P_EXCL = 'X'.
    PERFORM F_EXCLUSAO.
  ENDIF.

**********************************************************************
* Form's
**********************************************************************

*&---------------------------------------------------------------------*
*&      Form  F_INCLUIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_INCLUIR.

  SELECT MARA~MANDT
         MARA~MATNR
         MARC~WERKS
         MARA~MSTAE
         MARC~MAABC
         INTO CORRESPONDING FIELDS OF TABLE IT_ZMARAH
         FROM MARA AS MARA
         INNER JOIN MARC AS MARC
         ON MARA~MATNR = MARC~MATNR
         WHERE MARC~WERKS IN S_WERKS
         AND MARA~MTART IN S_MTART
         AND MARA~MSTAE IN S_MSTAE.

  IF SY-SUBRC <> 0.
    MESSAGE S002(ZC).
    STOP.
  ENDIF.


  IF SY-DATUM+4(2) = '01'.
    V_ANO = SY-DATUM(4) - 1.
    V_MES = '12'.
  ELSE.
    V_ANO = SY-DATUM(4).
    V_MES = SY-DATUM+4(2) - 1.
  ENDIF.


  LOOP AT IT_ZMARAH.
    IT_ZMARAH-GJAHR = V_ANO.
    IT_ZMARAH-LFMON = V_MES.
    MODIFY IT_ZMARAH.
  ENDLOOP.

  INSERT ZMARAH FROM TABLE IT_ZMARAH.

  IF SY-SUBRC <> 0.
    MESSAGE S002(ZC).
    STOP.
  ENDIF.

ENDFORM.                    " F_INCLUIR
*&---------------------------------------------------------------------*
*&      Form  F_EXCLUSAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_EXCLUSAO.

  V_VALID = SY-DATUM(4) - 2.

  DELETE FROM ZMARAH WHERE GJAHR LT V_VALID.

ENDFORM.                    " F_EXCLUSAO
