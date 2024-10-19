module register(out, in, clk, en, clr);
    input [31:0] in;
    input clk, en, clr;
    output [31:0] out;

    // USE GENVAR LOOPS
    genvar i;
    generate 
        for (i=0; i<32; i=i+1) begin : dffe_gen
            dffe_ref dff(.q(out[i]), .d(in[i]), .clk(clk), .en(en), .clr(clr));
        end
    endgenerate
endmodule