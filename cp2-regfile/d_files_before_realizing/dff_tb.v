`timescale 1ns / 1ps

module dff_tb();

    // Inputs
    reg data;
    reg clk;

    // Output
    wire out;

    // Instantiate the D flip-flop module
    dff uut (
        .data(data),
        .clk(clk),
        .out(out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with 10ns period
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        data = 0;

        // Wait for a few clock cycles
        #10;

        // Test case 1: Set data to 1
        data = 1;
        #10; // Wait for a clock cycle

        // Test case 2: Set data to 0
        data = 0;
        #10; // Wait for a clock cycle

        // Test case 3: Set data to 1 and hold for multiple clock cycles
        data = 1;
        #30; // Wait for three clock cycles

        // Test case 4: Set data to 0 and hold
        data = 0;
        #30;

        // End the simulation
        $finish;
    end

    always @(data,clk) begin
        #1;
        $display("D:%b, C:%b -> Q:%b", data, clk, out);
    end
    initial begin
        $dumpfile("dff_waveform.vcd");
        $dumpvars(0, dff_tb);
    end

endmodule
