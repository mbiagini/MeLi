
%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "include/utils.h"
	#include "include/types.h"
	#define MAX_VARS 5000

	int yylex(void);
	void yyerror(char const *);
	extern int yylineno;
	extern int state;
	extern int block;
	VARIABLE  vars[MAX_VARS] = {0};

	int addVar(VARIABLE var){
		int i;
		for(i = 0 ; i < MAX_VARS && vars[i].name != NULL ; i++){
			if(strcmp(vars[i].name, var.name) == 0 && vars[i].state == state && vars[i].block == block){
				return -1;
			}
		}

		if(i == MAX_VARS){
			return -2;
		}
		vars[i] = var;
		return i;	
	}

	int validateAsignation(char * name,expresion e){
		int i;
		int found = 0;
		VARIABLE ans;
		ans.name = NULL;
		for(i = 0 ; i < MAX_VARS && vars[i].name != NULL && !found ; i++){
			if(strcmp(vars[i].name, name) == 0 && (vars[i].state < state|| (vars[i].state == state && vars[i].block == block)  ))  {
				if(vars[i].state == state && vars[i].block == block){
					found = 1;
				}
				ans = vars[i];
			}
		}

		if(!found && ans.name == NULL){
		   return -1;
		}


		switch(ans.type){
			case STRING_TYPE: return validate("char *",e.type) == 0 ? -2 : 1 ;
					  break;
			case INT_TYPE:return validate("int",e.type) == 0 ? -2 : 1;
				      break;
			case DOUBLE_TYPE:return validate("double",e.type) == 0 ? -2 : 1;
					 break;
			case PRODUCT_TYPE:return validate("product",e.type) == 0 ? -2 : 1;
					 break;
			case PRODUCT_ARRAY_TYPE:return e.type == PRODUCT_ARRAY_TYPE;
					break; 
		}
		return -2;
			
	}

	VARIABLE *varSearch(char *name) {
		int i;
		VARIABLE * ans= NULL;
		for(i = 0 ; i < MAX_VARS && vars[i].name != NULL; i++){
			if(strcmp(vars[i].name, name) == 0 && (vars[i].state < state|| (vars[i].state == state && vars[i].block == block)  )){
				if(vars[i].state == state && vars[i].block == block){
					return &vars[i];
				}
				ans =  &vars[i];
			}
		}
		return ans;
	}

	char *substraction(expresion e1, expresion e2) {
		VARIABLE *var1 = varSearch(e1.expr);
		VARIABLE *var2 = varSearch(e2.expr);

		char *strVar1, *strVar2;

		if (var1 != NULL)
			strVar1 = var1->name;
		else
			strVar1 = e1.expr;
		if (var2 != NULL)
			strVar2 = var2->name;
		else
			strVar2 = e2.expr;

		if (e1.type == STRING_TYPE) {
			char *resp = malloc((strlen("removeSubstring(")+strlen(strVar1)+1+strlen(strVar2)+1+1)*sizeof(*resp));
			sprintf(resp,"removeSubstring(%s,%s)",strVar1,strVar2);
			return resp;
		}

		char *resp = malloc(strlen(strVar1)+1+strlen(strVar2)+1);
		resp = concat(concat(strVar1,"-"),strVar2);
		return resp;
	}

	char *addition(expresion e1, expresion e2) {
		VARIABLE *var1 = varSearch(e1.expr);
		VARIABLE *var2 = varSearch(e2.expr);

		char *strVar1, *strVar2, *str1, *str2;
		var_type type1, type2;

		if (var1 != NULL) { strVar1 = var1->name; type1 = var1->type; }
		else { strVar1 = e1.expr; type1 = e1.type; }
		if (var2 != NULL) { strVar2 = var2->name; type2 = var2->type; }
		else { strVar2 = e2.expr; type2 = e2.type; }

		if (type1 == STRING_TYPE || type2 == STRING_TYPE) {
			switch(type1) {
				case STRING_TYPE:
					str1 = malloc(strlen(strVar1)+1);
					sprintf(str1, "%s", strVar1);
					break;
				case INT_TYPE:
					str1 = malloc(strlen("intToChar(")+strlen(strVar1)+strlen(")")+1);
					sprintf(str1, "intToChar(%s)", strVar1);
					break;
				case DOUBLE_TYPE:
					str1 = malloc(strlen("doubleToChar(")+strlen(strVar1)+strlen(")")+1);
					sprintf(str1, "doubleToChar(%s)", strVar1);
					break;
			}
			switch(type2) {
				case STRING_TYPE:
					str2 = malloc(strlen(strVar2));
					sprintf(str2, "%s", strVar2);
					break;
				case INT_TYPE:
					str2 = malloc(strlen("intToChar(")+strlen(strVar2)+strlen(")")+1);
					sprintf(str2, "intToChar(%s)", strVar2);
					break;
				case DOUBLE_TYPE:
					str2 = malloc(strlen("doubleToChar(")+strlen(strVar2)+strlen(")")+1);
					sprintf(str2, "doubleToChar(%s)", strVar2);
					break;
			}
			char *resp = malloc(strlen("concat(")+strlen(str1)+strlen(",")+strlen(str2)+strlen(")")+1);
			sprintf(resp, "concat(%s,%s)", str1, str2);
			return resp;
		}
		char *resp = malloc(strlen(strVar1)+1+strlen(strVar2)+1);
		resp = concat(concat(strVar1,"+"),strVar2);
		return resp;
	}

	char *exprToPrint(expresion expr) {
		VARIABLE *var = varSearch(expr.expr);
		char *resp, *strVar;
		if (var != NULL)
			strVar = var->name;
		else
			strVar = expr.expr;

		if (expr.type == PRODUCT_TYPE)
			resp = malloc(strlen("printf(\"Name: %%s, Description: %%s, Price: %%f, Quantity: %%d\",")+
								4*strlen(strVar)+strlen(".name,")+strlen(".description,")+strlen(".price,")+strlen(".qty);")+1);
		else
			resp = malloc(strlen("printf(\"%%s\",")+strlen(strVar)+strlen(");\n")+1);
		switch(expr.type) {
			case STRING_TYPE:
				sprintf(resp,"printf(\"%%s\",%s);\n",strVar);
				break;
			case INT_TYPE:
				sprintf(resp,"printf(\"%%d\",%s);\n",strVar);
				break;
			case DOUBLE_TYPE:
				sprintf(resp,"printf(\"%%f\",%s);\n",strVar);
				break;
			case PRODUCT_TYPE:
				sprintf(resp,"printf(\"Name: %%s, Description: %%s, Price: %%f, Quantity: %%d\",%s.name,%s.description,%s.price,%s.qty);\n",strVar,strVar,strVar,strVar);
				break;
		}
		return resp;
	}

	char *exprToPrintln(expresion expr) {
		VARIABLE *var = varSearch(expr.expr);
		char *resp, *strVar;
		if (var != NULL)
			strVar = var->name;
		else
			strVar = expr.expr;

		if (expr.type == PRODUCT_TYPE)
			resp = malloc(strlen("printf(\"Name: %%s, Description: %%s, Price: %%f, Quantity: %%d\\n\",")+
								4*strlen(strVar)+strlen(".name,")+strlen(".description,")+strlen(".price,")+strlen(".qty);\n")+1);
		else
			resp = malloc(strlen("printf(\"%%s\\n\",")+strlen(strVar)+strlen(");\n")+1);
		switch(expr.type) {
			case STRING_TYPE:
				sprintf(resp,"printf(\"%%s\\n\",%s);\n",strVar);
				break;
			case INT_TYPE:
				sprintf(resp,"printf(\"%%d\\n\",%s);\n",strVar);
				break;
			case DOUBLE_TYPE:
				sprintf(resp,"printf(\"%%f\\n\",%s);\n",strVar);
				break;
			case PRODUCT_TYPE:
				sprintf(resp,"printf(\"Name: %%s, Description: %%s, Price: %%f, Quantity: %%d\\n\",%s.name,%s.description,%s.price,%s.qty);\n",strVar,strVar,strVar,strVar);
				break;
		}
		return resp;
	}

	//content could be null if var was only declared and not initialized
	VARIABLE prepareVar(char * type, char * name ,void * content,int constant){
		VARIABLE ans;
		ans.constant = constant;
		ans.name = malloc(strlen(name)+1);
		ans.state = state;
		ans.block = block;
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
		}else if(strcmp(type,"product[]")==0){
			ans.type = PRODUCT_ARRAY_TYPE;
			/*if(content != NULL){
				ans.content = malloc(sizeof(product));
				memcpy(ans.content,content,sizeof(double));
			}*/
		}

		return ans;
	}

	char *getRelationalComparison(expresion e1, expresion e2, const char *operand) {
		char *resp;
		if (e1.type == STRING_TYPE) {
			resp = malloc((strlen("strcmp(,)  0")+strlen(operand)+strlen(e1.expr)+strlen(e2.expr)+1)*sizeof(*resp));
			sprintf(resp, "(strcmp(%s,%s) %s 0)", e1.expr, e2.expr, operand); 
		}					
		else {
			resp = malloc((2+strlen(e1.expr)+strlen(operand)+strlen(e2.expr)+1)*sizeof(*resp));
			sprintf(resp, "%s %s %s", e1.expr, operand, e2.expr);
		}
		return resp;
	}

