# Trabalho 1 - SCC0112 - Organizacao de Computadores I
# Bitwise Trie - Assembly MIPS
# Testado com Mars 4.5
# Funciona tambem com o QtSpim 9.1.18, mas nao reconhece a chamada 34 do syscall, que imprime o endereco em hexadecimal.

# Caio Abreu de Oliveira Ribeiro      - nUSP 10262839
# Vinicius Torres Dutra Maia da Costa - nUSP 10262781
# Gabriel Citroni Uliana              - nUSP 9779367
# Daniel Penna Chaves Bertazzo        - nUSP 10349561

# A participacao dos integrantes foi equivalente na elaboracao do trabalho, realizando reunioes
#para discutir os algoritmos e utilizando ferramentas para programar em grupo (como o atom teletype).

		              .data

str_menu:         .asciiz "1 - Insercao\n2 - Remocao\n3 - Busca\n4 - Visualizacao\n5 - Fim\n\nEscolha uma opção (1 a 5): "
str_retorno:      .asciiz ">> Retornando ao menu.\n\n"

str_ins:          .asciiz ">> Digite o binario para insercao: "
str_rem:          .asciiz ">> Digite o binario para remocao: "
str_busca:        .asciiz ">> Digite o binario para busca: "

str_ins_suc:      .asciiz ">> Chave inserida com sucesso\n"
str_ins_rep:      .asciiz ">> Chave repetida. Insercao nao permitida\n"
str_inv_key:      .asciiz ">> Chave invalida. Insira somente numeros binarios (ou -1 retorna ao menu)\n"

str_key:          .asciiz ">> Chave encontrada na arvore: "
str_not_found:    .asciiz ">> Chave nao encontrada na arvore: -1\n"
str_path:         .asciiz ">> Caminho percorrido: raiz"
str_new_line:     .asciiz "\n"

str_esq:          .ascii ", esq"
str_dir:          .ascii ", dir"

str_null:         .asciiz "null"
str_N:            .asciiz ">> N"
str_NT:           .asciiz "NT, "
str_T:            .asciiz "T, "
str_sep:          .asciiz ", "
str_root:         .asciiz " (raiz, "
str_zero:         .asciiz " (0, "
str_one:          .asciiz " (1, "
str_close:        .asciiz ")"


mem_space_input:  .space 16 #espaco alocado para string de entrada
mem_space_output: .space 80 #espaco alocado para string de saida (caminho percorrido)

	.globl main
	.text


main:
	li $s7, 48       # $s7 = 0 na tabela ascii
  li $s6, 49       # $s6 = 1 na tabela ascii
  li $s5, 10       # $s5 = '/n' em ascii
	li $s4, 45			 # $s4 = '-' em ascii

	jal new_node  	 #inicializa a arvore
	move $s0, $v0 	 #s0 = retorno do new node, endereco para o inicio da arvore

#Loop enquanto o usuario nao seleciona o fim do programa
loop_menu:
	jal print_menu   #chamada da funcao que imprime o menu
	li $v0, 5        #leitura da opcao escolhida
	syscall
	move $t0, $v0 	 # $t0 = opcao escolhida

	li $t1, 1	    	 # 1 => insert
	li $t2, 2	    	 # 2 => remove
	li $t3, 3	    	 # 3 => search
	li $t4, 4	    	 # 4 => visualize
	li $t5, 5	    	 # 5 => exit

	li $v0, 4
	la $a0, str_new_line  #print "\n"
	syscall

	move $a0, $s0		 #$a0 = endereco para o inicio da arvore
	#teste de qual funcao deve ser chamada
	beq $t0, $t1, insert
	beq $t0, $t2, remove_test
	beq $t0, $t3, search
	beq $t0, $t4, visualize_root
	beq $t0, $t5, EXIT

EXIT:
    li $v0, 10
    syscall
#*************FIM DA MAIN*************#

#************IMPRIME O MENU***********#
 print_menu:
    la $a0, str_menu
    li $v0, 4
    syscall
		jr $ra
#*********FIM DO IMPRIME MENU*********#

#*********LEITURA E VERIFICACAO DA STRING DE ENTRADA*********#
#verifica caso a string de entrada seja diferente de binario ou
#seja -1, retornando a flag de erro em $v1 e end. para a string em $v0
read_verify_string:
	#Leitura da string de entrada
  li $v0, 8
  la $a0, mem_space_input 	#espaco para alocar a string
  li $a1, 16              	#16 bytes vao ser lidos
  syscall

  move $t4, $a0     #$t4 guarda o endereco do inicio string
	move $t0, $a0	 	  #$t0 recebe endereco da string para percorre-la
	move $t1, $zero		#zera inicialmente o $t1

