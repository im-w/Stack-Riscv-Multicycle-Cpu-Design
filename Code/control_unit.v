module control_unit(
    input         clk,
    input         reset,
    input  [2:0]  op,
    input         Zero,
    output reg    MemWrite,
    output reg    IRWrite,
    output reg    PCWrite,
    output reg    AdrSrc,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ALUControl,
    output reg [1:0] ResultSrc,
    output reg    push,
    output reg    pop,
    output reg    tos,
    output reg    A_or_B_stack_out_sel,
    output reg    AWriteEnable,
    output reg    BWriteEnable
);

  // State encoding
  localparam 
    FETCH1      = 5'd0,
    FETCH2      = 5'd1,
    DECODE      = 5'd2,
    R_POP1      = 5'd3,
    R_POP2      = 5'd4,
    R_EXEC      = 5'd5,
    R_PUSH      = 5'd6,
    P_ADDR      = 5'd7,
    P_PUSH      = 5'd8,
    L_POP       = 5'd9,
    L_ADDR      = 5'd10,
    JMP_ADDR    = 5'd11,
    JZ_TOS      = 5'd12,
    JZ_TEST     = 5'd13,
    RN_POP1     = 5'd14,
    RESET_STATE = 5'd15;

  reg [3:0] state, next_state;

  //────────────────────────────────────────────────────
  // 1. State Register
  //────────────────────────────────────────────────────
  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= RESET_STATE;
    else
      state <= next_state;
  end

  //────────────────────────────────────────────────────
  // 2. Output Logic (Moore-style: based on state only)
  //────────────────────────────────────────────────────
  always @(state or op) begin
    { MemWrite, IRWrite, PCWrite, AdrSrc,
      ALUSrcA, ALUSrcB, ALUControl, ResultSrc,
      push, pop, tos, A_or_B_stack_out_sel, AWriteEnable, BWriteEnable } = 0;

    case (state)
      //────────────────────────────────────────────
      // RESET_STATE: idle state during reset
      //────────────────────────────────────────────
      RESET_STATE: begin
      end

      //────────────────────────────────────────────
      // FETCH1: PC ← ALUOut (which contains PC+1)
      //────────────────────────────────────────────
      FETCH1: begin
        AdrSrc     = 0;
        ALUSrcA    = 2'b00;
        ALUSrcB    = 2'b10;
        ALUControl = 2'b00;
      end

      //────────────────────────────────────────────
      // FETCH2: PC ← compute PC+1 into ALUOut
      //────────────────────────────────────────────
      FETCH2: begin
        IRWrite    = 1;
        PCWrite    = 1;
        ResultSrc  = 2'b00;
      end

      //────────────────────────────────────────────
      // DECODE: wait to controller get op code
      //────────────────────────────────────────────
      DECODE: begin
      end

      //────────────────────────────────────────────
      // R‐type instructions
      //────────────────────────────────────────────
      R_POP1: begin
        pop                   = 1;
        A_or_B_stack_out_sel  = 0;
        AWriteEnable = 1;
      end
      R_POP2: begin
        pop                   = 1;
        A_or_B_stack_out_sel  = 1;
        BWriteEnable = 1;
      end
      R_EXEC: begin
        ALUSrcA    = 2'b10;
        ALUSrcB    = 2'b00;
        case (op)
          3'b000: ALUControl = 2'b00;
          3'b001: ALUControl = 2'b01;
          3'b010: ALUControl = 2'b10;
          3'b011: ALUControl = 2'b11;
        endcase
      end
      R_PUSH: begin
        ResultSrc  = 2'b00;
        push = 1;
      end

      //────────────────────────────────────────────
      // NR‐type (R‐type instructions for NOT)
      //────────────────────────────────────────────
      RN_POP1: begin
        pop                   = 1;
        A_or_B_stack_out_sel  = 0;
        AWriteEnable = 1;
      end

      //────────────────────────────────────────────
      // PUSH <Imm>
      //────────────────────────────────────────────
      P_ADDR: begin
        ResultSrc  = 2'b11;
        AdrSrc     = 1;
      end
      P_PUSH: begin
        ResultSrc  = 2'b01;
        push       = 1;
      end

      //────────────────────────────────────────────
      // POP <Imm>
      //────────────────────────────────────────────
      L_POP: begin
        pop                  = 1;
        A_or_B_stack_out_sel = 1;
        BWriteEnable = 1;
      end
      L_ADDR: begin
        ResultSrc  = 2'b11;
        AdrSrc     = 1;
        MemWrite =1;
      end

      //────────────────────────────────────────────
      // JMP <Imm>
      //────────────────────────────────────────────
      JMP_ADDR: begin
        ResultSrc  = 2'b11;
        PCWrite  = 1;
      end

      //────────────────────────────────────────────
      // JZ <Imm>
      //────────────────────────────────────────────
      JZ_TOS: begin
        tos                  = 1;
        A_or_B_stack_out_sel = 1;
        BWriteEnable = 1;
      end
      JZ_TEST: begin
        ALUSrcA    = 2'b11;
        ALUSrcB    = 2'b00;
        ALUControl = 2'b00;
      end
    endcase
  end

  //────────────────────────────────────────────────────
  // 3. Next-State Logic
  //────────────────────────────────────────────────────
  always @(state or op or Zero) begin
    next_state = FETCH1;

    case (state)
      RESET_STATE: next_state = FETCH1;

      FETCH1:     next_state = FETCH2;

      FETCH2:     next_state = DECODE;

      DECODE: begin
        case (op)
          3'b000, 3'b001, 3'b010: next_state = R_POP1;
          3'b011: next_state = RN_POP1;
          3'b100: next_state = P_ADDR;
          3'b101: next_state = L_POP;
          3'b110: next_state = JMP_ADDR;
          3'b111: next_state = JZ_TOS;
          default: next_state = FETCH1;
        endcase
      end

      R_POP1:    next_state = R_POP2;
      R_POP2:    next_state = R_EXEC;
      R_EXEC:    next_state = R_PUSH;
      R_PUSH:    next_state = FETCH1;
      RN_POP1:    next_state = R_EXEC;

      P_ADDR:    next_state = P_PUSH;
      P_PUSH:    next_state = FETCH1;

      L_POP:     next_state = L_ADDR;
      L_ADDR:    next_state = FETCH1;

      JMP_ADDR:  next_state = FETCH1;

      JZ_TOS:    next_state = JZ_TEST;
      JZ_TEST:   next_state = Zero ? JMP_ADDR : FETCH1;

      default:   next_state = FETCH1;
    endcase
  end

endmodule
