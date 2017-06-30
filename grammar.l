%option yylineno
%{
	#include <stdlib.h>
	#include "include/types.h"
	#include "y.tab.h"

	void yyerror(char *);
	extern int state;
	extern int block;
	extern int blocks;
	extern int * lastOne;
	extern int closeds;
	extern int wasOpened;


%}
space					[ \t]
nullSpace				{space}+


typeString				STRING
typeInt					INT
typeDouble				DOUBLE
typeProduct				PRODUCT

lowerCase				[a-z]
upperCase				[A-Z]
variableName			[a-z][A-Za-z]*
constName				[A-Z]+

digit					[0-9]
wholeNumber				{digit}+|-{digit}+
doubleNumber			{digit}+\.{digit}+
stringVal				[^\"]+



%%

"<="					{ return LE; }
">="					{ return GE; }
"!="					{ return NE; }
"=="					{ return EQ; }
"&&"					{ return AND; }
"||"					{ return OR; }
"++"					{ return INC; }
"--"					{ return DEC; }

"DISCOUNT"					{return DISCOUNT;}
"GOTSTOCK"					{return GOTSTOCK;}
"EQUALS"					{return EQUALS;}
"ADD"					{return ADD;}
"GET"					{return GET;}
"IF"					{ state++;lastOne = realloc(lastOne,(blocks-closeds+1)*sizeof(int));lastOne[blocks-closeds]=block;blocks++;if(!wasOpened){block = blocks;}wasOpened = 1;return IF; }
"THEN"					{ return THEN; }
"ELSE"					{ blocks++;block = blocks;return ELSE; }
"ENDIF"					{ closeds++;wasOpened = 0;block = lastOne[blocks-closeds];lastOne = realloc(lastOne,(blocks-closeds)*sizeof(int));state--;return ENDIF; }

"WHILE"					{ state++;lastOne = realloc(lastOne,(blocks-closeds+1)*sizeof(int));lastOne[blocks-closeds]=block;blocks++;if(!wasOpened){block = blocks;}wasOpened = 1; return WHILE; }
"ENDWHILE"				{ closeds++;wasOpened = 0;block = lastOne[blocks-closeds];lastOne = realloc(lastOne,(blocks-closeds)*sizeof(int));state--;return ENDWHILE; }

"PRINT"					{ return PRINT; }
"PRINTLN"				{ return PRINTLN; }
"GETINT TO"				{ return GETINT; }
"GETDOUBLE TO"			{ return GETDOUBLE; }
"GETSTRING TO"			{ return GETSTRING; }
"IN"			{ return IN; }
"MAX"			{ return MAX; }
"MIN"			{ return MIN; }

"SIZE"			{ return SIZE; }

"NAME"					{return NAME;}
"DESC"					{return DESC;}
"PRICE"					{return PRICE;}
"STOCK"					{return STOCK;}
"BETWEEN"				{return BETWEEN;}
"ROUND"					{return ROUND;}

{typeString}			{ return STRING; }
{typeInt}				{ return INT; }
{typeDouble}			{ return DOUBLE; }
{typeProduct}			{ return PRODUCT; }

{wholeNumber}			{ yylval.intnum = atoi(yytext);
							return NUMBER; }
{doubleNumber}			{ yylval.floatnum = atof(yytext);
							return DOUBLENUMBER; }

\"{stringVal}\"				{ yylval.string = malloc(strlen(yytext)+1);
							strcpy(yylval.string, yytext);
							return STRINGVAL; }

{variableName}				{ yylval.string = malloc(strlen(yytext)+1);
							strcpy(yylval.string, yytext);
							return VAR; }

{constName}				{ yylval.string = malloc(strlen(yytext)+1);
							strcpy(yylval.string, yytext);
							return CONST; }





[-+()</=$*\n>;{},\.\[\]!]			return *yytext;

{nullSpace}				; /* skip whitespace */
.						yyerror("invalid character");

%%

int yywrap(void) {
	return 1;
}
