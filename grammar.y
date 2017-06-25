%token STRING INT DOUBLE PRODUCT NUMBER DOUBLENUMBER
%token CONSTID ID VAR
%left '+' '-'
%left '*' '/'

%{
	#include <stdio.h>
	int yylex(void);
	void yyerror(char *);
	int sym[26];
%}

%%

program		:	program statement '\n'
			|
			;

statement	:	expr					{ printf("%d\n", $1); }
			|	VAR '<' '-' expr		{ sym[$1] = $4; }
			;

expr		:	number 					{ $$ = $1; }
			|	VAR						{ $$ = sym[$1]; }
			|	expr '+' expr			{ $$ = $1 + $3; }
			|	expr '-' expr			{ $$ = $1 - $3; }
			|	expr '*' expr			{ $$ = $1 * $3; }
			|	expr '/' expr			{ $$ = $1 / (double)$3; }
			|	'(' expr ')'			{ $$ = $2; }
			;

number 		:	NUMBER 					{ $$ = $1; }
			|	'(' number ')' 			{ $$ = $1; }
			;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

int main(void) {
	yyparse();
	return 0;
}