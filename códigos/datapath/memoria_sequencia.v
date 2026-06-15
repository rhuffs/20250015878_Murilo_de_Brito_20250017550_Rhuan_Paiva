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