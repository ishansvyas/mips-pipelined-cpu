module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] not_data_operandB, w1, y1, y2, y3, y4, y5;
    wire ne1, ne2, ne3, ne4;
    wire [31:0] zeroes;
    assign zeroes = 32'd0;

    not32 notB(not_data_operandB, data_operandB);

    assign w1 = ctrl_ALUopcode[0] ? not_data_operandB : data_operandB;

    cla_outer adder(.data_operandA(data_operandA), .data_operandB(w1), .Cin(ctrl_ALUopcode[0]), .data_result(y1), .Cout(overflow));

    and32 bitwise_and(.out(y2), .in1(data_operandA), .in2(data_operandB));
    or32 bitwise_or(.out(y3), .in1(data_operandA), .in2(data_operandB));

    // SLL - Shift Left Logical
    sll sll(.in(data_operandA), .sh_amt(ctrl_shiftamt), .out(y4));

    // SRA - Shift Right Arithmetic
    sra sra(.in(data_operandA), .sh_amt(ctrl_shiftamt), .out(y5));

    // isLT, isNE bits
    assign isLessThan = y1[31];
    or isNEl1(ne1, y1[0], y1[1], y1[2], y1[3], y1[4], y1[5], y1[6], y1[7]);
    or isNEl2(ne2, y1[8], y1[9], y1[10], y1[11], y1[12], y1[13], y1[14], y1[15]);
    or isNEl3(ne3, y1[16], y1[17], y1[18], y1[19], y1[20], y1[21], y1[22], y1[23]);
    or isNEl4(ne4, y1[24], y1[25], y1[26], y1[27], y1[28], y1[29], y1[30], y1[31]);
    or isNE(isNotEqual, ne1, ne2, ne3, ne4);

    mux8 final_mux(.out(data_result), .select(ctrl_ALUopcode[2:0]), .in0(y1),
    .in1(y1), .in2(y2), .in3(y3), .in4(y4), .in5(y5), .in6(zeroes), .in7(zeroes));


endmodule