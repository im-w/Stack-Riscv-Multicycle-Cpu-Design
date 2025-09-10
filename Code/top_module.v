module top_module(input clk, reset);

wire MemWrite, AdrSrc, PCWrite, IRWrite;
wire AWriteEnable, BWriteEnable;
wire [1:0] ALUSrcA;
wire [1:0] ALUSrcB;
wire [1:0] ResultSrc;
wire [2:0] ALUControl;
wire push, pop, tos;
wire A_or_B_stack_out_sel;
wire [2:0] op;
wire       Zero;

data_path dp (
  .clk(clk),
  .reset(reset),
  .MemWrite(MemWrite),
  .AdrSrc(AdrSrc),
  .PCWrite(PCWrite),
  .IRWrite(IRWrite),
  .ALUSrcA(ALUSrcA),
  .ALUSrcB(ALUSrcB),
  .ResultSrc(ResultSrc),
  .ALUControl(ALUControl),
  .push(push),
  .pop(pop),
  .tos(tos),
  .A_or_B_stack_out_sel(A_or_B_stack_out_sel),
  .op(op),
  .Zero(Zero),
  .AWriteEnable(AWriteEnable),
  .BWriteEnable(BWriteEnable)
);

control_unit cu (
  .clk(clk),
  .reset(reset),
  .op(op),
  .Zero(Zero),
  .MemWrite(MemWrite),
  .IRWrite(IRWrite),
  .PCWrite(PCWrite),
  .AdrSrc(AdrSrc),
  .ALUSrcA(ALUSrcA),
  .ALUSrcB(ALUSrcB),
  .ALUControl(ALUControl),
  .ResultSrc(ResultSrc),
  .push(push),
  .pop(pop),
  .tos(tos),
  .A_or_B_stack_out_sel(A_or_B_stack_out_sel),
  .AWriteEnable(AWriteEnable),
  .BWriteEnable(BWriteEnable)
);

endmodule
