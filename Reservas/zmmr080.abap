*&---------------------------------------------------------------------*
*& Report  ZMMR080
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zmmr080 NO STANDARD PAGE HEADING.

**********************************************************************
* Declarações Globais
**********************************************************************

*--------------------------------------------------------------------*
* Tabelas transparentes
*--------------------------------------------------------------------*
TABLES: resb.


*--------------------------------------------------------------------*
* Estruturas
*--------------------------------------------------------------------*
TYPES: BEGIN OF e_resb,
        rsnum TYPE rsnum,
        rspos TYPE rspos,
END OF e_resb.


*--------------------------------------------------------------------*
* Tabela Interna
*--------------------------------------------------------------------*
DATA: ti_resb               TYPE TABLE OF   e_resb,
      ti_res_item_change    TYPE TABLE OF   bapi2093_res_item_change,
      ti_res_item_changex   TYPE TABLE OF   bapi2093_res_item_changex,
      ti_return             TYPE TABLE OF   bapiret2,
      ti_return_aux         TYPE TABLE OF   bapiret2 WITH HEADER LINE.


*--------------------------------------------------------------------*
* Work Areas
*--------------------------------------------------------------------*
DATA: wa_resb               TYPE            e_resb,
      wa_res_item_change    TYPE            bapi2093_res_item_change,
      wa_res_item_changex   TYPE            bapi2093_res_item_changex,
      wa_return             TYPE            bapiret2.


*--------------------------------------------------------------------*
* Variaveis
*--------------------------------------------------------------------*
DATA: vg_rsnum              TYPE            rsnum,
      vg_lgort              TYPE            lgort_d.


**********************************************************************
* Tela
**********************************************************************

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_werks   FOR   resb-werks OBLIGATORY NO-EXTENSION NO INTERVALS,
                s_rsnum   FOR   resb-rsnum.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_lgort       LIKE  resb-lgort  OBLIGATORY.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK bl2.

*--------------------------------------------------------------------*

INITIALIZATION.

  s_werks-sign    = 'I'.
  s_werks-option  = 'EQ'.
  s_werks-low     = '5300'.
  APPEND s_werks.

*--------------------------------------------------------------------*

AT SELECTION-SCREEN.

  SELECT SINGLE lgort FROM t001l INTO vg_lgort WHERE werks IN s_werks AND lgort = p_lgort.

  IF sy-subrc <> 0.
    SET CURSOR FIELD 'p_lgort'.
    MESSAGE e018(zmm).
*     Informar um depósito váildo para o centro informado

  ENDIF.



**********************************************************************
* Execução do programa
**********************************************************************
START-OF-SELECTION.

  PERFORM f_selecionar_dados.

  IF lines( ti_resb ) > 0 .
    PERFORM f_change_reserva.
  ELSE.
    MESSAGE e002(zc).
*   Não existem dados para os parâmetros selecionados.
  ENDIF.

  PERFORM initialize_alv.

  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  ENDFORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_dados.

  SELECT rsnum rspos
                FROM resb
                INTO TABLE ti_resb
                WHERE rsnum IN s_rsnum
                AND werks IN s_werks
                AND rssta = 'B'
                AND xloek = space
                AND kzear = space
                AND lgort = space.

ENDFORM.                    "ENDFORM

*&---------------------------------------------------------------------*
*&      Form  f_change_reserva
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_change_reserva.

  LOOP AT ti_resb INTO wa_resb.

    CLEAR: vg_rsnum.
    FREE: ti_res_item_change,
          ti_res_item_changex.

    vg_rsnum                      = wa_resb-rsnum.
    wa_res_item_change-res_item   = wa_resb-rspos.
    wa_res_item_change-stge_loc   = p_lgort.
    APPEND wa_res_item_change TO ti_res_item_change.
    wa_res_item_changex-res_item  = wa_resb-rspos.
    wa_res_item_changex-stge_loc  = 'X'.
    APPEND wa_res_item_changex TO ti_res_item_changex.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = vg_rsnum
*       TESTRUN                   =
*       ATPCHECK                  =
      TABLES
        reservationitems_changed  = ti_res_item_change
        reservationitems_changedx = ti_res_item_changex
*       RESERVATIONITEMS_NEW      =
        return                    = ti_return_aux
*       EXTENSIONIN               =
      .

    LOOP AT ti_return_aux.
      MOVE-CORRESPONDING ti_return_aux to wa_return.
      APPEND wa_return to ti_return.
    ENDLOOP.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*       EXPORTING
