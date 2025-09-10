module demux_2 #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0]  in,    
    input  wire              sel, 
    output reg  [WIDTH-1:0]  out0,  
    output reg  [WIDTH-1:0]  out1  
);

    always @(sel or in) begin
        if (sel == 1'b0) begin
            out0 = in;
            out1 = {WIDTH{1'b0}};
        end else begin
            out0 = {WIDTH{1'b0}};
            out1 = in;
        end
    end

endmodule
