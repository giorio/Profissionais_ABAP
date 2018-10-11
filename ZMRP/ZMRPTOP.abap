*&---------------------------------------------------------------------*
*&  Include           ZMRPTOP
*&
*& Declaração da variaveis comuns a todos os programas ZMRP
*&---------------------------------------------------------------------*
*&  -- Documentação: --
*&
*& Tabelas internas:
*& >> XTAB1 e XTAB1AUX -> Para levantamento das quantidades das reservas
*& >> I_MARD e I_MARDAUX -> Para levantamento do estoque
*& >> I_ESTOQUE -> Para analise da criticidade do material no estoque
*& >> I_RESB1 e I_RESBAUX, -> Para coleta de dados para as reservas
*& >> T_SERIA e T_NSERI -> Para criação das reservas
*& >> ZTAB e ZTABAUX -> Para levantamento do estoque em pedidos
*& >> I_ZM0007 -> Deposito de poste
*& >> I_MARA -> Levantamento do grupo de mercadoria
*& >> I_MARC -> Entrada de dados para função de reservas.
*&---------------------------------------------------------------------*

*-Tabelas--------------------------------------------------------------*
TABLES: resb,                   "Tabela de Reservas
        marc,                   "Tabela de Dados de centro para material
        zmarah.                 "Tabela de Historico da MARA e MARC



*-Estruturas-----------------------------------------------------------*
TYPES: BEGIN OF e_resb1,
       depos TYPE resb-lgort,   "Depósito de Saída
       lgort TYPE resb-umlgo,   "Depóstio de Recebimento
       sernp TYPE marc-sernp,   "Perfil de nºs série
       matnr TYPE resb-matnr,   "Nº do material
       meins TYPE resb-meins,   "Unidade de medida básica
       bdmng TYPE resb-bdmng,   "Quantidade necessária - Quantidade Reservada (201, 221, 231, 241, 261, 281, 913 - Saida)
       bdmns TYPE resb-bdmng,   "Quantidade Reserva entrada (202, 222, 232, 242, 262, 282, 913 - Entrada)
       neces TYPE resb-bdmng,   "Quantidade Necessario antes da embalagem
       qtde  TYPE resb-bdmng,   "Quantidade necessária total
       atend TYPE resb-bdmng,   "Relação entre QTE/Necess (em %)
 END OF e_resb1.

TYPES: BEGIN OF e_xtab1,        "Estrutura para levatar as reservas
       werks TYPE resb-werks,   "Centro
       lgort TYPE resb-lgort,   "Depósito
       charg TYPE resb-charg,   "Número do lote
       matnr TYPE resb-matnr,   "Nº do material
       bdmng TYPE resb-bdmng,   "Quantidade necessária - Quantidade Reservada (201, 221, 231, 241, 261, 281, 913 - Saida)
       bdmns TYPE resb-bdmng,   "Quantidade Reserva entrada (202, 222, 232, 242, 262, 282, 913 - Entrada)
       erfme TYPE resb-erfme,   "Unidade de medida do registro = MEINS
       erfmg TYPE resb-erfmg,   "Quantidade na unidade de medida do registro
END OF e_xtab1.

TYPES: BEGIN OF e_mard,         "Estrutura para levantamento de estoque
       matnr TYPE mard-matnr,   "Nº do material
       werks TYPE mard-werks,   "Centro
       lgort TYPE mard-lgort,   "Depósito
       labst TYPE mard-labst,   "Estoque avaliado de utilização livre
       umlme TYPE mard-umlme,   "Estoque em transferência (de depósito para depósito)
       meins TYPE resb-meins,   "Unidade de medida básica
       menge TYPE ekpo-menge,   "Estoque em Pedido.
END OF e_mard.

TYPES: BEGIN OF e_ztab,
       werks TYPE ekpo-werks,   "Centro
       lgort TYPE ekpo-lgort,   "Depósito
       matnr TYPE ekpo-matnr,   "Nº do material
       menge TYPE ekpo-menge,   "Quantidade do pedido
END OF e_ztab.

TYPES: BEGIN OF e_estoque,
       matnr TYPE mard-matnr,   "Nº do material
       labst TYPE mard-labst,   "Estoque avaliado de utilização livre
       neces TYPE resb-bdmng,   "Quantidade necessária total sem Embalagem
       qtde  TYPE resb-bdmng,   "Quantidade necessária total com Embalagem
       crit  TYPE c,            "Estoque critico - em branco = não; 'C' = Critico; 'Z' = Zerado; 'S' = Sem Log
