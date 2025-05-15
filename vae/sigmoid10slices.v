`timescale 1ns / 1ps

module sigmoid10slices

(
    input wire clk,          
    input wire rst,
    input wire sigmoid_en,          
    input wire signed [15:0] x, 
    output wire signed [15:0] y
);
    // Wire to observe value
    wire signed [15:0] m16_w;
    wire signed [15:0] c16_w;
    wire signed [31:0] mx32_w;
    wire signed [15:0] mx16_w;

    // Register to save temporary value
    reg [3:0] cntr_sigmoid;
    reg signed [15:0] m16_reg;
    reg signed [15:0] c16_reg;
    reg signed [31:0] mx32_reg;
    reg signed [15:0] mx16_reg;
    reg signed [15:0] y_reg;
    

    // Choose value of gradient m based on input x value
    assign m16_w =  (x >= 16'sd50176 && x < 16'sd53504)  ? 16'sb000000_0000000000 : // m1 = 2.3333e-06
                    (x >= 16'sd53504 && x < 16'sd56832)  ? 16'sb000000_0000000000 : // m2 = 6.01654e-05
                    (x >= 16'sd56832 && x < 16'sd60160)  ? 16'sb000000_0000000010 : // m3 = 0.0015435996
                    (x >= 16'sd60160 && x <= 16'sd63488) ? 16'sb000000_0000100100 : // m4 = 0.0350716296
                    (x >= 16'sd63488 && x < 16'sd64512)  ? 16'sb000000_0010011001 : // m5 = 0.1497384994
                    (x >= 16'sd64512 && x < 16'sd65535)  ? 16'sb000000_0011101101 : // m6 = 0.2310585786
                    (x >= 16'sd0 && x < 16'sd1024)       ? 16'sb000000_0011101101 : // m7 = 0.2310585786
                    (x >= 16'sd1024 && x < 16'sd2048)    ? 16'sb000000_0010011001 : // m8 = 0.1497384994
                    (x >= 16'sd2048 && x < 16'sd6485)    ? 16'sb000000_0000011100 : // m9 = 0.0270992232
                    (x >= 16'sd6485 && x <= 16'sd15360)  ? 16'sb000000_0000000000 : // m10 = 0.0004037645
                                                           16'd0 ;

    // Choose value of constant c based on input x value
    assign c16_w =  (x >= 16'sd50176 && x < 16'sd53504)  ? 16'sb000000_0000000000 : // c1 = 3.53054e-05
                    (x >= 16'sd53504 && x < 16'sd56832)  ? 16'sb000000_0000000001 : // c2 = 0.0007148327
                    (x >= 16'sd56832 && x < 16'sd60160)  ? 16'sb000000_0000001110 : // c3 = 0.0133240236
                    (x >= 16'sd60160 && x <= 16'sd63488) ? 16'sb000000_0011000010 : // c4 = 0.1893461811
                    (x >= 16'sd63488 && x < 16'sd64512)  ? 16'sb000000_0110101101 : // c5 = 0.4186799208
                    (x >= 16'sd64512 && x < 16'sd65535)  ? 16'sb000000_1000000000 : // c6 = 0.5
                    (x >= 16'sd0 && x < 16'sd1024)       ? 16'sb000000_1000000000 : // c7 = 0.5
                    (x >= 16'sd1024 && x < 16'sd2048)    ? 16'sb000000_1001010011 : // c8 = 0.5813200792
                    (x >= 16'sd2048 && x < 16'sd6485)    ? 16'sb000000_1101001110 : // c9 = 0.8265986316
                    (x >= 16'sd6485 && x <= 16'sd15360)  ? 16'sb000000_1111111100 : // c10 = 0.9956698702
                                                           16'd0 ;
    
    // Assign value to wire
    assign y = y_reg ;
    assign mx32_w = mx32_reg ;
    assign mx16_w = mx16_reg ;
    
    // Counter for FSM
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cntr_sigmoid <= 4'd0;  
        end else if (cntr_sigmoid <= 4'd3 && sigmoid_en) begin
            cntr_sigmoid <= cntr_sigmoid + 4'd1;
        end else begin
            cntr_sigmoid <= 4'd0;      
        end
    end

    // calculate y = mx+c
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mx32_reg <= 32'sd0;  
        end else if (sigmoid_en) begin
            if (cntr_sigmoid == 0) begin
                m16_reg <= m16_w ;
                c16_reg <= c16_w ;
            end else if (cntr_sigmoid == 1) begin
                mx32_reg <= m16_reg * x;   
            end else if (cntr_sigmoid == 2) begin
                mx16_reg <= mx32_reg[25:10]; 
            end else if (cntr_sigmoid == 3) begin
                y_reg <= mx16_reg + c16_reg;  
            end
        end else begin
            c16_reg <= c16_reg ;
            mx16_reg <= mx16_reg;
            y_reg <= y_reg ;    
        end
    end
    
endmodule