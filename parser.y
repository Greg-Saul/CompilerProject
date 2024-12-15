%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 7919

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

Symbol* find_symbol(const char *key) {
    unsigned int index = hash(key);
    Symbol *current = symbol_table.table[index];

    while (current != NULL) {
        if (strcmp(current->key, key) == 0) {
            return current;
        }
        current = current->next;
    }

    return NULL;
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
    // for (int i = 0; i < level; i++) {
    //     printf("%d", level);
    // }
    printf("child count: %d, level: %d  ", node->child_count, level);
    printf("** Node %d: %s\n", node->node_id, node->type);
    for (int i = 0; i < node->child_count; i++) {
        // printf("%d", i);
        print_tree(node->children[i], level + 1);
    }
}

void walk_tree(Node *node) {
    print_tree(node, 0);
}

Node *parse_tree = NULL;

%}

%locations

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

%type <node> start program function_block function statement_block statement parameter_list
%type <node> declare_statement assign_statement print_statement procedure parameters parameter
%type <node> type input_statement loop_statement conditional_statement expression procedure_call
%type <node> while until do_condition condition else return_statement arguments argument_list constant
%type <node> simple_expression factor logical_expression term declare_list

%start start

%% 

start : program {
    parse_tree = $1;
}
;

program : K_PROGRAM IDENTIFIER LCURLY function_block statement_block RCURLY {
    $$ = create_node("program");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_child($$, id_node);
    add_child($$, $4);
    add_symbol($2, "program", "");
}
;


function_block : function function_block {
    $$ = create_node("function_block");
    add_child($$, $1);
    add_child($$, $2);
}
| procedure function_block{
    $$ = create_node("procedure");
    add_child($$, $1);
    add_child($$, $2);
}
| {
    $$ = create_node("empty");
}
;

procedure : K_PROCEDURE IDENTIFIER LPAREN parameters RPAREN LCURLY statement_block RCURLY {
    $$ = create_node("procedure");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_child($$, id_node);
    add_child($$, $4);
    add_child($$, $7);
    add_symbol($2, "procedure", "void");
}
;

function : K_FUNCTION type IDENTIFIER LPAREN parameters RPAREN LCURLY statement_block return_statement RCURLY {
    $$ = create_node("function");
    Node *return_type = create_node("K_INTEGER");
    add_child(return_type, create_node("integer"));
    add_child($$, return_type);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
    add_child($$, $8);
    add_symbol($3, "function", $2->type);
}
;

parameters : parameter_list {
    $$ = create_node("parameters");
    add_child($$, $1);
}
| {
    $$ = create_node("empty");
}
;

parameter_list : parameter COMMA parameter_list {
    $$ = create_node("parameter_list");
    add_child($$, $1);
    add_child($$, $3);
}
| parameter {
    $$ = create_node("parameter_list");
    add_child($$, $1);
}
;

parameter : type IDENTIFIER {
    $$ = create_node("parameter");
    add_child($$, $1);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_child($$, id_node);
    add_symbol($2, $1->type, "");
}
| type IDENTIFIER LBRACKET RBRACKET {
    $$ = create_node("parameter");
    add_child($$, $1);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_child($$, id_node);
    add_symbol($2, "array", $1->type);
}
;

type : K_DOUBLE {
    $$ = create_node("K_DOUBLE");
    add_child($$, create_node("double"));
}
| K_STRING {
    $$ = create_node("K_STRING");
    add_child($$, create_node("string"));
}
| K_INTEGER {
    $$ = create_node("K_INTEGER");
    add_child($$, create_node("integer"));
}
;

statement_block : statement statement_block {
    $$ = create_node("statement_block");
    add_child($$, $1);
    add_child($$, $2);
}
| procedure statement_block {
    $$ = create_node("statement_block");
    add_child($$, $1);
    add_child($$, $2);
}
| {
    $$ = create_node("empty");
}
;

