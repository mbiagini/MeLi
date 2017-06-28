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

var_type validExpr(expresion e1,expresion e2) {
	if(e1.type == STRING_TYPE && e2.type != STRING_TYPE)
		return -1;
	if(e2.type == STRING_TYPE && e1.type != STRING_TYPE){
		return -1;
	}
	if(e1.type == e2.type)
		return e1.type;
	return INT_TYPE;
}

var_type validAddExpr(expresion e1, expresion e2) {
	if (e1.type == PRODUCT_TYPE && e2.type != PRODUCT_TYPE)
		return -1;
	if (e2.type == PRODUCT_TYPE && e1.type != PRODUCT_TYPE)
		return -1;
	if (e1.type == STRING_TYPE || e2.type == STRING_TYPE)
		return STRING_TYPE;
	if (e1.type == e2.type) {
		if (e1.type == PRODUCT_TYPE)
			return PRODUCT_TYPE;		/* TODO: should return *PRODUCT_TYPE */
		return e1.type;
	}
	if (e1.type == DOUBLE_TYPE || e2.type == DOUBLE_TYPE)
		return DOUBLE_TYPE;
	return INT_TYPE;
}

char *substr(char *str, int start, int end) {
	char *resp = malloc(strlen(str));
	memcpy(resp, str+start, end - start);
	return resp;
}

char *concat(char*str1,char*str2) {
	char *resp = malloc(strlen(str1)+strlen(str2));
	sprintf(resp, "%s%s", str1, str2);
	return resp;
}

char *intToChar(int i) {
	char *resp = malloc(15);
	sprintf(resp,"%d",i);
	return resp;
}

char *doubleToChar(double d) {
	char *resp = malloc(20);
	sprintf(resp,"%f",d);
	return resp;
}