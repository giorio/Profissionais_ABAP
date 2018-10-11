*&---------------------------------------------------------------------*
*&  Include           ZMRPCRIAR913
*&---------------------------------------------------------------------*
FORM f_cria_transf.

  CLEAR:  t_nseri, t_nseri[],
          t_seria, t_seria[],
          t_poste, t_poste[].


  LOOP AT i_resb1.
    IF i_resb1-depos <> '3000'.
      MOVE-CORRESPONDING i_resb1 TO t_poste.
      append t_poste.
    ELSE.
      IF i_resb1-sernp IS INITIAL.
        MOVE-CORRESPONDING i_resb1 TO t_nseri.
        APPEND t_nseri.
      ELSEIF i_resb1-sernp IS NOT INITIAL.
        MOVE-CORRESPONDING i_resb1 TO t_seria.
        APPEND t_seria.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lines( t_nseri ) > 0.
    t_r913[] = t_nseri[].
    PERFORM f_criar_reserva_913.
  ENDIF.

  IF lines( t_seria ) > 0.
    t_r913[] = t_seria[].
    PERFORM f_criar_reserva_913.
  ENDIF.

  IF lines( t_poste ) > 0.
    t_r913[] = t_poste[].
    PERFORM f_criar_reserva_913.
  ENDIF.

  IF NOT p_email1 IS INITIAL AND NOT p_email2 IS INITIAL.
    PERFORM log_email.
  ENDIF.

  PERFORM f_log.

ENDFORM.                    "F_CRIA_TRANSF

*&---------------------------------------------------------------------*
*&      Form  F_CRIAR_RESERVA_913
*&---------------------------------------------------------------------*
*       Form para criar a estrutura e a tabela de parâmetros da BAPI
* F_CRIAR_RESERVA_913.
*----------------------------------------------------------------------*
FORM f_criar_reserva_913.

  SORT t_r913 BY lgort.

  LOOP AT t_r913.

    CLEAR: reservationheader, reservationitems.
    REFRESH: reservationitems.

    AT NEW lgort.

      reservationheader-res_date = sy-datum.
      reservationheader-created_by = sy-uname.
      reservationheader-move_type = '913'.
      reservationheader-move_plant = '5300'.
      reservationheader-move_stloc = t_r913-lgort.

      LOOP AT t_r913 WHERE lgort = reservationheader-move_stloc.
        reservationitems-material = t_r913-matnr.
        reservationitems-plant = s_werks-low.
        reservationitems-stge_loc = t_r913-depos.
        reservationitems-entry_qnt = t_r913-qtde.
        reservationitems-movement = 'X'.
        reservationitems-req_date = sy-datum.
        reservationitems-item_text = c_txt_item.
        APPEND reservationitems.
      ENDLOOP.

    ENDAT.
    SORT reservationitems by material.
    PERFORM cadastra_reserva.

  ENDLOOP.


  CLEAR: t_r913, t_r913[].

ENDFORM.                    "F_CRIAR_RESERVA_913.

*&---------------------------------------------------------------------*
*&      Form  cadastra_reserva
*&---------------------------------------------------------------------*
*       Pega a estrutura RESERVATIONHEADER e a tabela RESERVATIONITEMS
* e chama a BAPI: BAPI_RESERVATION_CREATE1, além de criar a tabela de
* saída de mentagem.
*----------------------------------------------------------------------*
FORM cadastra_reserva.
  IF lines( reservationitems ) > 0.
*      verificar se a tabela de itens está preenchida
    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader          = reservationheader
*         TESTRUN                    =
*         ATPCHECK                   =
*         CALCHECK                   =
*         RESERVATION_EXTERNAL       =
*       IMPORTING
*         RESERVATION                =
      TABLES
        reservationitems           = reservationitems
        profitabilitysegment       = profitabilitysegment
        return                     = return
*             EXTENSIONIN                =
              .
    LOOP AT return.
      MOVE-CORRESPONDING return TO message.
      APPEND message.
    ENDLOOP.


    DELETE message WHERE id = 'BAPI'.
    SORT message BY message.
    DELETE ADJACENT DUPLICATES FROM message.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*       EXPORTING
*         WAIT          =
*       IMPORTING
*         RETURN        =
              .

  ENDIF.
ENDFORM.                    "cadastra_reserva
