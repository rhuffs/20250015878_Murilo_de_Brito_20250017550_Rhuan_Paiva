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
    localparam IDLE             = 4'd0;
    localparam GERAR            = 4'd1;
    localparam SALVAR           = 4'd2;
    localparam PREP_EXIBICAO    = 4'd3;
    localparam EXIBIR           = 4'd4;
    localparam INTERVALO        = 4'd5;
    localparam PREP_ENTRADA     = 4'd6;
    localparam ESPERA_JOGADA    = 4'd7;
    localparam COMPARAR         = 4'd8;
    localparam PROXIMA_JOGADA   = 4'd9;
    localparam VITORIA_RODADA   = 4'd10;
    localparam DERROTA          = 4'd11;
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
            VITORIA_RODADA: prox_estado = GERAR;
            DERROTA:
                if(!start) prox_estado = IDLE;
                else prox_estado = DERROTA;
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
                cont_exp_inc = 1;
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