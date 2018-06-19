*&---------------------------------------------------------------------*
*& Report  ZMMR078
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZMMR078
       NO STANDARD PAGE HEADING.


**********************************************************************
**********************************************************************

*--------------------------------------------------------------------*
* Tabelas
*--------------------------------------------------------------------*
TABLES: EBAN,
        ZMMT0055,
        ZMMTPS_CATCOT.
*--------------------------------------------------------------------*
* Estruturas
*--------------------------------------------------------------------*
TYPES: BEGIN OF E_EBAN,
        BANFN         TYPE  EBAN-BANFN,       "Nº ReqC
        BNFPO         TYPE  EBAN-BNFPO,       "ITEM RC
        MATNR         TYPE  EBAN-MATNR,       "MATERIAL
        TXZ01         TYPE  EBAN-TXZ01,       "Texto Breve - Mercadoria
        EKGRP         TYPE  EBAN-EKGRP,       "Grupo de Compradores
        AFNAM         TYPE  EBAN-AFNAM,       "Nome do requisitante
        MATKL         TYPE  EBAN-MATKL,       "GRUPO DE MERCADORIA
        FRGST         TYPE  EBAN-FRGST,       "ESTRATÉGIA DE LIBERAÇÃO NA REQUISIÇÃO DE COMPRA
        FRGZU         TYPE  EBAN-FRGZU,       "Estado de liberação
        LFDAT         TYPE  EBAN-LFDAT,       "DATA DA REMESSA
        BADAT         TYPE  EBAN-BADAT,       "Data da solicitação
        PEINH         TYPE  EBAN-PEINH,       "Unidade de preço
        MENGE         TYPE  EBAN-MENGE,       "Quantidade
        PREIS         TYPE  EBAN-PREIS,       "VALOR UNIT
        PRTTL         TYPE  EBAN-RLWRT,       "Valor Total

END OF E_EBAN.

TYPES: BEGIN OF E_HEADER,
        ZMM_CODCAT    TYPE ZMM_CODCAT,      "Categoria por Contrato
        ZMM_CATCONT   TYPE ZMM_CATCONT,     "Descrição da Categoria
        BNAME         TYPE XUBNAME,         "Gestor do contrato
        USER          TYPE SY-UNAME,        "Usúario Emissor
        DATUM         TYPE SY-DATUM,        "Data de Emissão
  END OF E_HEADER.

*--------------------------------------------------------------------*
* Tabelas Interna
*--------------------------------------------------------------------*
DATA: TI_EBAN     TYPE TABLE OF E_EBAN.

*--------------------------------------------------------------------*
* Workarea
*--------------------------------------------------------------------*
DATA: WA_EBAN     TYPE E_EBAN,
      WA_HEADER   TYPE E_HEADER.

*--------------------------------------------------------------------*
* Constantes
*--------------------------------------------------------------------*
CONSTANTS: C_R1(02)   TYPE C          VALUE 'R1',   " Grupo campo tela seleção
           C_R2(02)   TYPE C          VALUE 'R2',   " Grupo campo tela seleção
           C_R3(02)   TYPE C          VALUE 'R3'.   " Grupo campo tela seleção

INCLUDE ZMM_ALV.

**********************************************************************
**********************************************************************

*--------------------------------------------------------------------*
* Tela
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_LFDAT FOR EBAN-LFDAT,
                S_BADAT FOR EBAN-BADAT,
                S_GRUP  FOR ZMMT0055-ZMM_CODCAT         MODIF ID R1,
                S_GEST  FOR ZMMT0055-BNAME              MODIF ID R2,
                S_MATKL FOR ZMMT0055-MATKL              MODIF ID R3.

SELECTION-SCREEN END OF BLOCK BL1.

SELECTION-SCREEN BEGIN OF BLOCK BL2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_GRUP  RADIOBUTTON GROUP RG1 USER-COMMAND RADIO,
            P_GEST  RADIOBUTTON GROUP RG1 DEFAULT 'X',
            P_MATKL RADIOBUTTON GROUP RG1.
SELECTION-SCREEN END OF BLOCK BL2.


*--------------------------------------------------------------------*
* Inicialização
*--------------------------------------------------------------------*
INITIALIZATION.

  S_GEST-SIGN     = 'I'.
  S_GEST-OPTION   = 'EQ'.
  S_GEST-LOW      = SY-UNAME.
  APPEND S_GEST.

  S_BADAT-SIGN    = 'I'.
  S_BADAT-OPTION  = 'GE'.
  S_BADAT-LOW     = SY-DATUM.
  APPEND S_BADAT.

*--------------------------------------------------------------------*
* At Selection-Screen
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

* Conforme opção de processamento, desabilita campos da tela.
  IF P_GRUP IS NOT INITIAL.
    PERFORM F_CONTROLA_TELA USING C_R1.
  ENDIF.

  IF P_GEST IS NOT INITIAL.
    PERFORM F_CONTROLA_TELA USING C_R2.
  ENDIF.

  IF P_MATKL IS NOT INITIAL.
    PERFORM F_CONTROLA_TELA USING C_R3.
  ENDIF.