#loop para percorrer a string de entrada
loop_verify_string:
	lb $t1, 0($t0)                    #$t1 recebe byte atual da string
	addi $t0, $t0, 1                  #$t0 percorre a string, itera 1 byte no valor do endereco da string
	beq $t1, $s7, loop_verify_string  #caso o caractere seja 0, avanca um byte na string
	beq $t1, $s6, loop_verify_string  #caso o caractere seja 1, avanca um byte na string
 #***fim do loop_verify_string***#

	beq $t1, $s5, remove_linefeed  #caso encontre um '\n', retira-o da string e substitui por '\0'

	#caso em que econtra o '-1' na string, retorna -1 em  $v1
	bne $t1, $s4, invalid_key      #caso nao for '-', string invalida
	lb $t1, 0($t0)                 # $t1 recebe proximo byte da string
	bne $t1, $s6, invalid_key      #caso nao for '1', string invalida
	lb $t1, 1($t0)                 # $t1 recebe o proximo byte atual da string
	bne $t1, $s5, invalid_key      #caso nao for '\n', string invalida

#caso usuario digite string "-1"
return_menu:
	li $v0, 4
	la $a0, str_retorno	  #imprime string de retorno ao menu
	syscall

	li $v1, -1 						#$v1 flag de retorno ao menu
	jr $ra

#caso o usuario digite uma string diferente de binario ou "-1"
invalid_key:
	li $v0, 4
	la $a0, str_inv_key		#imprime string de string invalida
	syscall

	li $v1, 0  						#flag de erro (string invalida)
	jr $ra

remove_linefeed:
	sb $zero, -1($t0) 		#insere o '/0' no fim da string, substituindo o /n
	move $v0, $t4 	  		#$v0 = retorna endereco para o inicio da string
	li $v1, 1		      		#flag 1, indica que a string esta correta
	jr $ra
#*******FIM DO read_verify_string*************#


#************INICIO DO NEW NODE***************#
#funcao que aloca um novo no, retornando $v0 com endereco do no alocado
new_node:
  #empilha
  addi $sp, $sp, -8
  sw $a0, 4($sp)
  sw $ra, 0($sp)

  li $a0, 9
  li $v0, 9 #aloca o espaco de 9 bytes(0-3 = filho esquerdo, 4-7 = filho direito, 8 = indicador de terminal)
  syscall

  sw $zero, 0($v0)  #no filho esquerdo = NULL
  sw $zero, 4($v0)  #no filho direito  = NULL
  sb $zero, 8($v0)  #flag de nao terminal(0)

  #desempilha
  lw $a0, 4($sp)
  lw $ra, 0($sp)
  addi $sp, $sp, 8

  jr $ra
#***********FIM DO NEW NODE***********#

#************INICIO DA INSERCAO************#
#funcao de insercao de uma nova chave na arvore, verificando se a chave
#eh valida(nao eh repetida) e chamando a funcao novamente enquanto o usuario
#nao inserir '-1' para retornar ao menu
insert_test: 								#verificacao para caso seja retorno ao menu
	li $t1, -1
	beq $v1, $t1, loop_menu 	#retorno ao menu

insert:
  addi $sp, $sp, -16
	sw 	 $a0, 12($sp) #salva valor de $a0
  sw   $ra, 8($sp)  #salva valor de $ra
  sw 	 $s0, 4($sp)  #salva valor de $s0
  sw 	 $s1, 0($sp)  #salva valor de $s1

  move $s0, $a0     #move o endereco da raiz passado por argumento em $a0 para $s0
  la $a0, str_ins		#imprime string de insercao
  li $v0, 4
  syscall

  jal read_verify_string  		#le e verifica a string de entrada
	li $t1, 1
	bne $v1, $t1, return_insert  #caso a string nao esteja correta, flag retornada em $v1 diferente de 1, brench para o fim da funcao

  move $s1, $v0     # $s1 guarda o endereco do inicio string
  move $t1, $zero   # zerar os bytes de $t1
	move $t0, $s1     # $t0 recebe o endereco para o inicio da string de entrada
	lb $t1, 0($t0)    # $t1 recebe primeiro byte da string

#*****INICIO DO loop de insercao*****#
loop_insert:
  beq $t1, $s6, insert_1  # caso o byte de insercao atual seja 1, avanca para insercao de 1

