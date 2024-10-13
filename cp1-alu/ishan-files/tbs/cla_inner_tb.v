`timescale 1ns /100ps
module cla_inner_tb;
    ///////// MODULE
    // inputs
    reg [7:0] A, B;
    reg Cin;
    // outputs
    wire [7:0] S;
    wire Cout, big_G, big_P;

    // Instantiate the module to test
    cla_inner adder(.data_operandA(A), .data_operandB(B), .Cin(Cin), .Cout(Cout), .data_result(S), .big_G(big_G), .big_P(big_P));

    ///////// INITIALIZATION
    initial begin;
        A=0;
        B=0;
        Cin=0;
        #20480;
        $finish;
    end
    // toggle
    always
        #5 A = A+1;
    always
        #1280 B = B+1;
    always
        #20 Cin = ~Cin; // not all cases tried

    always @(A,B,Cin) begin
        #1;
        $display("A:%b, B:%b, Cin:%b => Cout:%b, S:%b, P:%b, G:%b", A, B, Cin, Cout, S, big_P, big_G);
    end
    ///////// WAVEFORM
    initial begin  
        $dumpfile("cla_inner_waveform.vcd");
        $dumpvars(0, cla_inner_tb);
    end
endmodule