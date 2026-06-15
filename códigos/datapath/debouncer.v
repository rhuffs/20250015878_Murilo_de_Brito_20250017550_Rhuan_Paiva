module debouncer (
    input clk,
    input rst,
    input botao,
    output reg clock
);
    reg [19:0] contador;
    reg estado;

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1)begin
            contador <= 1'b0;
            estado <= 1'b1;
            clock <= 1'b0;
        end else begin
            clock <= 0;

            if(botao != estado) begin
                contador <= contador + 1;

                if(contador == 20'd500000) begin
                    estado <= botao;
                    contador <= 0;
                    if(botao == 0) clock <= 1;
                end
            end

            else begin
                contador <= 0;
            end

        end
    end
endmodule