module memory (
    input wire clk,
    input wire [4:0] A,
    input wire [7:0] WD,
    input wire MemWrite,
    output wire [7:0] RD
);
    reg [7:0] memory [0:31]; 
    initial begin
        $readmemb("C:\\Users\\ASUS\\Desktop\\CA_CA3\\memory.mem", memory);
    end
    assign RD = memory[A];
    
    always @(posedge clk) begin
        if (MemWrite)
            memory[A] <= WD;
    end
endmodule