insert_0:
  lw  $t4, 0($s0)  						# $t4 = endereco para o proximo nó esquerdo
	bne $t4, $zero, next_node	 	# caso o no nao seja null, avanca a arvore para o filho esquerdo
  jal new_node    						# caso seja null, cria um novo no
  sw $v0, 0($s0)  						# filho esquerdo do no atual = endereco do novo no passado por $v0
  j next_node 								# avanca para o filho esquerdo

insert_1:
  lw $t4, 4($s0)   						# $t4 = endereco para o proximo nó direito
  addi $s0, $s0, 4 						# somando 4 bytes no endereco de $s0(no atual), deslocando o offset para endereco do no direito
  bne $t4, $zero, next_node 	# caso o nó nao seja null, avanca a arvore para o filho direito
  jal new_node    						#	caso seja null, cria um novo no
  sw $v0, 0($s0) 							#	filho direito do no atual = endereco do novo no passado por $v0

next_node:
	lw $s0, 0($s0)							#avanca a arvore para o proximo no da arvore
	lb $t5, 8($s0)	 						#guarda o valor terminal ou nao terminal do no atual

	addi $t0, $t0, 1							#percorre a string de entrada, deslocando 1 byte no valor do endereco da string
	lb $t1, 0($t0)   							#$t1 = byte atual da string
	bne $t1, $zero, loop_insert  	#permanece no loop ate encontrar o '\0'
#*****FIM DO LOOP_INSERT*****#

	li $t1, 1      							# $t1 = indicador de node terminal(1)
	bne $t5, $t1, end_insert 	  #caso o ultimo node percorrido na arvore nao seja um no terminal, insercao correta

	li $v0, 4										#erro de insercao com chave repetida, print string de erro
	la $a0, str_ins_rep
	syscall
	j return_insert

end_insert:
	sb $t1, 8($s0) 				#atribui ao ultimo byte do ultimo node percorrido na arvore o indicador de node terminal
	li $v0, 4
	la $a0, str_ins_suc   #print da string de insercao correta
	syscall

return_insert:
	#libera pilha
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	lw $a0, 12($sp)
	addi $sp, $sp, 16

	j insert_test 			#retona para nova insercao, caso a string de entrada nao seja de retorno ao menu
#*************FIM DA INSERCAO***************#

#*************INICIO DA BUSCA***************#
#funcao de busca de uma chave na arvore, verificando se a chave
#eh valida(existe na arvore), printando o caminho percorrido na arvore
#e chamando a funcao novamente enquanto o usuario nao inserir '-1' para retornar ao menu
search_test:
	li $t1, -1
	beq $v1, $t1, loop_menu		#verifica o caso de retorno ao menu, flag em $v1
search:
	#empilha
	addi $sp, $sp, -16
	sw   $a0, 12($sp) #salva valor de $a0
  sw   $ra, 8($sp)  #salva valor de $ra
  sw 	 $s0, 4($sp)  #salva valor de $s0
  sw 	 $s1, 0($sp)  #salva valor de $s1

	move $s0, $a0     #salva o endereco da raiz passado por $a0 em $s0

  la $a0, str_busca #imprime string de busca
  li $v0, 4
  syscall

  jal read_verify_string       #leitura e verificacao da string de entrada
	li $t1, 1
	bne $v1, $t1, return_search  #caso a string nao seja binario, flag em $v1 diferente de 1, brench para o fim da funcao

	move $s1, $v0     #$s1 = sempre guarda o endereco do inicio string, sendo retornado apos a leitura em $v0
	move $t1, $zero   #zerar os bytes de $t1
	move $t0, $v0     #$t0 = recebe o endereco para o inicio da string

	la $t6, mem_space_output #$t6 = endereco para a string output
	sb $zero, 0($t6) 				 #coloca '\0' no primeiro byte para evitar impressao de caminhos anteriores
loop_search:
	lb $t1, 0($t0)    									# $t1 = byte atual da string
	beq $t1, $zero, check_if_terminal 	#caso o byte atual seja '\0'
	beq $t1, $s6, next_node_right   		#caso o byte atual seja 1

next_node_left:
	lw $t4, 0($s0)  								# $t4 = endereco para o proximo nó esquerdo
	beq $t4, $zero, error_search 		# caso o nó seja null, erro na busca
	lw $s0, 0($s0)  								# avanca para o proximo no esquerdo
	lb $t7, 8($s0)									# guarda a flag terminal do no (terminal ou nao terminal)
	addi $t0, $t0, 1                                # avanca 1 byte na string

	la $t4, str_esq 		 #$t4 = endereco para string esquerda
	li $t2, 0 					 #$t2 = contador de vezes que o loop de preencher a string iterou
	li $t3, 5 					 #define $t3 como 5 (condicao de parada do loop)
