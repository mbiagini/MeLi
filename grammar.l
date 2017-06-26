%{
	#include <stdlib.h>
	#include "y.tab.h"
	void yyerror(char *);


%}

space					[ \t]
nullSpace				{space}+

letter					[a-zA-Z]
lowerCase				[a-z]
upperCase				[A-Z]
variableName				[A-Za-z]+

digit					[0-9]
wholeNumber				{digit}+|-{digit}+
doubleNumber			{digit}+\.{digit}+

typeString				STRING{space}
typeInt					INT{space}
typeDouble				DOUBLE{space}
typeProduct				PRODUCT{space}

/*
constIdentifier			{upperCase}+
identifier 				{lowerCase}[{lowerCase}{upperCase}{number}_-]*






{lowerCase}				{ yylval = *yytext - 'a';
							return VAR; }
*/

%%

{typeString}			{ return STRING; }
{typeInt}				{ return INT; }
{typeDouble}			{ return DOUBLE; }
{typeProduct}			{ return PRODUCT; }

{wholeNumber}			{ yylval.intnum = atoi(yytext);
							return NUMBER; }
{doubleNumber}			{ yylval.floatnum = atof(yytext);
							return DOUBLENUMBER; }

{variableName}				{ yylval.string = malloc(strlen(yytext)+1);
							strcpy(yylval.string, yytext);
							return VAR; }





[-+()</=*\n;]			return *yytext;
{nullSpace}				; /* skip whitespace */
.						yyerror("invalid character");

%%

int yywrap(void) {
	return 1;
}
