module dff(out, data, clk);
    input data, clk;
    output out;

    wire not_clk, w2;
    wire not_out_1, not_out_2;

    not notgate(not_clk, clk);
    d_latch dl1(w2, not_out_1, data, not_clk);
    d_latch dl2(out, not_out_2, w2, clk);
endmodule