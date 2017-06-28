#include "include/utils.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "include/types.h"


int  validate(char * type, var_type expr);


int validate(char * type, var_type expr_type){
	if(strcmp(type,"char *") == 0 && expr_type == STRING_TYPE){
	  return 1;
	}else if((strcmp(type,"int")== 0 || strcmp(type,"double") == 0)&& (expr_type == INT_TYPE || expr_type == DOUBLE_TYPE)){
	    return 1;
	}else if(strcmp(type,"product")==0 && expr_type == PRODUCT_TYPE){
		return 1;
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

int intLength(int num){
	int i =0;
	while(num > 0){
		num = num/10;
		i++;
	}
	return i;
}
