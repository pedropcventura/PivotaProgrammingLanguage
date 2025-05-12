%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

%union {
    int num;
    char* str;
}

%token <str> STRATEGY START_DATE END_DATE ASSET VAR IF THEN ENDIF FOR IN BUY SELL RSI
%token <str> IDENTIFIER STRING
%token <num> NUMBER
%token EQEQ LT GT ASSIGN LPAREN RPAREN COMMA LBRACKET RBRACKET LBRACE RBRACE

%start program
%define parse.error verbose

%%
program:
      /* empty */
    | program statement
    ;

statement:
      STRATEGY STRING
    | START_DATE STRING
    | END_DATE STRING
    | ASSET STRING
    | VAR IDENTIFIER ASSIGN simple_expression
    | VAR IDENTIFIER ASSIGN NUMBER                    
    | IF simple_expression THEN action ENDIF
    | FOR IDENTIFIER IN value_list LBRACE for_block RBRACE
    ;

for_block:
      /* empty */
    | for_block if_statement
    ;

if_statement:
    IF simple_expression THEN action ENDIF
    ;

value_list:
    LBRACKET STRING value_list_tail RBRACKET
    ;

value_list_tail:
      /* empty */
    | COMMA STRING value_list_tail
    ;

simple_expression:
      function_call comparison_operator NUMBER
    | function_call comparison_operator IDENTIFIER        
    | IDENTIFIER comparison_operator NUMBER
    | IDENTIFIER comparison_operator IDENTIFIER          
    ;

function_call:
    RSI LPAREN IDENTIFIER COMMA NUMBER RPAREN
    ;

comparison_operator:
      LT
    | GT
    | EQEQ
    ;

action:
      BUY IDENTIFIER
    | SELL IDENTIFIER
    ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int main(void) {
    if (yyparse() == 0)
        printf("Program parsed successfully!\n");
    return 0;
}
