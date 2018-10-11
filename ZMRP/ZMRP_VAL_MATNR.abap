*----------------------------------------------------------------------*
***INCLUDE ZMRP_VAL_MATNR.
*----------------------------------------------------------------------*
FORM f_valida_matnr.

  DATA: wa_matnr      TYPE    matnr.

  FREE: i_mardaux1.

  break e208747.

  rg_mstae-sign     = 'I'.
  rg_mstae-option   = 'BT'.
  rg_mstae-low      = 'N'.
  rg_mstae-high     = 'NZ'.
  APPEND rg_mstae.

  rg_mstae-sign     = 'I'.
  rg_mstae-option   = 'BT'.
  rg_mstae-low      = 'U'.
  rg_mstae-high     = 'UZ'.
  APPEND rg_mstae.

  rg_mstae-sign     = 'I'.
  rg_mstae-option   = 'BT'.
  rg_mstae-low      = 'X'.
  rg_mstae-high     = 'XZ'.
  APPEND rg_mstae.

  SELECT matnr FROM mara
                  INTO wa_matnr
                  WHERE matnr IN s_matnr
                  AND mstae IN rg_mstae.

    rg_matnr-sign      = 'I'.
    rg_matnr-option    = 'EQ'.
    rg_matnr-low       = wa_matnr.
    APPEND rg_matnr.

  ENDSELECT.

ENDFORM.                    " F_VALIDA_MATNR
