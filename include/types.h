typedef enum
{
	STRING_TYPE ,
	INT_TYPE,
	DOUBLE_TYPE,
	PRODUCT_TYPE
} var_type;

typedef struct {
	var_type type;
	char * name;
	int constant;
	void * content;
} VARIABLE;

typedef struct {
	char * name;
	char * description;
	double price;
	int qty;
}product;
