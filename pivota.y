%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *out;

// Symbol table
#define MAX_VARS 100
char* var_names[MAX_VARS];
int var_values[MAX_VARS];
int var_count = 0;

// Block tracking
int inside_if = 0;
int inside_loop = 0;

void yyerror(const char *s) { fprintf(stderr, "error: %s\n", s); }
int yylex(void);

// symbol table helpers
void define_var(char* name, int value) {
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            var_values[i] = value;
            return;
        }
    }
    var_names[var_count] = strdup(name);
    var_values[var_count] = value;
    var_count++;
}

int get_var_value(char* name) {
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            return var_values[i];
        }
    }
    fprintf(stderr, "error: undefined variable '%s'\n", name);
    exit(1);
}
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
        define_var($2, $4);
        fprintf(out, "    integer %s = %d;\n", $2, $4);
    }
    ;


conditional:
    IF LPAREN condition RPAREN LBRACE
        { inside_if = 1; }
    statements RBRACE
        { inside_if = 0; fprintf(out, "    end\n"); }
    ;


loop:
    LOOP NUMBER TIMES LBRACE
        { inside_loop = 1; fprintf(out, "    repeat(%d) begin\n", $2); }
    statements RBRACE
        { inside_loop = 0; fprintf(out, "    end\n"); }
    ;

emit_stmt:
    EMIT BUY NUMBER SEMICOLON
    {
        fprintf(out, "%sorder = 1; qty = %d;\n", (inside_if || inside_loop) ? "        " : "    ", $3);
    }
    | EMIT SELL NUMBER SEMICOLON
    {
        fprintf(out, "%sorder = 2; qty = %d;\n", (inside_if || inside_loop) ? "        " : "    ", $3);
    }
    ;

condition:
    IDENTIFIER GT NUMBER
    {
        int val = get_var_value($1);
        fprintf(out, "    if (%d > %d) begin\n", val, $3);
        $$ = val > $3;
    }
    | IDENTIFIER LT NUMBER
    {
        int val = get_var_value($1);
        fprintf(out, "    if (%d < %d) begin\n", val, $3);
        $$ = val < $3;
    }
    | IDENTIFIER EQ NUMBER
    {
        int val = get_var_value($1);
        fprintf(out, "    if (%d == %d) begin\n", val, $3);
        $$ = val == $3;
    }
    ;


%%

int main() {
    return yyparse();
}