loop_output_path_left: #loop que adiciona na string do caminho a str_esq (foi para a esquerda)
	lb $t5, 0($t4)  		 #$t5 = byte da string: ", esq"
	sb $t5, 0($t6)       #mem_space_output = byte da string
	addi $t4, $t4, 1 		 #desloca 1 byte na string esquerda
	addi $t6, $t6, 1 		 #desloca 1 byte na string de saida
	addi $t2, $t2, 1 		 #incrementa $t2 em uma unidade
	bne $t2, $t3, loop_output_path_left #compara $t2 com $t3 para ver se o loop continua ou nao

	j loop_search  #volta para o loop de busca

next_node_right:
	lw $t4,  4($s0)   				   # $t4 = endereco para o proximo no direito
	beq $t4, $zero, error_search # caso o nó seja null, erro na busca
	lw $s0, 4($s0)    				   # avanca para o proximo no direito
	lb $t7,  8($s0)   					 # guarda a flag terminal do no (terminal ou nao terminal)
	addi $t0, $t0, 1    				 # avanca 1 byte na string

	la $t4, str_dir     		     #$t4 = endereco para string direita
	li $t2, 0 			     			   #$t2 = contador de vezes que o loop de preencher a string rodou
	li $t3, 5 			   	  			 #define $t3 como 5 (condicao de parada do loop)
loop_output_path_right: 			 #loop que adiciona na string do caminho a str_dir (foi para a direita)
	lb $t5, 0($t4)  		 			   #$t5 = byte da string: ", dir"
	sb $t5, 0($t6)			 			   # mem_space_output = byte da string
	addi $t4, $t4, 1 		 			   #desloca 1 byte na string esquerda
	addi $t6, $t6, 1 		  		   #desloca 1 byte na string de saida
	addi $t2, $t2, 1 		  		   #incrementa $t2 em uma unidade
	bne $t2, $t3, loop_output_path_right #compara $t2 com $t3 para ver se o loop continua ou nao

	j loop_search # volta para o loop de busca

check_if_terminal:
	li $t1, 1 	                 #flag terminal = 1
	beq $t7, $t1, success_search #caso for terminal, busca correta

error_search:
	li $v0, 4
	la $a0, str_not_found        #imprime string de erro (string buscada nao encontrada na arvore)
	syscall
	j end_search

success_search:
	#imprime a string de caminho encontrado com sucesso
	li $v0, 4
	la $a0, str_key
	syscall

	move $a0, $s1
	syscall

	la $a0, str_new_line
	syscall

end_search:
	#imprime a string de caminho percorrido
	sb $zero, 0($t6)
	la $a0, str_path
	syscall

 	la $a0, mem_space_output
	syscall

	la $a0, str_new_line
	syscall

return_search:
	#libera pilha
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	lw $a0, 12($sp)
	addi $sp, $sp, 8
	j search_test
#****************FIM DA BUSCA*****************#

#**************INICIO DA REMOCAO**************#
#funcao de remocao, que verifica de uma chave esta presente na arvore e, se sim,
#remove-a. Caso contrario, nao altera a arvore.

remove_test: #loop que mantem a chamada de remove ate que seja digitado -1
	#empilha
	addi $sp, $sp, -8
	sw $v0, 4($sp)
	sw $a0, 0($sp)

	la $t6, mem_space_output #$t6 = endereco para a string output
	sb $zero, 0($t6)         #coloca '\0' no primeiro byte para evitar impressao de caminhos anteriores

	jal remove               #comeco da funcao remove propriamente dita

	li $t5, -1
	beq $t5, $v1, removal_return_menu #caso o retorno da funcao seja -1, nao imprime as strings de saida

#impressao do caminho percorrido:
	li $v0, 4
	la $a0, str_path
	syscall

	la $a0, mem_space_output
	syscall

	la $a0, str_new_line
	syscall

removal_return_menu:
	#desempilha
	lw $v0, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 4

	#volta para o menu, em caso o retorno da funcao em $v1 tenha sido -1
	beq $v1, $t5, loop_menu

	j remove_test
	#***loop do remove***#