%}

%union {
  int intnum;
  char * string;
  float floatnum;
  expresion expre;
  statement state;
}

%error-verbose

%token STRING INT DOUBLE PRODUCT DISCOUNT BETWEEN ROUND NAME PRICE DESC STOCK GOTSTOCK EQUALS ADD GET GETINT GETDOUBLE GETSTRING SIZE IN SEARCH INSIDE MIN MAX REMOVE SUBSTRACT FROM

%token <string> VAR CONST STRINGVAL  
%token <intnum> NUMBER	PERCENTAGE
%token <floatnum> DOUBLENUMBER

%token IF THEN ENDIF
%nonassoc IFX
%nonassoc ELSE

%token WHILE ENDWHILE

%token PRINT PRINTLN

%token LE GE NE EQ AND OR INC DEC
%left '+' '-'
%left '*' '/'
%left '%'
%right '!'
%left INC DEC '<' '>' LE GE NE EQ AND OR


%type <string> block  const;
%type <expre> expr;
%type <expre> const_expr;
%type <string> type;
%type <expre> field;
%type <expre> get;
%type <state> statement



%start program

%%

program		:	'$' '$' '\n' constList '$' '$' '\n' main
			|	main
			;

main		:  	main statement						{ printf("%s", $2.string); }
			| 	/*NULL*/
			;

constList 	:	const constList 
			|	/* NULL */
			;

const 		:	type CONST '<' '-' const_expr ';' '\n' 	{	if (validate($1,$5.type)) {
														int ans = addVar(prepareVar($1,$2,$5.expr,1));
														if( ans >= 0) {
															$$ = malloc((strlen($1)+1+strlen($2)+3+strlen($5.expr)+8+1)*sizeof(*$$));
															sprintf($$, "const %s %s = %s;\n", $1,$2,$5.expr);
															printf("%s",$$);
														}
														else if(ans == -1){
															yyerror("ALREADY DEFINED CONST");
															YYABORT;
														}
														else if(ans == -2){
															yyerror("MAX VARS SIZE REACHED(5000 VARS)");
															YYABORT;
														}
							   						}
							   						else{
														yyerror("WRONG CONST DECLARATION");
														YYABORT;
													}	
												}


			|	PRODUCT CONST '<' '-' '{'STRINGVAL ','STRINGVAL ','const_expr','const_expr'}' ';' '\n' 	{	if($10.type != DOUBLE_TYPE || $12.type!= INT_TYPE){
															
														yyerror("wrong const declaration");YYABORT;
														}
														int ans = addVar(prepareVar("product",$2,NULL,1));
														if( ans >= 0) {
															$$ = malloc((strlen($2)+strlen($6)+strlen($8)+strlen($10.expr)+strlen($12.expr)+24+1)*sizeof($$));
								  							sprintf($$,"const product %s = {%s,%s,%s,%s};\n",$2,$6,$8,$10.expr,$12.expr);
								  							printf("%s",$$);
														}
														else if(ans == -1){
															yyerror("ALREADY DEFINED CONST");
															YYABORT;
														}
														else if(ans == -2){
															yyerror("MAX VARS SIZE REACHED(5000 VARS)");
															YYABORT;
														}
														
													}
			;

type 		:	STRING				{$$="char *";}
			| 	INT					{$$="int";}
			| 	DOUBLE				{$$="double";}
			;

field 		:	NAME				{$$.expr=".name";$$.type=STRING_TYPE;}
			| 	DESC					{$$.expr=".description";$$.type=STRING_TYPE;}
			| 	PRICE				{$$.expr=".price";$$.type=DOUBLE_TYPE;}
			| 	STOCK				{$$.expr=".qty";$$.type=INT_TYPE;}
			;

