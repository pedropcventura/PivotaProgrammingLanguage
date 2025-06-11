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
