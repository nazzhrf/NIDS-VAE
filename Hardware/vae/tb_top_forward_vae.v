`timescale 1ns/1ps

module tb_top_forward_vae;

    parameter DATA_WIDTH = 16;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg signed [DATA_WIDTH-1:0] xj ;
    reg signed [DATA_WIDTH-1:0] nnl2_mean_w1j, nnl2_mean_w2j, nnl2_mean_b1, nnl2_mean_b2 ;
    reg signed [DATA_WIDTH-1:0] nnl2_var_w1j, nnl2_var_w2j, nnl2_var_b1, nnl2_var_b2 ;
    reg signed [DATA_WIDTH-1:0] nnl3_w1i, nnl3_w2i, nnl3_w3i, nnl3_w4i, nnl3_w5i, nnl3_w6i, nnl3_w7i, nnl3_w8i, nnl3_w9i ;
    reg signed [DATA_WIDTH-1:0] nnl3_b1, nnl3_b2, nnl3_b3, nnl3_b4, nnl3_b5, nnl3_b6, nnl3_b7, nnl3_b8, nnl3_b9 ;

    // Outputs
    wire signed [DATA_WIDTH-1:0] sys2x1_mean_res1, sys2x1_mean_res2 , z1_mean, z2_mean ;
    wire signed [DATA_WIDTH-1:0] sys2x1_var_res1, sys2x1_var_res2 , z1_var, z2_var ;
    wire signed [DATA_WIDTH-1:0] sys9x1_res1, sys9x1_res2 , sys9x1_res3, sys9x1_res4, sys9x1_res5, sys9x1_res6, sys9x1_res7, sys9x1_res8, sys9x1_res9 ;
    wire signed [DATA_WIDTH-1:0] a3_1, a3_2, a3_3, a3_4, a3_5, a3_6, a3_7, a3_8, a3_9 ;
    wire done ;

    // Sinyal antara
    wire signed [DATA_WIDTH-1:0] a2_1, a2_2, a2;
    wire signed [DATA_WIDTH-1:0] random_number_1, random_number_2 ;
    wire signed [(2*DATA_WIDTH)-1:0] dot1_w, dot2_w ;
    wire signed [DATA_WIDTH-1:0] sqrt_a1var, sqrt_a2var;
    wire signed [DATA_WIDTH-1:0] a1_mean, a2_mean, a1_var, a2_var ;
    wire signed [DATA_WIDTH-1:0] z3_1, z3_2, z3_3, z3_4, z3_5, z3_6, z3_7, z3_8, z3_9 ;
    wire nnl3_en;
    
    // Instantiate
    top_forward_vae uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .clr(),
        .xj(xj),
        .nnl2_mean_w1j(nnl2_mean_w1j), .nnl2_mean_w2j(nnl2_mean_w2j), .nnl2_mean_b1(nnl2_mean_b1), .nnl2_mean_b2(nnl2_mean_b2),
        .nnl2_var_w1j(nnl2_var_w1j), .nnl2_var_w2j(nnl2_var_w2j), .nnl2_var_b1(nnl2_var_b1), .nnl2_var_b2(nnl2_var_b2),
        .nnl3_w1i(nnl3_w1i), .nnl3_w2i(nnl3_w2i), .nnl3_w3i(nnl3_w3i), .nnl3_w4i(nnl3_w4i), .nnl3_w5i(nnl3_w5i), .nnl3_w6i(nnl3_w6i), .nnl3_w7i(nnl3_w7i), .nnl3_w8i(nnl3_w8i), .nnl3_w9i(nnl3_w9i),
        .nnl3_b1(nnl3_b1), .nnl3_b2(nnl3_b2), .nnl3_b3(nnl3_b3), .nnl3_b4(nnl3_b4), .nnl3_b5(nnl3_b5), .nnl3_b6(nnl3_b6), .nnl3_b7(nnl3_b7), .nnl3_b8(nnl3_b8), .nnl3_b9(nnl3_b9),
        .sys2x1_mean_res1(sys2x1_mean_res1), .sys2x1_mean_res2(sys2x1_mean_res2), .z1_mean(z1_mean), .z2_mean(z2_mean),
        .sys2x1_var_res1(sys2x1_var_res1), .sys2x1_var_res2(sys2x1_var_res2), .z1_var(z1_var), .z2_var(z2_var),
        .sys9x1_res1(sys9x1_res1), .sys9x1_res2(sys9x1_res2), .sys9x1_res3(sys9x1_res3), .sys9x1_res4(sys9x1_res4), .sys9x1_res5(sys9x1_res5),
        .sys9x1_res6(sys9x1_res6), .sys9x1_res7(sys9x1_res7), .sys9x1_res8(sys9x1_res8), .sys9x1_res9(sys9x1_res9),
        .a3_1(a3_1), .a3_2(a3_2), .a3_3(a3_3), .a3_4(a3_4), .a3_5(a3_5), .a3_6(a3_6), .a3_7(a3_7), .a3_8(a3_8), .a3_9(a3_9),
        .done(done)
    );

    assign a2 = uut.a2 ;
    assign a2_1 = uut.a2_1;
    assign a2_2 = uut.a2_2;
    assign random_number_1 = uut.random_number_1;
    assign random_number_2 = uut.random_number_2;
    assign dot1_w = uut.dot1_w;
    assign dot2_w = uut.dot2_w;
    assign sqrt_a1var = uut.sqrt_a1var;
    assign sqrt_a2var = uut.sqrt_a2var;
    assign a1_mean = uut.a1_mean;
    assign a2_mean = uut.a2_mean;
    assign a1_var = uut.a1_var;
    assign a2_var = uut.a2_var;
    assign nnl3_en = uut.nnl3_en;
    
    assign z3_1 = uut.z3_1;
    assign z3_2 = uut.z3_2;
    assign z3_3 = uut.z3_3;
    assign z3_4 = uut.z3_4;
    assign z3_5 = uut.z3_5;
    assign z3_6 = uut.z3_6;
    assign z3_7 = uut.z3_7;
    assign z3_8 = uut.z3_8;
    assign z3_9 = uut.z3_9;

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
        nnl2_mean_b1 = 16'sb111111_0100010111 ; //-0.7278
        nnl2_mean_b2 = 16'sb111111_0011100001 ; //-0.7807
        nnl2_mean_w1j = 16'sb000000_0000000000; //-0.0004
        nnl2_mean_w2j = 16'sb111111_1111111101; //-0.0034

        nnl2_var_b1 = 16'sb111110_0000001001; //-1.9914
        nnl2_var_b2 = 16'sb111101_1101001111; //-2.1724
        nnl2_var_w1j = 16'sb111111_0001010100; //-0.9178
        nnl2_var_w2j = 16'sb111110_1110001101; //-1.1124

        xj = 16'sb000001_0000000000; 
        #10

        //CLOCK 2
        start = 0 ;
        nnl2_mean_w1j = 16'sb111111_1111111101; //-0.0028
        nnl2_mean_w2j = 16'sb000000_0000000100; //0.0038

        nnl2_var_w1j = 16'sb111111_1101101101; //-0.1435
        nnl2_var_w2j = 16'sb000000_0000100101; //0.0357
        
        xj = 16'sb000001_0000000000; 
        #10

        // CLOCK 3
        nnl2_mean_w1j = 16'sb000000_0000000000; // -0.0004
        nnl2_mean_w2j = 16'sb111111_1111111101; // -0.0032

        nnl2_var_w1j = 16'sb111111_0011100000; //-0.7811
        nnl2_var_w2j = 16'sb111110_1100101000; //-1.2106

        xj = 16'sb000001_0000000000; 
        #10

        //CLOCK 4
        nnl2_mean_w1j = 16'sb111111_1111111111; //-0.0012
        nnl2_mean_w2j = 16'sb000000_0000000011; // 0.0034

        nnl2_var_w1j = 16'sb000000_0001001011; //0.0728 
        nnl2_var_w2j = 16'sb111111_1111111111; //-0.0005
        
        xj = 16'sb000001_0000000000; 
        #10

        // CLOCK 5
        nnl2_mean_w1j = 16'sb000000_0000000010; //0.0024
        nnl2_mean_w2j = 16'sb111111_1111111010; //-0.0056

        nnl2_var_w1j = 16'sb111111_1001011000; //-0.4137
        nnl2_var_w2j = 16'sb111111_1011110010; //-0.2634

        xj = 16'd0; 
        #10

        //CLOCK 6
        nnl2_mean_w1j = 16'sb111111_1111111100; //-0.0036
        nnl2_mean_w2j = 16'sb000000_0000000100; //0.0036

        nnl2_var_w1j = 16'sb111111_0110100111; //-0.5869
        nnl2_var_w2j = 16'sb111111_0010111110; //-0.8148

        xj = 16'sb000001_0000000000; 
        #10

        // CLOCK 7
        nnl2_mean_w1j = 16'sb111111_1101000001; //-0.1861
        nnl2_mean_w2j = 16'sb000000_0111110101; //0.4888

        nnl2_var_w1j = 16'sb111110_1101010101; //-1.1672
        nnl2_var_w2j = 16'sb111111_0101000110; //-0.6815

        xj = 16'sb000001_0000000000; 
        #10

        //CLOCK 8
        nnl2_mean_w1j = 16'sb000001_0011100000; // 1.2185
        nnl2_mean_w2j = 16'sb111111_1000011011; // -0.4737

        nnl2_var_w1j = 16'sb111111_1011001101; //-0.3001
        nnl2_var_w2j = 16'sb111111_1111001001; //-0.0534

        xj = 16'sb000001_0000000000; 
        #10

        // CLOCK 9
        nnl2_mean_w1j = 16'sb000000_0110001000; // 0.3831
        nnl2_mean_w2j = 16'sb000000_1010001000; // 0.6324

        nnl2_var_w1j = 16'sb111110_1001001110; //-1.424
        nnl2_var_w2j = 16'sb111110_1001110010; //-1.3883

        xj = 16'sb000001_0000000000; 
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

        // CLOCK 23
        #10;
        
        // CLOCK 24
        #10;

        // CLOCK 25
        #10
         
        //CLOCK 26 
        // in_atas = 16'sb000000_1011011000 ; //0.7106 
        nnl3_b1 = 16'sb000100_0011101110 ; //4.2329
        nnl3_b2 = 16'sb111111_1011010000 ; //-0.2964
        nnl3_b3 = 16'sb000100_0100010111 ; //4.2722
        nnl3_b4 = 16'sb111111_1011100110 ; //-0.2755
        nnl3_b5 = 16'sb000000_0001100110 ; //0.0995
        nnl3_b6 = 16'sb111111_1010111011 ; //-0.3173
        nnl3_b7 = 16'sb000100_0011010111 ; // 4.2099
        nnl3_b8 = 16'sb111111_1011011001 ; //-0.2876
        nnl3_b9 = 16'sb000100_0100101101 ; //4.2941

        nnl3_w1i = 16'sb000001_0100001110; //1.2638
        nnl3_w2i = 16'sb000101_1010000101; //5.6302
        nnl3_w3i = 16'sb000001_0011101110; //1.2328
        nnl3_w4i = 16'sb000101_1001010110; //5.5842
        nnl3_w5i = 16'sb111010_1100101011; //-5.2076
        nnl3_w6i = 16'sb000101_1010110000; //5.6714
        nnl3_w7i = 16'sb000001_0101000001; //1.3139
        nnl3_w8i = 16'sb000101_1001110100; //5.6133
        nnl3_w9i = 16'sb000001_0010110101; //1.1772
        #10

        // CLOCK 27
        // in_atas = 16'sb111111_1101101001 ; //-0.1473
        nnl3_w1i = 16'sb000010_1100101111; //2.7963
        nnl3_w2i = 16'sb111110_0011111110; //-1.7521
        nnl3_w3i = 16'sb000010_1010010001; //2.6412
        nnl3_w4i = 16'sb111110_0010010111; //-1.8523
        nnl3_w5i = 16'sb000010_1011110101; //2.7393
        nnl3_w6i = 16'sb111110_0101110001; //-1.6399
        nnl3_w7i = 16'sb000010_1110010000; //2.8903
        nnl3_w8i = 16'sb111110_0011001100; //-1.8008
        nnl3_w9i = 16'sb000010_1000110011; //2.5499
        #10;
        
        // CLOCK 28
        #10;

        // CLOCK 29
        #10
         
        //CLOCK 30 
        #10

        // CLOCK 31
        #10;
        
        // CLOCK 32
        #10;

        // CLOCK 33
        #10
         
        //CLOCK 34 
        #10

        // CLOCK 35
        #10;
        
        // CLOCK 36
        #10;

        // CLOCK 37
        #10;

        // CLOCK 38
        #10
         
        //CLOCK 39 
        #10

        // CLOCK 40
        #10;
        
        // CLOCK 41
        #10;
        
         //CLOCK 42 
        #10

        // CLOCK 43
        #10;
        
        // CLOCK 44
        #10;
        
         //CLOCK 45 
        #10

        // CLOCK 46
        #10;
        
        // CLOCK 47
        #10;
        
        // CLOCK 48
        #10;
        
        // CLOCK 49
        #10;
        

        // Finish simulation
        $finish;
    end
    
    initial begin
        $monitor("time=%0d, nnl3_w1i=%0d, a2=%0d, sys9x1_res1=%0d", $time, nnl3_w1i, a2, sys9x1_res1);
    end


endmodule
