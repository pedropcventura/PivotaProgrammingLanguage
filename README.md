# Pivota Programming Language
- Backtest focused:

Example:
```
STRATEGY "RSI Multi-Asset Test"
START_DATE "2022-01-01"
END_DATE "2022-12-31"

ASSET "AAPL"

VAR threshold = 30

FOR asset IN ["AAPL", "GOOG", "MSFT"] {
    IF RSI(asset, 14) < threshold THEN
        BUY asset
    ENDIF
}

```

- Rodar Flex e Bison:
```
bison -d parser.y
flex tokens.l
gcc -o pivota parser.tab.c lex.yy.c
./pivota < example.pv
```