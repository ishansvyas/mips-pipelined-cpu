`timescale 1 ns / 100 ps
module sra_tb();
    reg[31:0] in;
    reg[4:0] sh_amt;
    wire[31:0] out, expected, diff;
    sra sra(.in(in), .sh_amt(sh_amt), .out(out));

    assign expected = $signed(in) >>> sh_amt;
    assign diff = out - expected;

    initial begin
        in = 32'd0;
        sh_amt = 5'd0;
        #240;   
        $finish;
    end
    always 
        #10 in = $random;
    always 
        #10 sh_amt = $random;
    always @(in) begin
        #5;
        if(expected === out) begin
            $display("PASSED: In:%b, Shift:%b => Out:%b", in, sh_amt, out);
        end else begin 
            $display("FAILED: In:%b, Shift:%b => Out:%b", in, sh_amt, out);
        end
    end    
    initial begin
        $dumpfile("sra_waveform.vcd");
        $dumpvars(0, sra_tb);
    end   

endmodule