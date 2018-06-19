*&---------------------------------------------------------------------*
*&  Include           ZMM_ALV
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Estruturas ALV
*&---------------------------------------------------------------------*
CLASS LCL_HANDLE_EVENTS DEFINITION DEFERRED.
DATA ALV     TYPE REF TO CL_SALV_TABLE.
DATA COLUMNS TYPE REF TO CL_SALV_COLUMNS_TABLE.
DATA COLUMN  TYPE REF TO CL_SALV_COLUMN.
DATA: GR_EVENTS TYPE REF TO LCL_HANDLE_EVENTS.
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
* §5.1 define a local class for handling events of cl_salv_table
*---------------------------------------------------------------------*
CLASS LCL_HANDLE_EVENTS DEFINITION.
  PUBLIC SECTION.
    METHODS:
      ON_USER_COMMAND FOR EVENT ADDED_FUNCTION OF CL_SALV_EVENTS
        IMPORTING E_SALV_FUNCTION,

      ON_BEFORE_SALV_FUNCTION FOR EVENT BEFORE_SALV_FUNCTION OF CL_SALV_EVENTS
        IMPORTING E_SALV_FUNCTION,

      ON_AFTER_SALV_FUNCTION FOR EVENT AFTER_SALV_FUNCTION OF CL_SALV_EVENTS
        IMPORTING E_SALV_FUNCTION,

      ON_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_SALV_EVENTS_TABLE
        IMPORTING ROW COLUMN,

      ON_LINK_CLICK FOR EVENT LINK_CLICK OF CL_SALV_EVENTS_TABLE
        IMPORTING ROW COLUMN.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS LCL_HANDLE_EVENTS IMPLEMENTATION.
  METHOD ON_USER_COMMAND.
*    perform show_function_info using e_salv_function text-i08.
  ENDMETHOD.                    "on_user_command

  METHOD ON_BEFORE_SALV_FUNCTION.
*    perform show_function_info using e_salv_function text-i09.
  ENDMETHOD.                    "on_before_salv_function

  METHOD ON_AFTER_SALV_FUNCTION.
*    perform show_function_info using e_salv_function text-i10.
  ENDMETHOD.                    "on_after_salv_function

  METHOD ON_DOUBLE_CLICK.
*    PERFORM trata_duplo_clique USING row column.
  ENDMETHOD.                    "on_double_click

  METHOD ON_LINK_CLICK.
*    perform show_cell_info using row column text-i06.
  ENDMETHOD.                    "on_single_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


*&---------------------------------------------------------------------*
FORM DISPLAY_ALV.
*&---------------------------------------------------------------------*
  ALV->DISPLAY( ).
ENDFORM.                    " DISPLAY_ALV

*&---------------------------------------------------------------------*
FORM ENABLE_LAYOUT_SETTINGS.
*&---------------------------------------------------------------------*
  DATA LAYOUT_SETTINGS TYPE REF TO CL_SALV_LAYOUT.
  DATA LAYOUT_KEY      TYPE SALV_S_LAYOUT_KEY.
  DATA: LR_EVENTS TYPE REF TO CL_SALV_EVENTS_TABLE.

  LAYOUT_SETTINGS = ALV->GET_LAYOUT( ).

  LAYOUT_KEY-REPORT = SY-REPID.
  LAYOUT_SETTINGS->SET_KEY( LAYOUT_KEY ).
*  IF p_layout IS NOT INITIAL.
*    layout_settings->set_initial_layout( p_layout ).
*  ENDIF.
  LAYOUT_SETTINGS->SET_SAVE_RESTRICTION( IF_SALV_C_LAYOUT=>RESTRICT_NONE ).

  LR_EVENTS = ALV->GET_EVENT( ).

  CREATE OBJECT GR_EVENTS.

  SET HANDLER GR_EVENTS->ON_USER_COMMAND FOR LR_EVENTS.

  SET HANDLER GR_EVENTS->ON_BEFORE_SALV_FUNCTION FOR LR_EVENTS.

  SET HANDLER GR_EVENTS->ON_AFTER_SALV_FUNCTION FOR LR_EVENTS.

  SET HANDLER GR_EVENTS->ON_DOUBLE_CLICK FOR LR_EVENTS.

  SET HANDLER GR_EVENTS->ON_LINK_CLICK FOR LR_EVENTS.

ENDFORM.                    "enable_layout_settings

*&---------------------------------------------------------------------*
FORM OPTIMIZE_COLUMN_WIDTH.
*&---------------------------------------------------------------------*
  COLUMNS->SET_OPTIMIZE( ).
  COLUMNS->SET_KEY_FIXATION( ).
ENDFORM.                    "OPTIMIZE_COLUMN_WIDTH

*&---------------------------------------------------------------------*
FORM HIDE_CLIENT_COLUMN.
*&---------------------------------------------------------------------*
  DATA NOT_FOUND TYPE REF TO CX_SALV_NOT_FOUND.

  TRY.
      COLUMN = COLUMNS->GET_COLUMN( 'BSTYP' ).
      COLUMN->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>FALSE ).
      COLUMN = COLUMNS->GET_COLUMN( 'UNSEZ' ).
      COLUMN->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>FALSE ).

    CATCH CX_SALV_NOT_FOUND INTO NOT_FOUND.
      " error handling
  ENDTRY.
