%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include "symbol.c"
// #include "parseTree.c"

#define MAX_SYMBOLS 50

typedef struct Symbol {
    char *key;
    char *type;
    char *value;
    struct Symbol *next;
} Symbol;

typedef struct SymbolTable {
    Symbol *table[MAX_SYMBOLS];
} SymbolTable;

SymbolTable symbol_table;

unsigned int hash(const char *key) {
    unsigned int hash = 0;
    while (*key) {
        hash = (hash << 5) + *key++;
    }
    return hash % MAX_SYMBOLS;
}

Symbol* create_symbol(char *key, char *type, char *value) {
    Symbol *new_symbol = (Symbol*)malloc(sizeof(Symbol));
    new_symbol->key = strdup(key);
    new_symbol->type = strdup(type);
    new_symbol->value = strdup(value);
    new_symbol->next = NULL;
    return new_symbol;
}

void add_symbol(char *key, char *type, char *value) {
    unsigned int index = hash(key);
    Symbol *new_symbol = create_symbol(key, type, value);

    if (symbol_table.table[index] == NULL) {
        symbol_table.table[index] = new_symbol;
    } else {
        Symbol *current = symbol_table.table[index];
        while (current->next != NULL) {
            if (strcmp(current->key, key) == 0) {
                printf("Symbol '%s' already exists.\n", key);
                free(new_symbol->key);
                free(new_symbol->type);
                free(new_symbol->value);
                free(new_symbol);
                return;
            }
            current = current->next;
        }
        if (strcmp(current->key, key) == 0) {
            printf("Symbol '%s' already exists.\n", key);
            free(new_symbol->key);
            free(new_symbol->type);
            free(new_symbol->value);
            free(new_symbol);
            return;
        }
        current->next = new_symbol;
    }
}

void update_symbol_value(char *key, char *new_value) {
    unsigned int index = hash(key);
    Symbol *symbol = symbol_table.table[index];

    while (symbol != NULL) {
        if (strcmp(symbol->key, key) == 0) {
            free(symbol->value);
            symbol->value = strdup(new_value);
            return;
        }
        symbol = symbol->next;
    }
}

void print_symbol_table() {
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        Symbol *current = symbol_table.table[i];
        while (current != NULL) {
            printf("Key: %s, Type: %s, Value: %s\n", current->key, current->type, current->value);
            current = current->next;
        }
    }
}

void free_symbol_table() {
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        Symbol *current = symbol_table.table[i];
        while (current != NULL) {
            Symbol *temp = current;
            current = current->next;
            free(temp->key);
            free(temp->type);
            free(temp->value);
            free(temp);
        }
        symbol_table.table[i] = NULL;
    }
}

typedef struct Node {
    int node_id;
    char *type;
    struct Node **children;
    int child_count;
} Node;

void yyerror(const char *s);
int yylex(void);

int current_node_id = 1;

Node* create_node(const char *type) {
    Node *node = (Node*)malloc(sizeof(Node));
    node->node_id = current_node_id++;
    node->type = strdup(type);
    node->children = NULL;
    node->child_count = 0;
    return node;
}

void add_child(Node *parent, Node *child) {
    parent->children = realloc(parent->children, sizeof(Node*) * (parent->child_count + 1));
    parent->children[parent->child_count++] = child;
}

void print_tree(Node *node, int level) {
    if (node == NULL) return;
    for (int i = 0; i < level; i++);
    printf("** Node %d: %s\n", node->node_id, node->type);
    for (int i = 0; i < node->child_count; i++) {
        print_tree(node->children[i], level + 1);
    }
}

void walk_tree(Node *node) {
    print_tree(node, 0);
}

Node *parse_tree = NULL;

%}

%union {
    int int_val;
    double double_val;
    char* str;
    struct Node* node;
}

