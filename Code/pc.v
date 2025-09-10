module pc (
    input clk, reset, PCWrite,
    input [4:0] PCNext,
    output reg [4:0] PC
);

always @(posedge clk or posedge reset) begin
    if (reset)
        PC <= 5'b0;
    else if (PCWrite)
        PC <= PCNext;
end

endmodule