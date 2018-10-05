*---------------------------------------------------------------------*
* Report  ZLBR003
*
*   Programa para cadastro da tabela zlbt_isslei, que irá guardar as
* descrições e validade de cada item da lei 116/03 e posteriores.
*   O programa faz o cadastro de um único registro e pode ser via carga,
* um arquivo formato .csv.
*--------------------------------------------------------------------*
*    Nota: O arquivo não deverá ter seu lay-out alterado. Segue abaixo
*  como arquivo deve ser.
*
*  Tipo de Arquivo: .csv
*  Modelo de dados:
*  Linha 01 - Cabeçalho: Obrigatório - Cód. Lei 116/03; Data Incio; Data Fim; descrição
*  Linha 02 a n: S-XXXX-X/XX-XX;XX.XX.XXXX;XX.XX.XXXX;XXXXX(limite 255 caracteres)
*---------------------------------------------------------------------*
* ESF: MM.01.06.009 ESF  J1BTAX - Relatorio de ISS
* Responsaveis pela ESF: CR/TB - Valquiria Mendes (c056327)
*                        TI/SI - Juliane Mendonça (e216990)
*
* EST: MM.01.06.009 EST J1BTAX - Carga Item Lei 116/03
* Responsavel pela EST:  TI/SI - Gustavo Di Iório (e208747)
*
* Desenvolvido por: Gustavo Di Iório (e208747)
* Desenvolvido em: 01/10/2018.
* RDM original: C125071
* Correção Original: 8000012290
*---------------------------------------------------------------------*
* Manutenções:
*--------+-----------+---------+-----------+--------------------------*
* Data   |  Autor    | RDM     | Correção  | Motivo
*--------+-----------+---------+-----------+--------------------------*
*
*
*
*
*---------------------------------------------------------------------*

REPORT zlbr003 NO STANDARD PAGE HEADING.

*--------------------------------------------------------------------*
* Tabelas Transparentes
*--------------------------------------------------------------------*
TABLES: marc,
        sscrfields,
        zlbt_isslei.

TYPE-POOLS icon.
*--------------------------------------------------------------------*
* Estruturas
*--------------------------------------------------------------------*
TYPES: BEGIN OF e_import,
        texto             TYPE  string,
  END OF e_import.

TYPES: BEGIN OF e_grade,
        sel               TYPE  c,
        style             TYPE  lvc_t_styl.
        INCLUDE STRUCTURE zlbt_isslei.
TYPES: END OF e_grade.


*--------------------------------------------------------------------*
* Tabelas internas
*--------------------------------------------------------------------*
DATA: ti_import           TYPE TABLE OF e_import WITH HEADER LINE,
      ti_116              TYPE TABLE OF zlbt_isslei,
      ti_grade            TYPE TABLE OF e_grade,
      ti_fieldcat         TYPE          lvc_t_fcat,
      ti_layout           TYPE          lvc_s_layo,
      itab                TYPE TABLE OF sy-ucomm.

*--------------------------------------------------------------------*
* Work Areas
*--------------------------------------------------------------------*
DATA: wa_116              TYPE  zlbt_isslei,
      wa_grade            TYPE  e_grade.

*--------------------------------------------------------------------*
* Variaveis
*--------------------------------------------------------------------*
DATA: vg_tot_reg          TYPE  i,
      vg_qtd_ok           TYPE  i,
      vg_qtd_er           TYPE  i.

*--------------------------------------------------------------------*
* Field-Symbols
*--------------------------------------------------------------------*
FIELD-SYMBOLS: <fs_grade> LIKE LINE OF ti_grade.

**********************************************************************

*--------------------------------------------------------------------*
* Tela de seleção
*--------------------------------------------------------------------*

SELECTION-SCREEN FUNCTION KEY 1.  "Importar Dados

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_steuc     FOR marc-steuc.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.

PARAMETERS: p_file          LIKE rlgrap-filename.

SELECTION-SCREEN END OF BLOCK bl2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_busca_arquivo_local USING p_file.

*--------------------------------------------------------------------*
* Inicialização
*--------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_botoes_status.

AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'FC01'.
      PERFORM f_importa_dados.
  ENDCASE.

*--------------------------------------------------------------------*
* Processamento
*--------------------------------------------------------------------*
START-OF-SELECTION.

