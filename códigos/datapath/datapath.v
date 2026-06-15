module datapath(
    input clk,
    input rst,
    input lfsr_enable,
    input mem_write,
    input nivel_inc,
    input cont_exp_inc,
    input cont_exp_clr,
    input cont_ent_inc,
    input cont_ent_clr,
    input timer_led,
    input timer_intervalo,
    input timer_timeout,
    input seletor_memoria,
    input key0,
    input key1,
    input key2,
    input key3,
    output fim_exibicao,
    output fim_entrada,
    output resultado_comparacao,
    output fim_led,
    output fim_intervalo,
    output timeout,
    output jogada_valida,
    output [3:0] nivel,
    output [1:0] simbolo_memoria,
    output [1:0] simbolo_jogado
);
wire [1:0] simbolo_randomico;
wire [3:0] contador_exibicao;
wire [3:0] contador_entrada;
wire [3:0] endereco_leitura;

assign endereco_leitura = seletor_memoria ? contador_entrada : contador_exibicao;
// LFSR
gerador_pseudoaleatorio  GP(
    .clk(clk),
    .rst(rst),
    .enable(lfsr_enable),
    .simbolo_randomico(simbolo_randomico)
);

// Registrador de nível
Registrador_nivel RN(
    .clk(clk),
    .rst(rst),
    .increment(nivel_inc),
    .Nivel(nivel)
);

// Contador de exibição
Contador_exibicao CE(
    .clk(clk),
    .rst(rst),
    .clr(cont_exp_clr),
    .increment(cont_exp_inc),
    .Nivel(nivel),
    .fim_exibicao(fim_exibicao),
    .S(contador_exibicao)
);

// Contador de entrada
Contador_entrada CI(
    .clk(clk),
    .rst(rst),
    .clr(cont_ent_clr),
    .increment(cont_ent_inc),
    .Nivel(nivel),
    .fim_entrada(fim_entrada),
    .counter(contador_entrada)
);

// Memória
Memoria_sequencial MEM(
    .clk(clk),
    .write_enable(mem_write),
    .write_addres(nivel),
    .write_data(simbolo_randomico),
    .read_addres(endereco_leitura   ),
    .read_data(simbolo_memoria)
);

// Entrada do jogador
entrada_jogador EJ(
    .key0(key0),
    .key1(key1),
    .key2(key2),
    .key3(key3),
    .simbolo_jogado(simbolo_jogado),
    .jogada_valida(jogada_valida)
);


// Comparador
Comparar CMP(
    .simbolo_esperando(simbolo_memoria),
    .simbolo_jogado(simbolo_jogado),
    .resultado_comparacao(resultado_comparacao)
);

// Temporizador
temporizador TMP(
    .clk(clk),
    .rst(rst),
    .ONLED(timer_led),
    .INTERVALO(timer_intervalo),
    .OFFLED(timer_timeout),
    .ENDLED(fim_led),
    .ENDINTERVALO(fim_intervalo),
    .ENDOFFLED(timeout)
);
endmodule