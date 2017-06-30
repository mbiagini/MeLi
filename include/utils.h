#ifndef _utils_h
#define _utils_h
#include "types.h"


int intLength(int num);

char *substr(char *str, int start, int end);
char *concat(char *str1, char *str2);
char *removeSubstring(char *str,const char *sub);

char *intToChar(int i);
char *doubleToChar(double d);

var_type validNumExpr(expresion e1,expresion e2);
var_type validRelExpr(expresion e1,expresion e2);
var_type validAddExpr(expresion e1, expresion e2);
var_type validSubsExpr(expresion e1, expresion e2);
int  validate(char * type, var_type expr);
int countCharInString(char * str, char c);
double myRound(double num, unsigned int digits);
int prodInArray(product,product_array);

product getMinProd(product_array array);
product getMaxProd(product_array p_array);

void removeFromArray(product_array *, int);
void removeProdFromArray(product_array *, product);
#endif


