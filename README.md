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

1. Escreva um código em um arquivo `.pv` seguindo a EBNF da linguagem Pivota:

```pivota
LET price = 60 * 2;
LET volume = 5 + 10;
LET threshold = 100;
LET total = price * volume;

IF (total > threshold) {
    EMIT BUY volume;
}

LET correction = total - 80;

IF (correction < 50) {
    EMIT SELL 3;
}

LOOP 3 TIMES {
    EMIT BUY 1;
}

LET i = 0;
LOOP 2 * 2 TIMES {
    EMIT SELL i + 1;
}
```

2. Compile com o comando:
```bash
make run
```

3. Veja o código Verilog gerado no arquivo `output.v`:

```verilog
module pivota_strategy(output reg [3:0] order, output reg [3:0] qty);
reg [31:0] price, volume, threshold, total, correction, i;
initial begin
    price = 120;
    volume = 15;
    threshold = 100;
    total = 1800;
    correction = 1720;
    i = 0;
    if (1800 > 100) begin
        order = 1; qty = 15;
    end
    if (1720 < 50) begin
        order = 2; qty = 3;
    end
    repeat(3) begin
        order = 1; qty = 1;
    end
    repeat(4) begin
        order = 2; qty = 1;
    end
end
endmodule
```

---

## Funcionalidades Implementadas

A linguagem **Pivota** foi desenvolvida como uma linguagem de domínio específico (DSL) para facilitar a descrição de estratégias de negociação e geração automática de código Verilog. A seguir, estão listadas as principais funcionalidades implementadas:

### Núcleo da Linguagem

- **Variáveis inteiras (`LET`)**
  - Suporte à declaração e inicialização de variáveis inteiras.
  - Armazenamento em uma tabela de símbolos com resolução automática de nomes.

- **Atribuições com expressões aritméticas**
  - Suporte completo aos operadores `+`, `-`, `*`, `/`.
  - Permite combinações entre literais e variáveis.
  - Exemplo:  
    ```pivota
    LET total = price * volume + 10;
    ```

### Expressões e Condições

- Comparações lógicas suportadas: `>`, `<`, `==`.
- Avaliação de condições com substituição dos valores das variáveis.
- Geração de código `if (...) begin ... end` com condições resolvidas em tempo de compilação.

### Controle de Fluxo

- **Condicionais (`IF`)**
  - Suporte a blocos com múltiplas instruções entre chaves.
- **Laços (`LOOP N TIMES`)**
  - Repetição de blocos de código por um número fixo de vezes, inclusive com expressões aritméticas.

### Comandos de Emissão

- **`EMIT BUY <valor>`** e **`EMIT SELL <valor>`** geram diretamente as instruções:
  ```verilog
  order = 1; qty = <valor>; // BUY
  order = 2; qty = <valor>; // SELL
  ```

### Geração de Código Verilog

- Todas as variáveis são resolvidas com seus respectivos valores em tempo de compilação.
- Expressões e condições são totalmente avaliadas e traduzidas.
- O código gerado é compatível com simuladores Verilog online e ferramentas de síntese.
---
<br>
<br>

- Observação: O Makefile foi feito para macOS
    - "make" compila
    - "make run" executa
    - "make clean" apaga os arquivos gerados