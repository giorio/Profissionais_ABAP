*&---------------------------------------------------------------------*
*& Report  ZLBRISSALI
*&
*&    Programa criado para gerar um relatório de alíquotas validas para
*& uma determinada cidade (domicilio Fiscal)e um material.
*&---------------------------------------------------------------------*
*& ESF: MM.01.06.009 ESF  J1BTAX - Relatorio de ISS
*& Responsaveis pela ESF: CR/TB - Valquiria Mendes (c056327)
*&                        TI/SI - Juliane Mendonça (e216990)
*&
*& EST: MM.01.06.009 EST J1BTAX - Relatorio de ISS
*& Responsavel pela EST:  TI/SI - Gustavo Di Iório (e208747)
*&
*& Desenvolvido por: Gustavo Di Iório (e208747)
*& Desenvolvido em: 08/08/2018.
*& RDM original: C125071
*& Correção Original: 8000012290
*&---------------------------------------------------------------------*
*& Manutenções:
*&--------+-----------+---------+-----------+--------------------------*
*& Data   |  Autor    | RDM     | Correção  | Motivo
*&--------+-----------+---------+-----------+--------------------------*
*&
*&
*&
*&
*&---------------------------------------------------------------------*

REPORT zlbrissali
        NO STANDARD PAGE HEADING.
**********************************************************************

*--------------------------------------------------------------------*
*Tabelas
*--------------------------------------------------------------------*
TABLES: j_1btxjurt,
        j_1btxiss,
        mara,
        marc,
        zlbt_isslei.

*--------------------------------------------------------------------*
* Estruturas
*--------------------------------------------------------------------*
TYPES: BEGIN OF e_iss,
        cidade      TYPE j_1btxjurt-text,
        domfis      TYPE j_1btxjurt-taxjurcode,
        matnr       TYPE marc-matnr,
        codncm      TYPE zlbt_isslei-steuc,
        des116      TYPE zlbt_isslei-deslei,
        base        TYPE j_1btxiss-base,
        tximp       TYPE j_1btxiss-rate,
  END OF e_iss.

TYPES: BEGIN OF e_city,
        domfis      TYPE j_1btxjurt-taxjurcode,
        cidade      TYPE j_1btxjurt-text,
  END OF e_city.

TYPES: BEGIN OF e_marc,
         matnr     TYPE marc-matnr,
         steuc     TYPE marc-steuc,
   END OF e_marc.

TYPES: BEGIN OF e_matnr,
        matnr     TYPE mara-matnr,
  END OF e_matnr.

*--------------------------------------------------------------------*
* Tabelas Interna
*--------------------------------------------------------------------*
DATA: ti_iss        TYPE TABLE OF e_iss,
      ti_116        TYPE TABLE OF zlbt_isslei,
      ti_city       TYPE TABLE OF e_city,
      ti_marc       TYPE TABLE OF e_marc,
      ti_matnr      TYPE TABLE OF e_matnr.

*--------------------------------------------------------------------*
* Work Area
*--------------------------------------------------------------------*
DATA: wa_iss        TYPE e_iss,
      wa_116        TYPE zlbt_isslei,
      wa_city       TYPE e_city,
      wa_marc       TYPE e_marc,
      wa_matnr      TYPE e_matnr.

*--------------------------------------------------------------------*
* Variaveis
*--------------------------------------------------------------------*
DATA: v_data        TYPE j_1btxdatf,
      v_chdat(8)    TYPE c,
      v_houtput(8)  TYPE n.

*********************************************************************

*--------------------------------------------------------------------*
* Tela de Seleção
*--------------------------------------------------------------------*
SELECTION-SCREEN SKIP 2.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_domfis  FOR j_1btxjurt-taxjurcode,
                s_matnr   FOR marc-matnr.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK bl1.

**********************************************************************

*--------------------------------------------------------------------*
* Eventos
*--------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF s_domfis IS INITIAL.
    SET CURSOR FIELD 's_domfis'.

    MESSAGE e002(zlb03).
*   Deverá informar um código de Domicilio Fiscal validos.
  ENDIF.

START-OF-SELECTION.

  IF s_matnr IS NOT INITIAL.
    PERFORM f_validar_matnr.
  ELSE.
    SELECT * FROM mara
              WHERE mtart = 'DIEN'.

      s_matnr-sign    = 'I'.
      s_matnr-option  = 'EQ'.
      s_matnr-low     = mara-matnr.
      APPEND s_matnr.
    ENDSELECT.
  ENDIF.

  PERFORM f_conveter_data.
  PERFORM f_select_cidade.
  PERFORM f_select_dados.

  IF ti_iss IS NOT INITIAL.

    PERFORM initialize_alv.
    PERFORM display_alv.

  ELSE.
    MESSAGE e002(zc).
*   Não existem dados para os parâmetros selecionados.

  ENDIF.