remove:
	move $s0, $a0 #guarda em $s0 o valor inicial da raiz da arvore, recebido por argumento em $a0

	# Imprime string de remocao
	li $v0, 4
	la $a0, str_rem
	syscall

	#empilha
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal read_verify_string #verifica se a string a ser removida esta escrita corretamente

	#desempilha
	lw $ra, 0($sp)
	addi $sp, $sp, 4


	li $t4, 1
	bne $v1, $t4, remove_return #em caso de string invalida ($v1 == 1), termina encerra a funcao

	move $s3, $v0   # s3 = endereco do inicio da string (fixo)
	move $s1, $v0	  # s1 = endereco do inicio da string (iteravel)
	move $s2, $s0   # s2 = endereco do no anterior ao s1, mas inicializado como s0
	move $t1, $zero	# t1 = zera os 4 bytes de t1

recursive_remove: #inicio da recursao de remocao
	#empilha
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)

	#iteracao da string
	lb $t1, 0($s1)   #$t1 recebe o byte atual da string
	addi $s1, $s1, 1 #itera s1, adicionando-a de um byte

	beq $t1, $zero, removal_first_base_case #caso o byte atual seja '\0'
	beq $t1, $s6, removal_next_right        #caso o byte atual seja 1

removal_next_left:
	lw $t2, 0($s0)                 #$t2 recebe o endereco do filho esquerdo de s0
	beq $t2, $zero, removal_error  #caso o filho esquerdo de s0 seja null, ocorreu erro
	move $s2, $s0									 #$s2 guarda o endereco atual de s0, o qual sera o pai de s0
	lw $s0, 0($s0)								 #atualiza $s0 ($s0 = filho esquerdo de $s2)

	#escreve ", esq"
	la $t4, str_esq     #$t4 = endereco para string esquerda
	li $t5, 0 		    	#$t5 = contador de vezes que o loop de preencher a string rodou
	li $t8, 5 			    #define $t8 como 5, para iterar no loop

removal_loop_output_path_left: #loop que adiciona na string do caminho a string de node esquerdo
	lb $t7, 0($t4)    #$t7 = byte da string: ", esq"
	sb $t7, 0($t6)  	# mem_space_output = byte da string
	addi $t4, $t4, 1  #desloca 1 byte em str_esq
	addi $t6, $t6, 1  #desloca 1 byte na string de saida
	addi $t5, $t5, 1  #incrementa o contador em uma unidade
	bne $t5, $t8, removal_loop_output_path_left
	#***fim do loop removal_loop_output_path_left***#

	move $t7, $zero #coloca '\0' no fim da string de output
	sb $t7, 0($t6)

	jal recursive_remove       #chamada recursiva, avanca um nivel na arvore
	j remove_general_base_case #primeiro retorno, para um caso base primario

removal_next_right:
	lw $t2, 4($s0)
	beq $t2, $zero, removal_error
	move $s2, $s0
	lw $s0, 4($s0)

  #escreve ", dir"
	la $t4, str_dir     #$t4 = endereco para string direita
	li $t5, 0 			    #$t5 = contador de vezes que o loop de preencher a string rodou
	li $t8, 5 			    #define $t8 como 5, para iterar no loop

removal_loop_output_path_right: #loop que adiciona na string do caminho a string de node direito
	lb $t7, 0($t4)   #$t7 = byte da string: ", dir"
	sb $t7, 0($t6)	 # mem_space_output = byte da string
	addi $t4, $t4, 1 #desloca 1 byte em str_dir
	addi $t6, $t6, 1 #desloca 1 byte na string de saida
	addi $t5, $t5, 1 #incrementa o contador em uma unidade
	bne $t5, $t8, removal_loop_output_path_right

	move $t7, $zero #coloca '\0' no fim da string de output
	sb $t7, 0($t6)

	jal recursive_remove         #chamada recursiva, avanca um nivel na arvore
	j remove_general_base_case   #primeiro retorno, para um caso base primario