ENDFORM.                    " HIDE_CLIENT_COLUMN
*&---------------------------------------------------------------------*
FORM SET_CUSTOM_COLUMN.
*&---------------------------------------------------------------------*
  DATA NOT_FOUND TYPE REF TO CX_SALV_NOT_FOUND.
  DATA LR_COLTAB TYPE REF TO CL_SALV_COLUMN_TABLE.
  TRY.

*      lr_coltab ?= columns->get_column( 'EBELN' ).
*      lr_coltab->set_key( abap_true ).

*      Coluna OBJETO
      COLUMN = COLUMNS->GET_COLUMN( 'OBJETO' ).
      COLUMN->SET_SHORT_TEXT( 'OBJETO' ).

    CATCH CX_SALV_NOT_FOUND INTO NOT_FOUND.
      " error handling
  ENDTRY.
ENDFORM.                    " set_custom_column.
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR.
*&---------------------------------------------------------------------*
  DATA FUNCTIONS TYPE REF TO CL_SALV_FUNCTIONS_LIST.

  FUNCTIONS = ALV->GET_FUNCTIONS( ).
  FUNCTIONS->SET_ALL( ).
ENDFORM.                    " SET_TOOLBAR

**&---------------------------------------------------------------------*
**&      Form  built_header
**&---------------------------------------------------------------------*
**& Implementar esse form direto na função principal.
**&---------------------------------------------------------------------*
**----------------------------------------------------------------------*
*FORM BUILT_HEADER CHANGING CR_CONTENT TYPE REF TO CL_SALV_FORM_ELEMENT.
*  DATA: LR_GRID   TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
*        LR_GRID_1 TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
*        LR_LABEL  TYPE REF TO CL_SALV_FORM_LABEL,
*        LR_TEXT   TYPE REF TO CL_SALV_FORM_TEXT,
*        L_TEXT    TYPE STRING,
*        L_DAT1(10),
*        L_DAT2(10),
*        I         TYPE I.
*
*  CREATE OBJECT LR_GRID.
*
*  L_TEXT = 'Relatório de requisições de compra' .
*
*  LR_GRID->CREATE_HEADER_INFORMATION(
*    ROW    = 1
*    COLUMN = 1
*    TEXT    = L_TEXT
*    TOOLTIP = L_TEXT ).
*
*  LR_GRID->ADD_ROW( ).
*
*  LR_GRID_1 = LR_GRID->CREATE_GRID(
*                ROW    = 3
*                COLUMN = 1 ).
*
*  LR_LABEL = LR_GRID_1->CREATE_LABEL(
*    ROW     = 1
*    COLUMN  = 1
*    TEXT    = 'Categoria:'
*    TOOLTIP = 'Categoria' ).
*  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
*  LR_TEXT = LR_GRID_1->CREATE_TEXT(
*    ROW     = 1
*    COLUMN  = 2
*    TEXT    = WA_HEADER-ZMM_CODCAT
*  TOOLTIP = 'Categoria' ).
*
*  LR_LABEL = LR_GRID_1->CREATE_LABEL(
*    ROW     = 2
*    COLUMN  = 1
*    TEXT    = 'Descrição da Categoria:'
*    TOOLTIP = 'Descrição da Categoria' ).
*  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
*  LR_TEXT = LR_GRID_1->CREATE_TEXT(
*   ROW     = 2
*   COLUMN  = 2
*   TEXT    = WA_HEADER-ZMM_CATCONT
*   TOOLTIP = 'Descrição da Categoria' ).
*
*  LR_LABEL = LR_GRID_1->CREATE_LABEL(
*    ROW     = 3
*    COLUMN  = 1
*    TEXT    = 'Gestor da Categoria:'
*    TOOLTIP = 'Gestor da Categoria' ).
*  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
*  LR_TEXT = LR_GRID_1->CREATE_TEXT(
*   ROW     = 3
*   COLUMN  = 2
*   TEXT    = WA_HEADER-BNAME
*   TOOLTIP = 'Gestor da Categoria' ).
*
*  LR_LABEL = LR_GRID_1->CREATE_LABEL(
*    ROW     = 4
*    COLUMN  = 1
*    TEXT    = 'Emissor:'
*    TOOLTIP = 'Emissor' ).
*  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
*  LR_TEXT = LR_GRID_1->CREATE_TEXT(
*    ROW     = 4
*    COLUMN  = 2
*    TEXT    = WA_HEADER-USER
*    TOOLTIP = 'Emissor' ).
*
*  LR_LABEL = LR_GRID_1->CREATE_LABEL(
*    ROW     = 5
*    COLUMN  = 1
*    TEXT    = 'Data da Emissão:'
*    TOOLTIP = 'Data da Emissão' ).
*  LR_LABEL->SET_LABEL_FOR( LR_TEXT ).
*  LR_TEXT = LR_GRID_1->CREATE_TEXT(
*    ROW     = 5
*    COLUMN  = 2
*    TEXT    = WA_HEADER-DATUM
*    TOOLTIP = 'Data da Emissão' ).
*
*  CR_CONTENT = LR_GRID.
*ENDFORM.                    " built_header
