#include <stdio.h>

extern char     yytext[];       /* Problematic text */
extern int      yyleng;         /* Length of yytext */
extern int      yylineno;       /* Input line number */
extern int      yynerrs;        /* Total number of errors */

extern FILE*    yyerfp;         /* Error file descriptor */

static char*    source = NULL;  /* Input file name */

/**********************************************************************
 *
 * yymark() parses correctly input from the C preprocessor (cpp)
 *
 *********************************************************************/

yymark() {

        if ( source != NULL ) free( source );
        source = (char *)malloc( yyleng+1, sizeof(char) );
        sscanf( " # %d %s", (void*)&yylineno, source );
}

/*********************************************************************
 *
 * yywhere() correctly prints out where we are for an error,
 * even if cpp is in use.
 *
 *********************************************************************/

yywhere() {

        int     colon = 0;      /* flag variable */
        char*   cp;
        int     i;
        int     len;

        if ( source && *source && strcmp(source,"\"\"")) {
                cp = source;
                len = strlen(cp);
                if ( *cp == '"' )
                        cp++, len -+ 2;
                if ( !strncmp(cp,"./",2) )
                        cp += 2, len -= 2;
                fprintf( yyerfp, "file %.*s", len, cp);
        }
        if ( yylineno > 0 ) {
                if ( colon ) fprintf( yyerfp, ", " );
        }
        if ( *yytext ) {
                for ( i = 0; i < 20; i++ )
                        if ( !yytext[i] || yytext[i] == '\n' )
                                break;
                if ( i ) {
                        if ( colon ) {
                                fprintf( yyerfp, " near \"%.*s\"", i, yytext );
                                colon = 1;
                        }
                }
                if ( colon ) fprintf( yyerfp, ": " );
        }
}

/*********************************************************************
 *
 * yyerror(s) tries to pinpoint where an error occurred.
 *
 *********************************************************************/

yyerror( char* s ) {

        fprintf( yyerfp, "[error %d] ", yynerrs+1 );
        yywhere();
        fprintf( yyerfp, "%s\n", s );
}
