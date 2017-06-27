
%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "include/utils.h"
	#include "include/types.h"
	#define MAX_VARS 5000


	int yylex(void);
	void yyerror(char *);
	extern int yylineno;

	

	VARIABLE  vars[MAX_VARS] = {0};

	int addVar(VARIABLE var){
		int i;

		for(i = 0 ; i < MAX_VARS && vars[i].name != NULL ; i++){
			if(strcmp(vars[i].name, var.name) == 0){
				return -1;
			}
		}

		if(i == MAX_VARS){
			return -2;
		}
		vars[i] = var;
		return i;	
	}

	int validateAsignation(char * name,char * content){
		int i;
		int found = 0;
		for(i = 0 ; i < MAX_VARS && vars[i].name != NULL && !found ; i++){
			if(strcmp(vars[i].name, name) == 0){
				found = 1;
			}
		}

		if(!found){
		   return -1;
		}
		if(vars[i-1].constant)
			return -3;

		switch(vars[i-1].type){
			case STRING_TYPE: return validate("char *",content) == 0 ? -2 : 1 ;
					  break;
			case INT_TYPE:return validate("int",content) == 0 ? -2 : 1;
				      break;
			case DOUBLE_TYPE:return validate("double",content) == 0 ? -2 : 1;
					 break;
			case PRODUCT_TYPE:return validate("product",content) == 0 ? -2 : 1;
					 break;
		}
		return -2;
			
	}

	VARIABLE *varSearch(char *name) {
		int i;
		for(i = 0 ; i < MAX_VARS && vars[i].name != NULL; i++){
			if(strcmp(vars[i].name, name) == 0){
				return &vars[i];
			}
		}
		return NULL;
	}

	char *addition(char *expr1, char *expr2) {
		VARIABLE *var1 = varSearch(expr1);
		VARIABLE *var2 = varSearch(expr2);
		if (var1 != NULL && var2 != NULL && var1->type == PRODUCT_TYPE && var2->type == PRODUCT_TYPE)
			;			/* implement prod + prod */
		return strcat(strcat(expr1,"+"), expr2);
	}

	char *exprToPrint(char *expr) {
		char *resp;
		VARIABLE *var = varSearch(expr);
		if (var != NULL) {
			resp = malloc((12+strlen(var->name)+3));
			switch(var->type) {
				case STRING_TYPE:
					sprintf(resp,"printf(\"%%s\",%s);\n",var->name);
					break;
				case INT_TYPE:
					sprintf(resp,"printf(\"%%d\",%s);\n",var->name);
					break;
				case DOUBLE_TYPE:
					sprintf(resp,"printf(\"%%f\",%s);\n",var->name);
					break;
				case PRODUCT_TYPE:
					sprintf(resp,"printf(\"%%s\",%s);\n",var->name);
					break;
			}
		}
		else {
			resp = malloc((8+strlen(expr)+2)*sizeof(*resp));
			sprintf(resp, "printf(%s);\n", expr);
		}
		return resp;
	}

	char *exprToPrintln(char *expr) {
		char *resp;
		VARIABLE *var = varSearch(expr);
		if (var != NULL) {
			resp = malloc((12+strlen(var->name)+4)*sizeof(*resp));
			switch(var->type) {
				case STRING_TYPE:
					sprintf(resp,"printf(\"%%s\\n\",%s);\n",var->name);
					break;
				case INT_TYPE:
					sprintf(resp,"printf(\"%%d\\n\",%s);\n",var->name);
					break;
				case DOUBLE_TYPE:
					sprintf(resp,"printf(\"%%f\\n\",%s);\n",var->name);
					break;
				case PRODUCT_TYPE:
					sprintf(resp,"printf(\"%%s\\n\",%s);\n",var->name);
					break;
			}
		}
		else {
			resp = malloc((8+strlen(expr)+4)*sizeof(*resp));
			sprintf(resp, "printf(%s\\n);\n", expr);
		}
		return resp;
	}

	//content could be null if var was only declared and not initialized
	VARIABLE prepareVar(char * type, char * name ,void * content,int constant){
		VARIABLE ans;
		ans.constant = constant;
		ans.name = malloc(strlen(name)+1);
		strcpy(ans.name,name);
		if(strcmp(type,"char *")==0){
			ans.type = STRING_TYPE;	
			if(content != NULL){
				ans.content = malloc(strlen((char *)content)+1);
				memcpy(ans.content,content,strlen((char *)content));
			}
		}else if(strcmp(type,"int")==0){
			ans.type = INT_TYPE;
			if(content != NULL){
				ans.content = malloc(sizeof(int));
				memcpy(ans.content,content,sizeof(int));
			}
		}else if(strcmp(type,"double")==0){
			ans.type = DOUBLE_TYPE;
			if(content != NULL){
				ans.content = malloc(sizeof(double));
				memcpy(ans.content,content,sizeof(double));
			}
		}else if(strcmp(type,"product")==0){
			ans.type = PRODUCT_TYPE;
			/*if(content != NULL){
				ans.content = malloc(sizeof(product));
				memcpy(ans.content,content,sizeof(double));
			}*/
		}

		return ans;
	}
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

