
%{
	#include <stdio.h>
	#include <string.h>
	int yylex(void);
	void yyerror(char *);
	int sym[26];
%}

%union {
  int intnum;
  char * string;
  float floatnum;

}

%token STRING INT DOUBLE PRODUCT  DOUBLENUMBER
%token CONSTID ID 
%token <string> VAR
%token <intnum> NUMBER
%left '+' '-'
%left '*' '/'


%type <string> statement;

%type <string> expr;

%type <intnum> number;


%start program


%%
program		:	program statement '\n'
			|
			;

statement	:	expr					{ printf("%s\n",$1); }
			|	VAR '<' '-' expr';'		{/* sym[$1] = $4;*/ printf("%s = %s;\n",$1,$4); }
			;

expr		:	number 					{ $$ = malloc(256*sizeof(*$$)) ; sprintf($$, "%d", $1); }
			|	VAR						{ /*$$ = sym[$1];*/ }
			|	'(' expr '+' expr ')'			{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$));  sprintf($$,"(%s+%s)",$2,$4); }
			|	'(' expr '-' expr ')'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$)); sprintf($$,"(%s-%s)",$2,$4);}
			|	'(' expr '*' expr')'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$)); sprintf($$,"(%s*%s)",$2,$4); }
			|	'(' expr '/' expr')'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1)*sizeof(*$$));  sprintf($$,"(%s/%s)",$2,$4);}
			|	expr '+' expr			{ $$ = strcat(strcat($1,"+"), $3); }
			|	expr '-' expr			{ $$ = strcat(strcat($1,"-"), $3) ;}
			|	expr '*' expr			{ $$ = strcat(strcat($1,"*"), $3); }
			|	expr '/' expr			{ $$ = strcat(strcat($1,"/"), $3); }
			;

number 		:	NUMBER 					{ $$ = $1; }
			|	'(' number ')' 			{ $$ = $2; }
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
