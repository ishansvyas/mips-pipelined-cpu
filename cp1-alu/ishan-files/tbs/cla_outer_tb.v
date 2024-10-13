`timescale 1 ns / 100ps
module cla_outer_tb;
    ///////// MODULE
    // inputs
    reg [31:0] A, B;
    reg Cin;

    // outputs
    wire [31:0] result, expected;
    wire Cout;
    
    cla_outer mod(.data_operandA(A), .data_operandB(B), .Cin(Cin), .data_result(result), .Cout(Cout));

    assign expected = A + B + Cin;

    // TB only add
    initial begin
        $dumpfile("cla_outer_waveform.vcd");
        $dumpvars(0, cla_outer_tb);
        A = 32'd0;
        B = 32'd0;
        Cin = 0;
        // time delay -> CHANGE LATER
        #200;
        $finish;
    end
    always begin
        #10;
        A = $random;
        B = $random;
    end

    always @(A,B,Cin) begin
        #2;
        $display("A:%b, B:%b, Cin:%b => Cout:%b, S:%b", A, B, Cin, Cout, result);
        $finish;
    end
endmodule