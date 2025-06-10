%{
#include "pivota.tab.h"
#include <string.h>
#include <stdio.h>
%}

%%

"LET"           { printf("TOKEN: LET\n"); return LET; }
"IF"            { printf("TOKEN: IF\n"); return IF; }
"LOOP"          { printf("TOKEN: LOOP\n"); return LOOP; }
"TIMES"         { printf("TOKEN: TIMES\n"); return TIMES; }
"EMIT"          { printf("TOKEN: EMIT\n"); return EMIT; }
"BUY"           { printf("TOKEN: BUY\n"); yylval.str = strdup(yytext); return BUY; }
"SELL"          { printf("TOKEN: SELL\n"); yylval.str = strdup(yytext); return SELL; }

">"             { printf("TOKEN: GT\n"); return GT; }
"<"             { printf("TOKEN: LT\n"); return LT; }
"=="            { printf("TOKEN: EQ\n"); return EQ; }
"+"             { printf("TOKEN: PLUS\n"); return PLUS; }
"-"             { printf("TOKEN: MINUS\n"); return MINUS; }
"*"             { printf("TOKEN: TIMES_OP\n"); return TIMES_OP; }
"/"             { printf("TOKEN: DIVIDE\n"); return DIVIDE; }

[0-9]+          { printf("TOKEN: NUMBER(%s)\n", yytext); yylval.num = atoi(yytext); return NUMBER; }

[a-zA-Z_][a-zA-Z0-9_]* {
                    printf("TOKEN: IDENTIFIER(%s)\n", yytext);
                    yylval.str = strdup(yytext);
                    return IDENTIFIER;
                }

"="             { printf("TOKEN: ASSIGN\n"); return ASSIGN; }
";"             { printf("TOKEN: SEMICOLON\n"); return SEMICOLON; }
"{"             { printf("TOKEN: LBRACE\n"); return LBRACE; }
"}"             { printf("TOKEN: RBRACE\n"); return RBRACE; }
"("             { printf("TOKEN: LPAREN\n"); return LPAREN; }
")"             { printf("TOKEN: RPAREN\n"); return RPAREN; }

[ \t\r\n]+      { /* ignora espaços e quebras de linha */ }

.               { printf("Unknown character: %s\n", yytext); return UNKNOWN; }

%%