statement : declare_statement {
    $$ = $1;
}
| assign_statement {
    $$ = $1;
}
| print_statement {
    $$ = $1;
} 
| input_statement {
    $$ = $1;
}
| loop_statement {
    $$ = $1;
}
| conditional_statement {
    $$ = $1;
}
| procedure_call {
    $$ = $1;
}
| expression SEMI {
    $$ = $1;
}
;

declare_statement : type IDENTIFIER ASSIGN expression SEMI {
    $$ = create_node("declare_assign");
    add_child($$, $1);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_child($$, id_node);
    add_child($$, $4);
    add_symbol($2, $1->type, "");
}
| type declare_list SEMI
| type IDENTIFIER SEMI {
    $$ = create_node("declare");
    add_child($$, $1);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_child($$, id_node);
    add_symbol($2, $1->type, "");
}
;

declare_list : IDENTIFIER COMMA declare_list {
    $$ = create_node("declare_list");
    Node *id_node = create_node("IDENTIFIER");
    id_node->type = strdup($1);
    add_child($$, id_node);
    add_child($$, $3);
}
| IDENTIFIER LBRACKET expression RBRACKET COMMA declare_list {
    $$ = create_node("array_declare_list");
    Node *id_node = create_node("IDENTIFIER");
    id_node->type = strdup($1);
    add_child($$, id_node);
    add_child($$, $3);
    add_child($$, $6);
}
| IDENTIFIER ASSIGN constant COMMA declare_list {
    $$ = create_node("assign_declare_list");
    Node *id_node = create_node("IDENTIFIER");
    id_node->type = strdup($1);
    add_child($$, id_node);
    add_child($$, $3);
    add_child($$, $5);
}
| IDENTIFIER LBRACKET expression RBRACKET {
    $$ = create_node("array_declare");
    Node *id_node = create_node("IDENTIFIER");
    id_node->type = strdup($1);
    add_child($$, id_node);
    add_child($$, $3);
}
| IDENTIFIER ASSIGN constant {
    $$ = create_node("assign_declare");
    Node *id_node = create_node("IDENTIFIER");
    id_node->type = strdup($1);
    add_child($$, id_node);
    add_child($$, $3);
}
| IDENTIFIER {
    $$ = create_node("single_declare");
    Node *id_node = create_node("IDENTIFIER");
    id_node->type = strdup($1);
    add_child($$, id_node);
}
;


assign_statement
: IDENTIFIER ASSIGN ICONSTANT SEMI {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    add_child(lhs_node, create_node($1));
    add_child($$, lhs_node);
    Node *val_node = create_node("ICONSTANT");
    char buffer[20];
    sprintf(buffer, "%d", $3);
    add_child(val_node, create_node(buffer));
    add_child($$, val_node);
    update_symbol_value($1, buffer);
}
| IDENTIFIER ASSIGN DCONSTANT SEMI {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    lhs_node->type = strdup($1);
    add_child($$, lhs_node);
    Node *val_node = create_node("DCONSTANT");
    char buffer[20];
    sprintf(buffer, "%f", $3);
    val_node->type = strdup(buffer);
    add_child($$, val_node);
    update_symbol_value($1, buffer);
}
| IDENTIFIER ASSIGN IDENTIFIER SEMI {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    lhs_node->type = strdup($1);
    add_child($$, lhs_node);
    Node *rhs_node = create_node("IDENTIFIER");
    rhs_node->type = strdup($3);
    add_child($$, rhs_node);
}
| IDENTIFIER ASSIGN expression SEMI {
    $$ = create_node("assign_expression");
    Node *lhs_node = create_node("IDENTIFIER");
    lhs_node->type = strdup($1);
    add_child($$, lhs_node);
    add_child($$, $3);
}
| IDENTIFIER ASSIGN procedure_call SEMI {
    $$ = create_node("assign_procedure_call");
    Node *lhs_node = create_node("IDENTIFIER");
    lhs_node->type = strdup($1);
    add_child($$, lhs_node);
    add_child($$, $3);
}
| IDENTIFIER ASSIGN_PLUS expression SEMI {
    $$ = create_node("assign_plus");
    Node *lhs_node = create_node("IDENTIFIER");
    lhs_node->type = strdup($1);
    add_child($$, lhs_node);
    add_child($$, $3);
}
| IDENTIFIER LBRACKET expression RBRACKET ASSIGN assign_statement {
    $$ = create_node("array_assign");
    Node *array_node = create_node("IDENTIFIER");
    array_node->type = strdup($1);
    add_child($$, array_node);
    add_child($$, $3);
    add_child($$, $6);
}
| IDENTIFIER LBRACKET expression RBRACKET ASSIGN expression SEMI {
    $$ = create_node("array_assign_expression");
    Node *array_node = create_node("IDENTIFIER");
    array_node->type = strdup($1);
    add_child($$, array_node);
    add_child($$, $3);
    add_child($$, $6);
}
;

