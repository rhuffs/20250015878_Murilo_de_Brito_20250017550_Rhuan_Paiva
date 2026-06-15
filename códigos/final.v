module gerador_pseudoaleatorio (
    input clk,
    input rst,
    input enable,
    output [1:0] simbolo_randomico
);
    reg [3:0] LFSR;
    wire msb;
    assign msb = LFSR[3] ^ LFSR[2];

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) LFSR <= 4'b0001;
        else if(enable == 1'b1) LFSR <= {LFSR[2:0], msb};
    end
    assign simbolo_randomico = LFSR[1:0];
endmodule

module Memoria_sequencial (
    input clk,  
    input write_enable,
    input [3:0]write_addres,
    input [1:0]write_data,
    input [3:0]read_addres,
    output [1:0]read_data
);
    reg [1:0] memoria [15:0];
    always @(posedge clk) begin
        if(write_enable == 1'b1) memoria[write_addres] <= write_data;
    end
    assign read_data = memoria[read_addres];
endmodule

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

module Comparar (
    input [1:0] simbolo_esperando,
    input [1:0] simbolo_jogado,
    output resultado_comparacao
);

    assign resultado_comparacao = (simbolo_esperando == simbolo_jogado);
endmodule

module temporizador(

    input clk,
    input rst,

    input ONLED,
    input INTERVALO,
    input OFFLED,

    output reg ENDLED,
    output reg ENDINTERVALO,
    output reg ENDOFFLED

);

    reg [31:0] contador;

    localparam TEMPO_LED = 25_000_000;      
    localparam TEMPO_GAP = 10_000_000;      
    localparam TEMPO_MAX = 3_000_000_000;   
    always @(posedge clk or posedge rst) begin

        if(rst) begin
            contador <= 0;
            ENDLED <= 0;
            ENDINTERVALO <= 0;
            ENDOFFLED <= 0;
        end

        else begin
            ENDLED <= 0;
            ENDINTERVALO <= 0;
            if(ONLED == 1'b1) begin
                if(contador >= TEMPO_LED) begin
                    ENDLED <= 1;
                    contador <= 0;
                end
                else
                    contador <= contador + 1;
            end 
            else if(INTERVALO == 1'b1) begin
                if(contador >= TEMPO_GAP) begin
                    ENDINTERVALO <= 1;
                    contador <= 0;
                end
                else
                    contador <= contador + 1;
            end 
            else if(OFFLED == 1'b1) begin
                if(contador >= TEMPO_MAX) begin
                    ENDOFFLED <= 1;
                end
                else
                    contador <= contador + 1;
            end
            else begin
                contador <= 0;
                ENDOFFLED <= 0;
            end
        end
    end
endmodule

module D7S(
    input [3:0] valor,
    output reg [6:0] hex
);
    always @(*) begin
        case(valor)
            4'h0: hex = 7'b1000000;
            4'h1: hex = 7'b1111001;
            4'h2: hex = 7'b0100100;
            4'h3: hex = 7'b0110000;
            4'h4: hex = 7'b0011001;
            4'h5: hex = 7'b0010010;
            4'h6: hex = 7'b0000010;
            4'h7: hex = 7'b1111000;
            4'h8: hex = 7'b0000000;
            4'h9: hex = 7'b0010000;
            4'hA: hex = 7'b0001000;
            4'hB: hex = 7'b0000011;
            4'hC: hex = 7'b1000110;
            4'hD: hex = 7'b0100001;
            4'hE: hex = 7'b0000110;
            4'hF: hex = 7'b0001110;
        endcase
    end
endmodule

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

module fsm(
    input clk,
    input rst,
    input start,
    input fim_led,
    input fim_intervalo,
    input timeout,
    input fim_exibicao,
    input fim_entrada,
    input jogada_valida,
    input resultado_comparacao,
    input [3:0] nivel,
    output reg lfsr_enable,
    output reg mem_write,
    output reg nivel_inc,
    output reg cont_exp_inc,
    output reg cont_exp_clr,
    output reg cont_ent_inc,
    output reg cont_ent_clr,
    output reg timer_led,
    output reg timer_intervalo,
    output reg timer_timeout,
    output reg seletor_memoria,
    output reg [3:0] estado
);
    localparam IDLE = 4'd0;
    localparam GERAR = 4'd1;
    localparam SALVAR = 4'd2;
    localparam PREP_EXIBICAO = 4'd3;
    localparam EXIBIR = 4'd4;
    localparam INTERVALO = 4'd5;
    localparam PREP_ENTRADA = 4'd6;
    localparam ESPERA_JOGADA = 4'd7;
    localparam COMPARAR = 4'd8;
    localparam PROXIMA_JOGADA = 4'd9;
    localparam VITORIA_RODADA = 4'd10;
    localparam DERROTA = 4'd11;
    localparam WIN = 4'd12;

    reg [3:0] prox_estado;

    always @(posedge clk or posedge rst)
    begin
        if(rst) estado <= IDLE;
        else estado <= prox_estado;
    end
    always @(*)
    begin

        case(estado)

            IDLE:
                if(start) prox_estado = GERAR;
                else prox_estado = IDLE;
            GERAR: prox_estado = SALVAR;
            SALVAR: prox_estado = PREP_EXIBICAO;
            PREP_EXIBICAO: prox_estado = EXIBIR;
            EXIBIR:
                if(fim_led) prox_estado = INTERVALO;
                else prox_estado = EXIBIR;
            INTERVALO:
                if(fim_intervalo)
                begin
                    if(fim_exibicao) prox_estado = PREP_ENTRADA;
                    else prox_estado = EXIBIR;
                end
                else prox_estado = INTERVALO;
            PREP_ENTRADA:
                prox_estado = ESPERA_JOGADA;
            ESPERA_JOGADA:
                if(timeout) prox_estado = DERROTA;
                else if(jogada_valida) prox_estado = COMPARAR;
                else prox_estado = ESPERA_JOGADA;
            COMPARAR:
                if(resultado_comparacao) prox_estado = PROXIMA_JOGADA;
                else prox_estado = DERROTA;
            PROXIMA_JOGADA:
            begin
                if(fim_entrada) prox_estado = VITORIA_RODADA;
                else prox_estado = ESPERA_JOGADA;
            end
            VITORIA_RODADA:begin
                if(nivel == 4'd15) prox_estado = WIN;
                else prox_estado = GERAR;
            end
            DERROTA: begin
                if(!start) prox_estado = IDLE;
                else prox_estado = DERROTA;
            end
            WIN: begin
                if(!start) prox_estado = IDLE;
                else prox_estado = WIN;
            end
            default: prox_estado = IDLE;
        endcase
    end

    always @(*)
    begin

        lfsr_enable = 0;
        mem_write = 0;

        nivel_inc = 0;

        cont_exp_inc = 0;
        cont_exp_clr = 0;
        cont_ent_inc = 0;
        cont_ent_clr = 0;

        timer_led = 0;
        timer_intervalo = 0;
        timer_timeout = 0;

        seletor_memoria = 0;

        case(estado)
            GERAR: lfsr_enable = 1;
            SALVAR: mem_write = 1;
            PREP_EXIBICAO: cont_exp_clr = 1;
            EXIBIR: timer_led = 1;
            INTERVALO: begin
                timer_intervalo = 1;
                if(fim_intervalo) cont_exp_inc = 1;
            end
            PREP_ENTRADA: cont_ent_clr = 1;
            ESPERA_JOGADA:
            begin
                timer_timeout = 1;
                seletor_memoria = 1;
            end
            COMPARAR: seletor_memoria = 1;

            PROXIMA_JOGADA:
            begin
                seletor_memoria = 1;
                cont_ent_inc = 1;
            end

            VITORIA_RODADA:
                nivel_inc = 1;

        endcase

    end
endmodule

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

/*datapath*/
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