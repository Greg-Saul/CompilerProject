%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


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
    }printf("  ");
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

%type <node> start program function_block function statement_block statement parameters
%type <node> declare_statement assign_statement print_statement input_statement loop_statement
%type <node> conditional_statement procedure_call expression simple_expression term condition
%type <node> argument_list return_statement parameter procedure else while type parameter_list



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
    add_symbol($2, "program", "N/A");
    add_child($$, id_node);
    add_child($$, $4); // Function block
    add_child($$, $5); // Statement block
}
;

function_block : function function_block {
    $$ = create_node("function_block");
    add_child($$, $1);
    add_child($$, $2);
}
| procedure function_block {
    $$ = create_node("function_block");
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
    add_symbol($2, "procedure", "N/A");
    add_child($$, id_node);
    add_child($$, $4); // Parameters
    add_child($$, $7); // Statement block
}
;

function : K_FUNCTION type IDENTIFIER LPAREN parameters RPAREN LCURLY statement_block return_statement RCURLY {
    $$ = create_node("function");
    add_child($$, $2); // Type
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_symbol($3, $2->type, "function");
    add_child($$, id_node);
    add_child($$, $8); // Statement block
    add_child($$, $9); // Return statement
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
    Node *type_node = create_node("type");
    add_child(type_node, create_node($1->type));
    add_child($$, type_node);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));  // $2 is the identifier
    add_symbol($2, $1->type, "N/A");
    add_child($$, id_node);
}
| type IDENTIFIER LBRACKET RBRACKET {
    $$ = create_node("parameter_array");
    Node *type_node = create_node("type");
    add_child(type_node, create_node($1->type));
    add_child($$, type_node);
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));  // $2 is the identifier
    add_symbol($2, $1->type, "array");
    add_child($$, id_node);
}
;

type : K_INTEGER {
    $$ = create_node("K_INTEGER");
    add_child($$, create_node("integer"));
}
| K_DOUBLE {
    $$ = create_node("K_DOUBLE");
    add_child($$, create_node("double"));
}
| K_STRING {
    $$ = create_node("K_STRING");
    add_child($$, create_node("string"));
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

declare_statement : type IDENTIFIER SEMI {
    $$ = create_node("declare");
    add_child($$, $1); // Type
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($2));
    add_symbol($2, $1->type, "variable");
    add_child($$, id_node);
}
;

assign_statement : IDENTIFIER ASSIGN expression SEMI {
    $$ = create_node("assign");
    Node *lhs_node = create_node("IDENTIFIER");
    add_child(lhs_node, create_node($1));
    add_child($$, lhs_node);
    add_child($$, $3); // Expression
    update_symbol_value($1, $3->type);
}
;

print_statement : K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN SEMI {
    $$ = create_node("print_integer");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
;

input_statement : K_READ_INTEGER LPAREN IDENTIFIER RPAREN SEMI {
    $$ = create_node("read_integer");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($3));
    add_child($$, id_node);
}
;

loop_statement 
    : K_DO while statement {
        $$ = create_node("do_while");
        add_child($$, $2); // While condition
        add_child($$, $3); // Single statement or statement block
    }
    | K_DO while LCURLY statement_block RCURLY {
        $$ = create_node("do_while");
        add_child($$, $2); // While condition
        add_child($$, $4); // Statement block
    }
;

while
    : K_WHILE LPAREN expression RPAREN {
        $$ = create_node("while_condition");
        add_child($$, $3); // Expression inside the parentheses
    }
;

conditional_statement : K_IF condition K_THEN LCURLY statement_block RCURLY else {
    $$ = create_node("if");
    add_child($$, $2); // Condition
    add_child($$, $5); // Statement block
    add_child($$, $7); // Else block
}
;

else : K_ELSE LCURLY statement_block RCURLY {
    $$ = create_node("else");
    add_child($$, $3); // Statement block
}
;

condition : LPAREN expression RPAREN {
    $$ = $2;
}
;

return_statement : K_RETURN expression SEMI {
    $$ = create_node("return");
    add_child($$, $2); // Expression to return
}
;

expression : simple_expression {
    $$ = $1;
}
;

simple_expression : term {
    $$ = $1;
}
;

term : ICONSTANT {
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
| IDENTIFIER {
    $$ = create_node("IDENTIFIER");
    add_child($$, create_node($1));
}
;

procedure_call : IDENTIFIER LPAREN argument_list RPAREN SEMI {
    $$ = create_node("procedure_call");
    Node *id_node = create_node("IDENTIFIER");
    add_child(id_node, create_node($1));
    add_child($$, id_node);
    add_child($$, $3); // Argument list
}
;

argument_list : expression COMMA argument_list {
    $$ = create_node("argument_list");
    add_child($$, $1);
    add_child($$, $3);
}
| expression {
    $$ = create_node("argument_list");
    add_child($$, $1);
}
| {
    $$ = create_node("empty");
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

    printf("\n\n++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("+             Symbol Table Elements            +\n");
    printf("++++++++++++++++++++++++++++++++++++++++++++++++\n");
    print_symbol_table();
    free_symbol_table();

    return 0;
}
