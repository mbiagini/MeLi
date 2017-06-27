
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
		}
		return -4;
			
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
		}

		return ans;
	}

	char *concat(int nstr, ...) {
		va_list strs;
		char *resp;
		int i;

		for (i = 0; i < nstr; i++) {
			resp = strcat(resp, va_arg(strs, char*));
		}
		va_end(strs);
		return resp;
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
											else if(ans == -1)
												yyerror("ALREADY DEFINED CONST/VAR ");
											else if(ans == -2)
												yyerror("MAX VARS SIZE REACHED(5000 VARS)");
										 }else
											yyerror("WRONG CONST DECLARATION"); }
			;

type 		:	STRING				{$$="char *";}
			| 	INT					{$$="int";}
			| 	DOUBLE				{$$="double";}
			| 	PRODUCT				{$$="void *";}
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
								   else if (ans == -2)
									yyerror("WRONG TYPE FOR VAR ");
													
												}
			|	type VAR ';' '\n'				{
													int ans = addVar(prepareVar($1,$2,NULL,0));
													if (ans >= 0) {
														$$ = malloc((strlen($1)+1+strlen($2)+2)*sizeof(*$$));
														sprintf($$, "%s %s;\n", $1,$2);
													}
													else if(ans == -1)
														yyerror("ALREADY DEFINED CONST/VAR");
													else if(ans == -2)
														yyerror("MAX VARS SIZE REACHED(5000 VARS)");
												}
			|	type VAR '<' '-' expr ';' '\n' 	{
													if (validate($1,$5)) {
														int ans = addVar(prepareVar($1,$2,$5,0));
														if( ans >= 0) {
															$$ = malloc((strlen($1)+1+strlen($2)+3+strlen($5)+2)*sizeof(*$$));
															sprintf($$, "%s %s = %s;\n", $1,$2,$5);
														}
														else if(ans == -1)
															yyerror("ALREADY DEFINED CONST/VAR");
														else if(ans == -2)
															yyerror("MAX VARS SIZE REACHED(5000 VARS)");
							   						}
							   						else
														yyerror("WRONG VAR DECLARATION");
												}
			| 	IF expr '\n' 
					statement 
				ENDIF '\n'						{ 
													$$ = malloc((4+strlen($2)+4+strlen($4)+2)*sizeof(*$$));
													sprintf($$, "if (%s) {\n%s}\n", $2,$4);
												}
			|	IF expr '\n' 
					statement 
				ELSE '\n'
					statement
				ENDIF '\n' 						{
													$$ = malloc((4+strlen($2)+4+strlen($4)+9+strlen($7)+2)*sizeof(*$$));
													sprintf($$, "if (%s) {\n%s}\nelse {\n%s}\n", $2,$4,$7);
												}
			;

/*
statement	:	VAR '<' '-' expr';' '\n'		{   int ans = validateAsignation($1,$4);
								    if (ans ==1)
									printf("%s = %s;\n",$1,$4);
								    else if (ans == -1){
									yyerror("NOT DEFINED CONST/VAR ");
									YYABORT;
								  }
								   else if (ans == -2)
									yyerror("WRONG TYPE FOR VAR ");
								  else if (ans == -3)
									yyerror(strcat($1," IS A CONST"));
								 }
			| type VAR';' '\n'			{ int ans = addVar(prepareVar($1,$2,NULL,0))
									if( ans >= 0)
										printf("%s %s ;\n", $1,$2);
									else if(ans == -1)
										yyerror("ALREADY DEFINED CONST/VAR ");
									else if(ans == -2)
										yyerror("MAX VARS SIZE REACHED(5000 VARS)"); }
			| type VAR '<' '-' expr';' '\n'	{  if(validate($1,$5)){
								int ans = addVar(prepareVar($1,$2,$5,0));
								if( ans >= 0)
									printf("%s %s = %s;\n", $1,$2, $5);
								else if(ans == -1)
									yyerror("ALREADY DEFINED CONST/VAR ");
								else if(ans == -2)
									yyerror("MAX VARS SIZE REACHED(5000 VARS)");
							   }else
								yyerror("WRONG VAR DECLARATION");  }
			|	IF expr '\n' statement				{ printf("if(%s){\n", $2); }
			;
*/

expr		:	NUMBER	 					{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%d", $1); }
			|	DOUBLENUMBER				{ $$ = malloc(256*sizeof(*$$)); sprintf($$, "%f", $1); }
			| 	STRINGVAL						
			|	VAR						
			|	expr '+' expr			{ $$ = strcat(strcat($1,"+"), $3); }
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
	
    printf("int main(void) { \n");

    yyparse();

    printf("}\n");

    return 0;
}
