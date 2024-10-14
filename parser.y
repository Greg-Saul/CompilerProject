%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Define a simple parse tree node structure with unique ID
typedef struct Node {
    int node_id;             // Unique identification number
    char *type;
    struct Node **children;
    int child_count;
} Node;

// Function prototypes
void yyerror(const char *s);
int yylex(void);

// Functions to create and manage parse tree nodes
int current_node_id = 1; // Global counter for node IDs

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
    if(node == NULL) return;
    for(int i = 0; i < level; i++) printf("  ");
    printf("** Node %d: %s\n", node->node_id, node->type);
    for(int i = 0; i < node->child_count; i++) {
        print_tree(node->children[i], level + 1);
    }
}

void walk_tree(Node *node) {
    
    print_tree(node, 0);
}

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

start : program
      ;

program : K_PROGRAM IDENTIFIER LCURLY function_block RCURLY
        {
            // Create program node
            $$ = create_node("program");

            // Add IDENTIFIER node
            Node *id_node = create_node("IDENTIFIER");
            add_child(id_node, create_node($2));
            add_child($$, id_node);

            // Add function_block node
            add_child($$, $4); // $4 is of type <node>

            // Print reduction information
            printf("** Node %d: Reduced: program -> K_PROGRAM IDENTIFIER LCURLY function_block RCURLY\n", $$->node_id);
            printf("**** program -> K_PROGRAM\n");
            printf("**** program -> IDENTIFIER %s\n", $2);
            printf("**** program -> LCURLY\n");
            printf("**** program -> function_block\n");
            printf("**** program -> RCURLY\n");
        }
        ;

function_block : function function_block
               {
                   // Create function_block node
                   $$ = create_node("function_block");
                   add_child($$, $1); // $1 is of type <node>
                   add_child($$, $2); // $2 is of type <node>

                   // Print reduction information
                   printf("** Node %d: Reduced: function_block -> function function_block\n", $$->node_id);
                   printf("**** function_block -> function (Node %d)\n", $1->node_id);
                   printf("**** function_block -> function_block (Node %d)\n", $2->node_id);
               }
               | /* empty */
               {
                   $$ = create_node("empty");

                   // Print reduction information
                   printf("** Node %d: Reduced: function_block -> empty\n", $$->node_id);
               }
               ;

function : K_FUNCTION K_INTEGER IDENTIFIER LPAREN RPAREN LCURLY statement_block RCURLY
         {
             // Create function node
             $$ = create_node("function");

             // Add return type node
             Node *return_type = create_node("K_INTEGER");
             add_child(return_type, create_node("integer"));
             add_child($$, return_type);

             // Add IDENTIFIER node
             Node *id_node = create_node("IDENTIFIER");
             add_child(id_node, create_node($3));
             add_child($$, id_node);

             // Add statement_block node
             add_child($$, $7); // $7 is of type <node>

             // Print reduction information
             printf("** Node %d: Reduced: function -> K_FUNCTION K_INTEGER IDENTIFIER LPAREN RPAREN LCURLY statement_block RCURLY\n", $$->node_id);
             printf("**** function -> K_FUNCTION\n");
             printf("**** function -> K_INTEGER\n");
             printf("**** function -> IDENTIFIER %s\n", $3);
             printf("**** function -> LPAREN\n");
             printf("**** function -> RPAREN\n");
             printf("**** function -> LCURLY\n");
             printf("**** function -> statement_block (Node %d)\n", $7->node_id);
             printf("**** function -> RCURLY\n");
         }
         ;

statement_block : statement statement_block
               {
                   // Create statement_block node
                   $$ = create_node("statement_block");
                   add_child($$, $1); // $1 is of type <node>
                   add_child($$, $2); // $2 is of type <node>

                   // Print reduction information
                   printf("** Node %d: Reduced: statement_block -> statement statement_block\n", $$->node_id);
                   printf("**** statement_block -> statement (Node %d)\n", $1->node_id);
                   printf("**** statement_block -> statement_block (Node %d)\n", $2->node_id);
               }
               | /* empty */
               {
                   $$ = create_node("empty");

                   // Print reduction information
                   printf("** Node %d: Reduced: statement_block -> empty\n", $$->node_id);
               }
               ;

statement : declare SEMI
          {
              $$ = $1; // $1 is of type <node>
              // Print reduction information
              printf("** Node %d: Reduced: statement -> declare SEMI\n", $$->node_id);
              printf("**** statement -> declare (Node %d)\n", $1->node_id);
              printf("**** statement -> SEMI\n");
          }
          | assign SEMI
          {
              $$ = $1; // $1 is of type <node>
              // Print reduction information
              printf("** Node %d: Reduced: statement -> assign SEMI\n", $$->node_id);
              printf("**** statement -> assign (Node %d)\n", $1->node_id);
              printf("**** statement -> SEMI\n");
          }
          | print_statement SEMI
          {
              $$ = $1; // $1 is of type <node>
              // Print reduction information
              printf("** Node %d: Reduced: statement -> print_statement SEMI\n", $$->node_id);
              printf("**** statement -> print_statement (Node %d)\n", $1->node_id);
              printf("**** statement -> SEMI\n");
          }
          ;

