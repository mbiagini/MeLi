
%{
	#include <stdio.h>
	#include <string.h>
	#include "include/utils.h"
	int yylex(void);
	void yyerror(char *);
	extern int yylineno;
%}

%union {
  int intnum;
  char * string;
  float floatnum;

}

%token STRING INT DOUBLE PRODUCT
%token <string> VAR CONST STRINGVAL
%token <intnum> NUMBER
%token <floatnum> DOUBLENUMBER
%left '+' '-'
%left '*' '/'


%type <string> statement;
%type <string> expr;
%type <string> const_type;



%start program

%%

program		:	'$' '$' '\n' constList '$' '$' '\n' main
			|	main
			;

main		:  	main statement '\n'
			| 	/*NULL*/
			;

constList 	:	const constList 
			|	/* NULL */
			;

const 		:	const_type CONST '<' '-' expr ';' '\n'			{ if(validate($1,$5))
											printf("const %s  %s = %s;\n", $1,$2, $5);
										  else
											yyerror("WRONG CONST DECLARATION"); }
			;

const_type 	:	 STRING				{$$="char *";}
			| INT				{$$="int";}
			| DOUBLE			{$$="double";}
			| PRODUCT			{$$="void *";}
			;


statement	:	VAR '<' '-' expr';'		{ printf("%s = %s;\n",$1,$4); }
			;

expr		:	NUMBER	 					{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%d", $1); }
			|	DOUBLENUMBER						{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%f", $1); }
			| 	STRINGVAL						
			|	VAR						
			|	expr '+' expr			{ $$ = strcat(strcat($1,"+"), $3); }
			|	expr '-' expr			{ $$ = strcat(strcat($1,"-"), $3) ;}
			|	expr '*' expr			{ $$ = strcat(strcat($1,"*"), $3); }
			|	expr '/' expr			{ $$ = strcat(strcat($1,"/"), $3); }
			| '(' expr ')'				{ $$ = malloc((1+strlen($2)+1)*sizeof(*$$));
								  sprintf($$,"(%s)",$2);}
			;





%%

void yyerror(char *s) {
	fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main(void) {

    printf("#include <stdlib.h>\n");
	
    printf("int main(void) { \n");

    yyparse();

    printf("}\n");

    return 0;
}