*--------------------------------------------------------------------*
* Processamento
*--------------------------------------------------------------------*
START-OF-SELECTION.

*Busca o grupo de mercadoria caso não seja informado.
  IF P_GEST IS INITIAL.
    CLEAR: S_GEST[].
  ENDIF.

  IF P_MATKL IS INITIAL.
    PERFORM F_BUSCAR_MATKL.
  ENDIF.

* Busca os dados

  IF S_MATKL IS NOT INITIAL.
    PERFORM F_BUSCAR_REQC.
  ENDIF.

  PERFORM F_MONTAR_CABECALHO.

  PERFORM INITIALIZE_ALV.

  PERFORM DISPLAY_ALV.


*&---------------------------------------------------------------------*
*&      Form  f_controla_tela
*&---------------------------------------------------------------------*
*     Mostra e oculta os campos  da tela de seleção conforme opção
* de processamento escolhido
*----------------------------------------------------------------------*
* --> p_campo    Grupo que deve se habilitado
*----------------------------------------------------------------------*
FORM F_CONTROLA_TELA USING P_CAMPO.

* Dá o loop em cada objeto da tela.
  LOOP AT SCREEN.

*   Condicão para ativar ou desativar, Mostra ou não mostra na tela .
    IF P_CAMPO IS NOT INITIAL.
      IF SCREEN-GROUP1 NE P_CAMPO AND
       NOT SCREEN-GROUP1 IS INITIAL.
        SCREEN-ACTIVE = 0.
      ELSE.
        SCREEN-ACTIVE = 1.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.                    " f_controla_tela
*&---------------------------------------------------------------------*
*&      Form  F_BUSCAR_MATKL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_BUSCAR_MATKL .

  IF P_GEST IS NOT INITIAL.
    SELECT *  FROM ZMMT0055
              WHERE BNAME IN S_GEST.
      S_MATKL-OPTION  = 'EQ'.
      S_MATKL-SIGN    = 'I'.
      S_MATKL-LOW     = ZMMT0055-MATKL.
      APPEND S_MATKL.
    ENDSELECT.

    IF SY-SUBRC <> 0.
      MESSAGE ID 'ZC'
              TYPE 'E'
              NUMBER '002'.
      STOP.
    ENDIF.

  ELSEIF P_GRUP IS NOT INITIAL.
    SELECT *  FROM ZMMT0055
              WHERE ZMM_CODCAT IN S_GRUP.
      S_MATKL-OPTION  = 'EQ'.
      S_MATKL-SIGN    = 'I'.
      S_MATKL-LOW     = ZMMT0055-MATKL.
      APPEND S_MATKL.
    ENDSELECT.

    IF SY-SUBRC <> 0.
      MESSAGE ID 'ZC'
              TYPE 'E'
              NUMBER '002'.
      STOP.
    ENDIF.

  ENDIF.


ENDFORM.                    " F_BUSCAR_MATKL
*&---------------------------------------------------------------------*
*&      Form  F_BUSCAR_REQC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_BUSCAR_REQC .

  IF S_MATKL IS NOT INITIAL.
    SELECT  BANFN
            BNFPO
            MATNR
            TXZ01
            EKGRP
            AFNAM
            MATKL
            FRGST
            FRGZU
            LFDAT
            BADAT
            PEINH
            MENGE
            PREIS
            FROM EBAN
            INTO TABLE TI_EBAN
            WHERE MATKL IN S_MATKL
            AND EBELN = SPACE
            AND LOEKZ = SPACE
            AND (
                  LFDAT IN S_LFDAT
                  OR BADAT IN S_BADAT
                )
      .

    IF SY-SUBRC <> 0.
      MESSAGE ID 'ZC'
              TYPE 'E'
              NUMBER '002'.
      STOP.
    ENDIF.

  ENDIF.

  LOOP AT TI_EBAN INTO WA_EBAN.
    WA_EBAN-PRTTL = ( WA_EBAN-MENGE * WA_EBAN-PREIS ) / WA_EBAN-PEINH.
    MODIFY TI_EBAN FROM WA_EBAN TRANSPORTING PRTTL.
  ENDLOOP.

ENDFORM.                    " F_BUSCAR_REQC
*&---------------------------------------------------------------------*
*&      Form  F_MONTAR_CABECALHO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_MONTAR_CABECALHO .

  IF S_GRUP IS NOT INITIAL.
    SELECT *  FROM ZMMTPS_CATCOT
              WHERE ZMM_CODCAT = S_GRUP-LOW.
      WA_HEADER-ZMM_CATCONT = ZMMTPS_CATCOT-ZMM_CATCONT.
    ENDSELECT.
    SELECT *  FROM ZMMT0055
              WHERE ZMM_CODCAT = S_GRUP-LOW.
      WA_HEADER-BNAME = ZMMT0055-BNAME.
    ENDSELECT.
    WA_HEADER-ZMM_CODCAT  = S_GRUP-LOW.
    WA_HEADER-USER        = SY-UNAME.
    WA_HEADER-DATUM       = SY-DATUM.
  ENDIF.



