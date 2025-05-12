%{
#include "parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
%}

%option noyywrap
%option nounput
%option noinput

%%
"STRATEGY"    { return STRATEGY; }
"START_DATE"  { return START_DATE; }
"END_DATE"    { return END_DATE; }
"ASSET"       { return ASSET; }
"VAR"         { return VAR; }
"IF"          { return IF; }
"THEN"        { return THEN; }
"ENDIF"       { return ENDIF; }
"FOR"         { return FOR; }
"IN"          { return IN; }
"BUY"         { return BUY; }
"SELL"        { return SELL; }
"RSI"         { return RSI; }

"=="          { return EQEQ; }
"<"           { return LT; }
">"           { return GT; }
"="           { return ASSIGN; }
"("           { return LPAREN; }
")"           { return RPAREN; }
","           { return COMMA; }
"["           { return LBRACKET; }
"]"           { return RBRACKET; }
"{"           { return LBRACE; }
"}"           { return RBRACE; }

\"([^\"\n]*)\" {
    yylval.str = strdup(yytext);
    return STRING;
}

[0-9]+ {
    yylval.num = atoi(yytext);
    return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

[ \t\r\n]+   { /* skip whitespace */ }

. { printf("Unexpected character: %s\n", yytext); return -1; }

%%
