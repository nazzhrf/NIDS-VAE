`timescale 1ns/1ps

module tb_nn_classifier;

    // Inputs
    reg clk;
    reg rst;
    reg nn_classifier_en;
    reg signed [15:0] in_kiri_1;
    reg signed [15:0] in_atas;
    reg signed [15:0] b1;

    // Outputs
    wire signed [15:0] sys2x1_res1;
    wire signed [15:0] res1_w;

    // Sinyal antara
    wire signed [15:0] out_bawah_1;
    wire signed [15:0] b1_w;
    wire signed [15:0] in_kiri_1_w0;

    // Instantiate the systolic array module
    nn_classifier uut (
        .clk(clk),
        .rst(rst),
        .nn_classifier_en(nn_classifier_en),
        .in_kiri_1(in_kiri_1),
        .in_atas(in_atas),
        .b1(b1),
        .sys2x1_res1(sys2x1_res1),
        .res1_w(res1_w)
    );

    // Menghubungkan sinyal antara
    assign out_bawah_1 = uut.out_bawah_1;
    assign b1_w = uut.b1_w;
    assign in_kiri_1_w0 = uut.in_kiri_1_w0;
    
    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 0;
        in_kiri_1 = 0;
        in_atas = 0;

        // Reset the system
        #5 rst = 1;

        // Provide inputs


        // CLOCK PERTAMA
        nn_classifier_en = 1;
        in_kiri_1 = 16'sb000000_1101001100; //0.8246
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        //CLOCK KEDUA
        in_kiri_1 = 16'sb000001_1001001111; //1.577
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        // CLOCK KETIGA
        in_kiri_1 = 16'sb000001_1001111101; // 1.6217
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        //CLOCK KEEMPAT
        in_kiri_1 = 16'sb000001_0010001010; //1.1347
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        // CLOCK KELIMA
        in_kiri_1 = 16'sb000001_0001001111; //1.0774
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        //CLOCK KEENAM
        in_kiri_1 = 16'sb000000_1111001001; //0.9467
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        // CLOCK KETUJUH
        in_kiri_1 = 16'sb000001_0101100011; //1.3465
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        //CLOCK KEDELAPAN
        in_kiri_1 = 16'sb000001_0010111010; // 1.1818
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10

        // CLOCK KESEMBILAN
        in_kiri_1 = 16'sb000001_1010011101; // 1.6534
        in_atas = 16'sb000000_0000000000; //0.0001 
        #10
         
        //CLOCK KESEPULUH 
        b1 = 16'sb111100_1110100011 ; // -3.091
        #10

      
        // CLOCK KESEBELAS
        #10;
        
        // CLOCK 12
        #10;
        
        // CLOCK 13
        nn_classifier_en = 0;
        #10;
        
        #10;
        #10;
        #10;

        // Finish simulation
        $finish;
    end


endmodule