*Seleciona os dados da tabela zlbt_isslei
  PERFORM f_select_dados.

  PERFORM f_montar_grade_exibicao.

  IF ti_grade[] IS NOT INITIAL.

*   Configura o Layout
    PERFORM f_layout.
*   Configuração das colunas
    PERFORM f_monta_fieldcat.
*   Mostra a grade
    PERFORM f_mostrar_grid.

  ENDIF.



*---------------------------------------------------------------------*
*      Form  F_BUSCA_ARQUIVO_LOCAL
*---------------------------------------------------------------------*
FORM f_busca_arquivo_local USING p_file.

  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

ENDFORM.                    " F_BUSCA_ARQUIVO_LOCAL

*---------------------------------------------------------------------*
*      Form  BOTOES_STATUS
*---------------------------------------------------------------------*
FORM f_botoes_status.

  DATA: ls_sel_button TYPE smp_dyntxt.

  ls_sel_button-icon_id    = icon_import.
  ls_sel_button-icon_text  = 'Importar Dados'.
  ls_sel_button-quickinfo  = 'Importar Dados'.
  sscrfields-functxt_01    = ls_sel_button.

ENDFORM.                    " BOTOES_STATUS
*---------------------------------------------------------------------*
*      Form  F_IMPORTA_DADOS
*---------------------------------------------------------------------*
FORM f_importa_dados.

  IF p_file IS NOT INITIAL.

    PERFORM f_download_arq.

  ELSE.
    MESSAGE e003(zlb03).
*   Favor selecionar o arquivo.

  ENDIF.

ENDFORM.                    " F_IMPORTA_DADOS
*---------------------------------------------------------------------*
*      Form  F_DOWNLOAD_ARQ
*---------------------------------------------------------------------*
FORM f_download_arq.

  DATA: vl_filename     TYPE string.

  vl_filename = p_file.

  CHECK vl_filename IS NOT INITIAL.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = vl_filename
      filetype                = 'ASC'
      has_field_separator     = ','
    TABLES
      data_tab                = ti_import
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc <> 0.
    MESSAGE e004(zlb03).
*   Erro ao abrir arquivo. Verificar o arquivo e tente novamente
  ELSE.
    PERFORM f_trata_arq.
  ENDIF.


ENDFORM.                    " F_DOWNLOAD_ARQ
*---------------------------------------------------------------------*
*      Form  F_TRATA_ARQ
*---------------------------------------------------------------------*
*    Nota: O arquivo não deverá ter seu lay-out alterado. Segue abaixo
*  como arquivo deve ser.
*
*  Tipo de Arquivo: .csv
*  Modelo de dados:
*  Linha 01 - Cabeçalho: Obrigatório - Cód. Lei 116/03; Data Incio; Data Fim; descrição
*  Linha 02 a n: S-XXXX-X/XX-XX;XX.XX.XXXX;XX.XX.XXXX;XXXXX(limite 255 caracteres)
*&---------------------------------------------------------------------*
FORM f_trata_arq.

  DATA: vl_steuc      TYPE    steuc,
        vl_deslei     TYPE    ze_lb_lei116.

  DATA: vl_bit        TYPE    i               VALUE 0,
        vl_col        TYPE    i               VALUE 0,
        vl_ini        TYPE    i               VALUE 0,
        vl_tam        TYPE    i,
        vl_lin        TYPE    i.

  CHECK ti_import[] IS NOT INITIAL.

  LOOP AT ti_import.

*    Pula linha de cabeçalho (linha 1)
    CHECK sy-tabix > 1.

    CLEAR:  vl_steuc,
            vl_deslei.

    vl_bit  = 0.
    vl_col  = 0.
    vl_ini  = 0.
    vl_lin  = strlen( ti_import-texto ).

*   Verifica se a linha não está vazia
    CHECK vl_lin > 1.
*   Verifica se há dados na linha
    CHECK ti_import-texto(1) <> ';'.

*   Acrescenta ';' no final da linha
    CONCATENATE ti_import-texto ';' INTO ti_import-texto.

    vl_lin  = strlen( ti_import-texto ).

    DO vl_lin TIMES.

      IF ti_import-texto+vl_bit(1) = ';'.

        ADD 1 TO vl_col.

        CASE vl_col.
*         Campo Steuc - Item da Lei 116/03
          WHEN 1.
            vl_tam    = vl_bit - vl_ini.
            vl_steuc  = ti_import-texto+vl_ini(vl_tam).
