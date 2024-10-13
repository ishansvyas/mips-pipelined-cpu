`timescale 1 ns / 100 ps
module or32_tb;
    reg [31:0] in0, in1;
    wire [31:0] out, expected;

    // to do
    or32 or_gate(.out(out), .in1(in0), .in2(in1));
    assign expected = in0 | in1;

    initial begin
        in0 = 32'h00000000;
        in1 = 32'h00000000;
        #240;
        $finish;
    end
    always begin
        #10 in0 = $random;
        #10 in1 = $random;
    end
    always @(in0, in1) begin
        #1;
        if(expected === out) begin
            $display("PASSED: A:%b, B:%b => Out:%b", in0, in1, out);
        end else begin 
            $display("FAILED: A:%b, B:%b => Out:%b", in0, in1, out);
        end
    end    
    initial begin
        $dumpfile("or32_waveform.vcd");
        $dumpvars(0, or32_tb);
    end    

endmodule