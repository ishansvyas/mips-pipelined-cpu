`timescale 1 ns/ 100 ps
module d_latch_tb();
    reg data, enable;
    wire Q, notQ;
    
    d_latch d_latch1(data, enable, Q, notQ);

    initial begin
        data = 1'b0;
        enable = 1'b0;
        #160;
        $finish;
    end

    always 
        #40 enable = !enable;

    always 
        #10 data = $random;
    
    always @(enable, data) begin
        #1;
        $display("D:%b, E:%b -> Q:%b, !Q:%b", data, enable, Q, notQ);
    end
    initial begin
        $dumpfile("d_latch_waveform.vcd");
        $dumpvars(0, d_latch_tb);

    end


endmodule;