*         Campo descrição do item da lei 116/03
          WHEN 2.
            vl_tam    = vl_bit - vl_ini.
            vl_deslei = ti_import-texto+vl_ini(vl_tam).
        ENDCASE.

        vl_ini = vl_bit + 1.

      ENDIF.

      ADD 1 TO vl_bit.


    ENDDO.

    ADD 1 TO vg_tot_reg.

    CLEAR wa_116.

    wa_116-steuc    = vl_steuc.
    wa_116-deslei   = vl_deslei.

    INSERT zlbt_isslei FROM wa_116.

    IF sy-subrc = 0.
      ADD 1 TO vg_qtd_ok.
    ELSE.
      ADD 1 TO vg_qtd_er.
    ENDIF.

  ENDLOOP.

  PERFORM f_mostrar_resultado.

ENDFORM.                    " F_TRATA_ARQ
*&---------------------------------------------------------------------*
*&      Form  F_MOSTRAR_RESULTADO
*&---------------------------------------------------------------------*
FORM f_mostrar_resultado.

  DATA: vl_texto    TYPE  char100,
        vl_tot      TYPE  char4,
        vl_suc      TYPE  char4,
        vl_err      TYPE  char4.

  vl_tot    = vg_tot_reg.
  vl_suc    = vg_qtd_ok.
  vl_err    = vg_qtd_er.

  UNPACK vl_tot TO  vl_tot.
  UNPACK vl_suc TO  vl_suc.
  UNPACK vl_err TO  vl_err.

  CONCATENATE 'Registro Lidos {' vl_tot ']'
              '_Sucesso [' vl_suc ']'
              '_Erro [' vl_err ']'
              INTO vl_texto.

  MESSAGE vl_texto TYPE 'S' DISPLAY LIKE 'S'.

  CLEAR:  vg_tot_reg,
          vg_qtd_ok,
          vg_qtd_er.

ENDFORM.                    " F_MOSTRAR_RESULTADO
*&---------------------------------------------------------------------*
*&      Form  F_CONVERTER_DATA
*&---------------------------------------------------------------------*

FORM f_converter_data  CHANGING datum.

  DATA: vl_ano(4)       TYPE  n,
        vl_chdat(8)     TYPE  c,
        vl_data         TYPE  j_1btxdatf,
        vl_datum(10)    TYPE  c,
        vl_dia(2)       TYPE  n,
        vl_houtput(8)   TYPE  n,
        vl_mes(2)       TYPE  n.

  vl_datum  = datum.
  REPLACE ALL OCCURRENCES OF '.' IN vl_datum WITH ''.

  vl_dia  = vl_datum(2).
  vl_mes  = vl_datum+2(2).
  vl_ano  = vl_datum+4(4).

  CONCATENATE vl_ano
              vl_mes
              vl_dia INTO vl_chdat.

  vl_houtput  = '99999999' - vl_chdat.
  datum       = vl_houtput.


ENDFORM.                    " F_CONVERTER_DATA
*---------------------------------------------------------------------*
*      Form  F_SELECT_DADOS
*---------------------------------------------------------------------*
FORM f_select_dados.

  SELECT *
          FROM zlbt_isslei
          INTO TABLE ti_116
          WHERE steuc IN s_steuc.

  SORT ti_116 BY steuc.

ENDFORM.                    " F_SELECT_DADOS
*---------------------------------------------------------------------*
*      Form  F_MONTAR_GRADE_EXIBICAO
*---------------------------------------------------------------------*
FORM f_montar_grade_exibicao.

  LOOP AT ti_116 INTO wa_116.

    CLEAR wa_grade.

    MOVE-CORRESPONDING wa_116 TO wa_grade.

    APPEND wa_grade TO ti_grade.

  ENDLOOP.

ENDFORM.                    " F_MONTAR_GRADE_EXIBICAO
*---------------------------------------------------------------------*
*      Form  F_LAYOUT
*---------------------------------------------------------------------*
FORM f_layout.

  ti_layout-zebra      = 'X'.
  ti_layout-stylefname = 'STYLE'.

ENDFORM.                    " F_LAYOUT
*---------------------------------------------------------------------*
*      Form  F_MONTA_FIELDCAT
*---------------------------------------------------------------------*
FORM f_monta_fieldcat.

  PERFORM set_fieldcat USING:

