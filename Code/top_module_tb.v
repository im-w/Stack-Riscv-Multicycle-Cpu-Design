`timescale 1ns/1ps

module topmodule_tb();
  reg clk   = 0;
  reg reset = 1;

  always #5 clk = ~clk;

  top_module uut (
    .clk(clk),
    .reset(reset)
  );

  initial begin
    #25;
    reset = 0;

    #2560;
    $stop;
  end

endmodule
