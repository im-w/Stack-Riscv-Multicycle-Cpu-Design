module mux_2 #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] in0,    
    input  wire [WIDTH-1:0] in1,  
    input  wire              sel, 
    output reg  [WIDTH-1:0]  out   
);

    always @(sel or in0 or in1) begin
        out = sel ? in1 : in0;
    end

endmodule