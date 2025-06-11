# Pivota Programming Language (PPL)

Pivota é uma linguagem de programação minimalista desenvolvida para transformar estratégias de negociação em hardware de baixa latência. Com PPL, você escreve regras de trading de forma imperativa e clara, e o compilador gera automaticamente módulos Verilog prontos para simulação e síntese.

Originada em um contexto de high-frequency trading (HFT), PPL permite expressar lógica de ordens (`BUY` e `SELL`) diretamente em circuitos digitais, reduzindo a latência ao mínimo. Seu design enfatiza:

- **Variáveis inteiras** (`LET`) para armazenar sinais e parâmetros de estratégia.
- **Condicionais** (`IF`) para decisões baseadas em comparações.
- **Laços** (`LOOP N TIMES`) para padrões repetitivos de ordens.
- **Emissão de ordens** (`EMIT BUY 10`, `EMIT SELL x`) para gerar sinais de execução.

O compilador lê arquivos `.pv` e produz dois artefatos:

1. **`output.v`**: um módulo Verilog com esta assinatura: de "order" e "qty"
2. um testbench que imprime no console 



## Executando o Compilador

### Instalação de Dependências

**Flex e Bison**
- macOS:
  ```bash
  brew install flex bison
  ```
- Ubuntu/Debian:
  ```bash
  sudo apt update
  sudo apt install flex bison gcc
  ```

**Icarus Verilog**
- macOS:
  ```bash
  brew install icarus-verilog
  ```
- Ubuntu/Debian:
  ```bash
  sudo apt install iverilog
  ```

### Compilando o Compilador
```bash
bison -d pivota.y
flex pivota.l
g++ -o compiler lex.yy.c pivota.tab.c -ll
```

### Gerando Verilog e Testbench
1. Escreva seu programa em `example.pv`.
2. Execute:
   ```bash
   ./compiler < example.pv
   ```
   Isso criará `output.v` e `testbench.sv`.

### Simulando com Icarus Verilog
```bash
iverilog -g2012 -o sim output.v testbench.sv
vvp sim
```




## Exemplo

# Exemplo de Uso de PPL

### Arquivo de Entrada (`example.pv`)
```pivota
LET price      = 60 * 2;
LET volume     = 5 + 10;
LET threshold  = 100;
LET total      = price * volume;

IF (total > threshold) {
    EMIT BUY volume;
}

LET correction = total - 800;

IF (correction < 150) {
    EMIT SELL 3;
}

LOOP 3 TIMES {
    EMIT BUY 1;
}

LET reps       = 2 * 2;
LOOP reps TIMES {
    EMIT SELL price / 30;
}

LET sum        = price + volume;
LET diff       = sum - 20;

IF (diff == 115) {
    EMIT BUY diff;
}
```

### Código Verilog Gerado (`output.v`)
```verilog
module pivota_strategy(output reg [3:0] dummy);
reg [3:0] order_list [0:255];
reg [3:0] qty_list [0:255];
integer i;
reg [31:0] price, volume, threshold, total, correction, reps, sum, diff;
initial begin
    i = 0;
    price = 120;
    volume = 15;
    threshold = 100;
    total = 1800;
    correction = 1000;
    reps = 4;
    sum = 135;
    diff = 115;
    if (1800 > 100) begin
        order_list[i] = 1; qty_list[i] = 15; i = i + 1;
    end
    if (1000 < 150) begin
        order_list[i] = 2; qty_list[i] = 3; i = i + 1;
    end
    repeat(3) begin
        order_list[i] = 1; qty_list[i] = 1; i = i + 1;
    end
    repeat(4) begin
        order_list[i] = 2; qty_list[i] = 4; i = i + 1;
    end
    if (115 == 115) begin
        order_list[i] = 1; qty_list[i] = 115; i = i + 1;
    end
end
endmodule
```

### Resultado da Simulação
```bash
$ iverilog -g2012 -o sim output.v testbench.sv
$ vvp sim
Order:  1 Qty: 15
Order:  2 Qty:  3
Order:  1 Qty:  1
Order:  1 Qty:  1
Order:  2 Qty:  4
Order:  2 Qty:  4
Order:  2 Qty:  4
Order:  2 Qty:  4
Order:  1 Qty: 115
```  
Cada linha mostra a **ordem** (1 = BUY, 2 = SELL) e a **quantidade** correspondente, na sequência em que foram enfileiradas no bloco `initial` pela lógica do compilador.


- Observação: O Makefile foi feito para macOS
    - "make" compila
    - "make run" executa
    - "make clean" apaga os arquivos gerados