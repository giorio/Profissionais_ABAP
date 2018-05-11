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
TABLES: RESB,                   "Tabela de Reservas
        MARC,                   "Tabela de Dados de centro para material
        ZMARAH                  "Tabela de Historico da MARA e MARC
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
       NECES TYPE RESB-BDMNG,   "Quantidade Necessario antes da embalagem
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
       NECES TYPE RESB-BDMNG,   "Quantidade necessária total sem Embalagem
       QTDE  TYPE RESB-BDMNG,   "Quantidade necessária total com Embalagem
       CRIT  TYPE C,            "Estoque critico - em branco = não; 'C' = Critico; 'Z' = Zerado; 'S' = Sem Log
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

DATA: BEGIN OF I_BDC OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF I_BDC.

DATA: XTAB1                 TYPE TABLE OF E_XTAB1 WITH HEADER LINE,
      XTAB1AUX              TYPE TABLE OF E_XTAB1 WITH HEADER LINE,
      I_MARD                TYPE TABLE OF E_MARD WITH HEADER LINE,
      I_MARDAUX             TYPE TABLE OF E_MARD WITH HEADER LINE,
      I_RESB1               TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      I_RESBAUX             TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      T_SERIA               TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      T_NSERI               TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      T_R913                TYPE TABLE OF E_RESB1 WITH HEADER LINE,
      ZTAB                  TYPE TABLE OF E_ZTAB WITH HEADER LINE,
      ZTABAUX               TYPE TABLE OF E_ZTAB WITH HEADER LINE,
      I_ESTOQUE             TYPE TABLE OF E_ESTOQUE WITH HEADER LINE,
      RESERVATIONHEADER     LIKE          BAPI2093_RES_HEAD,
      RESERVATIONITEMS      TYPE TABLE OF BAPI2093_RES_ITEM WITH HEADER LINE,
      PROFITABILITYSEGMENT  TYPE TABLE OF BAPI_PROFITABILITY_SEGMENT WITH HEADER LINE,
      RETURN                TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
      MESSAGE               TYPE TABLE OF BAPIRET2 WITH HEADER LINE
      .

*-Ranges-----------------------------------------------------------------*

RANGES: XBDART FOR RESB-BDART.

*-Ponteiros--------------------------------------------------------------*

FIELD-SYMBOLS <FS_MARC> LIKE I_MARC.

*-Constantes-----------------------------------------------------------*

CONSTANTS: C_TXT_ITEM  LIKE BAPI2093_RES_ITEM-ITEM_TEXT  VALUE 'Reserva gerada pela ZMPR01'.

*-Variáveis--------------------------------------------------------------*

DATA: V_ESTOQUE       TYPE MARD-LABST,
      V_ESTOQUEPEDIDO TYPE EKPO-MENGE,
      V_NECES         TYPE MARD-LABST,
      V_ARRED         TYPE MARC-BSTRF,
      V_COR_LINHA,
      V_FILE,
      V_REST(10)      TYPE C,
      RES1            LIKE RESB-BDMNG,
      RES2            LIKE RESB-BDMNG,
      V_MES           TYPE MONAT.

*-Parâmetros de Seleção--------------------------------------------------*
*-Tela-------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_WERKS FOR RESB-WERKS NO INTERVALS NO-EXTENSION OBLIGATORY DEFAULT '5300',
                S_LGORT FOR RESB-LGORT OBLIGATORY,
                S_DEPOS FOR RESB-LGORT OBLIGATORY,
                S_MATNR FOR RESB-MATNR.
SELECTION-SCREEN END OF BLOCK A1.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_REL1 RADIOBUTTON GROUP C1,
            P_TRA1 RADIOBUTTON GROUP C1.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK C1 WITH FRAME TITLE TEXT-003.
PARAMETERS: P_EMAIL AS CHECKBOX DEFAULT '',
            P_EMAIL1 TYPE STRING,
            P_EMAIL2 TYPE STRING.
SELECTION-SCREEN END OF BLOCK C1.

INITIALIZATION.

AT SELECTION-SCREEN.
  IF NOT P_EMAIL IS INITIAL.
    IF P_EMAIL1 IS INITIAL AND P_EMAIL2 IS INITIAL.
      MESSAGE TEXT-004 TYPE 'E'.
    ENDIF.
  ENDIF.
