module test;
    wire [3:0] dummy;
    pivota_strategy uut (.dummy(dummy));

    initial begin
        #1;
        for (int j = 0; j < uut.i; j = j + 1) begin
            $display("Order: %d Qty: %d", uut.order_list[j], uut.qty_list[j]);
        end
        $finish;
    end
endmodule