*         WAIT          =
*       IMPORTING
*         RETURN        =
                .
  ENDLOOP.

  delete ti_return WHERE id = 'BAPI'.

ENDFORM.                    "f_change_reserva

**********************************************************************
* ALV
**********************************************************************

*&---------------------------------------------------------------------*
*&      Estruturas ALV
*&---------------------------------------------------------------------*
DATA alv     TYPE REF TO cl_salv_table.
DATA columns TYPE REF TO cl_salv_columns_table.
DATA column  TYPE REF TO cl_salv_column.

*&---------------------------------------------------------------------*
FORM display_alv.
*&---------------------------------------------------------------------*
  alv->display( ).
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM enable_layout_settings.
*&---------------------------------------------------------------------*
  DATA layout_settings TYPE REF TO cl_salv_layout.
  DATA layout_key      TYPE salv_s_layout_key.
  DATA: lr_events TYPE REF TO cl_salv_events_table.

  layout_settings = alv->get_layout( ).

  layout_key-report = sy-repid.
  layout_settings->set_key( layout_key ).
  layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

  lr_events = alv->get_event( ).

ENDFORM.                    "enable_layout_settings
*&---------------------------------------------------------------------*
FORM optimize_column_width.
*&---------------------------------------------------------------------*
  columns->set_optimize( ).
  columns->set_key_fixation( ).
ENDFORM.                    "OPTIMIZE_COLUMN_WIDTH
*&---------------------------------------------------------------------*
*FORM hide_client_column.
**&---------------------------------------------------------------------*
*  DATA not_found TYPE REF TO cx_salv_not_found.
*
*  TRY.
*      column = columns->get_column( 'BSTYP' ).
*      column->set_visible( if_salv_c_bool_sap=>false ).
*      column = columns->get_column( 'UNSEZ' ).
*      column->set_visible( if_salv_c_bool_sap=>false ).
*
*    CATCH cx_salv_not_found INTO not_found.
*      " error handling
*  ENDTRY.
*ENDFORM.                    " HIDE_CLIENT_COLUMN
*&---------------------------------------------------------------------*
*FORM set_custom_column.
**&---------------------------------------------------------------------*
*  DATA not_found TYPE REF TO cx_salv_not_found.
*  DATA lr_coltab TYPE REF TO cl_salv_column_table.
*  TRY.
*
**      lr_coltab ?= columns->get_column( 'EBELN' ).
**      lr_coltab->set_key( abap_true ).
*
**      Coluna OBJETO
*      column = columns->get_column( 'OBJETO' ).
*      column->set_short_text( 'OBJETO' ).
*
*    CATCH cx_salv_not_found INTO not_found.
*      " error handling
*  ENDTRY.
*ENDFORM.                    " set_custom_column.
*&---------------------------------------------------------------------*
FORM set_toolbar.
*&---------------------------------------------------------------------*
  DATA functions TYPE REF TO cl_salv_functions_list.

  functions = alv->get_functions( ).
  functions->set_all( ).
ENDFORM.                    " SET_TOOLBAR
*---------------------------------------------------------------------*
* Forms para controle do alv
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM initialize_alv.
*&---------------------------------------------------------------------*
  DATA message        TYPE REF TO cx_salv_msg.
  DATA: lr_content    TYPE REF TO cl_salv_form_element.

  TRY.
      cl_salv_table=>factory(
      IMPORTING
        r_salv_table = alv
      CHANGING
        t_table      = ti_return ).

      columns = alv->get_columns( ).

      PERFORM enable_layout_settings.
      PERFORM optimize_column_width.
*      PERFORM hide_client_column.
*      PERFORM set_custom_column.
      PERFORM set_toolbar.
      PERFORM built_header  CHANGING lr_content.
      alv->set_top_of_list( lr_content ).
      " ...
      " PERFORM setting_n.

    CATCH cx_salv_msg INTO message.
      " error handling
  ENDTRY.
ENDFORM.                    " INITIALIZE_ALV
*&---------------------------------------------------------------------*
*&      Form  built_header
*----------------------------------------------------------------------*
FORM built_header CHANGING cr_content TYPE REF TO cl_salv_form_element.
  DATA: lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text,
        l_text    TYPE string,
        l_dat1(10),
        l_dat2(10),
        i         TYPE i.

  CREATE OBJECT lr_grid.

  l_text = 'Relatório de requisições de compra' .

ENDFORM.                    " built_header
