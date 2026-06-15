module genius (
    input CLOCK_50,
    input [3:0] KEY,
    input [1:0] SW,
    output [3:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX3
);
/*sinais datapath*/
    wire lfsr_enable;
    wire mem_write;
    wire nivel_inc;

    wire cont_exp_inc;
    wire cont_exp_clr;

    wire cont_ent_inc;
    wire cont_ent_clr;

    wire timer_led;
    wire timer_intervalo;
    wire timer_timeout;

    wire seletor_memoria;
/*sinais fsm*/
    wire fim_exibicao;
    wire fim_entrada;
    wire resultado_comparacao;

    wire fim_led;
    wire fim_intervalo;
    wire timeout;

    wire jogada_valida;

    wire [3:0] nivel;
    wire [1:0] simbolo_memoria;
    wire [1:0] simbolo_jogado;
/*sinais debouncer*/
    wire key0_db;
    wire key1_db;
    wire key2_db;
    wire key3_db;
    debouncer DB0(
        .clk(CLOCK_50),
        .rst(SW[1]),
        .botao(KEY[0]),
        .clock(key0_db)
    );

    debouncer DB1(
        .clk(CLOCK_50),
        .rst(SW[1]),
        .botao(KEY[1]),
        .clock(key1_db)
    );

    debouncer DB2(
        .clk(CLOCK_50),
        .rst(SW[1]),
        .botao(KEY[2]),
        .clock(key2_db)
    );

    debouncer DB3(
        .clk(CLOCK_50),
        .rst(SW[1]),
        .botao(KEY[3]),
        .clock(key3_db)
    );
    wire [3:0] estado;
//fsm
    fsm CONTROL(

        .clk(CLOCK_50),
        .rst(SW[1]),
        .start(SW[0]),

        .fim_led(fim_led),
        .fim_intervalo(fim_intervalo),
        .timeout(timeout),

        .fim_exibicao(fim_exibicao),
        .fim_entrada(fim_entrada),

        .jogada_valida(jogada_valida),
        .resultado_comparacao(resultado_comparacao),

        .nivel(nivel),

        .lfsr_enable(lfsr_enable),
        .mem_write(mem_write),

        .nivel_inc(nivel_inc),

        .cont_exp_inc(cont_exp_inc),
        .cont_exp_clr(cont_exp_clr),

        .cont_ent_inc(cont_ent_inc),
        .cont_ent_clr(cont_ent_clr),

        .timer_led(timer_led),
        .timer_intervalo(timer_intervalo),
        .timer_timeout(timer_timeout),

        .seletor_memoria(seletor_memoria),

        .estado(estado)
    );

    datapath DP(

        .clk(CLOCK_50),
        .rst(SW[1]),

        .lfsr_enable(lfsr_enable),
        .mem_write(mem_write),

        .nivel_inc(nivel_inc),

        .cont_exp_inc(cont_exp_inc),
        .cont_exp_clr(cont_exp_clr),

        .cont_ent_inc(cont_ent_inc),
        .cont_ent_clr(cont_ent_clr),

        .timer_led(timer_led),
        .timer_intervalo(timer_intervalo),
        .timer_timeout(timer_timeout),

        .seletor_memoria(seletor_memoria),

        .key0(key0_db),
        .key1(key1_db),
        .key2(key2_db),
        .key3(key3_db),

        .fim_exibicao(fim_exibicao),
        .fim_entrada(fim_entrada),

        .resultado_comparacao(resultado_comparacao),

        .fim_led(fim_led),
        .fim_intervalo(fim_intervalo),
        .timeout(timeout),

        .jogada_valida(jogada_valida),

        .nivel(nivel),

        .simbolo_memoria(simbolo_memoria),
        .simbolo_jogado(simbolo_jogado)
    );

    assign LEDR[0] = (timer_led && simbolo_memoria == 2'd0);
    assign LEDR[1] = (timer_led && simbolo_memoria == 2'd1);
    assign LEDR[2] = (timer_led && simbolo_memoria == 2'd2);
    assign LEDR[3] = (timer_led && simbolo_memoria == 2'd3);

    D7S DISPLAY_NIVEL(
        .valor(nivel),
        .hex(HEX0)
    );

    D7S DISPLAY_ESTADO(
        .valor(estado),
        .hex(HEX3)
    );
endmodule