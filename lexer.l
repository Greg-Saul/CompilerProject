%{
    // C code: Headers and other declarations
    #include <stdio.h>
    #include <stdlib.h>
%}

%%


[0-9]+                          { printf("ICONSTANT: %s\n", yytext); }
[a-zA-Z_$][a-zA-Z_$0-9]+        { printf("IDENTIFIER: %s\n", yytext); }
"="                             { printf("ASSIGNMENT: %s\n", yytext); }
"+"                             { printf("PLUS: %s\n", yytext); }
"*"                             { printf("MULTIPLICATION: %s\n", yytext); }
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
