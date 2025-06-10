module pivota_strategy(output reg [3:0] dummy);
reg [3:0] order_list [0:255];
reg [3:0] qty_list [0:255];
integer i;
reg [31:0] price, volume, threshold, total, correction;
initial begin
    i = 0;
    price = 100;
    volume = 5;
    threshold = 450;
    total = 500;
    correction = 200;
    if (500 > 450) begin
        order_list[i] = 1; qty_list[i] = 5; i = i + 1;
    end
    if (200 < 100) begin
        order_list[i] = 2; qty_list[i] = 3; i = i + 1;
    end
    repeat(2) begin
        order_list[i] = 1; qty_list[i] = 1; i = i + 1;
    end
end
endmodule
