
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

	int validateAsignation(char * name,expresion e){
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
			case STRING_TYPE: return validate("char *",e.type) == 0 ? -2 : 1 ;
					  break;
			case INT_TYPE:return validate("int",e.type) == 0 ? -2 : 1;
				      break;
			case DOUBLE_TYPE:return validate("double",e.type) == 0 ? -2 : 1;
					 break;
			case PRODUCT_TYPE:return validate("product",e.type) == 0 ? -2 : 1;
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



	char *addition(expresion expr1, expresion expr2) {
		VARIABLE *var1 = varSearch(expr1.expr);
		VARIABLE *var2 = varSearch(expr2.expr);

		if (var1 == NULL && var2 == NULL) {
			if (expr1.type == STRING_TYPE) {
				if (expr2.type == STRING_TYPE)
					return concat((char*)substr(expr1.expr,0,strlen(expr1.expr)-1), expr2.expr+1);
				if (expr2.type == INT_TYPE || expr2.type == DOUBLE_TYPE)
					return concat(concat((char*)substr(expr1.expr,0,strlen(expr1.expr)-1), expr2.expr), "\"");
			}
			if (expr2.type == STRING_TYPE) {
				return concat(concat("\"",expr1.expr), expr2.expr+1);
			}
			if (expr1.type != PRODUCT_TYPE && expr2.type != PRODUCT_TYPE)
				return concat(concat(expr1.expr, "+"), expr2.expr);
			if (expr1.type == PRODUCT_TYPE && expr2.type == PRODUCT_TYPE) {
				return NULL;	/* TODO: implement suma de productos. */
			}
		}

		if (var1 != NULL && var2 != NULL && var1->type == PRODUCT_TYPE && var2->type == PRODUCT_TYPE) {
			return NULL;	/* TODO: implement suma de productos. */
		}

		char *strVar1, *strVar2, *str1, *str2;
		var_type type1, type2;

		if (var1 != NULL) { strVar1 = var1->name; type1 = var1->type; }
		else { strVar1 = expr1.expr; type1 = expr1.type; }
		if (var2 != NULL) { strVar2 = var2->name; type2 = var2->type; }
		else { strVar2 = expr2.expr; type2 = expr2.type; }

		if (type1 == STRING_TYPE || type2 == STRING_TYPE) {
			switch(type1) {
				case STRING_TYPE:
					str1 = malloc(strlen(strVar1));
					sprintf(str1, "%s", strVar1);
					break;
				case INT_TYPE:
					str1 = malloc(strlen("intToChar(")+strlen(strVar1)+strlen(")"));
					sprintf(str1, "intToChar(%s)", strVar1);
					break;
				case DOUBLE_TYPE:
					str1 = malloc(strlen("doubleToChar(")+strlen(strVar1)+strlen(")"));
					sprintf(str1, "doubleToChar(%s)", strVar1);
					break;
			}
			switch(type2) {
				case STRING_TYPE:
					str2 = malloc(strlen(strVar2));
					sprintf(str2, "%s", strVar2);
					break;
				case INT_TYPE:
					str2 = malloc(strlen("intToChar(")+strlen(strVar2)+strlen(")"));
					sprintf(str2, "intToChar(%s)", strVar2);
					break;
				case DOUBLE_TYPE:
					str2 = malloc(strlen("doubleToChar(")+strlen(strVar2)+strlen(")"));
					sprintf(str2, "doubleToChar(%s)", strVar2);
					break;
			}
			char *resp = malloc(strlen("concat(")+strlen(str1)+strlen(",")+strlen(str2)+strlen(")"));
			sprintf(resp, "concat(%s,%s)", str1, str2);
			return resp;
		}
		char *resp = malloc(strlen(strVar1)+strlen("+")+strlen(strVar2));
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
								4*strlen(strVar)+strlen(".name,")+strlen(".description,")+strlen(".price,")+strlen(".qty);"));
		else
			resp = malloc(strlen("printf(\"%%s\",")+strlen(strVar)+strlen(");\n"));
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
								4*strlen(strVar)+strlen(".name,")+strlen(".description,")+strlen(".price,")+strlen(".qty);\n"));
		else
			resp = malloc(strlen("printf(\"%%s\\n\",")+strlen(strVar)+strlen(");\n"));
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
%}

%union {
  int intnum;
  char * string;
  float floatnum;
  expresion expre;
}

