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