print_statement : K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN SEMI {
    $$ = create_node("print_integer");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
| K_PRINT_STRING LPAREN SCONSTANT RPAREN SEMI {
    $$ = create_node("print_string");
    Node *str_node = create_node("SCONSTANT");
    add_child(str_node, create_node($3));
    add_child($$, str_node);
}
| K_PRINT_DOUBLE LPAREN expression RPAREN SEMI {
    $$ = create_node("print_double");
    add_child($$, $3);
}
;

input_statement : K_READ_INTEGER LPAREN IDENTIFIER RPAREN SEMI {
    $$ = create_node("input_integer");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
| K_READ_DOUBLE LPAREN IDENTIFIER RPAREN SEMI {
    $$ = create_node("input_double");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
| K_READ_STRING LPAREN IDENTIFIER RPAREN SEMI {
    $$ = create_node("input_string");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
;

loop_statement : K_DO while statement_block {
    $$ = create_node("loop_while");
    add_child($$, $2);
    add_child($$, $3);
}
| K_DO while LCURLY statement_block RCURLY {
    $$ = create_node("loop_while_block");
    add_child($$, $2);
    add_child($$, $4);
}
| K_DO until LCURLY statement_block RCURLY {
    $$ = create_node("loop_until_block");
    add_child($$, $2);
    add_child($$, $4);
}
| K_DO do_condition LCURLY statement_block RCURLY {
    $$ = create_node("loop_do_condition");
    add_child($$, $2);
    add_child($$, $4);
}
| K_DO do_condition statement_block {
    $$ = create_node("loop_do_condition_inline");
    add_child($$, $2);
    add_child($$, $3);
}
;

while : K_WHILE LPAREN expression RPAREN {
    $$ = create_node("while");
    Node *expr_node = create_node("expression");
    add_child(expr_node, $3);
    add_child($$, expr_node);
}
;

until : K_UNTIL LPAREN expression RPAREN {
    $$ = create_node("until");
    Node *expr_node = create_node("expression");
    add_child(expr_node, $3);
    add_child($$, expr_node);
}
;

do_condition : LPAREN assign_statement expression SEMI expression RPAREN {
    $$ = create_node("do_condition");
    add_child($$, $2);
    Node *expr1_node = create_node("expression");
    add_child(expr1_node, $3);
    add_child($$, expr1_node);
    Node *expr2_node = create_node("expression");
    add_child(expr2_node, $5);
    add_child($$, expr2_node);
}
;

conditional_statement : K_IF condition K_THEN LCURLY statement_block return_statement RCURLY else {
    $$ = create_node("conditional_if_then_else");
    add_child($$, $2);
    add_child($$, $5);
    add_child($$, $6);
    add_child($$, $8);
}
| K_IF condition K_THEN statement_block return_statement else {
    $$ = create_node("conditional_if_then_else_inline");
    add_child($$, $2);
    add_child($$, $4);
    add_child($$, $5);
    add_child($$, $6);
}
;

else : K_ELSE LCURLY statement_block return_statement RCURLY {
    $$ = create_node("else_statement_block");
    add_child($$, $3);
    add_child($$, $4);
}
| K_ELSE statement_block return_statement {
    $$ = create_node("else_statement_block_inline");
    add_child($$, $2);
    add_child($$, $3);
}
|{
    $$ = create_node("empty_else");
}
;

condition : LPAREN expression RPAREN {
    $$ = create_node("condition");
    Node *expr_node = create_node("expression");
    add_child(expr_node, $2);
    add_child($$, expr_node);
}
;

procedure_call : IDENTIFIER LPAREN arguments RPAREN {
    $$ = create_node("procedure_call");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($1));
    add_child($$, id_node);
    add_child($$, $3);
}
;

arguments : argument_list {
    $$ = create_node("arguments");
    add_child($$, $1);
}
|{
    $$ = create_node("empty_arguments");
}
;

argument_list : IDENTIFIER COMMA argument_list {
    $$ = create_node("argument_list");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($1));
    add_child($$, id_node);
    add_child($$, $3);
}
| constant COMMA argument_list {
    $$ = create_node("argument_list_constant");
    Node *const_node = create_node("constant");
    char buffer[20];
    sprintf(buffer, "%p", $1);
    add_child(const_node, create_node(buffer));
    // add_child(const_node, create_node($1));
    add_child($$, const_node);
    add_child($$, $3); 
}
| IDENTIFIER {
    $$ = create_node("single_argument");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($1));
    add_child($$, id_node);
}
| constant {
    $$ = create_node("single_argument_constant");
    Node *const_node = create_node("constant");
    char buffer[20];
    sprintf(buffer, "%p", $1);
    add_child(const_node, create_node(buffer));
    // add_child(const_node, create_node($1));
    add_child($$, const_node);
}
;


constant : ICONSTANT {
    $$ = create_node("ICONSTANT");
    char buffer[20];
    sprintf(buffer, "%d", $1);
    add_child($$, create_node(buffer));
}
| DCONSTANT {
    $$ = create_node("DCONSTANT");
    char buffer[20];
    sprintf(buffer, "%f", $1);
    add_child($$, create_node(buffer));
}
| SCONSTANT {
    $$ = create_node("SCONSTANT");
    add_child($$, create_node($1));
}
;

return_statement
: K_RETURN expression SEMI {
    $$ = create_node("return_expression");
    Node *expr_node = create_node("expression");
    add_child(expr_node, $2);
    add_child($$, expr_node);
}
| K_RETURN procedure_call SEMI {
    $$ = create_node("return_procedure_call");
    Node *proc_call_node = create_node("procedure_call");
    add_child(proc_call_node, $2);
    add_child($$, proc_call_node);
}
| K_RETURN assign_statement {
    $$ = create_node("return_assign");
    add_child($$, $2);
}
| {
    $$ = create_node("return_void");
}
;


expression : simple_expression {
    $$ = create_node("expression_simple");
    add_child($$, $1);
}
| logical_expression {
    $$ = create_node("expression_logical");
    add_child($$, $1);
}
| procedure_call {
    $$ = create_node("expression_procedure_call");
    add_child($$, $1);
}
| expression DAND logical_expression {
    $$ = create_node("expression_and");
    add_child($$, $1);
    add_child($$, $3);
}
| expression DOR logical_expression {
    $$ = create_node("expression_or");
    add_child($$, $1);
    add_child($$, $3);
}
;

term : factor {
    $$ = create_node("term");
    add_child($$, $1);
}
;

simple_expression : term {
    $$ = create_node("simple_expression");
    add_child($$, $1);
}
| simple_expression MOD term {
    $$ = create_node("simple_expression_mod");
    add_child($$, $1);
    add_child($$, $3);
}
| simple_expression DIVIDE term {
    $$ = create_node("simple_expression_divide");
    add_child($$, $1);
    add_child($$, $3);
}
| simple_expression PLUS term {
    $$ = create_node("simple_expression_plus");
    add_child($$, $1);
    add_child($$, $3);
}
| simple_expression MINUS term {
    $$ = create_node("simple_expression_minus");
    add_child($$, $1);
    add_child($$, $3);
}
| simple_expression MULTIPLY term {
    $$ = create_node("simple_expression_times");
    add_child($$, $1);
    add_child($$, $3);
}
| MINUS expression {
    $$ = create_node("simple_expression_negate");
    add_child($$, $2);
}
| factor INCREMENT {
    $$ = create_node("simple_expression_increment");
    add_child($$, $1);
}
| factor DECREMENT {
    $$ = create_node("simple_expression_decrement");
    add_child($$, $1);
}
;

logical_expression : expression GEQ expression {
    $$ = create_node("logical_expression_geq");
    add_child($$, $1);
    add_child($$, $3);
}
| expression LEQ expression {
    $$ = create_node("logical_expression_leq");
    add_child($$, $1);
    add_child($$, $3);
}
| expression GT expression {
    $$ = create_node("logical_expression_gt");
    add_child($$, $1);
    add_child($$, $3);
}
| expression LT expression {
    $$ = create_node("logical_expression_lt");
    add_child($$, $1);
    add_child($$, $3);
}
| expression DEQ expression {
    $$ = create_node("logical_expression_deq");
    add_child($$, $1);
    add_child($$, $3);
}
| expression NE expression {
    $$ = create_node("logical_expression_ne");
    add_child($$, $1);
    add_child($$, $3);
}
;


factor : IDENTIFIER {
    $$ = create_node("factor_identifier");
    add_child($$, create_node($1));
}
| IDENTIFIER LBRACKET expression RBRACKET {
    $$ = create_node("factor_array");
    add_child($$, create_node($1));
    add_child($$, $3);
}
| ICONSTANT {
    $$ = create_node("factor_iconstant");
    char buffer[20];
    sprintf(buffer, "%d", $1);
    add_child($$, create_node(buffer));
}
| DCONSTANT {
    $$ = create_node("factor_dconstant");
    char buffer[20];
    sprintf(buffer, "%f", $1);
    add_child($$, create_node(buffer));
}
| SCONSTANT {
    $$ = create_node("factor_sconstant");
    add_child($$, create_node($1));
}
| LPAREN expression RPAREN {
    $$ = create_node("factor_parentheses");
    add_child($$, $2);
}
;

%% 

void gen(Node *node, int level, FILE *file) {
    if (node == NULL) return;
    
    if (strcmp(node->type, "declare") == 0) {
        fprintf(file, "\tSR -= 1;\n");
    }
    else if (strcmp(node->type, "assign") == 0) {
        Node *lhs_node = node->children[0];
        Node *rhs_node = node->children[1];
        
        if (strcmp(rhs_node->type, "ICONSTANT") == 0) {
            fprintf(file, "\tR[1] = %s;\n", rhs_node->children[0]->type); 
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
        }
        else if (strcmp(rhs_node->type, "IDENTIFIER") == 0) {
            fprintf(file, "\tR[1] = Mem[SR];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
        }
    }
    else if (strcmp(node->type, "print_integer") == 0) {
        fprintf(file, "\tprint_int(Mem[SR]);\n");
        fprintf(file, "\tF24_Time += (100+20);\n");
    }
    else if (strcmp(node->type, "print_string") == 0) {
        Node *string_node = node->children[0];
        fprintf(file, "\tstrcpy(SMem, %s);\n", string_node->children[0]->type);
        fprintf(file, "\tF24_Time += (20+1);\n");
        fprintf(file, "\tprint_string(SMem);\n");
        fprintf(file, "\tF24_Time += (100+20);\n");
    }
    //////////////////////////////////////////////////////////////////////////////////
    
    /* R[1] = 1;
    F24_Time += 1;
    R[2] = 1;
    F24_Time += 1;
    R[1] = R[1] + R[2];
    F24_Time += (1+1+1); */
 
    else if (strcmp(node->type, "expression_simple") == 0){
        Node *child = node->children[0];
        Node *lhs_node = child->children[0]->children[0]->children[0]->children[0]; 
        Node *rhs_node = child->children[1]->children[0]->children[0];
        /* printf("%s", child->children[1]->children[0]->children[0]->type); */
        
        if (strcmp(child->type, "simple_expression_plus") == 0){
            fprintf(file, "\tR[1] = %s;\n", lhs_node->type);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[2] = %s;\n", find_symbol(rhs_node->type)->value);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[1] = R[1] + R[2];\n");
            fprintf(file, "\tF24_Time += (1+1+1);\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
 
        }
        else if (strcmp(child->type, "simple_expression_minus") == 0){
            fprintf(file, "\tR[1] = %s;\n", find_symbol(lhs_node->type)->value);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[2] = %s;\n", rhs_node->type);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[1] = R[1] - R[2];\n");
            fprintf(file, "\tF24_Time += (1+1+1);\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
        }
        else if (strcmp(child->type, "simple_expression_negate") == 0){
            fprintf(file, "\tR[1] = %s;\n", child->children[0]->type);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[1] = -R[1];\n");
            fprintf(file, "\tF24_Time += (1+1+1);\n");
        }
        else if (strcmp(child->type, "simple_expression_times") == 0){
            fprintf(file, "\tR[1] = %s;\n", find_symbol(lhs_node->type)->value);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[2] = %s;\n", rhs_node->type);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[1] = R[1] * R[2];\n");
            fprintf(file, "\tF24_Time += (1+1+1);\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
        }
        else if (strcmp(child->type, "simple_expression_divide") == 0){
            fprintf(file, "\tR[1] = %s;\n", find_symbol(lhs_node->type)->value);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[2] = %s;\n", rhs_node->type);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[1] = R[1] / R[2];\n");
            fprintf(file, "\tF24_Time += (1+1+1);\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
        }
        else if (strcmp(child->type, "simple_expression_mod") == 0){
            fprintf(file, "\tR[1] = %s;\n", find_symbol(lhs_node->type)->value);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[2] = %s;\n", rhs_node->type);
            fprintf(file, "\tF24_Time += 1;\n");
            fprintf(file, "\tR[1] = R[1] %% R[2];\n");
            fprintf(file, "\tF24_Time += (1+1+1);\n");
            fprintf(file, "\tMem[SR] = R[1];\n");
            fprintf(file, "\tF24_Time += (20+1);\n");
        }
    }
    ////////////////////////////////////////////////////////////////////////////////
    if (strcmp(node->type, "expression_logical") == 0){
        
    }
    else if (strcmp(node->type, "logical_expression_lt") == 0){
        
    }
    else if (strcmp(node->type, "logical_expression_deq") == 0){
        
    }
    else if (strcmp(node->type, "logical_expression_neq") == 0){
        
    }
//////////////////////////////////////////////////////////////////////////////////////////
    for (int i = 0; i < node->child_count; i++) {
        gen(node->children[i], level + 1, file);
    }
}

void generate_code(Node *node, FILE *file) {
    gen(node, 0, file);
}

int main(void) {
    printf("Parsing started...\n");
	if (yyparse() == 0) {
		printf("Parsing completed successfully.\n");
		printf("++++++++++++++++++++++++++++++++++++++++++++++++\n");
		printf("+ Walking through the Parse Tree Begins Here  +\n");
		printf("++++++++++++++++++++++++++++++++++++++++++++++++\n");
		walk_tree(parse_tree);
	} 
    else {
		printf("Parsing failed.\n");
	}

    FILE *file = fopen("yourmain.h", "w");
    fprintf(file, "int yourmain()\n{\n");
    generate_code(parse_tree, file);
    fprintf(file, "\treturn 0;");
    fprintf(file, "\n}");
    fclose(file);

    printf("\n");
    print_symbol_table();
    free_symbol_table();

    return 0;
}
