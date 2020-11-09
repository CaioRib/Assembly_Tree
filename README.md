# Assembly Binary Tree

### 9 de abril de 2018

O objetivo deste trabalho é implementar em Assembly MIPS uma Árvore de Busca Digital Binária
(Árvore Digital Binária, Binary Tree ou Bitwise Trie), para armazenar e recuperar números binários.
O programa em assembly MIPS feito será executado no simulador SPIM ou no MARS.

As opções previstas para esta aplicação são: inserção, remoção, busca e visualização da
Árvore Digital Binária. Estas quatro opções são acessadas via um menu, acrescido apenas da
opção de finalização da aplicação, como última opção. A visualização da árvore deve ser feita por
amplitude, onde cada linha impressa contém os nós de um determinado nível da árvore
(começando pela raiz). A operação de busca deve retornar o valor da chave pesquisada e o
caminho usado na árvore para a encontrar, ou -1 caso a chave pesquisada não tenha sido
encontrada.


## Exemplos de entrada
### Inserção
__________________________________________________________________
Digite o binário para inserção: 10010011

Chave inserida com sucesso.
__________________________________________________________________
Digite o binário para inserção: 10010011

Chave repetida. Inserção não permitida.
__________________________________________________________________
Digite o binário para inserção: 12345678

Chave inválida. Insira somente números binários (ou -1 retorna ao menu).
__________________________________________________________________
Digite o binário para inserção: -1
Retornando ao menu.
__________________________

### Remoção
__________________________________________________________________
Digite o binário para remoção: 00

Chave encontrada na árvore: 00

Caminho percorrido: raiz, esq, esq

Chave removida com sucesso.
__________________________________________________________________
Digite o binário para remoção: 0

Chave não encontrada na árvore: -1.

Caminho percorrido: raiz, esq
__________________________________________________________________
Digite o binário para remoção: 120

Chave inválida. Insira somente números binários (ou -1 retorna ao menu).
__________________________________________________________________
Digite o binário para remoção: -1

Retornando ao menu.
_________________________________________________________________

### Busca
__________________________________________________________________
Digite o binário para busca: 00

Chave encontrada na árvore: 00

Caminho percorrido: raiz, esq, esq
__________________________________________________________________
Digite o binário para busca: 1010

Chave encontrada na árvore: 1010

Caminho percorrido: raiz, dir, esq, dir, esq
__________________________________________________________________
Digite o binário para busca: 0

Chave não encontrada na árvore: -1

Caminho percorrido: raiz, esq
__________________________________________________________________
Digite o binário para busca: 120

Chave inválida. Insira somente números binários (ou -1 retorna ao menu).
__________________________________________________________________
Digite o binário para busca: -1

Retornando ao menu.
___________________________

