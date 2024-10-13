`timescale 1 ns / 100 ps
module sll_tb();
    reg[31:0] in;
    reg[4:0] sh_amt;
    wire[31:0] out, expected, diff;
    sll sll(.in(in), .sh_amt(sh_amt), .out(out));

    assign expected = in << sh_amt;
    assign diff = out - expected;

    initial begin
        in = 32'd0;
        sh_amt = 5'd0;
        #240;
        $finish;
    end
    always 
        #40 sh_amt = (sh_amt * 2) + 1;
    always 
        #10 in = $random;
    always @(in) begin
        #1;
        if(expected === out) begin
            $display("PASSED: In:%b, Shift:%b => Out:%b", in, sh_amt, out);
        end else begin 
            $display("FAILED: In:%b, Shift:%b => Out:%b", in, sh_amt, out);
        end
    end    
    initial begin
        $dumpfile("sll_waveform.vcd");
        $dumpvars(0, sll_tb);
    end   

endmodule