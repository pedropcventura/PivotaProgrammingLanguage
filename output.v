module pivota_strategy(output reg [3:0] order, output reg [3:0] qty);
initial begin
    integer x = 100;
    // condition: x > 50
    order = 1; qty = 10;
    // IF
    if (/* condition */) begin
    // ...
    end
    order = 2; qty = 1;
    // LOOP
    repeat(2) begin
    // ...
    end
end
endmodule
