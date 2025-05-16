`timescale 1ns / 1ps

module nn_classifier
  
(
    input wire clk,
    input wire rst,
    input wire nn_classifier_en,
    input wire signed [15:0] in_kiri_1,
    input wire signed [15:0] in_atas,
    input wire signed [15:0] b1,
    output wire signed [15:0] sys2x1_res1,
    output wire signed [15:0] res1_w
);

    // Main counter
    reg [3:0] cntr_sys2x1_main;

    // Signal to activate PE
    wire sys2x1_pe1_en;
    
    // Wire to pass input x (in_atas) to pe 1
    wire signed [15:0] in_atas_w0;
    
    // wire to pass input weight from register to pe 
    wire signed [15:0] in_kiri_1_w0;

    // output of register that saved bias value
    wire signed [15:0] b1_w ;

    // output register
    reg signed [15:0] res1_reg ;

    // Moving register 
    wire signed [15:0] out_bawah_1 ;
    
    register reg_atas (
        .clk(clk),
        .rst(rst),
        .clr(!nn_classifier_en),
        .d_in(in_atas),
        .d_out(in_atas_w0)
    );

    register reg_kiri1_0 (
        .clk(clk),
        .rst(rst),
        .clr(!nn_classifier_en),
        .d_in(in_kiri_1),
        .d_out(in_kiri_1_w0)
    );
    
    register reg_bias_1 (
        .clk(clk),
        .rst(rst),
        .clr(!nn_classifier_en),
        .d_in(b1),
        .d_out(b1_w)
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

    // Counter for main
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cntr_sys2x1_main <= 4'd0;  
        end else if (cntr_sys2x1_main <= 4'd12 && nn_classifier_en) begin
            cntr_sys2x1_main <= cntr_sys2x1_main + 4'd1;
        end else begin
            cntr_sys2x1_main <= 4'd0;      
        end
    end
                        
    // Adding with bias
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            res1_reg <= 0;
        end else if (cntr_sys2x1_main == 4'd11 && nn_classifier_en) begin
            res1_reg <= sys2x1_res1 + b1_w;
        end else begin
            res1_reg <= res1_reg;  
        end
    end

    assign sys2x1_pe1_en = (cntr_sys2x1_main >= 4'd1 && cntr_sys2x1_main <= 4'd9) ? 1 : 0 ;
    assign res1_w = res1_reg;
   
endmodule


