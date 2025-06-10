%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *out;

void yyerror(const char *s) { fprintf(stderr, "error: %s\n", s); }
int yylex(void);
%}

%union {
    int num;
    char* str;
}

%token <str> IDENTIFIER BUY SELL
%token <num> NUMBER
%token LET IF LOOP TIMES EMIT
%token GT LT EQ
%token ASSIGN SEMICOLON LBRACE RBRACE LPAREN RPAREN
%token UNKNOWN

%type <num> condition

%%

program:
    { out = fopen("output.v", "w");
      fprintf(out, "module pivota_strategy(output reg [3:0] order, output reg [3:0] qty);\n");
      fprintf(out, "initial begin\n");
    }
    statements
    {
      fprintf(out, "end\nendmodule\n");
      fclose(out);
    }
    ;

statements:
    statements statement
    | statement
    ;

statement:
    var_decl
    | conditional
    | loop
    | emit_stmt
    ;

var_decl:
    LET IDENTIFIER ASSIGN NUMBER SEMICOLON
    {
        fprintf(out, "    integer %s = %d;\n", $2, $4);
    }
    ;

conditional:
    IF LPAREN condition RPAREN LBRACE statements RBRACE
    {
        fprintf(out, "    // IF\n    if (/* condition */) begin\n    // ...\n    end\n");
    }
    ;

loop:
    LOOP NUMBER TIMES LBRACE statements RBRACE
    {
        fprintf(out, "    // LOOP\n    repeat(%d) begin\n    // ...\n    end\n", $2);
    }
    ;

emit_stmt:
    EMIT BUY NUMBER SEMICOLON
    {
        fprintf(out, "    order = 1; qty = %d;\n", $3);
    }
    | EMIT SELL NUMBER SEMICOLON
    {
        fprintf(out, "    order = 2; qty = %d;\n", $3);
    }
    ;

condition:
    IDENTIFIER GT NUMBER
    {
        fprintf(out, "    // condition: %s > %d\n", $1, $3); $$ = 1;
    }
    | IDENTIFIER LT NUMBER
    {
        fprintf(out, "    // condition: %s < %d\n", $1, $3); $$ = 1;
    }
    | IDENTIFIER EQ NUMBER
    {
        fprintf(out, "    // condition: %s == %d\n", $1, $3); $$ = 1;
    }
    ;

%%

int main() {
    return yyparse();
}