END OF e_estoque.

TYPES: BEGIN OF e_matnr,
        matnr     TYPE mara-matnr,
  END OF e_matnr.

*-Tabelas Internas-------------------------------------------------------*

data: BEGIN OF i_marc OCCURS 0,
      matnr TYPE marc-matnr,
      werks TYPE marc-werks,
      meins TYPE mara-meins,
      sernp TYPE serail,
END OF i_marc.

DATA: BEGIN OF i_mara OCCURS 0,
      matnr TYPE mara-matnr,
      matkl TYPE mara-matkl,
END OF i_mara.

DATA: BEGIN OF i_zm0007 OCCURS 0,
      lgort TYPE resb-lgort,
      umlgo TYPE resb-lgort,
END OF i_zm0007.

DATA: xtab1                 TYPE TABLE OF e_xtab1 WITH HEADER LINE,
      xtab1aux              TYPE TABLE OF e_xtab1 WITH HEADER LINE,
      i_mard                TYPE TABLE OF e_mard WITH HEADER LINE,
      i_mardaux             TYPE TABLE OF e_mard WITH HEADER LINE,
      i_resb1               TYPE TABLE OF e_resb1 WITH HEADER LINE,
      i_resbaux             TYPE TABLE OF e_resb1 WITH HEADER LINE,
      t_seria               TYPE TABLE OF e_resb1 WITH HEADER LINE,
      t_nseri               TYPE TABLE OF e_resb1 WITH HEADER LINE,
      t_poste               TYPE TABLE OF e_resb1 WITH HEADER LINE,
      t_r913                TYPE TABLE OF e_resb1 WITH HEADER LINE,
      ztab                  TYPE TABLE OF e_ztab WITH HEADER LINE,
      ztabaux               TYPE TABLE OF e_ztab WITH HEADER LINE,
      i_estoque             TYPE TABLE OF e_estoque WITH HEADER LINE,
      reservationheader     LIKE          bapi2093_res_head,
      reservationitems      TYPE TABLE OF bapi2093_res_item WITH HEADER LINE,
      profitabilitysegment  TYPE TABLE OF bapi_profitability_segment WITH HEADER LINE,
      return                TYPE TABLE OF bapiret2 WITH HEADER LINE,
      message               TYPE TABLE OF bapiret2 WITH HEADER LINE,
      i_mardaux1            TYPE TABLE OF e_matnr  WITH HEADER LINE.

*--------------------------------------------------------------------*
* Ranges
*--------------------------------------------------------------------*
RANGES: xbdart      FOR   resb-bdart,
        rg_mstae    FOR   mara-mstae,
        rg_matnr    FOR   mara-matnr.

*-Ponteiros--------------------------------------------------------------*

FIELD-SYMBOLS <fs_marc> LIKE i_marc.

*-Constantes-----------------------------------------------------------*

CONSTANTS: c_txt_item  LIKE bapi2093_res_item-item_text  VALUE 'Reserva gerada pela ZMPR01'.

*-Variáveis--------------------------------------------------------------*

DATA: v_estoque       TYPE mard-labst,
      v_estoquepedido TYPE ekpo-menge,
      v_neces         TYPE mard-labst,
      v_arred         TYPE marc-bstrf,
      v_disp          TYPE bdmng,
      v_rest(10)      TYPE c,
      res1            TYPE bdmng,
      res2            TYPE bdmng,
      v_mes           TYPE monat,
      v_cor_linha,
      v_file.

*-Parâmetros de Seleção--------------------------------------------------*
*-Tela-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_werks FOR resb-werks NO INTERVALS NO-EXTENSION OBLIGATORY DEFAULT '5300',
                s_lgort FOR resb-lgort OBLIGATORY,
                s_depos FOR resb-lgort OBLIGATORY,
                s_matnr FOR resb-matnr.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-002.
PARAMETERS: p_rel1 RADIOBUTTON GROUP c1,
            p_tra1 RADIOBUTTON GROUP c1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK c1 WITH FRAME TITLE text-003.
PARAMETERS: p_email AS CHECKBOX DEFAULT '',
            p_email1 TYPE string,
            p_email2 TYPE string.
SELECTION-SCREEN END OF BLOCK c1.

AT SELECTION-SCREEN.
  IF NOT p_email IS INITIAL.
    IF p_email1 IS INITIAL AND p_email2 IS INITIAL.
      MESSAGE text-004 TYPE 'E'.
    ENDIF.
  ENDIF.
