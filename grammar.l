%option yylineno
%{
	#include <stdlib.h>
	#include "y.tab.h"
	void yyerror(char *);


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
stringVal			[A-Za-z0-9]+

%%

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


[-+()</=$*\n;]			return *yytext;

{nullSpace}				; /* skip whitespace */
.						yyerror("invalid character");

%%

int yywrap(void) {
	return 1;
}