**********************************************************************

*--------------------------------------------------------------------*
* Form's
*--------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_VALIDAR_MATNR
*&---------------------------------------------------------------------*
*     Irá verificar os MATNR, caso tenha algum que não seja serviço,
* MTART = 'DIEN', ele será removido.
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_validar_matnr .

*--------------------------------------------------------------------*
* Ranges
*--------------------------------------------------------------------*
  DATA: rs_matnr    LIKE LINE  OF s_matnr.

  SELECT matnr FROM mara
            INTO wa_matnr
            WHERE  matnr IN s_matnr
            AND mtart = 'DIEN'.
    APPEND wa_matnr TO ti_matnr.
  ENDSELECT.

  FREE: s_matnr[].
  CLEAR: s_matnr.

  IF s_matnr IS INITIAL.
    MESSAGE e002(zc).
*   Não existem dados para os parâmetros selecionados.

  ENDIF.

  LOOP AT ti_matnr INTO wa_matnr.

    rs_matnr-sign   = 'I'.
    rs_matnr-option = 'EQ'.
    rs_matnr-low    = wa_matnr-matnr.
    APPEND rs_matnr TO s_matnr.
    CLEAR rs_matnr.

  ENDLOOP.

**   Vai remover os MATNR que não são DIEN.
*  DELETE s_matnr WHERE low NOT IN rg_matnr.


ENDFORM.                    " F_VALIDAR_MATNR
*&---------------------------------------------------------------------*
*&      Form  F_CONVETER_DATA
*&---------------------------------------------------------------------*
*   Converte a variavel de sistema sy_datum para o formato de data invertida
* usado nos campos de validade.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_conveter_data .

  MOVE sy-datum TO v_chdat.
  v_houtput = '99999999' - v_chdat.
  v_data = v_houtput.

ENDFORM.                    " F_CONVETER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_CIDADE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_select_cidade .

  SELECT taxjurcode text
                        FROM j_1btxjurt
                        INTO wa_city
                        WHERE taxjurcode IN s_domfis.

    IF sy-subrc = 0.
      APPEND wa_city TO ti_city.
    ENDIF.

  ENDSELECT.


ENDFORM.                    " F_SELECT_CIDADE
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_select_dados .

*   Pega o código da Lei 116/03 de cada material informado
  SELECT matnr steuc FROM marc
                      INTO wa_marc
                      WHERE matnr IN s_matnr.
    IF sy-subrc = 0.
      APPEND wa_marc TO ti_marc.
    ENDIF.

  ENDSELECT.

  SORT ti_marc BY matnr.
  DELETE ADJACENT DUPLICATES FROM ti_marc.

*   Pega os dados da lei 116/2003 referente aos códigos obtidos no 1 select,
* tabela interna 'ti_marc'.
  IF ti_marc[] IS NOT INITIAL.

    SELECT * FROM zlbt_isslei
            INTO wa_116
      FOR ALL ENTRIES IN ti_marc
            WHERE steuc = ti_marc-steuc.

      IF sy-subrc = 0.
        APPEND wa_116 TO ti_116.
      ELSEIF sy-subrc <> 0.
        MESSAGE e000(zlb03).
      ENDIF.

    ENDSELECT.

  ENDIF.


*   Executa um loop dentro do s_matnr e seleciona os dados de iss
* da tabela, por se tratar de chave dinamica deverá executar um texte
* nos 3 campos possiveis, são eles value, value2 e value3.
  LOOP AT s_matnr.

    SELECT * FROM j_1btxiss
            WHERE country = 'BR'
            AND taxjurcode IN s_domfis
            AND ( value = s_matnr-low
                    OR value2 = s_matnr-low
                    OR value3 = s_matnr-low
                )
            AND validto <= v_data
            AND validfrom >= v_data.

      IF sy-subrc = 0.
        wa_iss-domfis = j_1btxiss-taxjurcode.
        wa_iss-matnr  = s_matnr-low.
        wa_iss-base   = j_1btxiss-base.
        wa_iss-tximp  = j_1btxiss-rate.
        APPEND wa_iss TO ti_iss.
      ELSE.
        MESSAGE e001(zlb03).
      ENDIF.
      CLEAR: wa_iss.

    ENDSELECT.

  ENDLOOP.



*Unificar os dados dos 3 selects.
  LOOP AT ti_iss INTO wa_iss.
*   Unifica o nome da cidade com resultado obtido das aliquotas.
    READ TABLE ti_city INTO wa_city WITH KEY domfis = wa_iss-domfis.

    IF sy-subrc = 0.
      wa_iss-cidade = wa_city-cidade.
      MODIFY ti_iss FROM wa_iss.
    ENDIF.

    READ TABLE ti_marc INTO wa_marc WITH KEY matnr = wa_iss-matnr.

    IF sy-subrc = 0.
      wa_iss-codncm  = wa_marc-steuc.
      MODIFY ti_iss  FROM wa_iss.
    ENDIF.

