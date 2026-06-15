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
    output [3:0] nivel,
    output [1:0] simbolo_memoria,
    output [1:0] simbolo_jogado
);
wire [1:0] simbolo_randomico;
wire [3:0] contador_exibicao;
wire [3:0] contador_entrada;
wire [3:0] endereco_leitura;
wire jogada_valida;

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