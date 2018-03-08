*&---------------------------------------------------------------------*
*&  Include           ZMRPTOP
*&
*& Declaração da variaveis comuns a todos os programas ZMRP
*&---------------------------------------------------------------------*
*&  -- Documentação: --
*&
*& Tabelas:
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
TABLES: RESB,
        MARC
        .

*-Estruturas-----------------------------------------------------------*
TYPES: BEGIN OF E_RESB1,
       DEPOS TYPE RESB-LGORT,   "Depósito de Saída
       LGORT TYPE RESB-UMLGO,   "Depóstio de Recebimento
       SERNP TYPE MARC-SERNP,   "Perfil de nºs série
       MATNR TYPE RESB-MATNR,   "Nº do material
       MEINS TYPE RESB-MEINS,   "Unidade de medida básica
       BDMNG TYPE RESB-BDMNG,   "Quantidade necessária - Quantidade Reservada (201, 221, 231, 241, 261, 281, 913 - Saida)
       BDMNS TYPE RESB-BDMNG,   "Quantidade Reserva entrada (202, 222, 232, 242, 262, 282, 913 - Entrada)
       QTDE  TYPE RESB-BDMNG,   "Quantidade necessária total
 END OF E_RESB1.

TYPES: BEGIN OF E_XTAB1,        "Estrutura para levatar as reservas
       WERKS TYPE RESB-WERKS,   "Centro
       LGORT TYPE RESB-LGORT,   "Depósito
       CHARG TYPE RESB-CHARG,   "Número do lote
       MATNR TYPE RESB-MATNR,   "Nº do material
       BDMNG TYPE RESB-BDMNG,   "Quantidade necessária - Quantidade Reservada (201, 221, 231, 241, 261, 281, 913 - Saida)
       BDMNS TYPE RESB-BDMNG,   "Quantidade Reserva entrada (202, 222, 232, 242, 262, 282, 913 - Entrada)
       ERFME TYPE RESB-ERFME,   "Unidade de medida do registro = MEINS
       ERFMG TYPE RESB-ERFMG,   "Quantidade na unidade de medida do registro
END OF E_XTAB1.

TYPES: BEGIN OF E_MARD,         "Estrutura para levantamento de estoque
       MATNR TYPE MARD-MATNR,   "Nº do material
       WERKS TYPE MARD-WERKS,   "Centro
       LGORT TYPE MARD-LGORT,   "Depósito
       LABST TYPE MARD-LABST,   "Estoque avaliado de utilização livre
       UMLME TYPE MARD-UMLME,   "Estoque em transferência (de depósito para depósito)
       INSME TYPE MARD-INSME,   "Estoque em controle de qualidade
       EINME TYPE MARD-EINME,   "Estoque total de todos os batches não livres
       SPEME TYPE MARD-SPEME,   "Estoque bloqueado
       RETME TYPE MARD-RETME,   "Estoque bloqueado de devoluções
       VMLAB TYPE MARD-VMLAB,   "Estoque avaliado de utilização livre do período precedente
       VMUML TYPE MARD-VMUML,   "Estoque em transferência do período precedente
       VMINS TYPE MARD-VMINS,   "Estoque em controle de qualidade do período precedente
       VMEIN TYPE MARD-VMEIN,   "Estoque de utilização restrita do período precedente
       VMSPE TYPE MARD-VMSPE,   "Estoque bloqueado do período precedente
       VMRET TYPE MARD-VMRET,   "Estoque bloqueado de devoluções do período precedente
       MEINS TYPE RESB-MEINS,   "Unidade de medida básica
       MENGE TYPE EKPO-MENGE,   "Estoque em Pedido.
END OF E_MARD.

TYPES: BEGIN OF E_ZTAB,
       WERKS TYPE EKPO-WERKS,   "Centro
       LGORT TYPE EKPO-LGORT,   "Depósito
       MATNR TYPE EKPO-MATNR,   "Nº do material
       MENGE TYPE EKPO-MENGE,   "Quantidade do pedido
END OF E_ZTAB.

TYPES: BEGIN OF E_ESTOQUE,
       MATNR TYPE MARD-MATNR,   "Nº do material
       LABST TYPE MARD-LABST,   "Estoque avaliado de utilização livre
       QTDE  TYPE RESB-BDMNG,   "Quantidade necessária total
       CRIT  TYPE C,            "Estoque critico branco = não
END OF E_ESTOQUE.

*-Tabelas Internas-------------------------------------------------------*

DATA: BEGIN OF I_MARC OCCURS 0,
      MATNR TYPE MARC-MATNR,
      WERKS TYPE MARC-WERKS,
      MEINS TYPE MARA-MEINS,
      SERNP TYPE SERAIL,
END OF I_MARC.

DATA: BEGIN OF I_MARA OCCURS 0,
      MATNR TYPE MARA-MATNR,
      MATKL TYPE MARA-MATKL,
END OF I_MARA.

DATA: BEGIN OF I_ZM0007 OCCURS 0,
      LGORT TYPE RESB-LGORT,
      UMLGO TYPE RESB-LGORT,
END OF I_ZM0007.

DATA: BEGIN OF I_MARDAUX1 OCCURS 0,
      MATNR TYPE MARD-MATNR,
END OF I_MARDAUX1.


DATA: BEGIN OF I_MSG OCCURS   0,
      MSGTYP        LIKE BDCMSGCOLL-MSGTYP,
      TCODE         LIKE SY-TCODE,
      MESSAGE(100)  TYPE C,
      MATNR         TYPE RESB-MATNR,
      LGORT         TYPE RESB-LGORT,
      WERKS         TYPE MARD-WERKS,
 END OF I_MSG.

DATA: BEGIN OF I_BDC OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF I_BDC.

DATA: XTAB1 TYPE TABLE OF E_XTAB1 WITH HEADER LINE,
      XTAB1AUX TYPE TABLE OF E_XTAB1 WITH HEADER LINE,
      I_MARD TYPE TABLE OF E_MARD WITH HEADER LINE,
      I_MARDAUX TYPE TABLE OF E_MARD WITH HEADER LINE,
      I_RESB1 TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      I_RESBAUX TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      T_SERIA TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      T_NSERI TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      ZTAB TYPE TABLE OF E_ZTAB WITH HEADER LINE,
      ZTABAUX TYPE TABLE OF E_ZTAB WITH HEADER LINE,
      I_ESTOQUE TYPE TABLE OF E_ESTOQUE WITH HEADER LINE
      .

*-Ranges-----------------------------------------------------------------*

RANGES: XBDART FOR RESB-BDART.

*-Ponteiros--------------------------------------------------------------*

FIELD-SYMBOLS <FS_MARC> LIKE I_MARC.

*-Variáveis--------------------------------------------------------------*

DATA: V_ESTOQUE TYPE MARD-LABST,
      V_ESTOQUEPEDIDO TYPE EKPO-MENGE,
      V_NECES   TYPE MARD-LABST,
      V_ARRED TYPE MARC-BSTRF.

*-Parâmetros de Seleção--------------------------------------------------*
*-Tela-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_WERKS FOR RESB-WERKS NO INTERVALS NO-EXTENSION OBLIGATORY DEFAULT '5300',
                S_LGORT FOR RESB-LGORT,
                S_MATNR FOR RESB-MATNR.
SELECTION-SCREEN END OF BLOCK A1.