* 1 2         3         4                 5       6       7     8     9     10    11      12
  1 'SEL'     'SEL'     'TI_GRADE'        '02'    '02'    ' '   ' '   'X'   ' '   ' '     '',
  2 'ICON'    'ICON'    'TI_GRADE'        '04'    '04'    ' '   ' '   ' '   ' '   ' '     'Status',
  3 'STEUC'   'STEUC'   'ZLBT_ISSLEI'     '16'    '16'    ' '   ' '   ' '   ' '   ' '     'Item da Lei 116/03',
  4 'DESLEI'  'DESLEI'  'ZLBT_ISSLEI'     '255'   '255'   ' '   ' '   ' '   ' '   ' '     'Descrição da Lei 116/2003'
        .

ENDFORM.                    " F_MONTA_FIELDCAT
*---------------------------------------------------------------------*
*      Form  SET_FIELDCAT
*---------------------------------------------------------------------*
FORM set_fieldcat  USING p_colpos        " 1
                         p_fieldname     " 2
                         p_ref_fieldname " 3
                         p_ref_tabname   " 4
                         p_outputlen     " 5
                         p_noout         " 6
                         p_hotspot       " 7
                         p_fix_column    " 8
                         p_box           " 9
                         p_edit          " 10
                         p_rot_conv      " 11
                         p_seltext_s.    " 12

  DATA: wa_fieldcat   TYPE lvc_s_fcat.

  CLEAR: wa_fieldcat.

* Definições gerais

  wa_fieldcat-fieldname  = p_fieldname.
  wa_fieldcat-col_pos    = p_colpos.
  wa_fieldcat-no_out     = p_noout.
  wa_fieldcat-hotspot    = p_hotspot.
  wa_fieldcat-fix_column = p_fix_column.
  wa_fieldcat-edit       = p_edit.

* Cria as referencias fieldname, tablename e rollname.

  IF p_ref_tabname IS INITIAL.
    wa_fieldcat-rollname    = p_ref_fieldname.
  ELSE.
    wa_fieldcat-ref_table   = p_ref_tabname.
  ENDIF.

* Da o tamnho da saida.
  IF NOT p_outputlen IS INITIAL.
    wa_fieldcat-outputlen = p_outputlen.
  ENDIF.

* Dá o cabeçalho dos textos.
  wa_fieldcat-scrtext_s = p_seltext_s.
  wa_fieldcat-scrtext_m = p_seltext_s.
  wa_fieldcat-scrtext_l = p_seltext_s.

* Habilita checkbox
  IF p_box = 'X'.
    wa_fieldcat-tabname   = p_ref_tabname.
    wa_fieldcat-ref_table = ''.
    wa_fieldcat-checkbox  = 'X'.
    wa_fieldcat-edit      = 'X'.
  ENDIF.

  APPEND wa_fieldcat TO ti_fieldcat.

ENDFORM.                    " SET_FIELDCAT
*---------------------------------------------------------------------*
*      Form  F_MOSTRAR_GRID
*---------------------------------------------------------------------*
FORM f_mostrar_grid.

  DATA : li_grid_setting  TYPE  lvc_s_glay,
          vl_repid        LIKE  sy-repid.

  li_grid_setting-edt_cll_cb = 'X'.

*& Monta ALV

  vl_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = vl_repid
      i_callback_pf_status_set = 'F_STATUS_LOCAL'
      i_callback_user_command  = 'Z_USER_COMAND'
      is_layout_lvc            = ti_layout
      it_fieldcat_lvc          = ti_fieldcat
      i_save                   = 'A'
    TABLES
      t_outtab                 = ti_grade
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " F_MOSTRAR_GRID
*&---------------------------------------------------------------------*
*&      Form  z_user_comand
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_UCOMM    text
*      -->P_SELFIELD text
*----------------------------------------------------------------------*
FORM z_user_comand USING p_ucomm    LIKE sy-ucomm
                         p_selfield TYPE slis_selfield.

  DATA: ref1          TYPE REF TO cl_gui_alv_grid,
        vl_acao       TYPE        i,
        vl_nreg       TYPE        i.

  CLEAR: vl_acao, vl_nreg.

* Refresh na grid
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = ref1.

  CALL METHOD ref1->check_changed_data.

