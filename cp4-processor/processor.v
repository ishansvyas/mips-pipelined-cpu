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
    assign not_clock = ~(clock);

    ////////// START OF FETCH 

    wire [31:0] pc_in, pc_plus_one;
    
	register program_counter(.out(address_imem), .in(pc_in), .clk(clock), .en(1'b1), .clr(reset));
    alu_cla_outer pc_plus_one_adder(.data_operandA(address_imem), .data_operandB(32'd1), .Cin(1'd0), .data_result(pc_plus_one), .Cout());
    assign pc_in = pc_plus_one;

    ////////// END OF FETCH 
    wire [31:0] fetch_PC_out, fetch_INSN_out;
    register fetch_PC(.out(fetch_PC_out), .in(pc_in), .clk(not_clock), .en(1'b1), .clr(reset));
    register fetch_INSN(.out(fetch_INSN_out), .in(q_imem), .clk(not_clock), .en(1'b1), .clr(reset));
    ////////// START OF DECODE

    wire [31:0] data_readRegA, data_readRegB, data_writeReg;
    // assign inputs to regfile, output of regfile in latch
    // NOTE: write_enable is disabled currently
    regfile regfile(
        .clock(clock),
        .ctrl_writeEnable(1'b0), .ctrl_reset(reset), .ctrl_writeReg(fetch_INSN_out[26:22]),
        .ctrl_readRegA(fetch_INSN_out[21:17]), .ctrl_readRegB(fetch_INSN_out[16:12]), .data_writeReg(data_writeReg),
        .data_readRegA(data_readRegA), .data_readRegB(data_readRegB));

    ////////// END OF DECODE
    wire [31:0] decode_PC_out, decode_A_out, decode_B_out, decode_INSN_out;  
    register decode_PC(.out(decode_PC_out), .in(fetch_PC_out), .clk(not_clock), .en(1'b1), .clr(reset));
    register decode_A(.out(decode_A_out), .in(data_readRegA), .clk(not_clock), .en(1'b1), .clr(reset));
    register decode_B(.out(decode_B_out), .in(data_readRegB), .clk(not_clock), .en(1'b1), .clr(reset));
    register decode_INSN(.out(decode_INSN_out), .in(fetch_INSN_out), .clk(not_clock), .en(1'b1), .clr(reset));
    ////////// START OF EXECUTE

	/* END CODE */

endmodule
