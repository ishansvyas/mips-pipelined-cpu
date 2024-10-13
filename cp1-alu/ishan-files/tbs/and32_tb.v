`timescale 1 ns / 100 ps
module and32_tb();
    reg [31:0] in0, in1;
    wire [31:0] out, expected;

    and32 and_gate(.out(out), .in1(in0), .in2(in1));
    assign expected = in0 & in1;

    initial begin
        in0 = 32'h00000000;
        in1 = 32'h00000000;
        #240;
        $finish;
    end
    always
        #10 in0 = $random;
    always
        #10 in1 = $random;
    always @(in0, in1) begin
        #1;
        if(expected === out) begin
            $display("PASSED: A:%b, B:%b => Out:%b", in0, in1, out);
        end else begin 
            $display("FAILED: A:%b, B:%b => Out:%b", in0, in1, out);
        end
    end    
    initial begin
        $dumpfile("and32_waveform.vcd");
        $dumpvars(0, and32_tb);
    end    

endmodule