%token <str> IDENTIFIER SCONSTANT
%token <int_val> ICONSTANT
%token <double_val> DCONSTANT
%token K_PROGRAM K_FUNCTION K_INTEGER K_PRINT_INTEGER K_PRINT_STRING K_PRINT_DOUBLE
%token K_DOUBLE K_ELSE K_EXIT K_IF K_PROCEDURE K_READ_DOUBLE K_READ_INTEGER K_READ_STRING
%token K_RETURN K_STRING K_THEN K_UNTIL K_WHILE K_DO
%token LCURLY RCURLY LPAREN RPAREN SEMI ASSIGN COMMA COMMENT DAND DIVIDE DOR
%token ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULTIPLY ASSIGN_DIVIDE ASSIGN_MOD
%token DEQ GEQ GT LBRACKET LT MINUS DECREMENT MOD MULTIPLY NE NOT PERIOD
%token PLUS INCREMENT RBRACKET LEQ

%type <node> start program function_block function statement_block statement
%type <node> declare assign print_statement

%start start

%% 

start : program {
    parse_tree = $1;
}
;

program : K_PROGRAM IDENTIFIER LCURLY function_block RCURLY {
    $$ = create_node("program");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_symbol($2, "program", "N/A");
    add_child($$, id_node);
    add_child($$, $4);
}
;

function_block : function function_block {
    $$ = create_node("function_block");
    add_child($$, $1);
    add_child($$, $2);
}
| {
    $$ = create_node("empty");
}
;

function : K_FUNCTION K_INTEGER IDENTIFIER LPAREN RPAREN LCURLY statement_block RCURLY {
    $$ = create_node("function");
    Node *return_type = create_node("K_INTEGER");
    add_child(return_type, create_node("integer"));
    add_child($$, return_type);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_symbol($3, "integer function", "N/A");
    add_child($$, id_node);
    add_child($$, $7);
}
;

statement_block : statement statement_block {
    $$ = create_node("statement_block");
    add_child($$, $1);
    add_child($$, $2);
}
| {
    $$ = create_node("empty");
}
;

statement : declare SEMI {
    $$ = $1;
}
| assign SEMI {
    $$ = $1;
}
| print_statement SEMI {
    $$ = $1;
}
;

declare : K_INTEGER IDENTIFIER {
    $$ = create_node("declare");
    Node *type_node = create_node("K_INTEGER");
    add_child(type_node, create_node("integer"));
    add_child($$, type_node);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_symbol($2, "integer", "N/A");
    add_child($$, id_node);
}
;

print_statement : K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN {
    $$ = create_node("print_integer");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
| K_PRINT_STRING LPAREN SCONSTANT RPAREN {
    $$ = create_node("print_string");
    Node *str_node = create_node("SCONSTANT");
    add_child(str_node, create_node($3));
    add_symbol($3, "SCONSTANT", $3);
    add_child($$, str_node);
}
;

assign : IDENTIFIER ASSIGN ICONSTANT {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    add_child(lhs_node, create_node($1));
    add_child($$, lhs_node);
    Node *val_node = create_node("ICONSTANT");
    char buffer[20];
    sprintf(buffer, "%d", $3);
    add_child(val_node, create_node(buffer));

    update_symbol_value($1, buffer);

    add_child($$, val_node);
}
| IDENTIFIER ASSIGN DCONSTANT {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    add_child(lhs_node, create_node($1));
    add_child($$, lhs_node);
    Node *val_node = create_node("DCONSTANT");
    char buffer[20];
    sprintf(buffer, "%f", $3);
    add_child(val_node, create_node(buffer));

    update_symbol_value($1, buffer);

    add_child($$, val_node);
}
| IDENTIFIER ASSIGN IDENTIFIER {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    add_child(lhs_node, create_node($1));
    add_child($$, lhs_node);
    Node *rhs_node = create_node("IDENTIFIER");
    add_child(rhs_node, create_node($3));
    add_child($$, rhs_node);
}
;

%% 

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    printf("Parsing started...\n");
	if (yyparse() == 0) {
		printf("Parsing completed successfully.\n");
		printf("+++++++++++++++++++++++++++++++++++++++++++++++\n");
		printf("+ Walking through the Parse Tree Begins Here  +\n");
		printf("+++++++++++++++++++++++++++++++++++++++++++++++\n");
		walk_tree(parse_tree);
	} 
    else {
		printf("Parsing failed.\n");
	}

    printf("\n\n++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("+             Symbol Table Elements            +\n");
    printf("++++++++++++++++++++++++++++++++++++++++++++++++\n");
    print_symbol_table();
    free_symbol_table();

    return 0;
}
