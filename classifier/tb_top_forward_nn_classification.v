`timescale 1ns/1ps

module tb_top_forward_nn_classification;

    parameter DATA_WIDTH = 16;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg signed [DATA_WIDTH-1:0] x1j , x2j, x3j;
    reg signed [DATA_WIDTH-1:0] wj, b1;

    // Outputs
    wire signed [DATA_WIDTH-1:0] sys2x1_res1, sys2x1_res2 , sys2x1_res3;
    wire signed [DATA_WIDTH-1:0] z1, z2, z3;
    wire signed [DATA_WIDTH-1:0] a1, a2, a3;
    wire unhealthy ;
    wire done ;

    // Sinyal antara
    wire signed [DATA_WIDTH-1:0] decision;
    
    // Instantiate
    top_forward_nn_classification uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .clr(),
        .x1j(x1j),
        .x2j(x2j),
        .x3j(x3j),
        .wj(wj),
        .b1(b1),
        .sys2x1_res1(sys2x1_res1),
        .sys2x1_res2(sys2x1_res2),
        .sys2x1_res3(sys2x1_res3),
        .z1(z1),
        .z2(z2),
        .z3(z3),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .unhealthy(unhealthy),
        .done(done)
    );

    assign decision = uut.decision ;

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 0;
        start = 0;
        
        // Reset the system
        #5 rst = 1;
        start = 1;

        // Provide inputs

        // CLOCK 1
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000000_1101001100; //0.8246
        b1 = 16'sb111100_1110100011 ; // -3.091
        #10

        //CLOCK 2
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_1001001111; //1.577
        #10

        // CLOCK 3
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_1001111101; // 1.6217 
        #10

        //CLOCK 4
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_0010001010; //1.1347 
        #10

        // CLOCK 5
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_0001001111; //1.0774 
        #10

        //CLOCK 6
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000000_1111001001; //0.9467 
        #10

        // CLOCK 7
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_0101100011; //1.3465
        #10

        //CLOCK 8
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_0010111010; // 1.1818 
        #10

        // CLOCK 9
        x1j = 16'sb000000_0000000000; //0.0001 
        x2j = 16'sb000000_0000000000; //0.0001 
        x3j = 16'sb000000_0000000000; //0.0001 

        wj = 16'sb000001_1010011101; // 1.6534 
        #10
         
        //CLOCK 10 
        #10

        // CLOCK 11
        #10;
        
        // CLOCK 12
        #10;

        // CLOCK 13
        #10
         
        //CLOCK 14 
        #10

        // CLOCK 15
        #10;
        
        // CLOCK 16
        #10;

        // CLOCK 17
        #10
         
        //CLOCK 18 
        #10

        // CLOCK 19
        #10;
        
        // CLOCK 20
        #10;

        // CLOCK 21
        #10
         
        //CLOCK 22 
        #10

        // Finish simulation
        $finish;
    end
  
endmodule
