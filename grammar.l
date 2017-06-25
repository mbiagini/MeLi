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
*/

%%

{typeString}			{ return STRING; }
{typeInt}				{ return INT; }
{typeDouble}			{ return DOUBLE; }
{typeProduct}			{ return PRODUCT; }

{wholeNumber}			{ yylval = atoi(yytext);
							return NUMBER; }
{doubleNumber}			{ yylval = atof(yytext);
							return DOUBLENUMBER; }

{lowerCase}				{ yylval = *yytext - 'a';
							return VAR; }

[-+()</=*\n]			return *yytext;
{nullSpace}				; /* skip whitespace */
.						yyerror("invalid character");

%%

int yywrap(void) {
	return 1;
}