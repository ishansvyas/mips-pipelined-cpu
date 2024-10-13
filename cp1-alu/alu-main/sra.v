module sra(in, out, sh_amt);
    input [4:0] sh_amt;
    input [31:0] in;
    output [31:0] out;

    // intermediate wires
    wire [31:0] s1, s2, s4, s8, s16;
    wire [31:0] ta, tb, tc, td;
    wire [31:0] zero;
    
    // reverse order; starts with least significant bit
    assign s1 = {in[31],in[31:1]};
    assign ta = sh_amt[0] ? s1 : in;

    assign s2 = {{2{ta[31]}},ta[31:2]};
    assign tb = sh_amt[1] ? s2 : ta;

    assign s4 = {{4{tb[31]}},tb[31:4]};
    assign tc = sh_amt[2] ? s4 : tb;

    assign s8 = {{8{tc[31]}},tc[31:8]};
    assign td = sh_amt[3] ? s8 : tc;

    assign s16 = {{16{td[31]}},td[31:16]};
    assign out = sh_amt[4] ? s16 : td;    
endmodule