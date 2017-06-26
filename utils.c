#include "include/utils.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int validate(char * type, char * expr){
	int length = strlen(expr);
	if(strcmp(type,"char *") == 0){
	    if(expr[0] != 34 || expr[length-1] != 34)
		return 0;
	 return 1;
	}else if(strcmp(type,"int")== 0 || strcmp(type,"double") == 0){
	   if(expr[0] == 34 || expr[length-1] == 34)
		return 0;
	    return 1;
	}
	return 0;
}
