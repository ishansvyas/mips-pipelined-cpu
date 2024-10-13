`timescale 1 ns / 100 ps
module counter5b_tb();
    //inputs to the counter
  reg clock;
  reg enable;
  reg clr;
  
  // Output of the counter
  wire [4:0] out;
  
  // Instantiate the counter module
  counter5b uut (
    .clock(clock),
    .enable(enable),
    .out(out),
    .clr(clr)
  );
  
  // Clock generation
  initial begin
    clock = 0;
    enable = 1;
    clr = 0;
    #160;
    clr = 1;
    #160;
    $finish;
  end
  always begin 
    #5 clock = ~clock;
  end
  
  // Display the output during simulation
  always @(posedge clock) begin
    if (enable) begin
      $display("out:%d", out);
    end
  end
      initial begin
        $dumpfile("counter5b_waveform.vcd");
        $dumpvars(0, counter5b_tb);
    end    
endmodule