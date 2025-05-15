`timescale 1ns/1ps

module top_forward_nn_classification

#(parameter DATA_WIDTH = 16) 

(
    input wire clk,
    input wire rst,
    input wire start,
    input wire clr,
    input wire signed [DATA_WIDTH-1:0] x1j , x2j, x3j, x4j,
    input wire signed [DATA_WIDTH-1:0] w1j , w2j, w3j, w4j, 
    input wire signed [DATA_WIDTH-1:0] b1, b2, b3, b4,
    output wire signed [DATA_WIDTH-1:0] sys2x1_res1, sys2x1_res2 , sys2x1_res3, sys2x1_res4,
    output wire signed [DATA_WIDTH-1:0] z1, z2, z3, z4,
    output wire signed [DATA_WIDTH-1:0] a1, a2, a3, a4,
    output wire signed [DATA_WIDTH-1:0] dos_detected, portscan_detected, ddos_detected, patator_detected, 
    output wire done
);
    // Control signal to activate each submodule
    wire nn_classifier_en, softplus_en ;

    // Register for main counter
    reg [6:0] cntr_main ;

    // Register to saved softplus output
    reg signed [DATA_WIDTH-1:0] a1_reg, a2_reg, a3_reg , a4_reg;

    // Register and wire to accumulate softplus result
//    reg signed [DATA_WIDTH-1:0] decision_reg ;
//    wire signed [DATA_WIDTH-1:0] decision ;

    // --- Classification nn --- //
    nn_classifier classifier_1(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(w1j),
        .in_atas(x1j),
        .b1(b1),
        .sys2x1_res1(sys2x1_res1),
        .res1_w(z1)
    );

    nn_classifier classifier_2(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(w2j),
        .in_atas(x2j),
        .b1(b2),
        .sys2x1_res1(sys2x1_res2),
        .res1_w(z2)
    );

    nn_classifier classifier_3(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(w3j),
        .in_atas(x3j),
        .b1(b3),
        .sys2x1_res1(sys2x1_res3),
        .res1_w(z3)
    );
    
    nn_classifier classifier_4(
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(w4j),
        .in_atas(x4j),
        .b1(b4),
        .sys2x1_res1(sys2x1_res4),
        .res1_w(z4)
    );

    softplus10slices softplus1 (.clk(clk), .rst(rst), .softplus_en(softplus_en), .x(z1), .y(a1));
    softplus10slices softplus2 (.clk(clk), .rst(rst), .softplus_en(softplus_en), .x(z2), .y(a2));
    softplus10slices softplus3 (.clk(clk), .rst(rst), .softplus_en(softplus_en), .x(z3), .y(a3));
    softplus10slices softplus4 (.clk(clk), .rst(rst), .softplus_en(softplus_en), .x(z4), .y(a4));

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
          //
        end else if (cntr_main >= 6'd17) begin
            a1_reg <= a1 ;
            a2_reg <= a2 ;
            a3_reg <= a3 ;
            a4_reg <= a4 ;   
        end else begin
            //   
        end
    end

    // Enable signal according to counter
    assign nn_classifier_en = (cntr_main >= 6'd1 && cntr_main <= 6'd12) ? 1 : 0 ;
    assign softplus_en       = (cntr_main >= 6'd13 && cntr_main <= 6'd17) ? 1 : 0 ;
    assign dos_detected      = a1_reg;
    assign portscan_detected = a2_reg;
    assign ddos_detected     = a3_reg;
    assign patator_detected  = a4_reg;
    //assign unhealthy        = (decision_reg > 16'b000010_0000000000) ? 1 : 0 ;
    assign done             = (cntr_main > 20) ? 1 : 0 ;

    // Assign value to output wire
    // assign decision = decision_reg;

endmodule

// (a1_reg > 16'b000010_1000000000)