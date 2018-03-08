*&---------------------------------------------------------------------*
*&  Include           ZMRPTOP_ZM137
*&---------------------------------------------------------------------*

*-Estruturas-----------------------------------------------------------*

*-Tabelas Internas-----------------------------------------------------*

DATA: RESERVATIONHEADER     LIKE BAPI2093_RES_HEAD,
      RESERVATIONITEMS      TYPE TABLE OF BAPI2093_RES_ITEM WITH HEADER LINE,
      PROFITABILITYSEGMENT  TYPE TABLE OF BAPI_PROFITABILITY_SEGMENT WITH HEADER LINE,
      RETURN                TYPE TABLE OF  BAPIRET2 WITH HEADER LINE.

*-Constantes-----------------------------------------------------------*

CONSTANTS:
  C_K1 LIKE T009-PERIV VALUE 'K1',
  C_GROUP_FILE            TYPE C VALUE 'G',
  C_POSTP LIKE RESB-POSTP VALUE SPACE.

*-Variáveis-------------------------------------------------------------*

DATA: "V_RESERVA LIKE RESB-BDMNG,
      V_RESER(10),
      V_COR_LINHA,
      V_MATERIAL(6),
      V_DATUM(8),
      V_FLAG,
      V_FILE,
      V_TIMES,
      "V_DEP LIKE RESB-LGORT,
      V_DATA LIKE SY-DATUM,
      V_QUANT(16) TYPE C,
      "QUANTIDADE_AUX(16) TYPE C,
      V_REST(10) TYPE C,
      RES1 LIKE RESB-BDMNG,
      RES2 LIKE RESB-BDMNG.
      "KZWSO LIKE MARA-KZWSM.

DATA: I_OPTIONS         TYPE CTU_PARAMS,
      IT_MESSAGE        LIKE  BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      V_MESSAGE(100),
      IT_MSG            LIKE I_MSG  OCCURS 0 WITH HEADER LINE.

I_OPTIONS-DISMODE  = 'N'.      "A e N
I_OPTIONS-DEFSIZE  = 'X'.
I_OPTIONS-UPDMODE  = 'S'.
I_OPTIONS-NOBINPT  = 'X'.
I_OPTIONS-RACOMMIT = 'X'.
I_OPTIONS-NOBIEND  = 'X'.

*----- Parâmetros de Seleção---------------------------------------------*
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