%token IF THEN ENDIF
%nonassoc IFX
%nonassoc ELSE

%token WHILE ENDWHILE

%token PRINT PRINTLN

%token LE GE NE EQ AND OR INC DEC
%left '+' '-'
%left '*' '/'
%right '!'
%left INC DEC '<' '>' LE GE NE EQ AND OR


%type <string> statement;
%type <string> expr;
%type <string> const_expr;
%type <string> type;



%start program

%%

program		:	'$' '$' '\n' constList '$' '$' '\n' main
			|	main
			;

main		:  	main statement					{ printf("%s", $2); }
			| 	/*NULL*/
			;

constList 	:	const constList 
			|	/* NULL */
			;

const 		:	type CONST '<' '-' const_expr ';' '\n'			{if(validate($1,$5)){
											int ans = addVar(prepareVar($1,$2,$5,1));
											if( ans >= 0)
												printf("const %s %s = %s;\n", $1,$2, $5);
											else if(ans == -1){
												yyerror("ALREADY DEFINED CONST/VAR ");
												YYABORT;
											}
											else if(ans == -2){
												yyerror("MAX VARS SIZE REACHED(5000 VARS)");
												YYABORT;
											}
										 }else{
											yyerror("WRONG CONST DECLARATION");
											YYABORT;
										  } }
			;

type 		:	STRING				{$$="char *";}
			| 	INT					{$$="int";}
			| 	DOUBLE				{$$="double";}
			| 	PRODUCT				{$$="product";}
			;

statement 	:	VAR '<' '-' expr ';' '\n' 		{int ans = validateAsignation($1,$4);
								    if (ans ==1){
									$$ = malloc((strlen($1)+3+strlen($4)+2)*sizeof(*$$));
									sprintf($$,"%s = %s;\n", $1, $4);
								     }
								    else if (ans == -1){
									yyerror("NOT DEFINED CONST/VAR ");
									YYABORT;
								  }
								   else if (ans == -2){
									yyerror("WRONG TYPE FOR VAR ");
									YYABORT;
								  }
													
												}
			|	type VAR ';' '\n'				{
													int ans = addVar(prepareVar($1,$2,NULL,0));
													if (ans >= 0) {
														$$ = malloc((strlen($1)+1+strlen($2)+2)*sizeof(*$$));
														sprintf($$, "%s %s;\n", $1,$2);
													}
													else if(ans == -1){
														yyerror("ALREADY DEFINED CONST/VAR");
														YYABORT;
													}
													else if(ans == -2){
														yyerror("MAX VARS SIZE REACHED(5000 VARS)");	
														YYABORT;
													}
												}
			|	type VAR '<' '-' expr ';' '\n' 	{
													if (validate($1,$5)) {
														int ans = addVar(prepareVar($1,$2,$5,0));
														if( ans >= 0) {
															$$ = malloc((strlen($1)+1+strlen($2)+3+strlen($5)+2)*sizeof(*$$));
															sprintf($$, "%s %s = %s;\n", $1,$2,$5);
														}
														else if(ans == -1){
															yyerror("ALREADY DEFINED CONST/VAR");
															YYABORT;
														}
														else if(ans == -2){
															yyerror("MAX VARS SIZE REACHED(5000 VARS)");
															YYABORT;
														}
							   						}
							   						else{
														yyerror("WRONG VAR DECLARATION");
														YYABORT;
													}	
												}
			| 	IF expr '\n' 
					statement 
				ENDIF '\n'						{ 
													$$ = malloc((3+strlen($2)+4+strlen($4)+2)*sizeof(*$$));
													sprintf($$, "if(%s) {\n%s}\n", $2,$4);
												}
			|	IF expr '\n' 
					statement 
				ELSE '\n'
					statement
				ENDIF '\n' 						{
													$$ = malloc((3+strlen($2)+4+strlen($4)+9+strlen($7)+2)*sizeof(*$$));
													sprintf($$, "if(%s) {\n%s}\nelse {\n%s}\n", $2,$4,$7);
												}
			|	WHILE expr '\n'
					statement
				ENDWHILE '\n'					{
													$$ = malloc((6+strlen($2)+4+strlen($4)+2)*sizeof(*$$));
													sprintf($$, "while(%s) {\n%s}\n", $2,$4);
												}
			|	PRINT '(' expr ')' ';' '\n'		{	$$ = exprToPrint($3); }
			| 	PRINTLN '(' expr ')' ';' '\n'	{ 	$$ = exprToPrintln($3); }
			;

