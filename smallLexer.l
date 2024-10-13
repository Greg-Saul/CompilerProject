%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap yylineno


K_PROGRAM        program
K_FUNCTION       function
K_INTEGER        integer
K_PRINT_INTEGER  print_integer
K_PRINT_STRING   print_string
IDENTIFIER       [a-zA-Z_][a-zA-Z0-9_]*
ICONSTANT        [0-9]+
DCONSTANT        [0-9]+\.[0-9]+
SCONSTANT        \"([^\\\"]|\\.)*\"
COMMA            ,


%%
    
{K_PROGRAM}        { return K_PROGRAM; }
{K_FUNCTION}       { return K_FUNCTION; }
{K_INTEGER}        { return K_INTEGER; }
{K_PRINT_INTEGER}  { return K_PRINT_INTEGER; }
{K_PRINT_STRING}   { return K_PRINT_STRING; }
{IDENTIFIER}       { yylval.str = strdup(yytext); return IDENTIFIER; }
{ICONSTANT}        { yylval.int_val = atoi(yytext); return ICONSTANT; }
{DCONSTANT}        { yylval.double_val = atof(yytext); return DCONSTANT; }
{SCONSTANT}        { yylval.str = strdup(yytext); return SCONSTANT; }

":="               { return ASSIGN; }
"{"                { return LCURLY; }
"}"                { return RCURLY; }
"("                { return LPAREN; }
")"                { return RPAREN; }
";"                { return SEMI; }
","                { return COMMA; }

[ \t\r\n]+         ;  // Ignore whitespace

.                   { printf("Illegal character: %s\n", yytext); }

%%
