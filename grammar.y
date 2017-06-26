
%{
	#include <stdio.h>
	#include <string.h>
	int yylex(void);
	void yyerror(char *);
%}

%union {
  int intnum;
  char * string;
  float floatnum;

}

%token STRING INT DOUBLE PRODUCT
%token <string> VAR CONST
%token <intnum> NUMBER
%token <floatnum> DOUBLENUMBER
%left '+' '-'
%left '*' '/'


%type <string> statement;
%type <string> expr;
%type <intnum> wholeNum;
%type <floatnum> doubleNum;


%start program

%%

program		:	'$' '$' '\n' constList '$' '$' '\n' program
			|	program statement '\n'
			|	/* NULL */
			;

constList 	:	constList const
			|	/* NULL */
			;

const 		:	STRING CONST '<' '-' expr ';' '\n'
			|	INT CONST '<' '-' expr ';' '\n'				{ printf("const int %s = %s;\n", $2, $5); }
			|	DOUBLE CONST '<' '-' expr ';' '\n'			{ printf("const double %s = %s;\n", $2, $5); }
			|	PRODUCT CONST '<' '-' expr ';' '\n'
			;


statement	:	expr					{ printf("%s\n",$1); }
			|	VAR '<' '-' expr';'		{ printf("%s = %s;\n",$1,$4); }
			;

expr		:	wholeNum	 					{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%d", $1); }
			|	doubleNum 						{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%f", $1); }
			|	VAR						
			|	'(' expr '+' expr ')'			{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$));  sprintf($$,"(%s+%s)",$2,$4); }
			|	'(' expr '-' expr ')'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$)); sprintf($$,"(%s-%s)",$2,$4);}
			|	'(' expr '*' expr')'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$)); sprintf($$,"(%s*%s)",$2,$4); }
			|	'(' expr '/' expr')'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$));  sprintf($$,"(%s/%s)",$2,$4);}
			|	expr '+' expr			{ $$ = strcat(strcat($1,"+"), $3); }
			|	expr '-' expr			{ $$ = strcat(strcat($1,"-"), $3) ;}
			|	expr '*' expr			{ $$ = strcat(strcat($1,"*"), $3); }
			|	expr '/' expr			{ $$ = strcat(strcat($1,"/"), $3); }
			;

wholeNum  	:	NUMBER 					{ $$ = $1; }
			|	'(' wholeNum ')' 		{ $$ = $2; }
			;

doubleNum 	:	DOUBLENUMBER 			{ $$ = $1; }
			|	'(' doubleNum ')'		{ $$ = $2; }
			;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

int main(void) {

    printf("#include <stdlib.h>\n");
	
    printf("int main(void) { \n");

    yyparse();

    printf("}\n");

    return 0;
}
