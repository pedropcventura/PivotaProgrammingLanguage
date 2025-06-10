# Pivota Programming Language (PPL)

Pivota é uma linguagem de programação minimalista criada como parte de um projeto acadêmico de lógica da computação. Ela foi projetada com o objetivo de **traduzir estratégias simples de negociação para hardware**, gerando automaticamente código Verilog a partir de instruções de alto nível.

Inspirada pelo universo de **high-frequency trading (HFT)** e pela ideia de trazer **decisões de mercado para o domínio físico (circuitos digitais)**, PPL permite descrever lógica de execução de ordens como `BUY` ou `SELL` de forma imperativa e legível.

O compilador da linguagem PPL lê arquivos `.pv` com instruções da linguagem e gera um módulo Verilog (`output.v`) que representa esse comportamento. A linguagem inclui:

- Declaração de variáveis (`LET`)
- Condicionais (`IF`)
- Laços (`LOOP N TIMES`)
- Emissão de ordens (`EMIT BUY 10`)

O objetivo de longo prazo seria transformar PPL em uma **linguagem DSL real para estratégias financeiras em hardware reconfigurável**.

## Requisitos

- **Flex**
- **Bison**
- **GCC ou Clang**
<br>
<br>

Instale no macOS:

```bash
brew install flex bison
```

Instale no Ubuntu:
```bash
sudo apt install flex bison gcc
```

## Como Compilar:
```bash
bison -d pivota.y
flex pivota.l
g++ -o compiler lex.yy.c pivota.tab.c -ll
```

## Como usar:
```bash
./compiler < example.pv
```

## Exemplo
1. Escreva um código seguindo a EBNF do repositório:
```
LET x = 100;
IF (x > 50) {
    EMIT BUY 10;
}
LOOP 2 TIMES {
    EMIT SELL 1;
}

```
2. Compile e execute e veja o verilog gerado em output.v
```
module pivota_strategy(output reg [3:0] order, output reg [3:0] qty);
initial begin
    integer x = 100;
    if (100 > 50) begin
        order = 1; qty = 10;
    end
    repeat(2) begin
        order = 2; qty = 1;
    end
end
endmodule
```

---
<br>
<br>

- Observação: O Makefile foi feito para macOS
    - "make" compila
    - "make run" executa
    - "make clean" apaga os arquivos gerados