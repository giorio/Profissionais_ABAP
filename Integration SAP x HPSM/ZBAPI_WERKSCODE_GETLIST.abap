FUNCTION ZBAPI_WERKSCODE_GETLIST.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(BURKS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRETURN STRUCTURE  BAPIRETURN
*"  TABLES
*"      WERKSCODE_LIST STRUCTURE  ZMMGF_HPSM_INTERGRATION_001
*"----------------------------------------------------------------------

  CLEAR: WERKSCODE_LIST,
        LM_WERKSCODE_LIST,
        IT_T001KW,
        RETURN.

  REFRESH: WERKSCODE_LIST,
           LM_WERKSCODE_LIST,
           IT_T001KW.

  SELECT BWKEY BUKRS FROM T001K
         INTO TABLE IT_T001KW
         WHERE BUKRS = BURKS.

  LOOP AT IT_T001KW.
    SELECT * FROM T001W
      WHERE BWKEY = IT_T001KW-BWKEY.
      IT_T001KW-WERKS = T001W-WERKS.
      MODIFY IT_T001KW.
    ENDSELECT.
  ENDLOOP.

  LOOP AT IT_T001KW.
    SELECT * FROM T001W
           WHERE WERKS = IT_T001KW-WERKS.
      LM_WERKSCODE_LIST-WERKS_CODE = T001W-WERKS.
      LM_WERKSCODE_LIST-WERKS_NAME = T001W-NAME1.
      APPEND LM_WERKSCODE_LIST.
    ENDSELECT.
  ENDLOOP.


  IF SY-SUBRC <> 0.
    FREE MESSAGE.
    MESSAGE-MSGTY = 'E'.
    MESSAGE-MSGID = 'ZMM'.
    MESSAGE-MSGNO = 012.
    PERFORM SET_RETURN_MESSAGE USING MESSAGE
                               CHANGING RETURN.
  ENDIF.
  CHECK RETURN IS INITIAL.

  WERKSCODE_LIST[] = LM_WERKSCODE_LIST[].
  SORT WERKSCODE_LIST.


ENDFUNCTION.