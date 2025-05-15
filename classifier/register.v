`timescale 1ns / 1ps

module register

#(parameter DATA_WIDTH = 16) 

(
    input wire clk,
    input wire rst,
    input wire clr,
    input wire [DATA_WIDTH-1:0] d_in, 
    output reg [DATA_WIDTH-1:0] d_out 
);

    always @(posedge clk) begin
        if (!rst || clr) begin
            d_out <= 0;
        end else begin
            d_out <= d_in; 
        end
    end
endmodule