%token STRING INT DOUBLE PRODUCT DISCOUNT NAME PRICE DESC STOCK GOTSTOCK EQUALS ADD
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
%right '!'
%left INC DEC '<' '>' LE GE NE EQ AND OR


%type <string> block statement const;
%type <expre> expr;
%type <expre> const_expr;
%type <string> type;
%type <expre> field;



%start program

%%

program		:	'$' '$' '\n' constList '$' '$' '\n' main
			|	main
			;

main		:  	main statement						{ printf("%s", $2); }
			| 	/*NULL*/
			;

constList 	:	const constList 
			|	/* NULL */
			;

const 		:	type CONST '<' '-' const_expr ';' '\n' 	{	if (validate($1,$5.type)) {
														int ans = addVar(prepareVar($1,$2,$5.expr,1));
														if( ans >= 0) {
															$$ = malloc((strlen($1)+1+strlen($2)+3+strlen($5.expr)+8)*sizeof(*$$));
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
															$$ = malloc((strlen($2)+strlen($6)+strlen($8)+strlen($10.expr)+strlen($12.expr)+24)*sizeof($$));
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


block		:	block statement		{
										$$ = malloc((strlen($1)+strlen($2))*sizeof(*$$));
										sprintf($$, "%s%s", $1,$2);
									}
			|						{	$$ = ""; }
			;

statement 	:	VAR '<' '-' expr ';' '\n' 		{
													int ans = validateAsignation($1,$4);
								    				if (ans ==1) {
														$$ = malloc((strlen($1)+3+strlen($4.expr)+2)*sizeof(*$$));
														sprintf($$,"%s = %s;\n", $1, $4.expr);
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

			|VAR '.' field '<' '-' expr ';' '\n' 		{VARIABLE * v = varSearch($1);
														    if(v == NULL ){
																yyerror(" var doesnt exist");YYABORT;}
															if(v->type != PRODUCT_TYPE){
																yyerror(" var must be a product");YYABORT;
															}
															if($3.type != $6.type){
																yyerror(" wrong asignation");YYABORT;
															}
															$$ = malloc((strlen($1)+strlen($3.expr)+strlen($6.expr)+5)*sizeof(*$$));
															  sprintf($$,"%s%s = %s;\n",$1,$3.expr,$6.expr);
															 
								    																	
																					}

			|VAR '<' '-' '{'STRINGVAL ','STRINGVAL ','expr','expr'}' ';' '\n'  		{VARIABLE * v = varSearch($1);
																					 if(v == NULL || v->type != PRODUCT_TYPE){
																					 		yyerror("wrong var type or var doesnt exist");YYABORT;}
																					if($9.type != INT_TYPE || $11.type!= DOUBLE_TYPE){															
																							yyerror("wrong var initialization");YYABORT;
																					}
																					$$ = malloc((strlen($1)+strlen($5)+strlen($7)
																						+strlen($9.expr)+strlen($11.expr)+35)*sizeof($$));
															  						sprintf($$,"%s.name=%s;\n%s.description=%s;\n%s.price=%s;\n%s.qty=%s;\n",$1,$5,$1,$7,$1,$9.expr,$1,$11.expr);	}																			
			|	type VAR ';' '\n'				{
													int ans = addVar(prepareVar($1,$2,NULL,0));
													if (ans >= 0) {
														$$ = malloc((strlen($1)+1+strlen($2)+2)*sizeof(*$$));
														sprintf($$, "%s %s;\n", $1,$2);
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
														$$ = malloc((5*strlen($2)+57)*sizeof(*$$));
														sprintf($$, "product %s;\n%s.name=\"\";\n%s.description=\"\";\n%s.price=0.0;\n%s.qty=0;\n", $2,$2,$2,$2,$2);
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
														$$ = malloc((3*strlen($2)+59)*sizeof(*$$));
														sprintf($$, "product_array %s;\n%s.array = malloc(sizeof(product));\n%s.size=0;\n", $2,$2,$2);
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
													$$ = malloc((6*strlen($1)+strlen($5)+77)*sizeof(*$$));
													sprintf($$,"%s.array[%s.size]=%s;\n%s.array = realloc(%s.array,(%s.size+1)*sizeof(product));\n%s.size++;\n",$1,$1,$5,$1,$1,$1,$1);													
													
												}
			|	type VAR '<' '-' expr ';' '\n' 	{	if (validate($1,$5.type)) {
														int ans = addVar(prepareVar($1,$2,$5.expr,0));
														if( ans >= 0) {
															$$ = malloc((strlen($1)+1+strlen($2)+3+strlen($5.expr)+2)*sizeof(*$$));
															sprintf($$, "%s %s = %s;\n", $1,$2,$5.expr);
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
															$$ = malloc((strlen($2)+strlen($6)+strlen($8)+strlen($10.expr)+strlen($12.expr)+18)*sizeof($$));
								  							sprintf($$,"product %s = {%s,%s,%s,%s};\n",$2,$6,$8,$10.expr,$12.expr);
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
														

			|	PRINT '(' expr ')' ';' '\n'		{	$$ = exprToPrint($3); }
			| 	PRINTLN '(' expr ')' ';' '\n'	{ 	$$ = exprToPrintln($3); }
			| 	IF expr '\n' 
					block 
				ENDIF '\n'						{ 
													$$ = malloc((3+strlen($2.expr)+4+strlen($4)+2)*sizeof(*$$));
													sprintf($$, "if(%s) {\n%s}\n", $2.expr,$4);
												}
			|	IF expr '\n'
					block 
				ELSE '\n'
					block
				ENDIF '\n' 						{
													$$ = malloc((3+strlen($2.expr)+4+strlen($4)+9+strlen($7)+2)*sizeof(*$$));
													sprintf($$, "if(%s) {\n%s}\nelse {\n%s}\n", $2.expr,$4,$7);
												}
			|	WHILE expr '\n'
					block
				ENDWHILE '\n'					{
													$$ = malloc((6+strlen($2.expr)+4+strlen($4)+2)*sizeof(*$$));
													sprintf($$, "while(%s) {\n%s}\n", $2.expr,$4);
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
														$$ = malloc((strlen($1)+intLength($3)+16)*sizeof(*$$));
														sprintf($$,"%s.price*=%d/100.0;\n",$1,(100-$3));
													 }

			
			;

expr		:	NUMBER	 					{ $$.type=INT_TYPE; $$.expr = malloc(intLength($1)*sizeof(*($$.expr))); sprintf($$.expr, "%d", $1); }
			|	DOUBLENUMBER				{ $$.type = DOUBLE_TYPE; $$.expr = malloc(256*sizeof(*($$.expr))); sprintf($$.expr, "%f", $1); }
			| 	STRINGVAL			{$$.expr=$1;$$.type = STRING_TYPE;}							
			|	expr '+' expr			{$$.type = validAddExpr($1,$3); if($$.type != -1){$$.expr = addition($1,$3);}else{yyerror("WRONG EXPR");YYABORT;} }
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
									$$.expr = malloc((strlen($1)+strlen($3.expr))*sizeof(*($$.expr)));
								   sprintf($$.expr,"%s%s",$1,$3.expr);
								   $$.type=$3.type;
								}
			|	GOTSTOCK'('VAR')' 			{VARIABLE * v = varSearch($3);
												 if(v ==NULL ){
												 	yyerror("VAR ISNT DECLARATED");YYABORT;
												  }
													if(v->type != PRODUCT_TYPE){
														yyerror("VAR ISNT OF TYPE PRODUCT");YYABORT;
													}
													$$.expr = malloc((strlen($3)+8)*sizeof(*($$.expr)));
													sprintf($$.expr,"(%s.qty>0)",$3);
													$$.type = INT_TYPE;
												 }

			|	VAR EQUALS VAR 			{VARIABLE * v = varSearch($1);VARIABLE * v2 = varSearch($3);
												 if(v ==NULL || v2 ==NULL){
												 	yyerror("AT LEAST ONEVAR ISNT DECLARATED");YYABORT;
												  }
													if(v->type != PRODUCT_TYPE || v2->type != PRODUCT_TYPE){
														yyerror("AT LEAST ONE VAR ISNT OF TYPE PRODUCT");YYABORT;
													}
													$$.expr = malloc((4*strlen($3)+4*strlen($1)+100)*sizeof(*($$.expr)));
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
												$$.expr = malloc((strlen($1)+strlen($3.expr))*sizeof(*($$.expr)));
											   sprintf($$.expr,"%s%s",$1,$3.expr);
											   $$.type=$3.type;
											}				
			|	expr '-' expr		{$$.type = validExpr($1,$3); if($$.type != -1){ $$.expr = strcat(strcat($1.expr,"-"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	expr '*' expr		{$$.type = validExpr($1,$3); if($$.type != -1){ $$.expr= strcat(strcat($1.expr,"*"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	expr '/' expr		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.expr = strcat(strcat($1.expr,"/"), $3.expr);}else{yyerror("WRONG EXPR");YYABORT;}} 
			|	expr '<' expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"<"), $3.expr);}else{yyerror("WRONG EXPR");YYABORT;}} 
			|	expr '>' expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,">"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	expr LE expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"<="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	expr GE expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,">="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	expr NE expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"!="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	expr EQ expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"=="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	expr AND expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"&&"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	expr OR expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"||"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	'!' expr 				{ $$.expr = strcat("!",$2.expr); $$.type = $2.type;}
			| '(' expr ')'				{ $$.type == $2.type;$$.expr = malloc((1+strlen($2.expr)+1)*sizeof(*($$.expr)));
								  sprintf($$.expr,"(%s)",$2.expr);}
			;

const_expr		:	NUMBER	 					{ $$.type=INT_TYPE; $$.expr = malloc(intLength($1)*sizeof(*($$.expr))); sprintf($$.expr, "%d", $1); }
			|	DOUBLENUMBER				{ $$.type = DOUBLE_TYPE; $$.expr = malloc(256*sizeof(*($$.expr))); sprintf($$.expr, "%f", $1); }
			| 	STRINGVAL			{$$.expr=$1;$$.type = STRING_TYPE;}							
			|	const_expr '+' const_expr			{$$.type = validAddExpr($1,$3); if($$.type != -1){$$.expr = addition($1,$3);}else{yyerror("WRONG EXPR");YYABORT;} }
			|	CONST'.'field				{VARIABLE * v = varSearch($1);
											    if(v == NULL ){
													yyerror(" const doesnt exist");YYABORT;}
												if(v->type != PRODUCT_TYPE){
													yyerror(" const must be a product");YYABORT;
												}
												$$.expr = malloc((strlen($1)+strlen($3.expr))*sizeof(*($$.expr)));
											   sprintf($$.expr,"%s%s",$1,$3.expr);
											   $$.type=$3.type;
											}
			|	CONST				{VARIABLE * v = varSearch($1);
								    if(v == NULL ){
										yyerror("const doesnt exist");YYABORT;}
								   $$.expr = $1;$$.type=v->type;
								}					
			|	const_expr '-' const_expr		{$$.type = validExpr($1,$3); if($$.type != -1){ $$.expr = strcat(strcat($1.expr,"-"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	const_expr '*' const_expr		{$$.type = validExpr($1,$3); if($$.type != -1){ $$.expr= strcat(strcat($1.expr,"*"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	const_expr '/' const_expr		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.expr = strcat(strcat($1.expr,"/"), $3.expr);}else{yyerror("WRONG EXPR");YYABORT;}} 
			|	const_expr '<' const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"<"), $3.expr);}else{yyerror("WRONG EXPR");YYABORT;}} 
			|	const_expr '>' const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,">"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			|	const_expr LE const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"<="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	const_expr GE const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,">="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	const_expr NE const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"!="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	const_expr EQ const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"=="), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	const_expr AND const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"&&"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	const_expr OR const_expr 		{ $$.type = validExpr($1,$3); if($$.type != -1){$$.type=INT_TYPE;$$.expr = strcat(strcat($1.expr,"||"), $3.expr); }else{yyerror("WRONG EXPR");YYABORT;}}
			| 	'!' const_expr 				{ $$.expr = strcat("!",$2.expr); $$.type = $2.type;}
			| '(' const_expr ')'				{ $$.type == $2.type;$$.expr = malloc((1+strlen($2.expr)+1)*sizeof(*($$.expr)));
								  sprintf($$.expr,"(%s)",$2.expr);}
			;





%%

void yyerror(char *s) {
	fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main(void) {

    printf("#include <stdlib.h>\n");
    printf("#include <stdio.h>\n");
    printf("#include <string.h>\n");
    printf("#include \"include/utils.h\"\n");
    printf("#include \"include/types.h\"\n");
    printf("int main(void) { \n");

    yyparse();

    printf("}\n");

    return 0;
}
