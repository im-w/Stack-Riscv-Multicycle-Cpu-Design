module data_path (
    // ———————————————————————————————————————————
    // IO
    // ———————————————————————————————————————————
    input clk, reset,
    input MemWrite, AdrSrc, PCWrite, IRWrite, AWriteEnable, BWriteEnable,
    input [1:0] ALUSrcA, ALUSrcB,
    input [1:0] ResultSrc,
    input [1:0] ALUControl,
    input push, pop, tos,
    input A_or_B_stack_out_sel,
    output [2:0] op,
    output Zero
    );

    // ———————————————————————————————————————————
    // PC register
    // ———————————————————————————————————————————
    wire [4:0] PC;
    wire [7:0] Result;
    pc pc_inst (
        .clk    (clk),
        .reset  (reset),
        .PCNext (Result[4:0]),
        .PC     (PC),
        .PCWrite (PCWrite)
    );

    // ———————————————————————————————————————————
    // adr mux
    // ———————————————————————————————————————————
    wire [4:0] memory_adr;
    mux_2 #(5) adr_mux (
        .in0    (PC),
        .in1  (Result[4:0]),
        .sel (AdrSrc),
        .out     (memory_adr)
    );
    
    // ———————————————————————————————————————————
    // Instruction memory
    // ———————————————————————————————————————————
    wire [7:0] ReadData;
    wire [7:0] B;
    memory memory_inst (
        .A  (memory_adr),
        .RD (ReadData),
        .WD (B),
        .MemWrite (MemWrite),
        .clk(clk)
    );

    // ———————————————————————————————————————————
    // OldPc and Instr reg
    // ———————————————————————————————————————————
    wire [4:0] oldPc;
    reg_with_en #(5) old_pc_reg  (
        .clk    (clk),
        .reset  (reset),
        .d (PC),
        .q     (oldPc),
        .en (IRWrite)
    );

    wire [7:0] Instr;
    wire [4:0] adr;
    assign op = Instr[7:5];
    assign adr = Instr[4:0];
    reg_with_en #(8) instr_reg  (
        .clk    (clk),
        .reset  (reset),
        .d (ReadData),
        .q     (Instr),
        .en (IRWrite)
    );
    


    // ———————————————————————————————————————————
    // Stack
    // ———————————————————————————————————————————
    wire [7:0] d_out;
    stack stack_inst (
        .d_in(Result),
        .d_out(d_out),
        .push(push),
        .pop(pop),
        .tos(tos),
        .clk(clk)
    );
    
    // ———————————————————————————————————————————
    // Stack d_out demux
    // ———————————————————————————————————————————
    wire [7:0] before_reg_A, before_reg_B;
    demux_2 #(8) stack_d_out_demux (
        .in    (d_out),
        .sel (A_or_B_stack_out_sel),
        .out0     (before_reg_A),
        .out1     (before_reg_B)
    );



    // ———————————————————————————————————————————
    // A and B reg
    // ———————————————————————————————————————————
    wire [7:0] A;
    reg_with_en #(8) A_reg  (
        .clk    (clk),
        .reset  (reset),
        .d (before_reg_A),
        .q     (A),
        .en (AWriteEnable)
    );

    reg_with_en #(8) B_reg  (
        .clk    (clk),
        .reset  (reset),
        .d (before_reg_B),
        .q     (B),
        .en (BWriteEnable)
    );

    // ———————————————————————————————————————————
    // srcA mux
    // ———————————————————————————————————————————
    wire [7:0]  SrcA ,SrcB, ALUResult;
    mux_4 #(8) srcA_mux (
        .in0    ({3'b000, PC}),
        .in1  ({3'b000, oldPc}),
        .in2  (A),
        .in3  (8'd0),
        .sel (ALUSrcA),
        .out     (SrcA)
    );
    // ———————————————————————————————————————————
    // srcB mux
    // ———————————————————————————————————————————
    mux_4 #(8) srcB_mux (
        .in0    (B),
        .in1  ({3'b000, adr}),
        .in2  (8'd1),
        .in3  (8'd0),
        .sel (ALUSrcB),
        .out     (SrcB)
    );
    
    // ———————————————————————————————————————————
    // ALU
    // ———————————————————————————————————————————
    alu alu_inst (
        .A          (SrcA),
        .B          (SrcB),
        .ALUControl (ALUControl),
        .ALUResult  (ALUResult),
        .Zero       (Zero)
    );

    // ———————————————————————————————————————————
    // ALUOut reg
    // ———————————————————————————————————————————
    wire [7:0] AluOut;
    reg_without_en #(8) alu_reg  (
        .clk    (clk),
        .reset  (reset),
        .d (ALUResult),
        .q     (AluOut)
    );

    // ———————————————————————————————————————————
    // Data reg
    // ———————————————————————————————————————————
    wire [7:0] Data;
    reg_without_en #(8) data_reg  (
        .clk    (clk),
        .reset  (reset),
        .d (ReadData),
        .q     (Data)
    );

    // ———————————————————————————————————————————
    // Result mux
    // ———————————————————————————————————————————
    mux_4 #(8) result_mux (
        .in0    (AluOut),
        .in1    (Data),
        .in2    (ALUResult),
        .in3    ({3'b000, adr}),
        .sel (ResultSrc),
        .out (Result)
    );

    
    
endmodule
