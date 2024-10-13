`timescale 1 ns / 100 ps

module not32_tb;
    // input = reg
    reg [31:0] in;
    // output = wire
    wire [31:0] out, expected;

    not32 not_gate(.in(in), .out(out));
    assign expected = ~in;

    initial begin
        in = 32'h00000000;

        #240;
        $finish;
    end
    always 
        #10 in = $random;
    always @(in) begin
        #1;
        if(expected === out) begin
            $display("PASSED: In:%b => Out:%b", in, out);
        end else begin 
            $display("FAILED: In:%b => Out:%b", in, out);
        end
    end    
    initial begin
        $dumpfile("not32_waveform.vcd");
        $dumpvars(0, not32_tb);
    end    

endmodule