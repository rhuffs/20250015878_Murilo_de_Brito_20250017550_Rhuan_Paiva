module Contador_exibicao (
    input clk,
    input rst,
    input clr,
    input increment,
    input [3:0] Nivel,
    output fim_exibicao,
    output reg [3:0] S
);
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1 || clr == 1'b1) S <= 4'b0000;
        else if(increment == 1'b1) S <= S + 1'b1;
    end

    assign fim_exibicao = (S == Nivel);
endmodule
