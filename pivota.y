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

// Buffer para armazenar código antes do initial
char *code_lines[1000];
int code_line_count = 0;

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
%token PLUS MINUS TIMES_OP DIVIDE
%token UNKNOWN

%type <num> condition expr

%%

program:
    {
        out = fopen("output.v", "w");
        fprintf(out, "module pivota_strategy(output reg [3:0] dummy);\n");
        fprintf(out, "reg [3:0] order_list [0:255];\n");
        fprintf(out, "reg [3:0] qty_list [0:255];\n");
        fprintf(out, "integer i;\n");
    }
    statements
    {
        fprintf(out, "reg [31:0] ");
        for (int i = 0; i < var_count; ++i) {
            if (i > 0) fprintf(out, ", ");
            fprintf(out, "%s", var_names[i]);
        }
        fprintf(out, ";\ninitial begin\n");
        fprintf(out, "    i = 0;\n");

        // replay variable assignments
        for (int i = 0; i < var_count; ++i) {
            fprintf(out, "    %s = %d;\n", var_names[i], var_values[i]);
        }

        // emitir todas as linhas geradas
        for (int i = 0; i < code_line_count; ++i) {
            fprintf(out, "%s\n", code_lines[i]);
            free(code_lines[i]);
        }

        fprintf(out, "end\nendmodule\n");
        fclose(out);

        // === gerar testbench.sv ===
        FILE *test = fopen("testbench.sv", "w");
        fprintf(test,
        "module test;\n"
        "    wire [3:0] dummy;\n"
        "    pivota_strategy uut (.dummy(dummy));\n\n"
        "    initial begin\n"
        "        #1;\n"
        "        for (int j = 0; j < uut.i; j = j + 1) begin\n"
        "            $display(\"Order: %%d Qty: %%d\", uut.order_list[j], uut.qty_list[j]);\n"
        "        end\n"
        "        $finish;\n"
        "    end\n"
        "endmodule\n");
        fclose(test);
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
    LET IDENTIFIER ASSIGN expr SEMICOLON
    {
        define_var($2, $4);
    }
    ;

conditional:
    IF LPAREN condition RPAREN LBRACE
        { inside_if = 1; }
    statements RBRACE
        { inside_if = 0; code_lines[code_line_count++] = strdup("    end"); }
    ;

loop:
    LOOP expr TIMES LBRACE
        {
            inside_loop = 1;
            char buf[128];
            sprintf(buf, "    repeat(%d) begin", $2);
            code_lines[code_line_count++] = strdup(buf);
        }
    statements RBRACE
        { inside_loop = 0; code_lines[code_line_count++] = strdup("    end"); }
    ;

emit_stmt:
    EMIT BUY expr SEMICOLON
    {
        char buf[128];
        sprintf(buf, "%sorder_list[i] = 1; qty_list[i] = %d; i = i + 1;", (inside_if || inside_loop) ? "        " : "    ", $3);
        code_lines[code_line_count++] = strdup(buf);
    }
    | EMIT SELL expr SEMICOLON
    {
        char buf[128];
        sprintf(buf, "%sorder_list[i] = 2; qty_list[i] = %d; i = i + 1;", (inside_if || inside_loop) ? "        " : "    ", $3);
        code_lines[code_line_count++] = strdup(buf);
    }
    ;


condition:
      IDENTIFIER GT expr {
        int val = get_var_value($1);
        char buf[128];
        sprintf(buf, "    if (%d > %d) begin", val, $3);
        code_lines[code_line_count++] = strdup(buf);
        $$ = val > $3;
      }
    | IDENTIFIER LT expr {
        int val = get_var_value($1);
        char buf[128];
        sprintf(buf, "    if (%d < %d) begin", val, $3);
        code_lines[code_line_count++] = strdup(buf);
        $$ = val < $3;
      }
    | IDENTIFIER EQ expr {
        int val = get_var_value($1);
        char buf[128];
        sprintf(buf, "    if (%d == %d) begin", val, $3);
        code_lines[code_line_count++] = strdup(buf);
        $$ = val == $3;
      }
    ;

expr:
      NUMBER           { $$ = $1; }
    | IDENTIFIER       { $$ = get_var_value($1); }
    | expr PLUS expr   { $$ = $1 + $3; }
    | expr MINUS expr  { $$ = $1 - $3; }
    | expr TIMES_OP expr { $$ = $1 * $3; }
    | expr DIVIDE expr { $$ = $3 == 0 ? 0 : $1 / $3; }
    ;

%%

int main() {
    return yyparse();
}