expr		:	NUMBER	 					{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%d", $1); }
			|	DOUBLENUMBER				{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%f", $1); }
			| 	STRINGVAL						
			|	VAR						
			|	expr '+' expr			{ $$ = addition($1,$3); }
			|	expr '-' expr			{ $$ = strcat(strcat($1,"-"), $3); }
			|	expr '*' expr			{ $$ = strcat(strcat($1,"*"), $3); }
			|	expr '/' expr			{ $$ = strcat(strcat($1,"/"), $3); }
			|	expr '<' expr 			{ $$ = strcat(strcat($1,"<"), $3); }
			|	expr '>' expr 			{ $$ = strcat(strcat($1,">"), $3); }
			|	expr LE expr 			{ $$ = strcat(strcat($1,"<="), $3); }
			| 	expr GE expr 			{ $$ = strcat(strcat($1,">="), $3); } 
			| 	expr NE expr 			{ $$ = strcat(strcat($1,"!="), $3); }
			| 	expr EQ expr 			{ $$ = strcat(strcat($1,"=="), $3); }
			| 	expr AND expr 			{ $$ = strcat(strcat($1,"&&"), $3); }
			| 	expr OR expr 			{ $$ = strcat(strcat($1,"||"), $3); }
			| 	'!' expr 				{ $$ = strcat("!",$2); }
			| '(' expr ')'				{ $$ = malloc((1+strlen($2)+1)*sizeof(*$$));
								  sprintf($$,"(%s)",$2);}
			| '{' STRINGVAL ',' STRINGVAL ',' expr ',' expr '}'				{ $$ = malloc((1+strlen($2)+1+strlen($4)+1+strlen($6)+1+strlen($8)+1)*sizeof(*$$));
								  sprintf($$,"{%s,%s,%s,%s}",$2,$4,$6,$8);}
			;

const_expr		:	NUMBER	 			{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%d", $1); }
			|	DOUBLENUMBER				{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%f", $1); }
			| 	STRINGVAL												
			|	const_expr '+' const_expr			{ $$ = strcat(strcat($1,"+"), $3); }
			|	const_expr '-' const_expr			{ $$ = strcat(strcat($1,"-"), $3); }
			|	const_expr '*' const_expr			{ $$ = strcat(strcat($1,"*"), $3); }
			|	const_expr '/' const_expr			{ $$ = strcat(strcat($1,"/"), $3); }
			| '(' const_expr ')'				{ $$ = malloc((1+strlen($2)+1)*sizeof(*$$));
								  sprintf($$,"(%s)",$2);}
			;





%%

void yyerror(char *s) {
	fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main(void) {

    printf("#include <stdlib.h>\n");
    printf("#include <stdio.h>\n");
    printf("#include <string.h>\n");
   printf("#include %cinclude/types.h%c \n",34,34);
    printf("int main(void) { \n");

    yyparse();

    printf("}\n");

    return 0;
}
