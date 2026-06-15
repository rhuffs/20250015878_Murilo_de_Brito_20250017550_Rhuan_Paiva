module entrada_jogador(
    input key0,
    input key1,
    input key2,
    input key3,
    output reg [1:0] simbolo_jogado,
    output reg jogada_valida
);

always @(*) begin
    jogada_valida = 1'b1;
    if(key0)
        simbolo_jogado = 2'd0;
    else if(key1)
        simbolo_jogado = 2'd1;
    else if(key2)
        simbolo_jogado = 2'd2;
    else if(key3)
        simbolo_jogado = 2'd3;
    else begin
        simbolo_jogado = 2'd0;
        jogada_valida = 1'b0;
    end
end
endmodule