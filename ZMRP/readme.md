Podem usar o código do programa, favor apenas referência a fonte e criador:
Fonte/Font: github
Desenvolvedor/Developer: G_Iorio (Gustavo Di Iório)

Programa ZMRP - Documento Funcional

  A transação será utilizada para criar reservas de transferência (913) com base nos dados de estoque e reserva observados na MMBE.

  As reservas de transferência (913) geradas devem ter como depósito supridor o depósito 3000.

  Para cálculo do estoque disponível nos depósitos supridores devem ser considerados os depósitos 3000, 3009, 3033 e 3960.
Deverá existir um campo na transação para informar estes depósitos.

O estoque disponível nos depósitos supridores deve considerar as seguintes colunas da MMBE:
- Utilização livre
- Transfer.(dpst.)

Colunas que devem ser consideradas como estoque nos depósitos RECEBEDORES:
- Utilização livre
- Estoque em pedido (somente para os depósitos RECEBEDORES)
- Transfer.(dpst.)

A reserva a ser considerada nos depósitos RECEBEDORES deve ser somente a reserva de saída (coluna “Reservado”) da MMBE. Os movimentos são 261, xxx, xxx, xxx.

TOTAL DE ESTOQUE (SUPRIDORES):
TOTAL DE ESTOQUE (RECEBEDORES):
TOTAL DE RESERVAS (RECEBEDORES):

A transação deve percorrer todos os depósitos informados para todos materiais informados identificando os casos em que o TOTAL DE RESERVAS para determinado material/depósito é maior que o TOTAL DE ESTOQUE para o mesmo material/depósito.

Caso 1: TOTAL DE ESTOQUE >= TOTAL DE RESERVAS para cada depósito/material

Neste caso, o programa não deve criar nenhuma reserva de transferência (913).

Caso 2: TOTAL DE ESTOQUE <= TOTAL DE RESERVAS para cada depósito/material

Neste caso, o programa deverá criar reservas de transferência (913) com a necessidade de envio de material (RESERVA – UTILIZAÇÃO LIVRE – PEDIDO – TRANSFERÊNCIA).

Antes da criação da reserva de transferência (913) a transação deve verificar condições de embalagem (arredondamento) e de disponibilidade de estoque nos depósitos supridores.

Caso o material não tenha embalagem (campo em branco, ou com zero), a embalagem deverá ser considerada como 1 (uma) unidade de medida.

Deverá ser calculada a NECESSIDADE ARREDONDADA para, cada depósito, conforme a embalagem informada nos dados mestres de cada material.

Caso a soma das NECESSIDADES ARREDONDADAS de todos depósitos para o material seja MENOR que o TOTAL DE ESTOQUE (SUPRIDORES), deverá ser criada a reserva arredondada de transferência (913) em cada depósito.

Caso a soma das NECESSIDADES ARREDONDADAS de todos depósitos para o material seja MAIOR que o TOTAL DE ESTOQUE (SUPRIDORES), o material deve ser sinalizado como CRÍTICO.
Neste caso, deverá ser desconsiderado o arredondamento do material e considerado o arredondamento como 1 (uma) unidade de medida. Deverá então ser criada a reserva de transferência (913) em cada depósito, considerando o novo arredondamento de 1 (uma) unidade de medida.

•	A quantidade da reserva a ser criada para cada depósito neste caso deve ser arredondada para o número inteiro mais próximo;
•	Caso a necessidade seja menor que 0,5, deverá ser considerada como zero;
•	Caso a necessidade total sem embalagem for menor ou igual ao estoque total o valor a ser considerado para uso da distribuição crítica será a necessidade caso contrário considerar a disponibilidade de estoque;
•	A quantidade da reserva a ser criada para o depósito é igual a: 
o	[(necessidade do depósito sem arredondamento) / (necessidade de todos os depósitos sem arredondamento)] * o valor definido no item acima.
