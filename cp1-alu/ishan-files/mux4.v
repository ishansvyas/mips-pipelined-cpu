module mux4(out, select, in0, in1, in2, in3);
    input [1:0] select;
    input [31:0] in0, in1, in2, in3;
    output [31:0] out;
    wire [31:0] w1, w2;
    assign w1 = select[0] ? in1 : in0;
    assign w2 = select[0] ? in3 : in2;
    assign out = select[1] ? w2 : w1;
endmodule