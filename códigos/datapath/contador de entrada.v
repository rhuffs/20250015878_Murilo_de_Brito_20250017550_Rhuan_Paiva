module Contador_entrada (
    input clk,
    input rst,
    input clr,
    input increment,
    input [3:0] Nivel,
    output fim_entrada,
    output reg [3:0] counter
);
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1 || clr == 1'b1) counter <= 4'b0000;
        else if(increment == 1'b1) counter <= counter + 1;        
    end
    assign fim_entrada = (counter == Nivel);
endmodule