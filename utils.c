#include "include/utils.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "include/types.h"
var_type validExpr(expresion e1,expresion w2);


int validate(char * type, char * expr){
	int length = strlen(expr);
	if(strcmp(type,"char *") == 0){
	  if(expr[0] == 34 && expr[length-1] ==34 && countCharInString(expr,34) == 2)
		return 1;
	   return 0;
	}else if(strcmp(type,"int")== 0 || strcmp(type,"double") == 0){
	   if(strchr(expr, 34)!= NULL)
		return 0;
	    return 1;
	}else if(strcmp(type,"product")==0){
		if(strchr(expr,'}') ==NULL)
			return 0;
		 if(countCharInString(expr,34) == 4)
			return 1;
		return 0;
	}
	return 0;
}

int countCharInString(char * str, char c){
	int length = strlen(str);
	int i = 0;
	int count = 0;
	for(;i<length;i++){
		if(str[i] == c)
			count++;
	}
	return count;
}

var_type validExpr(expresion e1,expresion e2){
	if(e1.type == STRING_TYPE && e2.type != STRING_TYPE)
		return -1;
	if(e2.type == STRING_TYPE && e1.type != STRING_TYPE){
		return -1;
	}
	if(e1.type == e2.type)
		return e1.type;
	return INT_TYPE;
}
