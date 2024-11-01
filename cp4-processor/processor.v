/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    wire not_clock;
    assign not_clock = !clock;
    wire [31:0] nop;
    assign nop = 32'd0;

    ////////// START OF FETCH //////////

    wire [31:0] pc_in, pc_plus_one;
    wire [4:0] stall_logic;
    wire [1:0] pc_branch_control;
    
	register program_counter(.out(address_imem), .in(pc_in), .clk(not_clock), .en(!stall_logic[0]), .clr(reset));
    alu_cla_outer pc_plus_one_adder(.data_operandA(address_imem), .data_operandB(32'd1), .Cin(1'd0), .data_result(pc_plus_one), .Cout());
    
    // next PC calculation [SEE branching IN EXECUTE FOR LOGIC/DESTINATION CALCULATION]
    mux4 pc_branch_control_mux(.out(pc_in), .select(pc_branch_control), .in0(pc_plus_one), .in1(pc_plus_N), .in2(decode_B_out), .in3(pc_T));
    /*      PC+1:       pc_plus_one
            PC+1+N:     pc_plus_N
            $rd:        decode_B_out
            T:          pc_T
    */

    // flush logic
    assign fetch_INSN_in = (!(|(decode_INSN_out[31:27]^5'b00110)) & !alu_isLT & alu_isNE) || (!(|(decode_INSN_out[31:27]^5'b00010)) & alu_isNE) ? nop : q_imem;

    ////////// END OF FETCH //////////
    wire [31:0] fetch_PC_out, fetch_INSN_out, fetch_INSN_in;
    register fetch_PC(.out(fetch_PC_out), .in(pc_in), .clk(not_clock), .en(!stall_logic[1]), .clr(reset));
    register fetch_INSN(.out(fetch_INSN_out), .in(fetch_INSN_in), .clk(not_clock), .en(!stall_logic[1]), .clr(reset));
    ////////// START OF DECODE //////////
    wire ctrl_readRegB_logic;
    assign ctrl_readRegB_logic = !(|(fetch_INSN_out[31:27]^5'b00110)) || !(|(fetch_INSN_out[31:27]^5'b00010))
            || !(|(fetch_INSN_out[31:27]^5'b00111)) || !(|(fetch_INSN_out[31:27]^5'b00010))
            || !(|(fetch_INSN_out[31:27]^5'b00100));

    /* ONLY INTERRACT WITH REGFILE VIA I/O OF PROCESSOR, NOT BY DIRECT INSTANTIAION */
    // assign ctrl_writeEnable IS DONE IN WRITEBACK STAGE
    // assign ctrl_writeReg IS DONE IN WRITEBACK STAGE
    assign ctrl_readRegA = !(|(fetch_INSN_out[31:27]^5'b10110)) ? 5'b11110 : fetch_INSN_out[21:17];
    assign ctrl_readRegB = ctrl_readRegB_logic ? fetch_INSN_out[26:22] : fetch_INSN_out[16:12]; 
	// assign data_writeReg IS DONE IN WRITEBACK STAGE

    // flush logic 
    assign decode_INSN_in = (!(|(decode_INSN_out[31:27]^5'b00110)) & !alu_isLT & alu_isNE) || (!(|(decode_INSN_out[31:27]^5'b00010)) & alu_isNE) ? nop : fetch_INSN_out;

    ////////// END OF DECODE //////////
    wire [31:0] decode_PC_out, decode_A_out, decode_B_out, decode_INSN_out, decode_INSN_in;  
    register decode_PC(.out(decode_PC_out), .in(fetch_PC_out), .clk(not_clock), .en(!stall_logic[2]), .clr(reset));
    register decode_A(.out(decode_A_out), .in(data_readRegA), .clk(not_clock), .en(!stall_logic[2]), .clr(reset));
    register decode_B(.out(decode_B_out), .in(data_readRegB), .clk(not_clock), .en(!stall_logic[2]), .clr(reset));
    register decode_INSN(.out(decode_INSN_out), .in(decode_INSN_in), .clk(not_clock), .en(!stall_logic[2]), .clr(reset));
    ////////// START OF EXECUTE //////////

    /// MUX for B input
    wire use_sign_extend_execute;
    assign use_sign_extend_execute = !(|(decode_INSN_out[31:27]^5'b00101)) || !(|(decode_INSN_out[31:27]^5'b00111)) || !(|(decode_INSN_out[31:27]^5'b01000));
    wire [31:0] sign_extend_immed_out, ALU_input_B;
    sign_extend_17_32 extender(.out(sign_extend_immed_out), .in(decode_INSN_out[16:0]));
    assign ALU_input_B = use_sign_extend_execute ? sign_extend_immed_out : decode_B_out;

    // ALU opcode -> account for addi insn needing opcode to be 00000.
    wire [4:0] execute_alu_opc;
    wire [1:0] alu_opc_is_diff;
    assign alu_opc_is_diff[0] = !(|(decode_INSN_out[31:27]^5'b00101)); // is addi
    assign alu_opc_is_diff[1] = !(|(decode_INSN_out[31:27]^5'b00010)) || !(|(decode_INSN_out[31:27]^5'b00110)); // is branch
    mux4 #(5) execute_alu_opc_mux(.out(execute_alu_opc), .select(alu_opc_is_diff), .in0(decode_INSN_out[6:2]), .in1(5'b00000), .in2(5'b00001), .in3(5'b00000));

    // ALU
    wire [31:0] alu_out;
    wire alu_isNE, alu_isLT, alu_ovf;
    alu execute_alu(
            .data_operandA(decode_A_out), .data_operandB(ALU_input_B),
            .ctrl_ALUopcode(execute_alu_opc), .ctrl_shiftamt(decode_INSN_out[11:7]),
            .data_result(alu_out),
            .isNotEqual(alu_isNE), .isLessThan(alu_isLT), .overflow(alu_ovf));    

    // branching: destination calculation
    wire [31:0] pc_plus_N, pc_T;
    alu_cla_outer pc_plus_N_alu(.data_operandA(decode_PC_out), .data_operandB(sign_extend_immed_out), .Cin(1'b0), .data_result(pc_plus_N), .Cout());
    assign pc_T[26:0] = decode_INSN_out[26:0];
    assign pc_T[31:27] = {5{decode_INSN_out[26]}};

    // branching: logic calculation
    wire [4:0] decode_out_opcode;
    wire take_pc_N, take_T, take_rd;
    assign decode_out_opcode = decode_INSN_out[31:27]; 
    assign take_pc_N = (!(|(decode_out_opcode^5'b00010)) && (alu_isNE)) || (!(|(decode_out_opcode^5'b00110)) && (!alu_isLT) && alu_isNE);
    assign take_T = (!(|(decode_out_opcode^5'b00011))) || (!(|(decode_out_opcode^5'b10110)) && (|(decode_A_out))) || (!(|(decode_out_opcode^5'b00001)));
    assign take_rd = (!(|(decode_out_opcode^5'b00100)));

    // mux assignment: {00,01,10,11} = {+1, +N+1, T, $rd}
    assign pc_branch_control[0] = take_pc_N || take_T;
    assign pc_branch_control[1] = take_rd || take_T;

    //// MULTIPLICATION / DIVISION ---------------------------------------------- COMPLETELY WRONG
    wire [31:0] multdiv_out;
    wire is_mult, is_div, multdiv_exception, multdiv_RDY;
    assign is_mult = !(|decode_out_opcode) && !(|(decode_INSN_out[6:2]^5'b00110));
    assign is_div = !(|decode_out_opcode) && !(|(decode_INSN_out[6:2]^5'b00111));

    // positive edge-triggered pulse generator 
    wire ctrl_MULT, ctrl_DIV, is_mult_delayed, is_div_delayed;
    dffe_ref ctrl_MULT_delayed(.q(is_mult_delayed), .d(is_mult), .clk(not_clock), .en(1'b1), .clr(reset));
    assign ctrl_MULT = !is_mult_delayed && is_mult;
    dffe_ref ctrl_DIV_delayed(.q(is_div_delayed), .d(is_div), .clk(not_clock), .en(1'b1), .clr(reset));
    assign ctrl_DIV = !is_div_delayed && is_div;

    multdiv multdiv_module(
        .data_operandA(decode_A_out), .data_operandB(decode_B_out), 
        .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV), 
        .clock(not_clock), 
        .data_result(multdiv_out), .data_exception(multdiv_exception), .data_resultRDY(multdiv_RDY));
    
    //gated SR latch (set = ctrl_MULT OR ctrl_DIV) (reset = data_resultRDY)
    wire md_stall_Qa, Qb, multdiv_S, multdiv_R;
    assign multdiv_S = ((ctrl_MULT | ctrl_DIV) && not_clock);
    assign multdiv_R = ((multdiv_RDY && not_clock) || reset);
    nor sr_multdiv1(md_stall_Qa, multdiv_R, Qb);
    nor sr_multdiv2(Qb, multdiv_S, md_stall_Qa);

    // assign stall logic
    assign stall_logic = {5{md_stall_Qa}};

    // output selector
    wire [31:0] execute_O_in;
    wire [1:0] execute_output_selector;
    assign execute_output_selector[0] = (is_mult || is_div);
    assign execute_output_selector[1] = !(|(decode_out_opcode^5'b00011));
    mux4 execute_output_select(.out(execute_O_in), .select(execute_output_selector), .in0(alu_out), .in1(multdiv_out), .in2(decode_PC_out), .in3(32'b0));

    ////////// END OF EXECUTE //////////
    wire [31:0] execute_pc_out, execute_O_out, execute_B_out, execute_INSN_out;
    register execute_O(.out(execute_O_out), .in(execute_O_in), .clk(not_clock), .en(!stall_logic[3]), .clr(reset));
    register execute_B(.out(execute_B_out), .in(decode_B_out), .clk(not_clock), .en(!stall_logic[3]), .clr(reset));
    register execute_INSN(.out(execute_INSN_out), .in(decode_INSN_out), .clk(not_clock), .en(!stall_logic[3]), .clr(reset));
    ////////// START OF MEMORY //////////

    assign address_dmem = execute_O_out;
    assign data = execute_B_out;
    assign wren = !(|(execute_INSN_out[31:27]^5'b00111));

    ////////// END OF MEMORY //////////
    wire [31:0] memory_O_out, memory_D_out, memory_INSN_out;
    register memory_O(.out(memory_O_out), .in(execute_O_out), .clk(not_clock), .en(!stall_logic[4]), .clr(reset));
    register memory_D(.out(memory_D_out), .in(q_dmem), .clk(not_clock), .en(!stall_logic[4]), .clr(reset));
    register memory_INSN(.out(memory_INSN_out), .in(execute_INSN_out), .clk(not_clock), .en(!stall_logic[4]), .clr(reset));
    ////////// START OF WRITEBACK //////////

    wire [4:0] wb_opc;
    assign wb_opc = memory_INSN_out[31:27];
    assign ctrl_writeEnable =   !(|(wb_opc^5'b00000) || !(|memory_INSN_out)) || !(|(wb_opc^5'b00101)) || !(|(wb_opc^5'b01000)) 
                                || !(|(wb_opc^5'b00011)) || !(|(wb_opc^5'b10101));
    mux4 data_writeReg_mux(.out(data_writeReg), .select(data_writeReg_controller),
            .in0(memory_O_out), .in1(memory_D_out), .in2(setx_T_extended), .in3(32'd0));    
    mux4 #(5) ctrl_writeReg_mux(.out(ctrl_writeReg), .select(ctrl_writeReg_controller), .in0(memory_INSN_out[26:22]), .in1(5'b11110), .in2(5'b11111), .in3(5'd0));


    // ctrls for ctrl_writeReg
    wire ctrl_writeReg_rstatus, ctrl_writeReg_r31;
    wire [1:0] ctrl_writeReg_controller; 
    assign ctrl_writeReg_rstatus = !(|(wb_opc^5'b10101)); // STILL NEED TO INCLUDE OVERFLOW CONDITIONS
    assign ctrl_writeReg_r31 = !(|(wb_opc^5'b00011)); // JAL
    assign ctrl_writeReg_controller = {ctrl_writeReg_r31, ctrl_writeReg_rstatus};

    // ctrls for data_writeReg
    wire [1:0] data_writeReg_controller;
    wire [31:0] setx_T_extended;
    assign data_writeReg_controller[0] = !(|(wb_opc^5'b01000));
    assign data_writeReg_controller[1] = !(|(wb_opc^5'b10101));
    assign setx_T_extended[26:0] = memory_INSN_out[26:0];
    assign setx_T_extended[31:27] = {5{memory_INSN_out[26]}};
 
	/* END CODE */

endmodule