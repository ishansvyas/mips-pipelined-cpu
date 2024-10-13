module counter6b_tb;

    reg clock, enable, dis, clr;
    wire [5:0] out;

    // Instantiate the counter6b module
    counter6b uut(
        .out(out),
        .clock(clock),
        .enable(enable),
        .dis(dis),
        .clr(clr)
    );

    // Clock generation: toggle clock every 10 time units
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Test stimulus
    initial begin
        // Initial values
        enable = 1;
        dis = 0;
        clr = 0;

        // Apply reset (clr) and verify output is zero
        clr = 1;
        #20;
        clr = 0;
        #20;

        // Enable the counter
        enable = 1;
        dis = 0;
        #400;

        // Disable the counter, it should hold its value
        enable = 0;
        dis = 1;
        #100;

        // Enable again and check counting resumes
        enable = 1;
        dis = 0;
        #100;

        // Apply reset and verify output is zero
        clr = 1;
        #20;
        clr = 0;

        // End of test
        $finish;
    end

    // Monitor the signals
    always @(posedge clock) begin
        $monitor("out: %b | enable: %b | dis: %b | clr: %b", out, enable, dis, clr);
    end

    initial begin
        $dumpfile("counter6b_waveform.vcd");
        $dumpvars(0, counter6b_tb);
    end    


endmodule