removal_first_base_case:        #caso base inicial, em que no terminal tem que ser removido
	move $t2, $zero               #zera o conteudo de $t2
	lb $t2, 8($s0)                #guarda o indicador de no terminal de $s0 em $t2
	beq $t2, $zero, removal_error #testa se o no eh terminal. Caso negativo, ocorreu erro.

	li $v0, 4
	la $a0, str_key               #imprime mensagem de busca bem sucedida
	syscall

	move $a0, $s3                 #imprime a string lida
	syscall

	la $a0, str_new_line          #imprime '\n'
	syscall

	#checa se eh folha
	lw $t2, 0($s0)                       #carrega em t2 o endereco do filho esquerdo de s0
	bne $t2, $zero, remove_flag_terminal #caso o filho esquerdo de s0 nao seja null, s0 nao necessita ser removido
	lw $t2, 4($s0)	                     #carrega em t2 o endereco do filho direito de s0
	bne $t2, $zero, remove_flag_terminal #caso o filho direito de s0 nao seja null, s0 nao necessita ser removido

	lw $t2, 0($s2)                       #$t2 recebe filho direito de $s2
	beq $t2, $s0, remove_last_node       #caso em que $s0 eh filho esquerdo de $s2, deve ser removido

	addi $s2, $s2, 4
	lw $t2, 0($s2)                       #$t2 recebe filho direito de $s2
	beq $t2, $s0, remove_last_node       #caso em que $s0 eh o filho direito de $s2, deve ser removido

remove_general_base_case:     #caso base geral, em que no terminal nao deve ser removido
	lw $s2, 8($sp)              #recupera o valor de $s2 da pilha
	lw $s0, 0($sp)              #recupera o valor de $s0 da pilha


	move $t2, $zero             #zera o conteudo de $t2
	lb $t2, 8($s0)              #$t2 recebe o indicador de terminal de $s0
	bne $t2, $zero, remove_end  #caso o no nao seja terminal, termina a funcao


	lw $t2, 0($s0)             # carrega em t2 o endereco do filho esquerdo de s0
	bne $t2, $zero, remove_end # caso o filho esquerdo de s0 nao seja null, s0 nao necessita ser removido
	lw $t2, 4($s0)	           #carrega em t2 o endereco do filho direito de s0
	bne $t2, $zero, remove_end # caso o filho direito de s0 nao seja null, s0 nao necessita ser removido


	lw $t2, 0($s2)                 #$t2 recebe filho esquerdo de $s2
	beq $t2, $s0, remove_last_node #remove o filho esquerdo

	addi $s2, $s2, 4
	lw $t2, 0($s2)                  #$t2 recebe filho direito de $s2
	beq $t2, $s0,  remove_last_node #remove o filho direito

	j remove_end

remove_flag_terminal: #caso a string a ser removida nao termine em um no folha
	sb $zero, 8($s0)    #apenas muda o marcador de terminal do no para zero (nao-terminal)
	j remove_end

remove_last_node:
	sw $zero, 0($s2)    #filho do no pai ($s2) recebe NULL (deleta o no folha)

remove_end:           #retorno da funcao, recuperando os elementos empilhados
	#desempilha
	lw $ra, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16

	jr $ra

removal_error:          #caso tenha tentado remover um no sem a marcacao de terminal
	li $v0, 4
	la $a0, str_not_found #imprime string de erro
	syscall

	jr $ra

remove_return:          #em caso de string invalida, retorna imediatamente
	jr $ra

#**************Fim remocao***************#


#**********Incicio Visualizacao**********#
#funcao que imprime a arvore em largura, imprimindo os nodes de cada nivel
#da arvore na formatacao definida pelo trabalho

visualize_root:			 #na primeira chamada da visualizacao, imprime o node raiz
	#empilha
	addi $sp, $sp, -12
	sw $a0, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	move $t0, $a0 			#$t0 recebe o endereco para a raiz passado em $a0
	#imprime 'N' - nivel
	li $v0, 4
	la $a0, str_N
	syscall
	#imprime nivel atual (raiz = 0)
	li $v0, 1
	li $a0, 0
	syscall
	#imprime raiz
	li $v0, 4
	la $a0, str_root
	syscall
	#imprime a flag nao terminal
	li $v0, 4
	la $a0, str_NT
	syscall

print_left_root: 												#imprime endereco do filho esquerdo da raiz
	lw $t3, 0($t0)												#$t3 recebe endereco do filho esquerdo
	beq $t3, $zero, print_null_left_root 	#caso o filho esquerdo seja null, imprime null

	li $v0, 34 				#imprime em hexadecimal o endereco para o no filho esquerdo
	move $a0, $t3
	syscall

	li $v0, 4
	la $a0, str_sep 	#imprime separacao ", "
	syscall
	j print_right_root

print_null_left_root: 	#caso filho esquerdo da raiz seja nulo
	li $v0, 4
	la $a0, str_null 			#imprime null para o endereco do filho esquerdo
	syscall

	li $v0, 4
	la $a0, str_sep				#imprime separacao ", "
	syscall