ENDFORM.                    " F_MONTAR_CABECALHO


*---------------------------------------------------------------------*
* Forms para controle do alv
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM INITIALIZE_ALV.
*&---------------------------------------------------------------------*
  DATA MESSAGE        TYPE REF TO CX_SALV_MSG.
  DATA: LR_CONTENT    TYPE REF TO CL_SALV_FORM_ELEMENT.

  TRY.
      CL_SALV_TABLE=>FACTORY(
      IMPORTING
        R_SALV_TABLE = ALV
      CHANGING
        T_TABLE      = TI_EBAN ).

      COLUMNS = ALV->GET_COLUMNS( ).

      PERFORM ENABLE_LAYOUT_SETTINGS.
      PERFORM OPTIMIZE_COLUMN_WIDTH.
      PERFORM HIDE_CLIENT_COLUMN.
      PERFORM SET_CUSTOM_COLUMN.
      PERFORM SET_TOOLBAR.
      PERFORM BUILT_HEADER  CHANGING LR_CONTENT.
      ALV->SET_TOP_OF_LIST( LR_CONTENT ).
      " ...
      " PERFORM setting_n.

    CATCH CX_SALV_MSG INTO MESSAGE.
      " error handling
  ENDTRY.
ENDFORM.                    " INITIALIZE_ALV

*&---------------------------------------------------------------------*
*&      Form  built_header
*----------------------------------------------------------------------*
FORM BUILT_HEADER CHANGING CR_CONTENT TYPE REF TO CL_SALV_FORM_ELEMENT.
  DATA: LR_GRID   TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
        LR_GRID_1 TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
        LR_LABEL  TYPE REF TO CL_SALV_FORM_LABEL,
        LR_TEXT   TYPE REF TO CL_SALV_FORM_TEXT,
        L_TEXT    TYPE STRING,
        L_DAT1(10),
        L_DAT2(10),
        I         TYPE I.

  CREATE OBJECT LR_GRID.

  L_TEXT = 'Relatório de requisições de compra' .

  LR_GRID->CREATE_HEADER_INFORMATION(
    ROW    = 1
    COLUMN = 1
    TEXT    = L_TEXT
    TOOLTIP = L_TEXT ).

  LR_GRID->ADD_ROW( ).

  LR_GRID_1 = LR_GRID->CREATE_GRID(
                ROW    = 3
                COLUMN = 1 ).

  LR_LABEL = LR_GRID_1->CREATE_LABEL(
    ROW     = 1
    COLUMN  = 1
    TEXT    = 'Categoria:'
    TOOLTIP = 'Categoria' ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_TEXT = LR_GRID_1->CREATE_TEXT(
    ROW     = 1
    COLUMN  = 2
    TEXT    = WA_HEADER-ZMM_CODCAT
  TOOLTIP = 'Categoria' ).

  LR_LABEL = LR_GRID_1->CREATE_LABEL(
    ROW     = 2
    COLUMN  = 1
    TEXT    = 'Descrição da Categoria:'
    TOOLTIP = 'Descrição da Categoria' ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_TEXT = LR_GRID_1->CREATE_TEXT(
   ROW     = 2
   COLUMN  = 2
   TEXT    = WA_HEADER-ZMM_CATCONT
   TOOLTIP = 'Descrição da Categoria' ).

  LR_LABEL = LR_GRID_1->CREATE_LABEL(
    ROW     = 3
    COLUMN  = 1
    TEXT    = 'Gestor da Categoria:'
    TOOLTIP = 'Gestor da Categoria' ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_TEXT = LR_GRID_1->CREATE_TEXT(
   ROW     = 3
   COLUMN  = 2
   TEXT    = WA_HEADER-BNAME
   TOOLTIP = 'Gestor da Categoria' ).

  LR_LABEL = LR_GRID_1->CREATE_LABEL(
    ROW     = 4
    COLUMN  = 1
    TEXT    = 'Emissor:'
    TOOLTIP = 'Emissor' ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_TEXT = LR_GRID_1->CREATE_TEXT(
    ROW     = 4
    COLUMN  = 2
    TEXT    = WA_HEADER-USER
    TOOLTIP = 'Emissor' ).

  LR_LABEL = LR_GRID_1->CREATE_LABEL(
    ROW     = 5
    COLUMN  = 1
    TEXT    = 'Data da Emissão:'
    TOOLTIP = 'Data da Emissão' ).
  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
  LR_TEXT = LR_GRID_1->CREATE_TEXT(
    ROW     = 5
    COLUMN  = 2
    TEXT    = WA_HEADER-DATUM
    TOOLTIP = 'Data da Emissão' ).

  CR_CONTENT = LR_GRID.
ENDFORM.                    " built_header
