*&---------------------------------------------------------------------*
*&  Include           ZMRPRESERVATIONQUATITIES
*&
*& Varificar as Reservas por Deposito
*&---------------------------------------------------------------------*
*&    O form consulta as reservas para os depositos, por meior da função
*& MB_ADD_RESERVATION_QUANTITIES
*&---------------------------------------------------------------------*
*& Entradas:
*& >> S_WERKS
*& >> S_MATNR
*& >> I_MARD
*&
*&---------------------------------------------------------------------*
*& Saídas:
*&  << I_RESB1
*&
*&
*&
*&---------------------------------------------------------------------*

FORM F_SELECT_RESERVA.

*  Para reduzir o tempo de execução do programa vai ser criado uma tabela
* de suporte para pegar os materias que há registro de Deposito (MARD)
* ele irá pegar o primeiro registro de cada material, excluindo os repetidos.

  SORT I_MARD BY MATNR.
  FREE: I_MARDAUX1.

  LOOP AT I_MARD.
    AT NEW MATNR.
      I_MARDAUX1-MATNR = I_MARD-MATNR.
      APPEND I_MARDAUX1.
    ENDAT.
  ENDLOOP.

*    Gerar a tebela com dados para função MB_ADD_RESERVATION_QUANTITIES e
* que depois irão para I_RESB1

  SELECT MARA~MATNR MARC~WERKS MARA~MEINS MARC~SERNP
    FROM MARA AS MARA
    INNER JOIN MARC AS MARC
    ON MARA~MATNR = MARC~MATNR
    INTO TABLE I_MARC
    FOR ALL ENTRIES IN I_MARDAUX1
    WHERE MARC~WERKS IN S_WERKS
    AND MARA~MATNR = I_MARDAUX1-MATNR.

  SORT I_MARC BY MATNR WERKS.

* Função para verificar e adicionar as quantidades em reservas.

  LOOP AT I_MARC.
    CALL FUNCTION 'MB_ADD_RESERVATION_QUANTITIES'
      EXPORTING
        X_KZEAR = SPACE
        X_MATNR = I_MARC-MATNR
        X_XLOEK = SPACE
*       X_KZWSO = ' '
      TABLES
        XBDART  = XBDART
        XTAB1   = XTAB1AUX
        XWERKS  = S_WERKS.

    LOOP AT XTAB1AUX.
      MOVE-CORRESPONDING XTAB1AUX TO XTAB1.
      APPEND XTAB1.
    ENDLOOP.

  ENDLOOP.

* Seleciona grupo de mercadoria do material

  SELECT MATNR
         MATKL
    INTO TABLE I_MARA
    FROM MARA
    FOR ALL ENTRIES IN I_MARD
    WHERE MATNR EQ I_MARD-MATNR.

* Seleciona equivalência de depósito/depósito de poste

  SELECT LGORT
         UMLGO
      INTO TABLE I_ZM0007
      FROM ZM0007.


* Preenchimento da I_RESB

  LOOP AT XTAB1 WHERE LGORT IN S_LGORT.

    READ TABLE I_MARC ASSIGNING <FS_MARC>
                                    WITH KEY MATNR = XTAB1-MATNR
                                             WERKS = XTAB1-WERKS
                                                    BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      MOVE <FS_MARC>-SERNP TO I_RESB1-SERNP.
      I_RESB1-MEINS = <FS_MARC>-MEINS.
    ENDIF.

    I_RESB1-MATNR = XTAB1-MATNR.
    I_RESB1-LGORT = XTAB1-LGORT.
    I_RESB1-BDMNG = XTAB1-BDMNG.
    I_RESB1-BDMNS = XTAB1-BDMNS.
    COLLECT I_RESB1.
  ENDLOOP.
ENDFORM.                    "F_SELECT_RESERVA
