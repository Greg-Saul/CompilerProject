%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap yylineno

K_DO             do
K_DOUBLE         double
K_ELSE           else
K_EXIT           exit
K_FUNCTION       function
K_IF             if
K_INTEGER        integer
K_PRINT_DOUBLE   print_double
K_PRINT_INTEGER  print_integer
K_PRINT_STRING   print_string
K_PROCEDURE      procedure
K_PROGRAM        program
K_READ_DOUBLE    read_double
K_READ_INTEGER   read_integer
K_READ_STRING    read_string
K_RETURN         return
K_STRING         string
K_THEN           then
K_UNTIL          until
K_WHILE          while



IDENTIFIER       [a-zA-Z_$][a-zA-Z_$0-9]* 
ICONSTANT        [0-9]+
DCONSTANT        -?[0-9]*"."[0-9]*[d|d+|d-]?[0-9]*
SCONSTANT        \"([^"\\\n]|\\.)*\" 
COMMA            ,

%%

{K_DO}                   { return K_DO; }
{K_DOUBLE}               { return K_DOUBLE; }
{K_ELSE}                 { return K_ELSE; }
{K_EXIT}                 { return K_EXIT; }
{K_FUNCTION}             { return K_FUNCTION; }
{K_IF}                   { return K_IF; }
{K_INTEGER}              { return K_INTEGER; }
{K_PRINT_DOUBLE}         { return K_PRINT_DOUBLE; }
{K_PRINT_INTEGER}        { return K_PRINT_INTEGER; }
{K_PRINT_STRING}         { return K_PRINT_STRING; }
{K_PROCEDURE}            { return K_PROCEDURE; }
{K_PROGRAM}              { return K_PROGRAM; }
{K_READ_DOUBLE}          { return K_READ_DOUBLE; }
{K_READ_INTEGER}         { return K_READ_INTEGER; }
{K_READ_STRING}          { return K_READ_STRING; }
{K_RETURN}               { return K_RETURN; }
{K_STRING}               { return K_STRING; }
{K_THEN}                 { return K_THEN; }
{K_UNTIL}                { return K_UNTIL; }
{K_WHILE}                { return K_WHILE; }


{IDENTIFIER}       { yylval.str = strdup(yytext); return IDENTIFIER; }
{ICONSTANT}        { yylval.int_val = atoi(yytext); return ICONSTANT; }
{DCONSTANT}        { yylval.double_val = atof(yytext); return DCONSTANT; }
{SCONSTANT}        { yylval.str = strdup(yytext); return SCONSTANT; }


":="         { return ASSIGN; }
"+="         { return ASSIGN_PLUS; }
"-="         { return ASSIGN_MINUS; }
"*="         { return ASSIGN_MULTIPLY; }
"/="         { return ASSIGN_DIVIDE; }
"%="         { return ASSIGN_MOD; }
","          { return COMMA; }
\/\/.*       ;
"&&"         { return DAND; }
"/"          { return DIVIDE; }
"||"         { return DOR; }
"=="         { return DEQ; }
">="         { return GEQ; }
">"          { return GT; }
"["          { return LBRACKET; }
"<="         { return LEQ; }
"{"          { return LCURLY; }
"("          { return LPAREN; }
"<"          { return LT; }
"-"          { return MINUS; }
"--"         { return DECREMENT; }
"%"          { return MOD; }
"*"          { return MULTIPLY; }
"!="         { return NE; }
"!"          { return NOT; }
"\."          { return PERIOD; }
"+"          { return PLUS; }
"++"         { return INCREMENT; }
"]"          { return RBRACKET; }
"}"          { return RCURLY; }
")"          { return RPAREN; }
";"          { return SEMI; }

[ \t\r\n]+   ;  // Ignore whitespace

.            { printf("Illegal character: %s\n", yytext); }

%%
