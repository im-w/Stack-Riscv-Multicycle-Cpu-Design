module stack (
    input  wire [7:0] d_in, 
    input  wire       push,  
    input  wire       pop,
    input  wire       tos,  
    input  wire       clk,   
    output reg  [7:0] d_out  
);

  reg [7:0] mem [0:31];
  
  reg [5:0] sp;

  initial begin
    $readmemb("C:\\Users\\ASUS\\Desktop\\CA_CA3\\stack.mem", mem);
    sp = 6'd0;
  end

  always @(sp) begin
    if (sp > 6'd0)
      d_out = mem[sp-1];
    else
      d_out = 8'd0;
  end

  always @(posedge clk) begin
    if (push && (sp < 6'd32)) begin
      mem[sp] <= d_in;
      sp      <= sp + 6'd1;
    end
    else if (pop && (sp > 6'd0)) begin
      sp <= sp - 6'd1;
    end
  end

endmodule
