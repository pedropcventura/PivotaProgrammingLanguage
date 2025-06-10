# Compila o compilador PPL
compiler: pivota.l pivota.y
	bison -d pivota.y
	flex pivota.l
	g++ -o compiler lex.yy.c pivota.tab.c -ll

# Executa o compilador com o arquivo de exemplo
run: compiler
	./compiler < example.pv

# Limpa os arquivos gerados
clean:
	rm -f compiler lex.yy.c pivota.tab.c pivota.tab.h output.v
