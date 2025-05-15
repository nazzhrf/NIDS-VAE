`timescale 1ns / 1ps

module nnl2
  
(
    input wire clk,
    input wire rst,
    input wire sys2x1_en,
    input wire signed [15:0] in_kiri_1,
    input wire signed [15:0] in_kiri_2,
    input wire signed [15:0] in_atas,
    input wire signed [15:0] b1 ,
    input wire signed [15:0] b2 ,
    output wire signed [15:0] sys2x1_res1,
    output wire signed [15:0] sys2x1_res2,
    output wire signed [15:0] res1_w,
    output wire signed [15:0] res2_w
);

    // Main counter
    reg [3:0] cntr_sys2x1_main;

    // Signal to activate PE
    wire sys2x1_pe1_en, sys2x1_pe2_en;
    
    // Wire to pass input x (in_atas) to pe 1
    wire signed [15:0] in_atas_w0;
    
    // wire to pass input weight from register to pe 
    wire signed [15:0] in_kiri_1_w0;
    wire signed [15:0] in_kiri_2_w01, in_kiri_2_w1 ;

    // output of register that saved bias value
    wire signed [15:0] b1_w, b2_w;

    // output register
    reg signed [15:0] res1_reg, res2_reg ;

    // Moving register 
    wire signed [15:0] out_bawah_1, out_bawah_2;
    
    register reg_atas (
        .clk(clk),
        .rst(rst),
        .clr(!sys2x1_en),
        .d_in(in_atas),
        .d_out(in_atas_w0)
    );

    register reg_kiri1_0 (
        .clk(clk),
        .rst(rst),
        .clr(!sys2x1_en),
        .d_in(in_kiri_1),
        .d_out(in_kiri_1_w0)
    );

    register reg_kiri2_0 (
        .clk(clk),
        .rst(rst),
        .clr(!sys2x1_en),
        .d_in(in_kiri_2),
        .d_out(in_kiri_2_w01)
    );
    
    register reg_kiri2_1 (
        .clk(clk),
        .rst(rst),
        .clr(!sys2x1_en),
        .d_in(in_kiri_2_w01),
        .d_out(in_kiri_2_w1)
    );
    
    register reg_bias_1 (
        .clk(clk),
        .rst(rst),
        .clr(!sys2x1_en),
        .d_in(b1),
        .d_out(b1_w)
    );
    
    register reg_bias_2 (
        .clk(clk),
        .rst(rst),
        .clr(!sys2x1_en),
        .d_in(b2),
        .d_out(b2_w)
    );

    systolic_pe pe_1 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys2x1_pe1_en),
        .in_kiri(in_kiri_1_w0),
        .in_atas(in_atas_w0),
        .out_bawah(out_bawah_1),
        .result(sys2x1_res1)
    );

    systolic_pe pe_2 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys2x1_pe2_en),
        .in_kiri(in_kiri_2_w1),
        .in_atas(out_bawah_1),
        .out_bawah(out_bawah_2),
        .result(sys2x1_res2)
    );

    // Counter for main
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cntr_sys2x1_main <= 4'd0;  
        end else if (cntr_sys2x1_main <= 4'd12 && sys2x1_en) begin
            cntr_sys2x1_main <= cntr_sys2x1_main + 4'd1;
        end else begin
            cntr_sys2x1_main <= 4'd0;      
        end
    end
                        
    // Adding with bias
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            res1_reg <= 0;
            res2_reg <= 0;
        end else if (cntr_sys2x1_main == 4'd11 && sys2x1_en) begin
            res1_reg <= sys2x1_res1 + b1_w;
            res2_reg <= sys2x1_res2 + b2_w;
        end else begin
            res1_reg <= res1_reg;
            res2_reg <= res2_reg;     
        end
    end

    assign sys2x1_pe1_en = (cntr_sys2x1_main >= 4'd1 && cntr_sys2x1_main <= 4'd9) ? 1 : 0 ;
    assign sys2x1_pe2_en = (cntr_sys2x1_main >= 4'd2 && cntr_sys2x1_main <= 4'd10) ? 1 : 0 ;
    assign res1_w = res1_reg;
    assign res2_w = res2_reg;
   
endmodule


