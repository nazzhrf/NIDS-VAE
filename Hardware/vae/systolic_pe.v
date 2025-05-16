`timescale 1ns / 1ps

module systolic_pe

(
    input wire clk,
    input wire rst,
	input wire sys_pe_en,
    input wire signed [15:0] in_kiri, 
    input wire signed [15:0] in_atas, 
    output wire signed [15:0] out_bawah,
    output wire signed [15:0] result
);
	
	wire signed [31:0] mult_temp ;
	reg signed [15:0] result_reg ;
	reg signed [15:0] out_bawah_reg ;


	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			result_reg <= 0;
			out_bawah_reg <= 0;
		end else if (sys_pe_en) begin
			result_reg <= result_reg + mult_temp[25:10];
			out_bawah_reg <= in_atas;
		end else begin
			result_reg <= result_reg;
			out_bawah_reg <= out_bawah_reg;
		end
	end

	assign mult_temp = in_kiri*in_atas;
	assign result = result_reg ;
	assign out_bawah = out_bawah_reg ;

endmodule