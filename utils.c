#include "include/utils.h"
#include <math.h>
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

int intLength(int num){
	int i =0;
	while(num > 0){
		num = num/10;
		i++;
	}
	return i;
}

var_type validExpr(expresion e1,expresion e2) {
	if (e1.type == PRODUCT_TYPE || e2.type == PRODUCT_TYPE)
		return -1;
	if (e1.type == STRING_TYPE || e2.type == STRING_TYPE)
		return -1;
	if (e1.type == DOUBLE_TYPE || e2.type == DOUBLE_TYPE)
		return DOUBLE_TYPE;
	return INT_TYPE;
}

var_type validAddExpr(expresion e1, expresion e2) {
	if (e1.type == PRODUCT_TYPE || e2.type == PRODUCT_TYPE)
		return -1;
	if (e1.type == STRING_TYPE || e2.type == STRING_TYPE)
		return STRING_TYPE;
	if (e1.type == e2.type)
		return e1.type;
	if (e1.type == DOUBLE_TYPE || e2.type == DOUBLE_TYPE)
		return DOUBLE_TYPE;
	return INT_TYPE;

}

var_type validSubsExpr(expresion e1, expresion e2) {
	if (e1.type == PRODUCT_TYPE || e2.type == PRODUCT_TYPE)
		return -1;
	if (e1.type == e2.type)
		return e1.type;
	if (e1.type == INT_TYPE && e2.type == DOUBLE_TYPE)
		return DOUBLE_TYPE;
	if (e2.type == INT_TYPE && e1.type == DOUBLE_TYPE)
		return DOUBLE_TYPE;
	return -1;
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

double myRound(double num, unsigned int digits) {
    double factor = pow(10, digits);
    return round(num*factor)/factor;
}

int prodInArray(product prod,product_array prod_arr){
	int i = 0 ;
	for(;i < prod_arr.size;i++){
		if(strcmp(prod.name,prod_arr.array[i].name)==0 && strcmp(prod.description,prod_arr.array[i].description)==0 && prod.price == prod_arr.array[i].price && prod.qty == prod_arr.array[i].qty)
			return 1;
	}
	return 0;
}

char *removeSubstring(char *str,const char *sub) {
	char *resp = malloc(strlen(str)+1);
	char *sub_location;
	if (strlen(sub) > strlen(str))
		return str;
	strcpy(resp, str);
	sub_location = strstr(resp, sub);
	if (sub_location != NULL) {
		strcpy(sub_location, sub_location + strlen(sub));
		char *next = removeSubstring(resp,sub);
		return next;
	}
	return resp;
}

product getMinProd(product_array p_array) {
	product resp;
	if (p_array.size == 0) {
		resp.name = "null"; resp.description = "null"; resp.price = 0.0; resp.qty = 0;
		return resp;
	}
	int i;
	int min_idx = 0;
	double min_price = p_array.array[0].price;
	for (i = 0; i < p_array.size; i++) {
		if (p_array.array[i].price < min_price) {
			min_idx = i;
			min_price = p_array.array[i].price;
		}
	}
	resp.name = p_array.array[min_idx].name;
	resp.description = p_array.array[min_idx].description;
	resp.price = p_array.array[min_idx].price;
	resp.qty = p_array.array[min_idx].qty;
	return resp;
}

product getMaxProd(product_array p_array) {
	product resp;
	if (p_array.size == 0) {
		resp.name = "null"; resp.description = "null"; resp.price = 0.0; resp.qty = 0;
		return resp;
	}
	int i;
	int max_idx = 0;
	double max_price = p_array.array[0].price;
	for (i = 0; i < p_array.size; i++) {
		if (p_array.array[i].price > max_price) {
			max_idx = i;
			max_price = p_array.array[i].price;
		}
	}
	resp.name = p_array.array[max_idx].name;
	resp.description = p_array.array[max_idx].description;
	resp.price = p_array.array[max_idx].price;
	resp.qty = p_array.array[max_idx].qty;
	return resp;
}