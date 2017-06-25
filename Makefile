all:
	flex grammar.l
	yacc -d grammar.y
	gcc -o grammar lex.yy.c y.tab.c -lfl -ly
clean:
			rm lex.yy.c y.tab.c y.tab.h