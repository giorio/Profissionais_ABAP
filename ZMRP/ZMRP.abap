*&---------------------------------------------------------------------*
*& Report  ZMRP
*& ZMRP - MRP para transferencia entre depositos (central > ponta)
*&---------------------------------------------------------------------*
*&      Descrição Resumida do Programa.
*&
*&    Esse programa verificar a possição do material nos depositos, e caso
*& haja mais reservas que material em livre ultilização ele gera uma
*& uma reserva 913 do deposito 3000 para o deposito que há necessidade.
*&---------------------------------------------------------------------*
*& Solicitante: Gabriel Furtado Alvares - C057048
*& Desenvolvedor: Gustavo Di Iório - E208747
*& Versão: 1
*& Desenvolvido em: 27/12/2017
*& Mudança Original (RDM/SDM): C124925 / 8000010733
*& Documentação:
*& ESF: MM.02.05.028 ESF Criar reserva de transferência - ZMRP01
*& EST: MM.02.05.028 EST Criar reserva de transferência - ZMRP01
*& TES: MM.02.05.028 TES Criar reserva de transferência - ZMRP01
*& EVI: MM.02.05.028 EVI Criar reserva de transferência - ZMRP01
*&---------------------------------------------------------------------*

REPORT zmrp
       NO STANDARD PAGE HEADING               "Retirar o cabeçalho padrão SAP
       MESSAGE-ID zc.                         "Classe de mensagem Z

**********************************************************************
* Includes ***********************************************************
**********************************************************************

INCLUDE zmrptop.                              "Variáveis comuns ao ZMRP e tela de seleção
INCLUDE zmrpestoque.                          "Levantamento do Estoque
INCLUDE zmrpreservationquatities.             "Quantidade reservada
INCLUDE zmrpprint.                            "Impressão
INCLUDE zmrpnecestransf.                      "Necessidade Transferencia
INCLUDE zmrpcriar913.                         "Gerar Reserva 913
INCLUDE zmrpcriticos.                         "Analisar se o estoque é critico e modifica as RESB1
INCLUDE zmrp_val_matnr.

*-----------------------------------------------------------------------*
START-OF-SELECTION.
*-----------------------------------------------------------------------*

*Procedimentos
  PERFORM f_valida_matnr.
  PERFORM f_select_estoque.
  PERFORM f_select_reserva.
  PERFORM f_selec_transf.
  PERFORM f_analiseestoque.
  PERFORM f_analisecritico.

  IF p_rel1 = 'X'.

    IF NOT i_resb1 IS INITIAL.
      PERFORM f_print1.
    ELSE.
      MESSAGE s672.
      STOP.
    ENDIF.

  ENDIF.

  IF p_tra1 = 'X'.

    IF NOT i_resb1 IS INITIAL.
*& Exibe Janela quando online
      IF sy-batch IS INITIAL.
*& Solicita Confirmação
        MOVE '' TO v_file.
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            defaultoption  = 'N'
            textline1      = 'Confirma geração da(s) transferência(s) ?'
*           TEXTLINE2      = ' '
            titel          = 'Confirmação'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = 'X'
          IMPORTING
            answer         = v_file.
*& Se confifmação OK - Criar as reservas
        IF  v_file = 'J'.
          PERFORM f_cria_transf.
        ENDIF.
      ELSE.
        PERFORM f_cria_transf.
      ENDIF.

    ELSE.
      MESSAGE s672.
      STOP.
    ENDIF.

  ENDIF.
*
*  wa_zmrph-dtfim = sy-datum.
*  wa_zmrph-hrfim = sy-uzeit.
*  MODIFY zmrph FROM wa_zmrph.