declare : K_INTEGER IDENTIFIER
        {
            // Create declare node
            $$ = create_node("declare");

            // Add type node
            Node *type_node = create_node("K_INTEGER");
            add_child(type_node, create_node("integer"));
            add_child($$, type_node);

            // Add IDENTIFIER node
            Node *id_node = create_node("IDENTIFIER");
            add_child(id_node, create_node($2));
            add_child($$, id_node);

            // Print reduction information
            printf("** Node %d: Reduced: declare -> K_INTEGER IDENTIFIER\n", $$->node_id);
            printf("**** declare -> K_INTEGER\n");
            printf("**** declare -> IDENTIFIER %s\n", $2);
        }
        ;

print_statement : K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN
                {
                    // Create print_integer node
                    $$ = create_node("print_integer");

                    // Add IDENTIFIER node
                    Node *id_node = create_node("IDENTIFIER");
                    add_child(id_node, create_node($3));
                    add_child($$, id_node);

                    // Print reduction information
                    printf("** Node %d: Reduced: print_statement -> K_PRINT_INTEGER LPAREN IDENTIFIER RPAREN\n", $$->node_id);
                    printf("**** print_integer -> K_PRINT_INTEGER\n");
                    printf("**** print_integer -> LPAREN\n");
                    printf("**** print_integer -> IDENTIFIER %s\n", $3);
                    printf("**** print_integer -> RPAREN\n");
                }
                | K_PRINT_STRING LPAREN SCONSTANT RPAREN
                {
                    // Create print_string node
                    $$ = create_node("print_string");

                    // Add SCONSTANT node
                    Node *str_node = create_node("SCONSTANT");
                    add_child(str_node, create_node($3));
                    add_child($$, str_node);

                    // Print reduction information
                    printf("** Node %d: Reduced: print_statement -> K_PRINT_STRING LPAREN SCONSTANT RPAREN\n", $$->node_id);
                    printf("**** print_string -> K_PRINT_STRING\n");
                    printf("**** print_string -> LPAREN\n");
                    printf("**** print_string -> SCONSTANT %s\n", $3);
                    printf("**** print_string -> RPAREN\n");
                }
                ;

assign : IDENTIFIER ASSIGN ICONSTANT
       {
           // Create assign node
           $$ = create_node("assign");

           // Add IDENTIFIER node (left-hand side)
           Node *lhs_node = create_node("IDENTIFIER");
           add_child(lhs_node, create_node($1));
           add_child($$, lhs_node);

           // Add ICONSTANT node (right-hand side)
           Node *val_node = create_node("ICONSTANT");
           char buffer[20];
           sprintf(buffer, "%d", $3);
           add_child(val_node, create_node(buffer));
           add_child($$, val_node);

           // Print reduction information
           printf("** Node %d: Reduced: assign -> IDENTIFIER ASSIGN ICONSTANT\n", $$->node_id);
           printf("**** assign -> IDENTIFIER %s\n", $1);
           printf("**** assign -> ASSIGN\n");
           printf("**** assign -> ICONSTANT %d\n", $3);
       }
       | IDENTIFIER ASSIGN DCONSTANT
       {
           // Create assign node
           $$ = create_node("assign");

           // Add IDENTIFIER node (left-hand side)
           Node *lhs_node = create_node("IDENTIFIER");
           add_child(lhs_node, create_node($1));
           add_child($$, lhs_node);

           // Add DCONSTANT node (right-hand side)
           Node *val_node = create_node("DCONSTANT");
           char buffer[20];
           sprintf(buffer, "%f", $3);
           add_child(val_node, create_node(buffer));
           add_child($$, val_node);

           // Print reduction information
           printf("** Node %d: Reduced: assign -> IDENTIFIER ASSIGN DCONSTANT\n", $$->node_id);
           printf("**** assign -> IDENTIFIER %s\n", $1);
           printf("**** assign -> ASSIGN\n");
           printf("**** assign -> DCONSTANT %f\n", $3);
       }
       | IDENTIFIER ASSIGN IDENTIFIER
       {
           // Create assign node
           $$ = create_node("assign");

           // Add IDENTIFIER node (left-hand side)
           Node *lhs_node = create_node("IDENTIFIER");
           add_child(lhs_node, create_node($1));
           add_child($$, lhs_node);

           // Add IDENTIFIER node (right-hand side)
           Node *rhs_node = create_node("IDENTIFIER");
           add_child(rhs_node, create_node($3));
           add_child($$, rhs_node);

           // Print reduction information
           printf("** Node %d: Reduced: assign -> IDENTIFIER ASSIGN IDENTIFIER\n", $$->node_id);
           printf("**** assign -> IDENTIFIER %s\n", $1);
           printf("**** assign -> ASSIGN\n");
           printf("**** assign -> IDENTIFIER %s\n", $3);
       }
       ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

// Main function
int main(void) {
    printf("Parsing started...\n");
    printf("++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("+ Walking through the Parse Tree Begins Here  +\n");
    printf("++++++++++++++++++++++++++++++++++++++++++++++++\n");
    Node *parse_tree = NULL;
    if (yyparse() == 0) {
        walk_tree(parse_tree);
        printf("Parsing completed successfully.\n");
        // After parsing, walk the parse tree
    } else {
        printf("Parsing failed.\n");
    }
    return 0;
}
