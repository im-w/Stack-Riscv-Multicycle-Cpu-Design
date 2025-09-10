module alu (A, B, ALUControl, ALUResult, Zero);
    input [7:0] A, B;
    input [1:0] ALUControl;
    output reg [7:0] ALUResult;
    output  Zero;
    always @(ALUControl or A or B) begin
        case (ALUControl)
            2'b00: ALUResult = A + B;              
            2'b01: ALUResult = A - B;              
            2'b10: ALUResult = A & B;              
            2'b11: ALUResult = ~A;
            default: ALUResult = 0;
        endcase
    end
    assign Zero = (~|ALUResult);
endmodule