get		:	GETINT						{$$.expr="%d";$$.type=INT_TYPE;}
			| 	GETDOUBLE					{$$.expr="%lf";$$.type=DOUBLE_TYPE;}
			| 	GETSTRING				{$$.expr="%s";$$.type=STRING_TYPE;}
			;


block		:	block statement		{
										$$ = malloc((strlen($1)+strlen($2.string)+1)*sizeof(*$$));
										sprintf($$, "%s%s", $1,$2.string);
									}
			|						{	$$ = ""; }
			;

statement 	:	VAR '<' '-' expr ';' '\n' 		{
													int ans = validateAsignation($1,$4);
								    				if (ans ==1) {
														$$.string = malloc((strlen($1)+3+strlen($4.expr)+2+1)*sizeof(*($$.string)));
														sprintf($$.string,"%s = %s;\n", $1, $4.expr);
								     				}
								    				else if (ans == -1) {
														yyerror("NOT DEFINED CONST/VAR ");
														YYABORT;
									  				}
								   					else if (ans == -2) {
														yyerror("WRONG TYPE FOR VAR ");
														YYABORT;
								  					}													
																					}

			|	VAR '.' GET '(' expr ')' '<' '-' expr ';''\n' 			{VARIABLE * v = varSearch($1);
																		 if(v ==NULL ){
																		 	yyerror("VAR ISNT DECLARATED");YYABORT;
																		  }
																			if(v->type != PRODUCT_ARRAY_TYPE){
																				yyerror("VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
																			}if($5.type != INT_TYPE){
																				yyerror(" index must be an integer");YYABORT;
																			}if($9.type != PRODUCT_TYPE){
																				yyerror(" wrong asignation");YYABORT;
																			}
																			$$.string = malloc((strlen($1)+strlen($5.expr)+strlen($9.expr)+11+1)*sizeof(*($$.string)));
																			sprintf($$.string,"%s.array[%s]=%s;\n",$1,$5.expr,$9.expr);
																			}
			| 	VAR '<' '-' SEARCH expr INSIDE VAR ';' '\n'				{ 
																			VARIABLE *v1 = varSearch($1);
																			VARIABLE *v2 = varSearch($7);
																			if (v1 == NULL || v2 == NULL) {
																				yyerror("AT LEAST ONE VAR ISN'T DECLARETED");YYABORT; }
																			if (v1->type != PRODUCT_ARRAY_TYPE || v2->type != PRODUCT_ARRAY_TYPE) {
																				yyerror("FIRST AND LAST VARIABLES MUST BE PRODUCT ARRAYS");YYABORT; }
																			if ($5.type != STRING_TYPE) {
																				yyerror("SEARCH REQUIRES A STRING");YYABORT; }
																			$$.string = malloc((strlen(" = *searchStr(,);\\n")+strlen($1)+strlen($5.expr)+strlen($7)+1)*sizeof(*($$.string)));
																			sprintf($$.string, "%s = *searchStr(%s,%s);\n", $1, $5.expr, $7);
																		}

			| 	VAR '.' field '<' '-' expr ';' '\n' 		{VARIABLE * v = varSearch($1);
														    if(v == NULL ){
																yyerror(" var doesnt exist");YYABORT;}
															if(v->type != PRODUCT_TYPE){
																yyerror(" var must be a product");YYABORT;
															}
															if($3.type != $6.type){
																yyerror(" wrong asignation");YYABORT;
															}
															$$.string = malloc((strlen($1)+strlen($3.expr)+strlen($6.expr)+5+1)*sizeof(*($$.string)));
															  sprintf($$.string,"%s%s = %s;\n",$1,$3.expr,$6.expr);
															 
								    																	
																					}

			|	VAR '.' GET '(' expr ')' '.' field '<' '-' expr ';''\n' 			{VARIABLE * v = varSearch($1);
																						 if(v ==NULL ){
																						 	yyerror("VAR ISNT DECLARATED");YYABORT;
																						  }
																							if(v->type != PRODUCT_ARRAY_TYPE){
																								yyerror("VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
																							}if($5.type != INT_TYPE){
																								yyerror(" index must be an integer");YYABORT;
																							}if($8.type != $11.type){
																								yyerror(" wrong asignation");YYABORT;
																							}
																							$$.string = malloc((strlen($1)+strlen($5.expr)+strlen($8.expr)+strlen($11.expr)+11+1)*sizeof(*($$.string)));
																							sprintf($$.string,"%s.array[%s]%s=%s;\n",$1,$5.expr,$8.expr,$11.expr);
																					 }


			|VAR '<' '-' '{'STRINGVAL ','STRINGVAL ','expr','expr'}' ';' '\n'  		{VARIABLE * v = varSearch($1);
																					 if(v == NULL || v->type != PRODUCT_TYPE){
																					 		yyerror("wrong var type or var doesnt exist");YYABORT;}
																					if($9.type != DOUBLE_TYPE || $11.type!= INT_TYPE){															
																							yyerror("wrong var initialization");YYABORT;
																					}
																					$$.string = malloc((strlen($1)+strlen($5)+strlen($7)
																						+strlen($9.expr)+strlen($11.expr)+35+1)*sizeof(*($$.string)));
															  						sprintf($$.string,"%s.name=%s;\n%s.description=%s;\n%s.price=%s;\n%s.qty=%s;\n",$1,$5,$1,$7,$1,$9.expr,$1,$11.expr);	}
			|VAR '.' GET '(' expr ')' '<' '-' '{'STRINGVAL ','STRINGVAL ','expr','expr'}' ';' '\n'  		{VARIABLE * v = varSearch($1);
																											 if(v ==NULL ){
																											 	yyerror("VAR ISNT DECLARATED");YYABORT;
																											  }
																												if(v->type != PRODUCT_ARRAY_TYPE){
																													yyerror("VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
																												}if($5.type != INT_TYPE){
																													yyerror(" index must be an integer");YYABORT;
																												}if($14.type != DOUBLE_TYPE || $16.type!= INT_TYPE){															
																														yyerror("wrong var initialization");YYABORT;
																												}
																												$$.string = malloc((4*strlen($1)+4*strlen($5.expr)+strlen($10)+strlen($12)+strlen($14.expr)+strlen($16.expr)+71)*sizeof(*($$.string)));
																						  						sprintf($$.string,"%s.array[%s].name=%s;\n%s.array[%s].description=%s;\n%s.array[%s].price=%s;\n%s.array[%s].qty=%s;\n",$1,$5.expr,$10,$1,$5.expr,$12,$1,$5.expr,$14.expr,$1,$5.expr,$16.expr);	}																				
			|	type VAR ';' '\n'				{
													int ans = addVar(prepareVar($1,$2,NULL,0));
													if (ans >= 0) {
														$$.string = malloc((strlen($1)+1+strlen($2)+2+1)*sizeof(*($$.string)));
														sprintf($$.string, "%s %s;\n", $1,$2);
													}
													else if(ans == -1){
														yyerror("ALREADY DEFINED VAR");
														YYABORT;
													}
													else if(ans == -2){
														yyerror("MAX VARS SIZE REACHED(5000 VARS)");	
														YYABORT;
													}
												}

			|	PRODUCT VAR ';' '\n'				{
													int ans = addVar(prepareVar("product",$2,NULL,0));
													if (ans >= 0) {
														$$.string = malloc((5*strlen($2)+57+1)*sizeof(*($$.string)));
														sprintf($$.string, "product %s;\n%s.name=\"\";\n%s.description=\"\";\n%s.price=0.0;\n%s.qty=0;\n", $2,$2,$2,$2,$2);
													}
													else if(ans == -1){
														yyerror("ALREADY DEFINED VAR");
														YYABORT;
													}
													else if(ans == -2){
														yyerror("MAX VARS SIZE REACHED(5000 VARS)");	
														YYABORT;
													}
												}

			|	PRODUCT VAR'['']' ';' '\n'				{
													int ans = addVar(prepareVar("product[]",$2,NULL,0));
													if (ans >= 0) {
														$$.string = malloc((3*strlen($2)+59+1)*sizeof(*($$.string)));
														sprintf($$.string, "product_array %s;\n%s.array = malloc(sizeof(product));\n%s.size=0;\n", $2,$2,$2);
													}
													else if(ans == -1){
														yyerror("ALREADY DEFINED VAR");
														YYABORT;
													}
													else if(ans == -2){
														yyerror("MAX VARS SIZE REACHED(5000 VARS)");	
														YYABORT;
													}
												}

			|	 VAR'.'ADD'('VAR')'';''\n'			{VARIABLE * v = varSearch($1);VARIABLE * v2 = varSearch($5);
												 if(v ==NULL || v2 ==NULL){
												 	yyerror("AT LEAST ONEVAR ISNT DECLARATED");YYABORT;
												  }
													if(v->type != PRODUCT_ARRAY_TYPE){
														yyerror("FIRST VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
													}if(v2->type != PRODUCT_TYPE){
														yyerror("SECOND VAR ISNT OF TYPE PRODUCT ");YYABORT;
													}
													$$.string = malloc((strlen("addProd(&,);\\n")+strlen($1)+strlen($5)+1)*sizeof(*($$.string)));
													sprintf($$.string, "addProd(&%s,%s);\n", $1, $5);													
												}

			|	VAR'.'REMOVE'('expr')'';''\n'			{VARIABLE * v = varSearch($1);
											    if(v == NULL ){
													yyerror(" var doesnt exist");YYABORT;}
												if(v->type != PRODUCT_ARRAY_TYPE){
													yyerror(" var must be a product array");YYABORT;
												}
												if($5.type != INT_TYPE){
													yyerror(" index must be an integer");YYABORT;
												}
												$$.string = malloc((strlen($1)+strlen($5.expr)+22)*sizeof(*($$.string)));
											   sprintf($$.string,"removeFromArray(&%s,%s);\n",$1,$5.expr);
											   
											}
			|	type VAR '<' '-' expr ';' '\n' 	{	if (validate($1,$5.type)) {
														int ans = addVar(prepareVar($1,$2,$5.expr,0));
														if( ans >= 0) {
															$$.string = malloc((strlen($1)+1+strlen($2)+3+strlen($5.expr)+2+1)*sizeof(*($$.string)));
															sprintf($$.string, "%s %s = %s;\n", $1,$2,$5.expr);
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

			|	PRODUCT VAR '<' '-' expr ';' '\n' 	{	if (validate("product",$5.type)) {
														int ans = addVar(prepareVar("product",$2,$5.expr,0));
														if( ans >= 0) {
															$$.string = malloc((8+strlen($2)+3+strlen($5.expr)+2+1)*sizeof(*($$.string)));
															sprintf($$.string, "product %s = %s;\n", $2,$5.expr);
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


			|	PRODUCT VAR '<' '-' '{'STRINGVAL ','STRINGVAL ','expr','expr'}' ';' '\n' 	{	if($10.type != DOUBLE_TYPE || $12.type!= INT_TYPE){
															
														yyerror("wrong var declaration");YYABORT;
														}
														int ans = addVar(prepareVar("product",$2,NULL,0));
														if( ans >= 0) {
															$$.string = malloc((strlen($2)+strlen($6)+strlen($8)+strlen($10.expr)+strlen($12.expr)+18+1)*sizeof(*($$.string)));
								  							sprintf($$.string,"product %s = {%s,%s,%s,%s};\n",$2,$6,$8,$10.expr,$12.expr);
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
			|	PRINT '(' expr ')' ';' '\n'		{	$$.string = exprToPrint($3); }
			| 	PRINTLN '(' expr ')' ';' '\n'	{ 	$$.string = exprToPrintln($3); }
			| 	IF expr '\n' 
					block 
				ENDIF '\n'						{ 
													$$.string = malloc((3+strlen($2.expr)+4+strlen($4)+2+1)*sizeof(*($$.string)));
													sprintf($$.string, "if(%s) {\n%s}\n", $2.expr,$4);
												}
			|	IF expr '\n'
					block 
				ELSE '\n'
					block
				ENDIF '\n' 						{
													$$.string = malloc((3+strlen($2.expr)+4+strlen($4)+9+strlen($7)+2+1)*sizeof(*($$.string)));
													sprintf($$.string, "if(%s) {\n%s}\nelse {\n%s}\n", $2.expr,$4,$7);
												}
			|	WHILE expr '\n'
					block
				ENDWHILE '\n'					{
													$$.string = malloc((6+strlen($2.expr)+4+strlen($4)+2+1)*sizeof(*($$.string)));
													sprintf($$.string, "while(%s) {\n%s}\n", $2.expr,$4);
												}
			;

			|	VAR DISCOUNT NUMBER';''\n' 			{if($3 > 100 || $3 < 0){
														yyerror("DISCOUNT RECEIVES A NUMBER BETWEEN 0 AND 100");YYABORT;
													 }
													 VARIABLE * v = varSearch($1);
													 if(v ==NULL ){
													 	yyerror("VAR ISNT DECLARATED");YYABORT;
													  }
														if(v->type != PRODUCT_TYPE){
															yyerror("VAR ISNT OF TYPE PRODUCT");YYABORT;
														}
														$$.string = malloc((strlen($1)+intLength(100-$3)+16+1)*sizeof(*($$.string)));
														sprintf($$.string,"%s.price*=%d/100.0;\n",$1,(100-$3));
													 }
			|	VAR ROUND NUMBER ';' '\n'			{
														if ($3 < 0) {
															yyerror("ROUND RECEIVES A POSITIVE NUMBER");YYABORT; }
														VARIABLE *v = varSearch($1);
														if (v == NULL) {
															yyerror("VAR ISN'T DECLARATED");YYABORT; }
														if (v->type != DOUBLE_TYPE) {
															yyerror("VAR ISN'T OF TYPE DOUBLE");YYABORT;
														}
														$$.string = malloc((strlen($1)+strlen(" = myRound(")+strlen($1)+1+intLength($3)+3+1)*sizeof(*($$.string)));
														sprintf($$.string, "%s = myRound(%s,%d);\n", $1, $1, $3);
													}
			|	VAR '.' GET '(' expr ')' DISCOUNT NUMBER';''\n' 			{if($8 > 100 || $8 < 0){
														yyerror("DISCOUNT RECEIVES A NUMBER BETWEEN 0 AND 100");YYABORT;
													 }
													 VARIABLE * v = varSearch($1);
													 if(v ==NULL ){
													 	yyerror("VAR ISNT DECLARATED");YYABORT;
													  }
														if(v->type != PRODUCT_ARRAY_TYPE){
															yyerror("VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
														}if($5.type != INT_TYPE){
															yyerror(" index must be an integer");YYABORT;
														}
														$$.string = malloc((strlen($1)+intLength(100-$8)+24+strlen($5.expr)+1)*sizeof(*($$.string)));
														sprintf($$.string,"%s.array[%s].price*=%d/100.0;\n",$1,$5.expr,(100-$8));
													 }
			|	get VAR  ';''\n' 			{ VARIABLE * v = varSearch($2);
													 if(v ==NULL ){
													 	yyerror("VAR ISNT DECLARATED");YYABORT;
													  }
														if(v->type != $1.type){
															yyerror("wrong var type");YYABORT;
														}
														if($1.type != STRING_TYPE){
															$$.string = malloc((strlen($1.expr)+strlen($2)+13+1)*sizeof(*($$.string)));
															sprintf($$.string,"scanf(\"%s\",&%s);\n",$1.expr,$2);
														}
														else{//lee como maximo 255 caracteres
																$$.string = malloc((strlen($1.expr)+2*strlen($2)+236)*sizeof(*($$.string)));
															sprintf($$.string,"for(AUX_IDX1 =0;AUX_IDX1<256;AUX_IDX1++){AUX_STRING_READER1[AUX_IDX1]=0;}scanf(\"%s\",AUX_STRING_READER1);\n%s=malloc((strlen(AUX_STRING_READER1)+1)*sizeof(char));\nmemcpy(%s,AUX_STRING_READER1,(strlen(AUX_STRING_READER1)+1)*sizeof(char));\n",$1.expr,$2,$2);
														}
													 }
			|	get VAR'.'field  ';''\n' 			{ VARIABLE * v = varSearch($2);
													 if(v ==NULL ){
													 	yyerror("VAR ISNT DECLARATED");YYABORT;
													  }
														if(v->type != PRODUCT_TYPE){
															yyerror("var isnt a product");YYABORT;
														}if ($4.type != $1.type){
															yyerror("wrong var type");YYABORT;
														}
														if($1.type != STRING_TYPE){
															$$.string = malloc((strlen($1.expr)+strlen($2)+strlen($4.expr)+15+1)*sizeof(*($$.string)));
															sprintf($$.string,"scanf(\"%s\",&(%s%s));\n",$1.expr,$2,$4.expr);
														}
														else{//lee como maximo 255 caracteres
																$$.string = malloc((strlen($1.expr)+2*strlen($2)+2*strlen($4.expr)+236)*sizeof(*($$.string)));
															sprintf($$.string,"for(AUX_IDX1 =0;AUX_IDX1<256;AUX_IDX1++){AUX_STRING_READER1[AUX_IDX1]=0;}scanf(\"%s\",AUX_STRING_READER1);\n%s%s=malloc((strlen(AUX_STRING_READER1)+1)*sizeof(char));\nmemcpy(%s%s,AUX_STRING_READER1,(strlen(AUX_STRING_READER1)+1)*sizeof(char));\n",$1.expr,$2,$4.expr,$2,$4.expr);
														}
													 }
			|	SUBSTRACT VAR FROM VAR ';''\n'		{ VARIABLE * v = varSearch($2);VARIABLE * v2 = varSearch($4);
														 if(v ==NULL || v2 ==NULL){
														 	yyerror("AT LEAST ONEVAR ISNT DECLARATED");YYABORT;
														  }
															if(v->type != PRODUCT_TYPE ){
																yyerror("FIRST VAR ISNT OF TYPE PRODUCT");YYABORT;
															}
															if(v2-> type != PRODUCT_ARRAY_TYPE){
																yyerror("SECOND VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
															}
															$$.string = malloc((strlen($4)+strlen($2)+26)*sizeof(*($$.string)));
															sprintf($$.string,"removeProdFromArray(&%s,%s);\n",$4,$2);
													 }

			| '\n' {$$.string="\n";}
			;

expr		:	NUMBER	 					{ $$.type=INT_TYPE; $$.expr = malloc((intLength($1)+1)*sizeof(*($$.expr))); sprintf($$.expr, "%d", $1); }
			|	DOUBLENUMBER				{ $$.type = DOUBLE_TYPE; $$.expr = malloc(256*sizeof(*($$.expr))); sprintf($$.expr, "%f", $1); }
			| 	STRINGVAL			{$$.expr=$1;$$.type = STRING_TYPE;}
			|	VAR				{VARIABLE * v = varSearch($1);
								    if(v == NULL ){
										yyerror(" var doesnt exist");YYABORT;}
								   $$.expr = $1;$$.type=v->type;
								}
			|	VAR'.'field				{VARIABLE * v = varSearch($1);
								    if(v == NULL ){
										yyerror(" var doesnt exist");YYABORT;}
									if(v->type != PRODUCT_TYPE){
										yyerror(" var must be a product");YYABORT;
									}
									$$.expr = malloc((strlen($1)+strlen($3.expr)+1)*sizeof(*($$.expr)));
								   sprintf($$.expr,"%s%s",$1,$3.expr);
								   $$.type=$3.type;
								}
			|	VAR'.'SIZE			{VARIABLE * v = varSearch($1);
								    if(v == NULL ){
										yyerror(" var doesnt exist");YYABORT;}
									if(v->type != PRODUCT_ARRAY_TYPE){
										yyerror(" var must be a product array");YYABORT;
									}
									$$.expr = malloc((strlen($1)+5+1)*sizeof(*($$.expr)));
								   sprintf($$.expr,"%s.size",$1);
								   $$.type=INT_TYPE;
								}
			|	VAR'.'GET'('expr')'			{VARIABLE * v = varSearch($1);
											    if(v == NULL ){
													yyerror(" var doesnt exist");YYABORT;}
												if(v->type != PRODUCT_ARRAY_TYPE){
													yyerror(" var must be a product array");YYABORT;
												}
												if($5.type != INT_TYPE){
													yyerror(" index must be an integer");YYABORT;
												}
												$$.expr = malloc((strlen($1)+strlen($5.expr)+8+1)*sizeof(*($$.expr)));
											   sprintf($$.expr,"%s.array[%s]",$1,$5.expr);
											   $$.type=PRODUCT_TYPE;
											}

			|	VAR'.'GET'('expr')'	'.'field	{VARIABLE * v = varSearch($1);
											    if(v == NULL ){
													yyerror(" var doesnt exist");YYABORT;}
												if(v->type != PRODUCT_ARRAY_TYPE){
													yyerror(" var must be a product array");YYABORT;
												}
												if($5.type != INT_TYPE){
													yyerror(" index must be an integer");YYABORT;
												}
												$$.expr = malloc((strlen($1)+strlen($5.expr)+8+strlen($8.expr)+1)*sizeof(*($$.expr)));
											   sprintf($$.expr,"%s.array[%s]%s",$1,$5.expr,$8.expr);
											   $$.type=$8.type;
											}
			|	GOTSTOCK'('VAR')' 			{VARIABLE * v = varSearch($3);
												 if(v ==NULL ){
												 	yyerror("VAR ISNT DECLARATED");YYABORT;
												  }
													if(v->type != PRODUCT_TYPE){
														yyerror("VAR ISNT OF TYPE PRODUCT");YYABORT;
													}
													$$.expr = malloc((strlen($3)+8+1)*sizeof(*($$.expr)));
													sprintf($$.expr,"(%s.qty>0)",$3);
													$$.type = INT_TYPE;
												 }
			|	GOTSTOCK'('VAR '.' GET '('expr')'')' 			{VARIABLE * v = varSearch($3);
																if(v == NULL ){
																	yyerror(" var doesnt exist");YYABORT;}
																if(v->type != PRODUCT_ARRAY_TYPE){
																	yyerror(" var must be a product array");YYABORT;
																}
																if($7.type != INT_TYPE){
																	yyerror(" index must be an integer");YYABORT;
																}
																$$.expr = malloc((strlen($3)+strlen($7.expr)+16+1)*sizeof(*($$.expr)));
																   sprintf($$.expr,"(%s.array[%s].qty>0)",$3,$7.expr);
																   $$.type=INT_TYPE;
																 }
			|	MIN VAR 				{
											VARIABLE *v = varSearch($2);
											if(v == NULL) {
												yyerror("VAR ISN'T DECLARATED");YYABORT; }
											if(v->type != PRODUCT_ARRAY_TYPE) {
												yyerror("VAR MUST BE A PRODUCT ARRAY");YYABORT; }
											$$.type = PRODUCT_TYPE;
											$$.expr = malloc((strlen("getMinProd()")+strlen($2)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "getMinProd(%s)", $2);
										}
			|	MAX VAR 				{
											VARIABLE *v = varSearch($2);
											if(v == NULL) {
												yyerror("VAR ISN'T DECLARATED");YYABORT; }
											if(v->type != PRODUCT_ARRAY_TYPE) {
												yyerror("VAR MUST BE A PRODUCT ARRAY");YYABORT; }
											$$.type = PRODUCT_TYPE;
											$$.expr = malloc((strlen("getMaxProd()")+strlen($2)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "getMaxProd(%s)", $2);
										}
			| 	DEC VAR 				{
											VARIABLE *v = varSearch($2);
											if(v == NULL) {
												yyerror("VAR ISN'T DECLARATED");YYABORT; }
											if(v->type != INT_TYPE && v->type != DOUBLE_TYPE) {
												yyerror("VAR MUST BE INT OR DOUBLE");YYABORT; }
											$$.type = v->type;
											$$.expr = malloc((strlen("(--)")+strlen($2)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "(--%s)", $2);
										}
			| 	VAR DEC 				{
											VARIABLE *v = varSearch($1);
											if(v == NULL) {
												yyerror("VAR ISN'T DECLARATED");YYABORT; }
											if(v->type != INT_TYPE && v->type != DOUBLE_TYPE) {
												yyerror("VAR MUST BE INT OR DOUBLE");YYABORT; }
											$$.type = v->type;
											$$.expr = malloc((strlen("(--)")+strlen($1)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "(%s--)", $1);
										}
			| 	INC VAR 				{
											VARIABLE *v = varSearch($2);
											if(v == NULL) {
												yyerror("VAR ISN'T DECLARATED");YYABORT; }
											if(v->type != INT_TYPE && v->type != DOUBLE_TYPE) {
												yyerror("VAR MUST BE INT OR DOUBLE");YYABORT; }
											$$.type = v->type;
											$$.expr = malloc((strlen("(++)")+strlen($2)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "(++%s)", $2);
										}
			| 	VAR INC 				{
											VARIABLE *v = varSearch($1);
											if(v == NULL) {
												yyerror("VAR ISN'T DECLARATED");YYABORT; }
											if(v->type != INT_TYPE && v->type != DOUBLE_TYPE) {
												yyerror("VAR MUST BE INT OR DOUBLE");YYABORT; }
											$$.type = v->type;
											$$.expr = malloc((strlen("(++)")+strlen($1)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "(%s++)", $1);
										}
			|	VAR EQUALS VAR 			{VARIABLE * v = varSearch($1);VARIABLE * v2 = varSearch($3);
												 if(v ==NULL || v2 ==NULL){
												 	yyerror("AT LEAST ONE VAR ISNT DECLARATED");YYABORT;
												  }
													if(v->type != PRODUCT_TYPE || v2->type != PRODUCT_TYPE){
														yyerror("AT LEAST ONE VAR ISNT OF TYPE PRODUCT");YYABORT;
													}
													$$.expr = malloc((4*strlen($3)+4*strlen($1)+100+1)*sizeof(*($$.expr)));
													sprintf($$.expr,"(strcmp(%s.name,%s.name)==0 && strcmp(%s.description,%s.description)==0 && %s.price == %s.price && %s.qty == %s.qty)",$1,$3,$1,$3,$1,$3,$1,$3);
													$$.type = INT_TYPE;
												 }
			|	CONST				{VARIABLE * v = varSearch($1);
								    if(v == NULL ){
										yyerror("const doesnt exist");YYABORT;}
								   $$.expr = $1;$$.type=v->type;
								}	

			|	CONST'.'field				{VARIABLE * v = varSearch($1);
											    if(v == NULL ){
													yyerror(" const doesnt exist");YYABORT;}
												if(v->type != PRODUCT_TYPE){
													yyerror(" const must be a product");YYABORT;
												}
												$$.expr = malloc((strlen($1)+strlen($3.expr)+1)*sizeof(*($$.expr)));
											   sprintf($$.expr,"%s%s",$1,$3.expr);
											   $$.type=$3.type;
											}	
			|	VAR IN VAR 				{VARIABLE * v = varSearch($1);VARIABLE * v2 = varSearch($3);
												 if(v ==NULL || v2 ==NULL){
												 	yyerror("AT LEAST ONEVAR ISNT DECLARATED");YYABORT;
												  }
													if(v->type != PRODUCT_TYPE ){
														yyerror("FIRST VAR ISNT OF TYPE PRODUCT");YYABORT;
													}
													if(v2-> type != PRODUCT_ARRAY_TYPE){
														yyerror("SECOND VAR ISNT OF TYPE PRODUCT ARRAY");YYABORT;
													}
													$$.expr = malloc((strlen($3)+strlen($1)+14)*sizeof(*($$.expr)));
													sprintf($$.expr,"prodInArray(%s,%s)",$1,$3);
													$$.type = INT_TYPE;
												 }
			|	VAR BETWEEN expr '<' '>' expr		{
														VARIABLE *v = varSearch($1);
														if (v == NULL) {
															yyerror("VAR ISN'T DECLARATED");YYABORT; }
														if (v->type == PRODUCT_TYPE) {
															yyerror("BETWEEN CONNOT BE APPLIED TO A PRODUCT");YYABORT; }
														if ($3.type != v->type || $6.type != v->type) {
															yyerror("AT LEAST ONE EXPRESSION IS OF INCORRECT TYPE");YYABORT; }
														if (v->type == STRING_TYPE) {
															$$.expr = malloc((strlen("(strcmp(")+strlen($3.expr)+1+strlen($1)+strlen(")<=0 && strcmp(")+strlen($1)+1+strlen($6.expr)+strlen(")<=0)")+1)*sizeof(*($$.expr)));
															sprintf($$.expr,"(strcmp(%s,%s)<=0 && strcmp(%s,%s)<=0)",$3.expr,$1,$1,$6.expr);
														}
														else if (v->type == INT_TYPE || v->type == DOUBLE_TYPE) {
															$$.expr = malloc((1+strlen($3.expr)+strlen(" <= ")+strlen($1)+strlen(" && ")+strlen($1)+strlen(" <= ")+strlen($6.expr)+1+1)*sizeof(*($$.expr)));
															sprintf($$.expr,"(%s <= %s && %s <= %s)",$3.expr,$1,$1,$6.expr);
														}
														$$.type = INT_TYPE;
													}
			|	expr '+' expr		{ 
										$$.type = validAddExpr($1,$3);
										if($$.type != -1)
											$$.expr = addition($1,$3);
										else {
											yyerror("WRONG EXPR");
											YYABORT; } 
									}
			|	expr '-' expr 		{ 	
										$$.type = validSubsExpr($1,$3);
										if($$.type != -1)
											$$.expr = substraction($1,$3);
										else {
											yyerror("WRONG EXPR");
											YYABORT; } 
									}
			| 	expr '*' '*' expr 	{
										$$.type = validNumExpr($1,$4);
										if($$.type != -1) {
											$$.type = DOUBLE_TYPE;
											$$.expr = malloc((strlen("pow(,)")+strlen($1.expr)+strlen($4.expr)+1)*sizeof(*($$.expr)));
											sprintf($$.expr, "pow(%s,%s)", $1.expr, $4.expr); }
										else {
											yyerror("WRONG EXPR");
											YYABORT; }
									}
			| 	expr '%' expr 		{ 
										if ($1.type != INT_TYPE || $3.type != INT_TYPE) {
											yyerror("BOTH OPERANDS MUST BE INT");YYABORT; }
										$$.type = INT_TYPE;
										$$.expr = malloc((strlen("( %% )")+strlen($1.expr)+strlen($3.expr)+1)*sizeof(*($$.expr)));
										sprintf($$.expr, "(%s %% %s)", $1.expr, $3.expr);
									}
			|	expr '*' expr		{ $$.type = validNumExpr($1,$3); if($$.type != -1){ $$.expr= strcat(strcat($1.expr,"*"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	expr '/' expr		{ $$.type = validNumExpr($1,$3); if($$.type != -1){$$.expr = strcat(strcat($1.expr,"/"), $3.expr);}else{yyerror("WRONG EXPR");YYABORT;}} 
			|	expr '<' expr 		{ 
										$$.type = validRelExpr($1,$3);
										if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
										$$.expr = getRelationalComparison($1,$3,"<");
									}
			|	expr '>' expr 		{ 
										$$.type = validRelExpr($1,$3);
										if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
										$$.expr = getRelationalComparison($1,$3,">");
									}
			|	expr LE expr 		{ 
										$$.type = validRelExpr($1,$3);
										if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
										$$.expr = getRelationalComparison($1,$3,"<=");
									}
			|	expr GE expr 		{ 
										$$.type = validRelExpr($1,$3);
										if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
										$$.expr = getRelationalComparison($1,$3,">=");
									}
			|	expr NE expr 		{ 
										$$.type = validRelExpr($1,$3);
										if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
										$$.expr = getRelationalComparison($1,$3,"!=");
									}
			|	expr EQ expr 		{ 
										$$.type = validRelExpr($1,$3);
										if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
										$$.expr = getRelationalComparison($1,$3,"==");
									}
			| 	expr AND expr 		{
										if ($1.type != INT_TYPE || $3.type != INT_TYPE) {
											yyerror("BOTH OPERANDS MUST BE INT");YYABORT; }
										$$.type = INT_TYPE;
										$$.expr = strcat(strcat($1.expr," && "), $3.expr);
									}
			| 	expr OR expr 		{
										if ($1.type != INT_TYPE || $3.type != INT_TYPE) {
											yyerror("BOTH OPERANDS MUST BE INT");YYABORT; }
										$$.type = INT_TYPE;
										$$.expr = strcat(strcat($1.expr," || "), $3.expr);
									}
			| 	'!' expr 			{ if($2.type != INT_TYPE){yyerror("WRONG EXPR");YYABORT;}$$.expr=malloc((1+strlen($2.expr)+1+1)*sizeof(char));sprintf($$.expr , "!%s",$2.expr); $$.type = INT_TYPE;}
			| 	'(' expr ')'		{ $$.type = $2.type;$$.expr = malloc((1+strlen($2.expr)+1+1)*sizeof(*($$.expr)));
								  sprintf($$.expr,"(%s)",$2.expr);}
			;

const_expr	:	NUMBER	 					{ $$.type=INT_TYPE; $$.expr = malloc((intLength($1)+1)*sizeof(*($$.expr))); sprintf($$.expr, "%d", $1); }
			|	DOUBLENUMBER				{ $$.type = DOUBLE_TYPE; $$.expr = malloc(256*sizeof(*($$.expr))); sprintf($$.expr, "%f", $1); }
			| 	STRINGVAL			{$$.expr=$1;$$.type = STRING_TYPE;}
			|	CONST'.'field				{VARIABLE * v = varSearch($1);
											    if(v == NULL ){
													yyerror(" const doesnt exist");YYABORT;}
												if(v->type != PRODUCT_TYPE){
													yyerror(" const must be a product");YYABORT;
												}
												$$.expr = malloc((strlen($1)+strlen($3.expr)+1)*sizeof(*($$.expr)));
											   sprintf($$.expr,"%s%s",$1,$3.expr);
											   $$.type=$3.type;
											}
			|	CONST				{VARIABLE * v = varSearch($1);
								    if(v == NULL ){
										yyerror("const doesnt exist");YYABORT;}
								   $$.expr = $1;$$.type=v->type;
								}
			|	const_expr '+' const_expr		{ 
													$$.type = validAddExpr($1,$3);
													if ($$.type != -1)
														$$.expr = addition($1,$3);
													else {
														yyerror("WRONG EXPR");
														YYABORT; } 
												}
			|	const_expr '-' const_expr 		{ 	
													$$.type = validSubsExpr($1,$3);
													if($$.type != -1)
														$$.expr = substraction($1,$3);
													else {
														yyerror("WRONG EXPR");
														YYABORT; } 
												}
			| 	const_expr '*' '*' const_expr 	{
													$$.type = validNumExpr($1,$4);
													if($$.type != -1) {
														$$.type = DOUBLE_TYPE;
														$$.expr = malloc((strlen("pow(,)")+strlen($1.expr)+strlen($4.expr)+1)*sizeof(*($$.expr)));
														sprintf($$.expr, "pow(%s,%s)", $1.expr, $4.expr); }
													else {
														yyerror("WRONG EXPR");
														YYABORT; }
												}
			| 	const_expr '%' const_expr 					{ 
													if ($1.type != INT_TYPE || $3.type != INT_TYPE) {
														yyerror("BOTH OPERANDS MUST BE INT");YYABORT; }
													$$.type = INT_TYPE;
													$$.expr = malloc((strlen("( %% )")+strlen($1.expr)+strlen($3.expr)+1)*sizeof(*($$.expr)));
													sprintf($$.expr, "(%s %% %s)", $1.expr, $3.expr);
												}
			|	const_expr '*' const_expr		{ $$.type = validNumExpr($1,$3); if($$.type != -1){ $$.expr= strcat(strcat($1.expr,"*"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	const_expr '/' const_expr		{ $$.type = validNumExpr($1,$3); if($$.type != -1){$$.expr = strcat(strcat($1.expr,"/"), $3.expr);}else{yyerror("WRONG EXPR");YYABORT;}} 
			|	const_expr '<' const_expr 		{ 
													$$.type = validRelExpr($1,$3);
													if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
													$$.expr = getRelationalComparison($1,$3,"<");
												}
			|	const_expr '>' const_expr 		{ 
													$$.type = validRelExpr($1,$3);
													if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
													$$.expr = getRelationalComparison($1,$3,">");
												}
			|	const_expr LE const_expr 		{ 
													$$.type = validRelExpr($1,$3);
													if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
													$$.expr = getRelationalComparison($1,$3,"<=");
												}
			|	const_expr GE const_expr 		{ 
													$$.type = validRelExpr($1,$3);
													if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
													$$.expr = getRelationalComparison($1,$3,">=");
												}
			|	const_expr NE const_expr 		{ 
													$$.type = validRelExpr($1,$3);
													if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
													$$.expr = getRelationalComparison($1,$3,"!=");
												}
			|	const_expr EQ const_expr 		{ 
													$$.type = validRelExpr($1,$3);
													if ($$.type == -1) { yyerror("WRONG EXPR");YYABORT; }
													$$.expr = getRelationalComparison($1,$3,"==");
												}
			| 	const_expr AND const_expr 		{
													if ($1.type != INT_TYPE || $3.type != INT_TYPE) {
														yyerror("BOTH OPERANDS MUST BE INT");YYABORT; }
													$$.type = INT_TYPE;
													$$.expr = strcat(strcat($1.expr," && "), $3.expr);
												}
			| 	const_expr OR const_expr 		{
													if ($1.type != INT_TYPE || $3.type != INT_TYPE) {
														yyerror("BOTH OPERANDS MUST BE INT");YYABORT; }
													$$.type = INT_TYPE;
													$$.expr = strcat(strcat($1.expr," || "), $3.expr);
												}
			| 	'!' const_expr 					{ if($2.type != INT_TYPE){yyerror("WRONG EXPR");YYABORT;}$$.expr=concat("!",$2.expr); $$.type = INT_TYPE;}
			| 	'(' const_expr ')'				{ $$.type == $2.type;$$.expr = malloc((1+strlen($2.expr)+1+1)*sizeof(*($$.expr)));
								  sprintf($$.expr,"(%s)",$2.expr);}
			;





%%
int state = 0;
int block =0;
int blocks = 0;
int * lastOne;
int closeds =0;

void yyerror(char const *s) {
	fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main(void) {

    printf("#include <stdlib.h>\n");
    printf("#include <stdio.h>\n");
    printf("#include <string.h>\n");
    printf("#include <math.h>\n");
    printf("#include \"include/utils.h\"\n");
    printf("#include \"include/types.h\"\n");
    printf("int main(void) { \n");
    printf("char AUX_STRING_READER1[256]={0}; \n");
     printf("int AUX_IDX1; \n");
    yyparse();

    printf("}\n");

    return 0;
}