* Verifica linha marcadas
  LOOP AT ti_grade INTO wa_grade WHERE sel EQ 'X'.
    vl_nreg = vl_nreg + 1.
  ENDLOOP.

  IF  vl_nreg EQ 0 AND p_ucomm EQ 'EXC'.
    MESSAGE s000(zmm) DISPLAY LIKE 'W' WITH text-005.
  ELSE.

*    captura acoes do usuario
    CASE p_ucomm.

      WHEN 'ATUALIZA'.
        PERFORM f_refresh.
      WHEN 'SAV'.
        PERFORM f_salvar_dados.
      WHEN 'NOVA'.
        PERFORM f_incluir.
      WHEN 'EXC'.
        PERFORM f_excluir_registro.
    ENDCASE.

  ENDIF.

  IF p_ucomm NE '&IC1'.

*   Refresh na grid
    CALL METHOD ref1->refresh_table_display.

  ENDIF.

ENDFORM.                    "z_user_comaand
*---------------------------------------------------------------------*
* Form  F_STATUS_LOCAL
*---------------------------------------------------------------------*
FORM f_status_local USING p_extab TYPE slis_t_extab .

  FREE: itab.

  SET PF-STATUS 'Z_MAIN' EXCLUDING itab.

ENDFORM.                    "f_status_local
*---------------------------------------------------------------------*
*      Form  F_REFRESH
*---------------------------------------------------------------------*
FORM f_refresh.

  PERFORM f_select_dados.

  IF ti_grade[] IS NOT INITIAL.

*   Mostra Grade de consulta
    PERFORM f_mostrar_grid.

  ENDIF.

ENDFORM.                    " F_REFRESH
*---------------------------------------------------------------------*
*      Form  F_SALVAR_DADOS
*---------------------------------------------------------------------*
FORM f_salvar_dados.

  LOOP AT ti_grade ASSIGNING <fs_grade>.

*   Gravar alteraçoes
    CLEAR wa_116.

*    PERFORM f_set_status CHANGING <fs_grade>-icon.

    MOVE-CORRESPONDING <fs_grade> TO wa_116.
    MODIFY zlbt_isslei FROM wa_116.
    COMMIT WORK.
  ENDLOOP.

ENDFORM.                    " F_SALVAR_DADOS
*---------------------------------------------------------------------*
*      Form  F_INCLUIR
*---------------------------------------------------------------------*
FORM f_incluir.

  FREE: wa_116.

  CALL SCREEN 1001 STARTING AT 5 5 ENDING AT 100 10.

ENDFORM.                    " F_INCLUIR
*---------------------------------------------------------------------*
*      Form  F_EXCLUIR_REGISTRO
*---------------------------------------------------------------------*
FORM f_excluir_registro.

    DATA: lv_retorno TYPE c,
        lv_index   TYPE sy-tabix.

  PERFORM f_confirma_acao USING text-004
                                text-003
                       CHANGING lv_retorno.

  CHECK lv_retorno EQ '1'.

  LOOP AT ti_grade ASSIGNING <fs_grade> WHERE sel EQ 'X'.

    lv_index = sy-tabix.

*   Excluir Registro
    CLEAR wa_116.

    MOVE-CORRESPONDING <fs_grade> TO wa_116.

    DELETE zlbt_isslei FROM wa_116.
    COMMIT WORK.

    DELETE ti_grade INDEX lv_index.

  ENDLOOP.

ENDFORM.                    " F_EXCLUIR_REGISTRO
*---------------------------------------------------------------------*
*      Form  F_CONFIRMA_ACAO
*---------------------------------------------------------------------*
FORM f_confirma_acao  USING    p_titulo
                               p_texto
                      CHANGING p_retorno.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = p_titulo
      text_question         = p_texto
      text_button_1         = 'Sim'
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = 'NÃO'
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '2'
      display_cancel_button = ''
      start_column          = 25
      start_row             = 6
      popup_type            = 'ICON_MESSAGE_QUESTION'
    IMPORTING
      answer                = p_retorno
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

ENDFORM.                    " F_CONFIRMA_ACAO
*---------------------------------------------------------------------*
*      Module  USER_COMMAND_1001  INPUT
*---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      INSERT zlbt_isslei FROM wa_116.
      APPEND wa_116 TO ti_116.

      APPEND INITIAL LINE TO ti_grade ASSIGNING <fs_grade>.
      MOVE-CORRESPONDING wa_116 TO <fs_grade>.

      COMMIT WORK.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'CANC'.
      SET SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'PF-1001'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_1001  OUTPUT
