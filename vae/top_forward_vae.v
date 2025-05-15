`timescale 1ns/1ps

module top_forward_vae 

#(parameter DATA_WIDTH = 16) 

(
    input wire clk,
    input wire rst,
    input wire start,
    input wire clr,
    input wire signed [DATA_WIDTH-1:0] xj ,
    input wire signed [DATA_WIDTH-1:0] nnl2_mean_w1j, nnl2_mean_w2j, nnl2_mean_b1, nnl2_mean_b2,
    input wire signed [DATA_WIDTH-1:0] nnl2_var_w1j, nnl2_var_w2j, nnl2_var_b1, nnl2_var_b2,
    input wire signed [DATA_WIDTH-1:0] nnl3_w1i, nnl3_w2i, nnl3_w3i, nnl3_w4i, nnl3_w5i, nnl3_w6i, nnl3_w7i, nnl3_w8i, nnl3_w9i,
    input wire signed [DATA_WIDTH-1:0] nnl3_b1, nnl3_b2, nnl3_b3, nnl3_b4, nnl3_b5, nnl3_b6, nnl3_b7, nnl3_b8, nnl3_b9,
    output wire signed [DATA_WIDTH-1:0] sys2x1_mean_res1, sys2x1_mean_res2 , z1_mean, z2_mean,
    output wire signed [DATA_WIDTH-1:0] sys2x1_var_res1, sys2x1_var_res2 , z1_var, z2_var,
    output wire signed [DATA_WIDTH-1:0] sys9x1_res1, sys9x1_res2 , sys9x1_res3, sys9x1_res4, sys9x1_res5, sys9x1_res6, sys9x1_res7, sys9x1_res8, sys9x1_res9,
    output wire signed [DATA_WIDTH-1:0] a3_1, a3_2, a3_3, a3_4, a3_5, a3_6, a3_7, a3_8, a3_9,
    output wire done
);
    // Control signal to activate each submodule
    wire nnl2_en, nnl3_en, softplus_en, sqrt_en, sigmoid_en, gauss_en ;

    // Register for main counter
    reg [6:0] cntr_main ;

    // Register
    wire signed [DATA_WIDTH-1:0] random_number_1, random_number_2 ;
    wire signed [(2*DATA_WIDTH)-1:0] dot1_w, dot2_w ;
    reg signed [(2*DATA_WIDTH)-1:0] dot1, dot2 ;
    
    // Output of layer 2
    wire signed [DATA_WIDTH-1:0] a1_mean, a2_mean, a1_var, a2_var ;
    wire signed [DATA_WIDTH-1:0] sqrt_a1var, sqrt_a2var;
    wire signed [DATA_WIDTH-1:0] a2_1, a2_2, a2;
    reg signed [DATA_WIDTH-1:0] a2_1_reg, a2_2_reg, a2_reg;
    // reg signed [DATA_WIDTH-1:0] z1_mean_reg, z2_mean_reg, z1_var_reg, z2_var_reg;
    // reg signed [DATA_WIDTH-1:0] a1_mean_reg, a2_mean_reg, a1_var_reg, a2_var_reg;
    // reg signed [DATA_WIDTH-1:0] sqrt_a1var_reg, sqrt_a2var_reg;

    // Output of layer 3
    // reg signed [DATA_WIDTH-1:0] z3_1_reg, z3_2_reg, z3_3_reg, z3_4_reg, z3_5_reg, z3_6_reg, z3_7_reg, z3_8_reg, z3_9_reg ;
    wire signed [DATA_WIDTH-1:0] z3_1, z3_2, z3_3, z3_4, z3_5, z3_6, z3_7, z3_8, z3_9 ;



    // Random number generator
    gaussian_lfsr_1 gauss1(.clk(clk), .rst(rst), .gauss_en(gauss_en), .random_number(random_number_1));
    gaussian_lfsr_2 gauss2(.clk(clk), .rst(rst), .gauss_en(gauss_en), .random_number(random_number_2));

    // --- LAYER 2 --- //
    nnl2 nnl2_mean(
        .clk(clk),
        .rst(rst),
        .sys2x1_en(nnl2_en),
        .in_kiri_1(nnl2_mean_w1j),
        .in_kiri_2(nnl2_mean_w2j),
        .in_atas(xj),
        .b1(nnl2_mean_b1),
        .b2(nnl2_mean_b2),
        .sys2x1_res1(sys2x1_mean_res1),
        .sys2x1_res2(sys2x1_mean_res2),
        .res1_w(z1_mean),
        .res2_w(z2_mean)
    );

    nnl2 nnl2_var(
        .clk(clk),
        .rst(rst),
        .sys2x1_en(nnl2_en),
        .in_kiri_1(nnl2_var_w1j),
        .in_kiri_2(nnl2_var_w2j),
        .in_atas(xj),
        .b1(nnl2_var_b1),
        .b2(nnl2_var_b2),
        .sys2x1_res1(sys2x1_var_res1),
        .sys2x1_res2(sys2x1_var_res2),
        .res1_w(z1_var),
        .res2_w(z2_var)
    );
    
    register reg_z1_mean(.clk(clk), .rst(rst), .clr(), .d_in(z1_mean), .d_out(a1_mean));
    register reg_z2_mean(.clk(clk), .rst(rst), .clr(), .d_in(z2_mean), .d_out(a2_mean));

    softplus10slices softplus1 (.clk(clk), .rst(rst), .softplus_en(softplus_en), .x(z1_var), .y(a1_var));
    softplus10slices softplus2 (.clk(clk), .rst(rst), .softplus_en(softplus_en), .x(z2_var), .y(a2_var));

    sqrt16slices sqrt1 (.clk(clk), .rst(rst), .sqrt_en(sqrt_en), .x(a1_var), .y(sqrt_a1var));  
    sqrt16slices sqrt2 (.clk(clk), .rst(rst), .sqrt_en(sqrt_en), .x(a2_var), .y(sqrt_a2var)); 

    // --- LAYER 3 --- //
    nnl3 nnl3 (
        .clk(clk),
        .rst(rst),
        .sys9x1_en(nnl3_en),
        .in_kiri_1(nnl3_w1i),
        .in_kiri_2(nnl3_w2i),
        .in_kiri_3(nnl3_w3i),
        .in_kiri_4(nnl3_w4i),
        .in_kiri_5(nnl3_w5i),
        .in_kiri_6(nnl3_w6i),
        .in_kiri_7(nnl3_w7i),
        .in_kiri_8(nnl3_w8i),
        .in_kiri_9(nnl3_w9i),
        .in_atas(a2),
        .b1(nnl3_b1),
        .b2(nnl3_b2),
        .b3(nnl3_b3),
        .b4(nnl3_b4),
        .b5(nnl3_b5),
        .b6(nnl3_b6),
        .b7(nnl3_b7),
        .b8(nnl3_b8),
        .b9(nnl3_b9),
        .sys9x1_res1(sys9x1_res1),
        .sys9x1_res2(sys9x1_res2),
        .sys9x1_res3(sys9x1_res3),
        .sys9x1_res4(sys9x1_res4),
        .sys9x1_res5(sys9x1_res5),
        .sys9x1_res6(sys9x1_res6),
        .sys9x1_res7(sys9x1_res7),
        .sys9x1_res8(sys9x1_res8),
        .sys9x1_res9(sys9x1_res9),
        .res1_w(z3_1),
        .res2_w(z3_2),
        .res3_w(z3_3),
        .res4_w(z3_4),
        .res5_w(z3_5),
        .res6_w(z3_6),
        .res7_w(z3_7),
        .res8_w(z3_8),
        .res9_w(z3_9),
        .start(),
        .done()
    );

    sigmoid10slices sigmoid1 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_1), .y(a3_1));
    sigmoid10slices sigmoid2 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_2), .y(a3_2));
    sigmoid10slices sigmoid3 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_3), .y(a3_3));
    sigmoid10slices sigmoid4 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_4), .y(a3_4));
    sigmoid10slices sigmoid5 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_5), .y(a3_5));
    sigmoid10slices sigmoid6 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_6), .y(a3_6));
    sigmoid10slices sigmoid7 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_7), .y(a3_7));
    sigmoid10slices sigmoid8 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_8), .y(a3_8));
    sigmoid10slices sigmoid9 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3_9), .y(a3_9));

    // Counter for main
    always @(posedge clk or negedge rst) begin
        if (!rst || clr) begin
            cntr_main <= 6'd0;  
        end else if (start) begin
            cntr_main <= cntr_main + 6'd1;
        end else if (cntr_main >= 6'd1 && cntr_main <= 6'd45) begin
            cntr_main <= cntr_main + 6'd1;
        end else begin
            cntr_main <= 6'd0;      
        end
    end

    // Multiply a2_var with std dist and add with a2_mean
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            a2_1_reg <= 16'sd0;  
            a2_2_reg <= 16'sd0;
            a2_reg <= 16'sd0; 
        end else if (cntr_main >= 6'd22 && cntr_main < 6'd23) begin
            dot1 <= sqrt_a1var * random_number_1 ;
            dot2 <= sqrt_a2var * random_number_2 ;
        end else if (cntr_main >= 6'd23 && cntr_main < 6'd24) begin
            a2_1_reg <= a1_mean + dot1[25:10] ;
            a2_2_reg <= a2_mean + dot2[25:10] ;
        end else if (cntr_main >=6'd24 && cntr_main <= 6'd25) begin
            a2_reg <= a2_1_reg ;
        end else if (cntr_main >=6'd26 && cntr_main <= 6'd27) begin
            a2_reg <= a2_2_reg ;
        end else begin
            a2_1_reg <= a2_1_reg;  
            a2_2_reg <= a2_2_reg; 
            a2_reg <= a2_reg;      
        end
    end

    // Enable signal according to counter
    assign nnl2_en      = (cntr_main >= 6'd1 && cntr_main <= 6'd12) ? 1 : 0 ;
    assign gauss_en     = (cntr_main >= 6'd9 && cntr_main <= 6'd25) ? 1 : 0 ;
    assign softplus_en  = (cntr_main >= 6'd13 && cntr_main <= 6'd17) ? 1 : 0 ;
    assign sqrt_en      = (cntr_main >= 6'd18 && cntr_main <= 6'd22) ? 1 : 0 ;
    assign nnl3_en      = (cntr_main >= 6'd25 && cntr_main <= 6'd39) ? 1 : 0 ;
    assign sigmoid_en   = (cntr_main >= 6'd40 && cntr_main <= 6'd44) ? 1 : 0 ;
    assign done         = (cntr_main > 44) ? 1 : 0 ;

    // Assign value to output wire
    assign a2 = a2_reg;
    assign a2_1 = a2_1_reg;
    assign a2_2 = a2_2_reg;
    assign dot1_w = dot1;
    assign dot2_w = dot2;

endmodule