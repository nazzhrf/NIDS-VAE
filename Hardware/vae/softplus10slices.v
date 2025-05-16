`timescale 1ns / 1ps

module softplus10slices

(
    input wire clk,          
    input wire rst,
    input wire softplus_en,          
    input wire signed [15:0] x, 
    output wire signed [15:0] y
);
    // Wire to observe value
    wire signed [15:0] m16_w;
    wire signed [15:0] c16_w;
    wire signed [31:0] mx32_w;
    wire signed [15:0] mx16_w;

    // Register to save temporary value
    reg [3:0] cntr_softplus;
    reg signed [15:0] m16_reg;
    reg signed [15:0] c16_reg;
    reg signed [31:0] mx32_reg;
    reg signed [15:0] mx16_reg;
    reg signed [15:0] y_reg;
    

    // Choose value of gradient m based on input x value
    assign m16_w =  (x >= 16'sd50176 && x < 16'sd53504)  ? 16'sb000000_0000000000 : // m1 = 1.0133e-06
                    (x >= 16'sd53504 && x < 16'sd56832)  ? 16'sb000000_0000000000 : // m2 = 2.61323e-05
                    (x >= 16'sd56832 && x < 16'sd60160)  ? 16'sb000000_0000000001 : // m3 = 0.0006722011
                    (x >= 16'sd60160 && x <= 16'sd63488) ? 16'sb000000_0000010001 : // m4 = 0.0162618846
                    (x >= 16'sd63488 && x < 16'sd64512)  ? 16'sb000000_0001010011 : // m5 = 0.0809236875 
                    (x >= 16'sd64512 && x < 16'sd65535)  ? 16'sb000000_0010101001 : // m6 = 0.1649821734
                    (x >= 16'sd0 && x < 16'sd1024)       ? 16'sb000000_0100010100 : // m7 = 0.2693123085
                    (x >= 16'sd1024 && x < 16'sd2048)    ? 16'sb000000_0101101010 : // m8 = 0.3533707944
                    (x >= 16'sd2048 && x < 16'sd6485)    ? 16'sb000000_0110110000 : // m9 = 0.4217513741
                    (x >= 16'sd6485 && x <= 16'sd15360)  ? 16'sb000000_0110111101 : // m10 =  0.4341189715
                                                           16'd0 ;

    // Choose value of constant c based on input x value
    assign c16_w =  (x >= 16'sd50176 && x < 16'sd53504)  ? 16'sb000000_0000000000 : // c1 = 1.53324e-05
                    (x >= 16'sd53504 && x < 16'sd56832)  ? 16'sb000000_0000000000 : // c2 = 0.0003104808
                    (x >= 16'sd56832 && x < 16'sd60160)  ? 16'sb000000_0000000110 : // c3 = 0.0058020656
                    (x >= 16'sd60160 && x <= 16'sd63488) ? 16'sb000000_0001011010 : // c4 = 0.0876479038
                    (x >= 16'sd63488 && x < 16'sd64512)  ? 16'sb000000_0011011110 : // c5 = 0.2169715098 
                    (x >= 16'sd64512 && x < 16'sd65535)  ? 16'sb000000_0100110100 : // c6 = 0.3010299957
                    (x >= 16'sd0 && x < 16'sd1024)       ? 16'sb000000_0100110100 : // c7 = 0.3010299957
                    (x >= 16'sd1024 && x < 16'sd2048)    ? 16'sb000000_0011011110 : // c8 = 0.2169715098
                    (x >= 16'sd2048 && x < 16'sd6485)    ? 16'sb000000_0001010010 : // c9 = 0.0802103504
                    (x >= 16'sd6485 && x <= 16'sd15360)  ? 16'sb000000_0000000010 : // c10 =  0.0018822337
                                                           16'd0 ;
    
    // Control signal to activate the softplus function
    assign y = y_reg ;
    assign mx32_w = mx32_reg ;
    assign mx16_w = mx16_reg ;
    
    // Counter for FSM
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cntr_softplus <= 4'd0;  
        end else if (cntr_softplus <= 4'd3 && softplus_en) begin
            cntr_softplus <= cntr_softplus + 4'd1;
        end else begin
            cntr_softplus <= 4'd0;      
        end
    end

    // calculate y = mx+c
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mx32_reg <= 32'sd0;  
        end else if (softplus_en) begin
            if (cntr_softplus == 0) begin
                m16_reg <= m16_w ;
                c16_reg <= c16_w ;
            end else if (cntr_softplus == 1) begin
                mx32_reg <= m16_reg * x;   
            end else if (cntr_softplus == 2) begin
                mx16_reg <= mx32_reg[25:10]; 
            end else if (cntr_softplus == 3) begin
                y_reg <= mx16_reg + c16_reg;  
            end
        end else begin
            c16_reg <= c16_reg ;
            mx16_reg <= mx16_reg;
            y_reg <= y_reg ;    
        end
    end
    
endmodule
