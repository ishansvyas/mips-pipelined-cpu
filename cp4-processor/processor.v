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

    ////////// START OF FETCH //////////

    wire [31:0] pc_in, pc_plus_one;
    
	register program_counter(.out(address_imem), .in(pc_in), .clk(clock), .en(1'b1), .clr(reset));
    alu_cla_outer pc_plus_one_adder(.data_operandA(address_imem), .data_operandB(32'd1), .Cin(1'd0), .data_result(pc_plus_one), .Cout());
    
    // next PC calculation [SEE branching IN EXECUTE FOR LOGIC/DESTINATION CALCULATION]
    mux4 pc_branch_control(.out(pc_in), .select(pc_branch_control), .in0(pc_plus_one), .in1(pc_plus_N), .in2(decode_B_out), .in3(pc_T));
    /*      PC+1:       pc_plus_one
            PC+1+N:     pc_plus_N
            $rd:        decode_B_out
            T:          pc_T
    */


    ////////// END OF FETCH //////////
    wire [31:0] fetch_PC_out, fetch_INSN_out;
    register fetch_PC(.out(fetch_PC_out), .in(pc_in), .clk(not_clock), .en(1'b1), .clr(reset));
    register fetch_INSN(.out(fetch_INSN_out), .in(q_imem), .clk(not_clock), .en(1'b1), .clr(reset));
    ////////// START OF DECODE //////////

    wire [31:0] data_writeReg_w;
    // assign inputs to regfile, output of regfile in latch

    /* ONLY INTERRACT WITH REGFILE VIA I/O OF PROCESSOR, NOT BY DIRECT INSTANTIAION */
    assign ctrl_writeEnable = 1'b0; // NOTE: CURRENTLY DISABLED
    assign ctrl_writeReg = fetch_INSN_out[26:22];
    assign ctrl_readRegA = fetch_INSN_out[21:17];
    assign ctrl_readRegB = !(|(fetch_INSN_out[31:27]^5'b10110)) ? 5'b11110 : fetch_INSN_out[16:12]; // BEX LOGIC
	assign data_writeReg = data_writeReg_w;

    ////////// END OF DECODE //////////
    wire [31:0] decode_PC_out, decode_A_out, decode_B_out, decode_INSN_out;  
    register decode_PC(.out(decode_PC_out), .in(fetch_PC_out), .clk(not_clock), .en(1'b1), .clr(reset));
    register decode_A(.out(decode_A_out), .in(data_readRegA), .clk(not_clock), .en(1'b1), .clr(reset));
    register decode_B(.out(decode_B_out), .in(data_readRegB), .clk(not_clock), .en(1'b1), .clr(reset));
    register decode_INSN(.out(decode_INSN_out), .in(fetch_INSN_out), .clk(not_clock), .en(1'b1), .clr(reset));
    ////////// START OF EXECUTE //////////

    /// MUX for B input
    wire is_R_type;
    assign is_R_type = !(|decode_INSN_out[31:27]);
    wire [31:0] sign_extend_immed_out, ALU_input_B;
    sign_extend_17_32 extender(.out(sign_extend_immed_out), .in(decode_INSN_out[31:27]));
    assign ALU_input_B = is_R_type ? decode_B_out : sign_extend_immed_out;

    // ALU; NOTE: isLT, isNE are unused. OVF undefined too but that's ok?
    wire [31:0] alu_out;
    wire alu_isNE, alu_isLT;
    alu execute_alu(
            .data_operandA(decode_A_out), .data_operandB(ALU_input_B),
            .ctrl_ALUopcode(decode_INSN_out[6:2]), .ctrl_shiftamt(decode_INSN_out[11:7]),
            .data_result(alu_out),
            .isNotEqual(alu_isNE), .isLessThan(alu_isLT), .overflow());    

    // branching: destination calculation
    wire [31:0] pc_plus_N, pc_T;
    alu_cla_outer pc_plus_N(.data_operandA(decode_PC_out), .data_operandB(sign_extend_immed_out), .Cin(1'b0), .data_result(pc_plus_N), .Cout());
    assign pc_T[26:0] = decode_INSN_out[26:0];
    assign pc_T[31:27] = {5{decode_INSN_out[26]}};

    // branching: logic calculation
    wire [4:0] decode_out_opcode;
    wire take_pc_N, take_T, take_rd;
    assign decode_out_opcode = decode_INSN_out[31:27]; 
    assign take_pc_N = (!(|(decode_out_opcode^5'b00010)) && (alu_isNE)) || (!(|(decode_out_opcode^5'b00110)) && (alu_isLT));
    assign take_T = (!(|(decode_out_opcode^5'b00011))) || (!(|(decode_out_opcode^5'b10110)) && (|(decode_B_out)));
    assign take_rd = (!(|(decode_out_opcode^5'b00100)));

    // mux assignment: {00,01,10,11} = {+1, +N+1, T, $rd}
    wire [1:0] pc_branch_control;
    assign pc_branch_control[0] = take_pc_N || take_rd;
    assign pc_branch_control[1] = take_T || take_rd;



    ////////// END OF EXECUTE //////////
    wire [31:0] execute_pc_out, execute_O_out, execute_B_out, execute_INSN_out;
    register execute_O(.out(execute_O_out), .in(alu_out), .clk(not_clock), .en(1'b1), .clr(reset));
    register execute_B(.out(execute_B_out), .in(decode_B_out), .clk(not_clock), .en(1'b1), .clr(reset));
    register execute_INSN(.out(execute_INSN_out), .in(decode_INSN_out), .clk(not_clock), .en(1'b1), .clr(reset));
    ////////// START OF MEMORY //////////


	/* END CODE */

endmodule
