module sll(in, out, sh_amt);
    input [4:0] sh_amt;
    input [31:0] in;
    output [31:0] out;

    wire [31:0] s1, s2, s4, s8, s16;
    wire [31:0] ta, tb, tc, td;
    wire [31:0] zero;
    
    assign zero = 32'h00000000;

    assign s1 = {in[30:0],zero[0]};
    assign ta = sh_amt[0] ? s1 : in;

    assign s2 = {ta[29:0],zero[1:0]};
    assign tb = sh_amt[1] ? s2 : ta;
    
    assign s4 = {tb[27:0],zero[3:0]};
    assign tc = sh_amt[2] ? s4 : tb;

    assign s8 = {tc[23:0],zero[7:0]};
    assign td = sh_amt[3] ? s8 : tc;

    assign s16 = {td[15:0],zero[15:0]};
    assign out = sh_amt[4] ? s16 : td;    
endmodule