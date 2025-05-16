`timescale 1ns/1ps

module top_forward_nn_classification

#(parameter DATA_WIDTH = 16) 

(
    input wire clk,
    input wire rst,
    input wire start,
    input wire clr,
    input wire signed [DATA_WIDTH-1:0] x1j , x2j, x3j,
    input wire signed [DATA_WIDTH-1:0] wj, b1,
    output wire signed [DATA_WIDTH-1:0] sys2x1_res1, sys2x1_res2 , sys2x1_res3 ,
    output wire signed [DATA_WIDTH-1:0] z1, z2, z3,
    output wire signed [DATA_WIDTH-1:0] a1, a2, a3,
    output wire unhealthy,
    output wire done
);
    // Control signal to activate each submodule
    wire nn_classifier_en, sigmoid_en ;

    // Register for main counter
    reg [6:0] cntr_main ;

    // Register to saved sigmoid output
    reg signed [DATA_WIDTH-1:0] a1_reg, a2_reg, a3_reg ;

    // Register and wire to accumulate sigmoid result
    reg signed [DATA_WIDTH-1:0] decision_reg ;
    wire signed [DATA_WIDTH-1:0] decision ;

    // --- Classification nn --- //
    nn_classifier classifier_1(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(wj),
        .in_atas(x1j),
        .b1(b1),
        .sys2x1_res1(sys2x1_res1),
        .res1_w(z1)
    );

    nn_classifier classifier_2(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(wj),
        .in_atas(x2j),
        .b1(b1),
        .sys2x1_res1(sys2x1_res2),
        .res1_w(z2)
    );

    nn_classifier classifier_3(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(wj),
        .in_atas(x3j),
        .b1(b1),
        .sys2x1_res1(sys2x1_res3),
        .res1_w(z3)
    );

    sigmoid10slices sigmoid1 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z1), .y(a1));
    sigmoid10slices sigmoid2 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z2), .y(a2));
    sigmoid10slices sigmoid3 (.clk(clk), .rst(rst), .sigmoid_en(sigmoid_en), .x(z3), .y(a3));

    // Counter for main
    always @(posedge clk or negedge rst) begin
        if (!rst || clr) begin
            cntr_main <= 6'd0;  
        end else if (start) begin
            cntr_main <= cntr_main + 6'd1;
        end else if (cntr_main >= 6'd1 && cntr_main <= 6'd20) begin
            cntr_main <= cntr_main + 6'd1;
        end else begin
            cntr_main <= 6'd0;      
        end
    end

    // decision maker
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            decision_reg <= 16'sd0;  
        end else if (cntr_main >= 6'd17 && cntr_main < 6'd18) begin
            decision_reg <= a1 + a2 + a3 ;
        end else begin
            decision_reg <= decision_reg;      
        end
    end

    // Enable signal according to counter
    assign nn_classifier_en = (cntr_main >= 6'd1 && cntr_main <= 6'd12) ? 1 : 0 ;
    assign sigmoid_en       = (cntr_main >= 6'd13 && cntr_main <= 6'd17) ? 1 : 0 ;
    assign unhealthy        = (decision_reg > 16'b000010_0000000000) ? 1 : 0 ;
    assign done             = (cntr_main > 20) ? 1 : 0 ;

    // Assign value to output wire
    assign decision = decision_reg;

endmodule