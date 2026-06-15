module Comparar (
    input [1:0] simbolo_esperando,
    input [1:0] simbolo_jogado,
    output resultado_comparacao
);

    assign resultado_comparacao = (simbolo_esperando == simbolo_jogado);
endmodule