*   Unifica os dados de ISS obtido no 2º select com resultado obtido no 1º.
    READ TABLE ti_116 INTO wa_116 WITH KEY steuc = wa_iss-codncm.

    IF sy-subrc = 0.
      wa_iss-des116  = wa_116-deslei.
      MODIFY ti_iss FROM wa_iss.
    ENDIF.


  ENDLOOP.

*   Organiza os dados para remoção de campos duplicados caso haja.
  SORT ti_iss BY cidade matnr tximp.
  DELETE ADJACENT DUPLICATES FROM ti_iss.

ENDFORM.                    " F_SELECT_DADOS

**********************************************************************

*--------------------------------------------------------------------*
* ALV
*--------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Estruturas ALV
*&---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION DEFERRED.
DATA alv     TYPE REF TO cl_salv_table.
DATA columns TYPE REF TO cl_salv_columns_table.
DATA column  TYPE REF TO cl_salv_column.
DATA: gr_events TYPE REF TO lcl_handle_events.
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
* §5.1 define a local class for handling events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_before_salv_function FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_after_salv_function FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
*    perform show_function_info using e_salv_function text-i08.
  ENDMETHOD.                    "on_user_command

  METHOD on_before_salv_function.
*    perform show_function_info using e_salv_function text-i09.
  ENDMETHOD.                    "on_before_salv_function

  METHOD on_after_salv_function.
*    perform show_function_info using e_salv_function text-i10.
  ENDMETHOD.                    "on_after_salv_function

  METHOD on_double_click.
*    PERFORM trata_duplo_clique USING row column.
  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.
*    perform show_cell_info using row column text-i06.
  ENDMETHOD.                    "on_single_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


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
*  IF p_layout IS NOT INITIAL.
*    layout_settings->set_initial_layout( p_layout ).
*  ENDIF.
  layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

  lr_events = alv->get_event( ).

  CREATE OBJECT gr_events.

  SET HANDLER gr_events->on_user_command FOR lr_events.

  SET HANDLER gr_events->on_before_salv_function FOR lr_events.

  SET HANDLER gr_events->on_after_salv_function FOR lr_events.

  SET HANDLER gr_events->on_double_click FOR lr_events.

  SET HANDLER gr_events->on_link_click FOR lr_events.

ENDFORM.                    "enable_layout_settings

*&---------------------------------------------------------------------*
FORM optimize_column_width.
*&---------------------------------------------------------------------*
  columns->set_optimize( ).
  columns->set_key_fixation( ).
ENDFORM.                    "OPTIMIZE_COLUMN_WIDTH

*&---------------------------------------------------------------------*
FORM hide_client_column.
*&---------------------------------------------------------------------*
  DATA not_found TYPE REF TO cx_salv_not_found.

  TRY.
      column = columns->get_column( 'BSTYP' ).
      column->set_visible( if_salv_c_bool_sap=>false ).
      column = columns->get_column( 'UNSEZ' ).
      column->set_visible( if_salv_c_bool_sap=>false ).

    CATCH cx_salv_not_found INTO not_found.
      " error handling
  ENDTRY.
ENDFORM.                    " HIDE_CLIENT_COLUMN
*&---------------------------------------------------------------------*
FORM set_custom_column.
*&---------------------------------------------------------------------*
  DATA not_found TYPE REF TO cx_salv_not_found.
  DATA lr_coltab TYPE REF TO cl_salv_column_table.
  TRY.

*      lr_coltab ?= columns->get_column( 'EBELN' ).
*      lr_coltab->set_key( abap_true ).

*      Coluna OBJETO
      column = columns->get_column( 'OBJETO' ).
      column->set_short_text( 'OBJETO' ).

    CATCH cx_salv_not_found INTO not_found.
      " error handling
  ENDTRY.
ENDFORM.                    " set_custom_column.
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
        t_table      = ti_iss ).

      columns = alv->get_columns( ).

      PERFORM enable_layout_settings.
      PERFORM optimize_column_width.
      PERFORM hide_client_column.
      PERFORM set_custom_column.
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

  l_text = 'Relatório ISS' .

  lr_grid->create_header_information(
    row    = 1
    column = 1
    text    = l_text
    tooltip = l_text ).

  lr_grid->add_row( ).

  lr_grid_1 = lr_grid->create_grid(
                row    = 3
                column = 1 ).

  lr_label = lr_grid_1->create_label(
    row     = 1
    column  = 1
    text    = ''
    tooltip = 'X' ).
  lr_label->set_label_for( lr_text ).
  lr_text = lr_grid_1->create_text(
    row     = 1
    column  = 2
    text    = ''
  tooltip = 'X' ).


  cr_content = lr_grid.
ENDFORM.                    "BUILT_HEADER
