*&---------------------------------------------------------------------*
*& Report  ZMRP
*& ZMRP - MRP para transferencia entre depositos (central > ponta)
*&---------------------------------------------------------------------*
*& Descrição Resumida do Programa.
*&
*& Esse programa verificar a possição do material nos depositos, e caso
*& haja mais reservas que material em livre ultilização ele gera uma
*& uma reserva 913 do deposito 3000 para o deposito que há necessidade.
*&---------------------------------------------------------------------*
*& Desenvolvedor: Gustavo Di Iório - E208747
*& Versão: 1
*& Desenvolvido em: 27/12/2017
*& Mudança Original (RDM/SDM): C124925 / 8000010733
*& Documentação:
*& ESF:
*& EST:
*& TES:
*& EVI:
*&---------------------------------------------------------------------*

REPORT ZMRP
       NO STANDARD PAGE HEADING               "Retirar o cabeçalho padrão SAP
       MESSAGE-ID ZC.                         "Classe de mensagem Z da CEMIG

**********************************************************************
* Includes ***********************************************************
**********************************************************************

INCLUDE ZMRPTOP.                              "Variáveis comuns ao ZMRP e tela de seleção
INCLUDE ZMRPESTOQUE.                          "Levantamento do Estoque
INCLUDE ZMRPRESERVATIONQUATITIES.             "Quantidade reservada
INCLUDE ZMRPPRINT.                            "Impressão
INCLUDE ZMRPNECESTRANSF.                      "Necessidade Transferencia
INCLUDE ZMRPTRANSF.                           "Gerar Reserva 913
INCLUDE ZMRPCRITICOS.                         "Analisar se o estoque é critico e modifica as RESB1

*-----------------------------------------------------------------------*
START-OF-SELECTION.
*-----------------------------------------------------------------------*

*Procedimentos

  PERFORM F_SELECT_ESTOQUE.
  PERFORM F_SELECT_RESERVA.
  PERFORM F_SELEC_TRANSF.
  PERFORM F_ANALISEESTOQUE.
  PERFORM F_ANALISECRITICO.

  IF P_REL1 = 'X'.

    IF NOT I_RESB1 IS INITIAL.
      PERFORM F_PRINT1.
    ELSE.
      MESSAGE S672.
      STOP.
    ENDIF.

  ENDIF.

  IF P_TRA1 = 'X'.

    IF NOT I_RESB1 IS INITIAL.
*& Exibe Janela quando online
      IF SY-BATCH IS INITIAL.
*& Solicita Confirmação
        MOVE '' TO V_FILE.
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            DEFAULTOPTION  = 'N'
            TEXTLINE1      = 'Confirma geração da(s) transferência(s) ?'
*           TEXTLINE2      = ' '
            TITEL          = 'Confirmação'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = 'X'
          IMPORTING
            ANSWER         = V_FILE.
*& Se confifmação OK - Criar as reservas
        IF  V_FILE = 'J'.
          PERFORM F_CRIA_TRANSF.
        ENDIF.
      ELSE.
        PERFORM F_CRIA_TRANSF.
      ENDIF.

    ELSE.
      MESSAGE S672.
      STOP.
    ENDIF.

  ENDIF.

*-----------------------------------------------------------------------*
*-----------------------------------------------------------------------*
