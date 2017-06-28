#ifndef _utils_h
#define _utils_h
#include "types.h"

var_type validExpr(expresion e1,expresion e2);
var_type validAddExpr(expresion e1,expresion e2);
int  validate(char * type, var_type expr);
int countCharInString(char * str, char c);
int intLength(int num);

char *substr(char *str, int start, int end);
char *concat(char *str1, char *str2);

char *intToChar(int i);
char *doubleToChar(double d);

var_type validExpr(expresion e1,expresion w2);
var_type validAddExpr(expresion e1, expresion e2);
int  validate(char * type, var_type expr);
int countCharInString(char * str, char c);

#endif


