%{
    // C code: Headers and other declarations
    #include <stdio.h>
    #include <stdlib.h>
%}

%%

"do"                     { printf("K_DO\n"); }
"double"                 { printf("K_DOUBLE\n"); }
"else"                   { printf("K_ELSE\n"); }
"exit"                   { printf("K_EXIT\n"); }
"function"               { printf("K_FUNCTION\n"); }
"if"                     { printf("K_IF\n"); }
"integer"                { printf("K_INTEGER\n"); }
"print_double"           { printf("K_PRINT_DOUBLE\n"); }
"print_integer"          { printf("K_PRINT_INTEGER\n"); }
"print_string"           { printf("K_PRINT_STRING\n"); }
"procedure"              { printf("K_PROCEDURE\n"); }
"program"                { printf("K_PROGRAM\n"); }
"read_double"            { printf("K_READ_DOUBLE\n"); }
"read_integer"           { printf("K_READ_INTEGER\n"); }
"read_string"            { printf("K_READ_STRING\n"); }
"return"                 { printf("K_RETURN\n"); }
"string"                 { printf("K_STRING\n"); }
"then"                   { printf("K_THEN\n"); }
"until"                  { printf("K_UNTIL\n"); }
"while"                  { printf("K_WHILE\n"); }


[0-9]+                          { printf("ICONSTANT: %s\n", yytext); }
[a-zA-Z_$][a-zA-Z_$0-9]*        { printf("IDENTIFIER: %s\n", yytext); }   // Work on limiting to only first 32 characters
// String Constant
// Floating Point
[ \t\n]+                        ;

":="         { printf("ASSIGN\n"); }
"\\+="       { printf("ASSIGN_PLUS\n"); }
"-="         { printf("ASSIGN_MINUS\n"); }
"\\*="       { printf("ASSIGN_MULTIPLY\n"); }
"/="         { printf("ASSIGN_DIVIDE\n"); }
"%="         { printf("ASSIGN_MOD\n"); }
","          { printf("COMMA\n"); }
"//"         { printf("COMMENT\n"); }
"&&"         { printf("DAND\n"); }
"/"          { printf("DIVIDE\n"); }
"||"         { printf("DOR\n"); }
"=="         { printf("DEQ\n"); }
">="         { printf("GEQ\n"); }
">"          { printf("GT\n"); }
"\\["        { printf("LBRACKET\n"); }
"<="         { printf("LEQ\n"); }
"{"          { printf("LCURLY\n"); }
"("          { printf("LPAREN\n"); }
"<"          { printf("LT\n"); }
"-"          { printf("MINUS\n"); }
"--"         { printf("DECREMENT\n"); }
"%"          { printf("MOD\n"); }
"\\*"        { printf("MULTIPLY\n"); }
"!="         { printf("NE\n"); }
"!"          { printf("NOT\n"); }
"\\."        { printf("PERIOD\n"); }
"\\+"        { printf("PLUS\n"); }
"\\+\\+"     { printf("INCREMENT\n"); }
"\\]"        { printf("RBRACKET\n"); }
"}"          { printf("RCURLY\n"); }
")"          { printf("RPAREN\n"); }
";"          { printf("SEMI\n"); }

%%
// User Code Section: Define any additional C functions or helper code.

int main() {
    yylex();  // Call the lexer
    return 0;
}

int yywrap() {
    return 1; // Required for the lex library to signal end of input
}