print_right_root:  												#imprime endereco do filho direito da raiz
	lw $t3, 4($t0)													# $t3 recebe endereco do filho direito
	beq $t3, $zero, print_null_right_root 	#caso o filho direito seja null

	li $v0, 34 			#imprime em hexadecimal
	move $a0, $t3 	#endereco para o node filho direito
	syscall

	li $v0, 4
	la $a0, str_close 		#imprime fim do node raiz ")"
	syscall

	li $v0, 4
	la $a0, str_new_line 	#imprime "\n"
	syscall

	j visualize_trie

print_null_right_root:	#caso filho direito da raiz seja nulo
	li $v0, 4
	la $a0, str_null			#imprime null para o endereco do filho direito
	syscall

	la $a0, str_close     #imprime fim do node raiz ")"
	syscall

	li $v0, 4
	la $a0, str_new_line  #imprime '\n'
	syscall

visualize_trie:
	lw $a0, 8($sp)		#a0 recebe o valor na pilha, endereco para a raiz da arvore

	jal max_depth     #chamada para a funcao que calcula a altura da arvore
	move $t0, $v0			#$t0 recebe o tamanho da arvore passada por $v0

	move $s0, $a0 		# s0 recebe o endereco para a raiz
	li $t1, 1  				# $t1 = inicia no nivel 1

	beq $t0, $t1, end_visualize    #caso a arvore so tenha a raiz, finaliza a visualizacao

#***Inicio do loop_visualize***#
loop_visualize: 	#loop para printar os niveis da arvore
	li $v0, 4
	la $a0, str_N  	#imprime ">>N"
	syscall

	move $a0, $t1 	#$a0 recebe nivel atual da arvore que sera impresso
	li $v0, 1				#imprime o nivel atual
	syscall

	move $a1, $s0 	#a1 = endereco para o no raiz
	move $a0, $t1 	#a0 = nivel a ser impresso

	jal print_tree  #chamada para a funcao recursiva que imprime o nivel

	li $v0, 4
	la $a0, str_new_line 					#imprime '/n'
	syscall

	addi $t1, $t1, 1    					#aumenta um nivel na arvore
	bne $t1, $t0, loop_visualize 	#caso nao seja o nivel maximo, retorna ao loop
#***fim do loop_visualize***#

end_visualize:					 #fim da visualizacao e retorno ao menu

	li $v0, 4
	la $a0, str_new_line 	#imprime "\n"
	syscall
	#desempilha
	lw $a0, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12

	j print_menu  				#retorna ao menu

#inicio da funcao recursiva que imprime o nivel atual
print_tree:   #$a0 - nivel a ser imprimido, $a1 - endereco para o node atual
	#empilha
	addi $sp, $sp, -12
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	sw $ra, 0($sp)

print_test_null:
	bne $a1, $zero, print_level 	#caso o node atual nao seja null, testa se o nivel deve ser printado
	j print_return 								#caso o node seja null, jump para o retorno da funcao

print_level:
	bne $a0, $zero, print_recursive #caso o nivel nao tenha zerado, jump para a chamada recursiva

#*************printar data*************#
	move $t4, $a0 							#guarda o $a0 em $t4 temporariamente

	bne $t3, $zero, print_one 	#caso o node seja direito, represente o byte 1, imprime o digito 1

print_zero:
	la $a0, str_zero 						#imprime o digito 0
	li $v0, 4
	syscall

	j print_node								#continua a impressao do no

print_one:
	la $a0, str_one 						#imprime o digito 1
	li $v0, 4
	syscall

print_node:
	lb $t3, 8($a1)									#$t3 recebe o byte que indica a flag terminal ou nao terminal
	bne $t3, $zero, print_terminal 	#verifica se o no atual e terminal, jump para imprimir string terminal

print_not_terminal:
	la $a0, str_NT 									#imprime a string de nao terminal
	li $v0, 4
	syscall
	j print_left_node  							#jump para impressao do filho esquerdo

print_terminal:
	la $a0, str_T  									#imprime a string de terminal
	li $v0, 4
	syscall

print_left_node:
	lw $t3, 0($a1)												#$t3 recebe endereco do filho esquerdo
	beq $t3, $zero, print_null_left_node 	#verifica se o filho esquerdo eh NULL. Se sim, imprime null na string output

	li $v0, 34														#impressao de hexadecimal
	move $a0, $t3   									    #imprime o endereco do no esquerdo em hexadecimal
	syscall

	li $v0, 4
	la $a0, str_sep 											#imprime a string separacao ", "
	syscall
	j print_right_node

