`timescale 1ns / 1ps

module nnl3
  
(
    input wire clk,
    input wire rst,
    input wire sys9x1_en,
    input wire signed [15:0] in_kiri_1,
    input wire signed [15:0] in_kiri_2,
    input wire signed [15:0] in_kiri_3,
    input wire signed [15:0] in_kiri_4,
    input wire signed [15:0] in_kiri_5,
    input wire signed [15:0] in_kiri_6,
    input wire signed [15:0] in_kiri_7,
    input wire signed [15:0] in_kiri_8,
    input wire signed [15:0] in_kiri_9,
    input wire signed [15:0] in_atas,
    input wire signed [15:0] b1 ,
    input wire signed [15:0] b2 ,
    input wire signed [15:0] b3 ,
    input wire signed [15:0] b4 ,
    input wire signed [15:0] b5 ,
    input wire signed [15:0] b6 ,
    input wire signed [15:0] b7 ,
    input wire signed [15:0] b8 ,
    input wire signed [15:0] b9 ,
    output wire signed [15:0] sys9x1_res1,
    output wire signed [15:0] sys9x1_res2,
    output wire signed [15:0] sys9x1_res3,
    output wire signed [15:0] sys9x1_res4,
    output wire signed [15:0] sys9x1_res5,
    output wire signed [15:0] sys9x1_res6,
    output wire signed [15:0] sys9x1_res7,
    output wire signed [15:0] sys9x1_res8,
    output wire signed [15:0] sys9x1_res9,
    output wire signed [15:0] res1_w,
    output wire signed [15:0] res2_w,
    output wire signed [15:0] res3_w,
    output wire signed [15:0] res4_w,
    output wire signed [15:0] res5_w,
    output wire signed [15:0] res6_w,
    output wire signed [15:0] res7_w,
    output wire signed [15:0] res8_w,
    output wire signed [15:0] res9_w,
    output wire start,
    output wire done
);

    // Main counter
    reg [3:0] cntr_sys9x1_main;

    // Signal to activate PE
    wire sys9x1_pe1_en, sys9x1_pe2_en, sys9x1_pe3_en, sys9x1_pe4_en, sys9x1_pe5_en, sys9x1_pe6_en, sys9x1_pe7_en, sys9x1_pe8_en, sys9x1_pe9_en;
    
    // Moving register 
    wire signed [15:0] out_bawah_1, out_bawah_2, out_bawah_3, out_bawah_4, out_bawah_5, out_bawah_6, out_bawah_7, out_bawah_8, out_bawah_9 ;

    // Wire to pass a (in_atas) to pe 1
    wire signed [15:0] in_atas_w0;

    // wire to pass input from register to pe
    wire signed [15:0] in_kiri_1_w0;
    wire signed [15:0] in_kiri_2_w01, in_kiri_2_w1 ;
    wire signed [15:0] in_kiri_3_w01, in_kiri_3_w12 , in_kiri_3_w2 ;
    wire signed [15:0] in_kiri_4_w01, in_kiri_4_w12 , in_kiri_4_w23 , in_kiri_4_w3 ;
    wire signed [15:0] in_kiri_5_w01, in_kiri_5_w12 , in_kiri_5_w23 , in_kiri_5_w34, in_kiri_5_w4 ;
    wire signed [15:0] in_kiri_6_w01, in_kiri_6_w12 , in_kiri_6_w23 , in_kiri_6_w34, in_kiri_6_w45, in_kiri_6_w5 ;
    wire signed [15:0] in_kiri_7_w01, in_kiri_7_w12 , in_kiri_7_w23 , in_kiri_7_w34, in_kiri_7_w45, in_kiri_7_w56, in_kiri_7_w6 ;
    wire signed [15:0] in_kiri_8_w01, in_kiri_8_w12 , in_kiri_8_w23 , in_kiri_8_w34, in_kiri_8_w45, in_kiri_8_w56, in_kiri_8_w67, in_kiri_8_w7 ;
    wire signed [15:0] in_kiri_9_w01, in_kiri_9_w12 , in_kiri_9_w23 , in_kiri_9_w34, in_kiri_9_w45, in_kiri_9_w56, in_kiri_9_w67, in_kiri_9_w78, in_kiri_9_w8 ;

    // output of register that saved bias value
    wire signed [15:0] b1_w, b2_w, b3_w, b4_w, b5_w, b6_w, b7_w, b8_w, b9_w ;

    // output register
    reg signed [15:0] res1_reg, res2_reg, res3_reg, res4_reg, res5_reg, res6_reg, res7_reg, res8_reg, res9_reg ;

    // Register to save in_atas (so the value didn't missing)
    register reg_a (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_atas), .d_out(in_atas_w0));

    // Register to saved bias value
    register reg_b1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b1), .d_out(b1_w));
    register reg_b2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b2), .d_out(b2_w));
    register reg_b3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b3), .d_out(b3_w));
    register reg_b4 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b4), .d_out(b4_w));
    register reg_b5 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b5), .d_out(b5_w));
    register reg_b6 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b6), .d_out(b6_w));
    register reg_b7 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b7), .d_out(b7_w));
    register reg_b8 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b8), .d_out(b8_w));
    register reg_b9 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(b9), .d_out(b9_w));


    // Register to saved in_kiri value
    register reg_kiri1_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_1), .d_out(in_kiri_1_w0));

    register reg_kiri2_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_2), .d_out(in_kiri_2_w01));
    register reg_kiri2_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_2_w01), .d_out(in_kiri_2_w1));

    register reg_kiri3_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_3), .d_out(in_kiri_3_w01));
    register reg_kiri3_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_3_w01), .d_out(in_kiri_3_w12));
    register reg_kiri3_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_3_w12), .d_out(in_kiri_3_w2));

    register reg_kiri4_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_4), .d_out(in_kiri_4_w01));
    register reg_kiri4_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_4_w01), .d_out(in_kiri_4_w12));
    register reg_kiri4_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_4_w12), .d_out(in_kiri_4_w23));
    register reg_kiri4_3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_4_w23), .d_out(in_kiri_4_w3));

    register reg_kiri5_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_5), .d_out(in_kiri_5_w01));
    register reg_kiri5_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_5_w01), .d_out(in_kiri_5_w12));
    register reg_kiri5_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_5_w12), .d_out(in_kiri_5_w23));
    register reg_kiri5_3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_5_w23), .d_out(in_kiri_5_w34));
    register reg_kiri5_4 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_5_w34), .d_out(in_kiri_5_w4));

    register reg_kiri6_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_6), .d_out(in_kiri_6_w01));
    register reg_kiri6_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_6_w01), .d_out(in_kiri_6_w12));
    register reg_kiri6_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_6_w12), .d_out(in_kiri_6_w23));
    register reg_kiri6_3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_6_w23), .d_out(in_kiri_6_w34));
    register reg_kiri6_4 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_6_w34), .d_out(in_kiri_6_w45));
    register reg_kiri6_5 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_6_w45), .d_out(in_kiri_6_w5));
    
    register reg_kiri7_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7), .d_out(in_kiri_7_w01));
    register reg_kiri7_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7_w01), .d_out(in_kiri_7_w12));
    register reg_kiri7_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7_w12), .d_out(in_kiri_7_w23));
    register reg_kiri7_3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7_w23), .d_out(in_kiri_7_w34));
    register reg_kiri7_4 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7_w34), .d_out(in_kiri_7_w45));
    register reg_kiri7_5 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7_w45), .d_out(in_kiri_7_w56));
    register reg_kiri7_6 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_7_w56), .d_out(in_kiri_7_w6));

    register reg_kiri8_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8), .d_out(in_kiri_8_w01));
    register reg_kiri8_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w01), .d_out(in_kiri_8_w12));
    register reg_kiri8_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w12), .d_out(in_kiri_8_w23));
    register reg_kiri8_3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w23), .d_out(in_kiri_8_w34));
    register reg_kiri8_4 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w34), .d_out(in_kiri_8_w45));
    register reg_kiri8_5 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w45), .d_out(in_kiri_8_w56));
    register reg_kiri8_6 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w56), .d_out(in_kiri_8_w67));
    register reg_kiri8_7 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_8_w67), .d_out(in_kiri_8_w7));

    register reg_kiri9_0 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9), .d_out(in_kiri_9_w01));
    register reg_kiri9_1 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w01), .d_out(in_kiri_9_w12));
    register reg_kiri9_2 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w12), .d_out(in_kiri_9_w23));
    register reg_kiri9_3 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w23), .d_out(in_kiri_9_w34));
    register reg_kiri9_4 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w34), .d_out(in_kiri_9_w45));
    register reg_kiri9_5 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w45), .d_out(in_kiri_9_w56));
    register reg_kiri9_6 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w56), .d_out(in_kiri_9_w67));
    register reg_kiri9_7 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w67), .d_out(in_kiri_9_w78));
    register reg_kiri9_8 (.clk(clk), .rst(rst), .clr(!sys9x1_en), .d_in(in_kiri_9_w78), .d_out(in_kiri_9_w8));


    // Processing unit
    systolic_pe pe_1 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe1_en),
        .in_kiri(in_kiri_1_w0),
        .in_atas(in_atas_w0),
        .out_bawah(out_bawah_1),
        .result(sys9x1_res1)
    );

    systolic_pe pe_2 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe2_en),
        .in_kiri(in_kiri_2_w1),
        .in_atas(out_bawah_1),
        .out_bawah(out_bawah_2),
        .result(sys9x1_res2)
    );

    systolic_pe pe_3 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe3_en),
        .in_kiri(in_kiri_3_w2),
        .in_atas(out_bawah_2),
        .out_bawah(out_bawah_3),
        .result(sys9x1_res3)
    );

    systolic_pe pe_4 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe4_en),
        .in_kiri(in_kiri_4_w3),
        .in_atas(out_bawah_3),
        .out_bawah(out_bawah_4),
        .result(sys9x1_res4)
    );

    systolic_pe pe_5 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe5_en),
        .in_kiri(in_kiri_5_w4),
        .in_atas(out_bawah_4),
        .out_bawah(out_bawah_5),
        .result(sys9x1_res5)
    );

    systolic_pe pe_6 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe6_en),
        .in_kiri(in_kiri_6_w5),
        .in_atas(out_bawah_5),
        .out_bawah(out_bawah_6),
        .result(sys9x1_res6)
    );

    systolic_pe pe_7 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe7_en),
        .in_kiri(in_kiri_7_w6),
        .in_atas(out_bawah_6),
        .out_bawah(out_bawah_7),
        .result(sys9x1_res7)
    );

    systolic_pe pe_8 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe8_en),
        .in_kiri(in_kiri_8_w7),
        .in_atas(out_bawah_7),
        .out_bawah(out_bawah_8),
        .result(sys9x1_res8)
    );

    systolic_pe pe_9 (
        .clk(clk),
        .rst(rst),
        .sys_pe_en(sys9x1_pe9_en),
        .in_kiri(in_kiri_9_w8),
        .in_atas(out_bawah_8),
        .out_bawah(out_bawah_9),
        .result(sys9x1_res9)
    );

    // Counter for main
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cntr_sys9x1_main <= 4'd0;  
        end else if (cntr_sys9x1_main <= 4'd13 && sys9x1_en) begin
            cntr_sys9x1_main <= cntr_sys9x1_main + 4'd1;
        end else begin
            cntr_sys9x1_main <= 4'd0;      
        end
    end
                        
    // Adding with bias
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            res1_reg <= 0 ;
            res2_reg <= 0 ;
            res3_reg <= 0 ;
            res4_reg <= 0 ;
            res5_reg <= 0 ;
            res6_reg <= 0 ;
            res7_reg <= 0 ;
            res8_reg <= 0 ;
            res9_reg <= 0 ;
        end else if (cntr_sys9x1_main == 4'd12 && sys9x1_en) begin
            res1_reg <= sys9x1_res1 + b1_w;
            res2_reg <= sys9x1_res2 + b2_w;
            res3_reg <= sys9x1_res3 + b3_w;
            res4_reg <= sys9x1_res4 + b4_w;
            res5_reg <= sys9x1_res5 + b5_w;
            res6_reg <= sys9x1_res6 + b6_w;
            res7_reg <= sys9x1_res7 + b7_w;
            res8_reg <= sys9x1_res8 + b8_w;
            res9_reg <= sys9x1_res9 + b9_w;
        end else begin
            res1_reg <= res1_reg;
            res2_reg <= res2_reg;
            res3_reg <= res3_reg;
            res4_reg <= res4_reg; 
            res5_reg <= res5_reg;
            res6_reg <= res6_reg; 
            res7_reg <= res7_reg;
            res8_reg <= res8_reg; 
            res9_reg <= res9_reg;    
        end
    end

    // Control signal to activate pe
    assign start = (cntr_sys9x1_main == 4'd1) ? 1 : 0 ;
    assign sys9x1_pe1_en = (cntr_sys9x1_main >= 4'd1 && cntr_sys9x1_main <= 4'd2) ? 1 : 0 ;
    assign sys9x1_pe2_en = (cntr_sys9x1_main >= 4'd2 && cntr_sys9x1_main <= 4'd3) ? 1 : 0 ;
    assign sys9x1_pe3_en = (cntr_sys9x1_main >= 4'd3 && cntr_sys9x1_main <= 4'd4) ? 1 : 0 ;
    assign sys9x1_pe4_en = (cntr_sys9x1_main >= 4'd4 && cntr_sys9x1_main <= 4'd5) ? 1 : 0 ;
    assign sys9x1_pe5_en = (cntr_sys9x1_main >= 4'd5 && cntr_sys9x1_main <= 4'd6) ? 1 : 0 ;
    assign sys9x1_pe6_en = (cntr_sys9x1_main >= 4'd6 && cntr_sys9x1_main <= 4'd7) ? 1 : 0 ;
    assign sys9x1_pe7_en = (cntr_sys9x1_main >= 4'd7 && cntr_sys9x1_main <= 4'd8) ? 1 : 0 ;
    assign sys9x1_pe8_en = (cntr_sys9x1_main >= 4'd8 && cntr_sys9x1_main <= 4'd9) ? 1 : 0 ;
    assign sys9x1_pe9_en = (cntr_sys9x1_main >= 4'd9 && cntr_sys9x1_main <= 4'd10) ? 1 : 0 ;
    assign done = (cntr_sys9x1_main > 4'd12) ? 1 : 0 ;
    
    // Assign result signal
    assign res1_w = res1_reg;
    assign res2_w = res2_reg;
    assign res3_w = res3_reg;
    assign res4_w = res4_reg;
    assign res5_w = res5_reg;
    assign res6_w = res6_reg;
    assign res7_w = res7_reg;
    assign res8_w = res8_reg;
    assign res9_w = res9_reg;
   
endmodule
