module Registrador_nivel (
    input clk,
    input rst,
    input increment,
    output reg [3:0] Nivel
);
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) Nivel <= 4'b0000;
        else if(increment == 1'b1) Nivel <= Nivel + 1;        
    end
endmodule