print_null_left_node:                   #imprime a string "null" caso o filho esquerdo seja nulo
	li $v0, 4
	la $a0, str_null
	syscall

	li $v0, 4
	la $a0, str_sep												#imprime a string separacao ", "
	syscall

print_right_node:
	lw $t3, 4($a1)													#$t3 recebe endereco do filho direito
	beq $t3, $zero, print_null_right_node 	#caso o filho esquerdo seja null

	li $v0, 34 															#imprime em hexadecimal
	move $a0, $t3 													#imprime o endereco do no direito em hexadecimal
	syscall

	li $v0, 4
	la $a0, str_close 											#imprime a string ")"
	syscall
	j end_print_data												#jump para o fim da impressao do node

print_null_right_node:	#imprime a string "null" caso o filho direito seja nulo
	li $v0, 4
	la $a0, str_null
	syscall

	la $a0, str_close			#imprime a string ")"
	syscall

end_print_data:
	move $a0, $t4			#recupera o valor de $a0
	j print_return		#jump para o retorno da funcao
#*************imprimir data***************#

print_recursive:

	li $t3, 0 					#$t3 = flag de node esquerdo
	addi $a0, $a0, -1 	#diminui um nivel, iniciando no nivel a ser impresso e decrementando ate 0
	lw $a1, 0($a1)			#$a1 recebe o endereco para o filho esquerdo
	jal print_tree			#jump para imprimir o nivel, caso seja o correto a ser impresso

	lw $a0, 8($sp)     	#$a0 recebe o nivel da arvore que foi empilhado na recursao
	lw $a1, 4($sp)			#$a1 recebe o endereco do node que foi empilhado na recursao


	li $t3, 4						#$t3 = flag de node direito
	addi $a0, $a0, -1 	#diminui um nivel, iniciando no nivel a ser impresso e decrementando ate 0
	lw $a1, 4($a1)    	#$a1 recebe o endereco para o filho direito
	jal print_tree    	#jump para imprimir o nivel, caso seja o correto a ser impresso

print_return:
	#desempilha
	lw $a0, 8($sp)
	lw $a1, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	jr $ra

#********Altura Maxima**********#
#funcao que retorna a altura maxima da arvore, recebendo a raiz da arvore em $a0
#e retornando em $v0 a altura da arvore.
max_depth:
	#empilha
	addi $sp, $sp, -8
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	move $s0, $a0 #guarda em $s0 o endereco para o inicio da arvore

	li $t0, 0 	  #guarda a altura da sub-arvore esquerda
	li $t1, 0 	  #guarda a altura da sub-arvore direita

	jal max_depth_recursive #primeira parte da chamada recursiva da funcao de calcular a altura

	#desempilha
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8

	jr $ra

max_depth_recursive:
	#empilha
	addi $sp, $sp, -16
	sw $s0, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp)
	sw $t0, 0($sp)


	beq $s0, $zero, max_depth_first_return #caso base: chegou em $s0 = NULL

	lw $s0, 0($s0)           #guarda em $s0 o endereco para o filho esquerdo de $s0
	jal max_depth_recursive  #chama recursivamente a funcao de calcular altura para o filho da esquerda
	move $t0, $v0            #atribui a $t0 o retorno da funcao

	lw $s0, 12($sp)          #recupera o valor de $s0 guardado na pilha (peek)
	lw $s0, 4($s0)
	jal max_depth_recursive  #chama recursivamente a funcao de calcular altura para o filho da direita
	move $t1, $v0            #atribui a $t1 o retorno da funcao

max_depth_base_case:
	slt $t3, $t1, $t0                     #caso altura da sub-arvore direita seja menor do que a esquerda, $t3 = 1
	bne $t3, $zero, max_depth_return_left #caso o t3 == 1, incremeta-se o tamanho da sub-arvore esquerda
																				#caso contrario, incrementa-se o tamanho da sub-arvore direita

max_depth_return_right:
	addi $v0, $t1, 1    #retorna em $v0 o valor de $t1, incrementado em uma unidade
	j max_depth_return

max_depth_return_left:
	addi $v0, $t0, 1    #retorna em $v0 o valor de $t0, incrementado em uma unidade
	j max_depth_return


max_depth_first_return:
	li $v0, 0           #retorna o valor 0 em $v0 no primeiro retorno das chamadas recursivas

max_depth_return:
	#desempilha
	lw $s0, 12($sp)
	lw $ra, 8($sp)
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 16

	jr $ra
