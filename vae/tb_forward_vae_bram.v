`timescale 1ns / 1ps

module tb_forward_vae_bram();
    localparam T = 10;

    // INPUT OUTPUT
    
    reg clk;
    reg rst_n;
    reg en;
    reg clr;

    wire ready;
    reg start;
    wire done;

    reg wb2_m_ena;
    reg [3:0]  wb2_m_addra;
    reg [63:0] wb2_m_dina;
    reg [7:0]  wb2_m_wea;  

    reg wb2_v_ena;
    reg [3:0]  wb2_v_addra;
    reg [63:0] wb2_v_dina;
    reg [7:0]  wb2_v_wea;

    reg wb3_ena;
    reg [3:0]  wb3_addra;
    reg [63:0] wb3_dina;
    reg [7:0]  wb3_wea;

    reg xin_ena;
    reg [3:0]  xin_addra;
    reg [15:0] xin_dina;
    reg [7:0]  xin_wea;       

    reg xout_enb;
    reg [3:0]   xout_addrb;
    wire [15:0] xout_doutb;

    // SINYAL ANTARA //
    // Wire for port b of BRAM wb2_m
    wire wb2_m_enb;
    wire [3:0] wb2_m_addrb;
    wire [63:0] wb2_m_doutb;
    // Wire for port b of BRAM wb2_v
    wire wb2_v_enb;
    wire [3:0] wb2_v_addrb;
    wire [63:0] wb2_v_doutb;
    // Wire for port b of BRAM wb3
    wire wb3_enb;
    wire [3:0] wb3_addrb;
    wire [63:0] wb3_doutb;
    // Wire for port b of BRAM input
    wire xin_enb;
    wire [3:0] xin_addrb;
    wire [15:0] xin_doutb;
    // Wire for port a of BRAM output
    wire xout_ena;
    wire [3:0] xout_addra;
    wire [7:0] xout_wea;
    wire [15:0] xout_dina;

    // Wire to saved wb2_m_doutb value per 16 bits
    wire [15:0] wb2_m_doutb_0, wb2_m_doutb_1, wb2_m_doutb_2, wb2_m_doutb_3;
    // Wire to saved wb2_v_doutb value per 16 bits
    wire [15:0] wb2_v_doutb_0, wb2_v_doutb_1, wb2_v_doutb_2, wb2_v_doutb_3;
    // Wire to saved wb3_doutb value per 16 bits
    wire [15:0] wb3_doutb_0, wb3_doutb_1, wb3_doutb_2;

    // Input connection
    wire start_vae ; 
    wire signed [15:0] xj ;
    wire signed [15:0] nnl2_mean_w1j, nnl2_mean_w2j, nnl2_mean_b1, nnl2_mean_b2 ;
    wire signed [15:0] nnl2_var_w1j, nnl2_var_w2j, nnl2_var_b1, nnl2_var_b2 ;
    wire signed [15:0] nnl3_w1i, nnl3_w2i, nnl3_w3i, nnl3_w4i, nnl3_w5i, nnl3_w6i, nnl3_w7i, nnl3_w8i, nnl3_w9i ;
    wire signed [15:0] nnl3_b1, nnl3_b2, nnl3_b3, nnl3_b4, nnl3_b5, nnl3_b6, nnl3_b7, nnl3_b8, nnl3_b9 ;
    // Output connection
    wire signed [15:0] z1_mean, z2_mean ;
    wire signed [15:0] z1_var, z2_var ;
    wire signed [15:0] a3_1, a3_2, a3_3, a3_4, a3_5, a3_6, a3_7, a3_8, a3_9;
    wire done_vae ;
    // Wire to observe values
    wire signed [15:0] w3_11_w,  w3_12_w;
    wire signed [15:0] w3_21_w,  w3_22_w;
    wire signed [15:0] w3_31_w,  w3_32_w;
    wire signed [15:0] w3_41_w,  w3_42_w;
    wire signed [15:0] w3_51_w,  w3_52_w;
    wire signed [15:0] w3_61_w,  w3_62_w;
    wire signed [15:0] w3_71_w,  w3_72_w;
    wire signed [15:0] w3_81_w,  w3_82_w;
    wire signed [15:0] w3_91_w,  w3_92_w;
    wire signed [15:0] b3_1_w, b3_2_w, b3_3_w, b3_4_w, b3_5_w, b3_6_w, b3_7_w, b3_8_w, b3_9_w;
    wire signed [15:0] a3_w;

    forward_vae_bram dut
    (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .clr(clr),
        .ready(ready),
        .start(start),
        .done(done),

        .wb2_m_ena(wb2_m_ena),
        .wb2_m_addra(wb2_m_addra),
        .wb2_m_dina(wb2_m_dina),
        .wb2_m_wea(wb2_m_wea),

        .wb2_v_ena(wb2_v_ena),
        .wb2_v_addra(wb2_v_addra),
        .wb2_v_dina(wb2_v_dina),
        .wb2_v_wea(wb2_v_wea),

        .wb3_ena(wb3_ena),
        .wb3_addra(wb3_addra),
        .wb3_dina(wb3_dina),
        .wb3_wea(wb3_wea),

        .xin_ena(xin_ena),
        .xin_addra(xin_addra),
        .xin_dina(xin_dina),
        .xin_wea(xin_wea),

        .xout_enb(xout_enb),
        .xout_addrb(xout_addrb),
        .xout_doutb(xout_doutb)
    );

    assign wb2_m_enb = dut.wb2_m_enb;
    assign wb2_m_addrb = dut.wb2_m_addrb;
    assign wb2_m_doutb = dut.wb2_m_doutb;
    assign wb2_v_enb = dut.wb2_v_enb;
    assign wb2_v_addrb = dut.wb2_v_addrb;
    assign wb2_v_doutb = dut.wb2_v_doutb;
    assign wb3_enb = dut.wb3_enb;
    assign wb3_addrb = dut.wb3_addrb;
    assign wb3_doutb = dut.wb3_doutb;
    assign xin_enb = dut.xin_enb;
    assign xin_addrb = dut.xin_addrb;
    assign xin_doutb = dut.xin_doutb;
    assign xout_ena = dut.xout_ena;
    assign xout_addra = dut.xout_addra;
    assign xout_wea = dut.xout_wea;
    assign xout_dina = dut.xout_dina;

    assign wb2_m_doutb_0 = dut.wb2_m_doutb_0;
    assign wb2_m_doutb_1 = dut.wb2_m_doutb_1;
    assign wb2_m_doutb_2 = dut.wb2_m_doutb_2;
    assign wb2_m_doutb_3 = dut.wb2_m_doutb_3;
    assign wb2_v_doutb_0 = dut.wb2_v_doutb_0;
    assign wb2_v_doutb_1 = dut.wb2_v_doutb_1;
    assign wb2_v_doutb_2 = dut.wb2_v_doutb_2;
    assign wb2_v_doutb_3 = dut.wb2_v_doutb_3;
    assign wb3_doutb_0 = dut.wb3_doutb_0;
    assign wb3_doutb_1 = dut.wb3_doutb_1;
    assign wb3_doutb_2 = dut.wb3_doutb_2;

    assign start_vae = dut.start_vae;
    assign xj = dut.xj;
    assign nnl2_mean_w1j = dut.nnl2_mean_w1j;
    assign nnl2_mean_w2j = dut.nnl2_mean_w2j;
    assign nnl2_mean_b1 = dut.nnl2_mean_b1;
    assign nnl2_mean_b2 = dut.nnl2_mean_b2;
    assign nnl2_var_w1j = dut.nnl2_var_w1j;
    assign nnl2_var_w2j = dut.nnl2_var_w2j;
    assign nnl2_var_b1 = dut.nnl2_var_b1;
    assign nnl2_var_b2 = dut.nnl2_var_b2;
    assign nnl3_w1i = dut.nnl3_w1i;
    assign nnl3_w2i = dut.nnl3_w2i;
    assign nnl3_w3i = dut.nnl3_w3i;
    assign nnl3_w4i = dut.nnl3_w4i;
    assign nnl3_w5i = dut.nnl3_w5i;
    assign nnl3_w6i = dut.nnl3_w6i;
    assign nnl3_w7i = dut.nnl3_w7i;
    assign nnl3_w8i = dut.nnl3_w8i;
    assign nnl3_w9i = dut.nnl3_w9i;
    assign nnl3_b1 = dut.nnl3_b1;
    assign nnl3_b2 = dut.nnl3_b2;
    assign nnl3_b3 = dut.nnl3_b3;
    assign nnl3_b4 = dut.nnl3_b4;
    assign nnl3_b5 = dut.nnl3_b5;
    assign nnl3_b6 = dut.nnl3_b6;
    assign nnl3_b7 = dut.nnl3_b7;
    assign nnl3_b8 = dut.nnl3_b8;
    assign nnl3_b9 = dut.nnl3_b9;
    assign z1_mean = dut.z1_mean;
    assign z2_mean = dut.z2_mean;
    assign z1_var = dut.z1_var;
    assign z2_var = dut.z2_var;
    assign a3_1 = dut.a3_1;
    assign a3_2 = dut.a3_2;
    assign a3_3 = dut.a3_3;
    assign a3_4 = dut.a3_4;
    assign a3_5 = dut.a3_5;
    assign a3_6 = dut.a3_6;
    assign a3_7 = dut.a3_7;
    assign a3_8 = dut.a3_8;
    assign a3_9 = dut.a3_9;
    assign done_vae = dut.done_vae;

    assign w3_11_w = dut.w3_11_w;
    assign w3_21_w = dut.w3_21_w;
    assign w3_31_w = dut.w3_31_w;
    assign w3_41_w = dut.w3_41_w;
    assign w3_51_w = dut.w3_51_w;
    assign w3_61_w = dut.w3_61_w;
    assign w3_71_w = dut.w3_71_w;
    assign w3_81_w = dut.w3_81_w;
    assign w3_91_w = dut.w3_91_w;

    assign w3_12_w = dut.w3_12_w;
    assign w3_22_w = dut.w3_22_w;
    assign w3_32_w = dut.w3_32_w;
    assign w3_42_w = dut.w3_42_w;
    assign w3_52_w = dut.w3_52_w;
    assign w3_62_w = dut.w3_62_w;
    assign w3_72_w = dut.w3_72_w;
    assign w3_82_w = dut.w3_82_w;
    assign w3_92_w = dut.w3_92_w;

    assign b3_1_w = dut.b3_1_w ;
    assign b3_2_w = dut.b3_2_w ;
    assign b3_3_w = dut.b3_3_w ;
    assign b3_4_w = dut.b3_4_w ;
    assign b3_5_w = dut.b3_5_w ;
    assign b3_6_w = dut.b3_6_w ;
    assign b3_7_w = dut.b3_7_w ;
    assign b3_8_w = dut.b3_8_w ;
    assign b3_9_w = dut.b3_9_w ;

    assign a3_w = dut.a3_w;

    always
    begin
        clk = 0;
        #(T/2);
        clk = 1;
        #(T/2);
    end
    
    initial
    begin
        en = 1;
        clr = 0;
        start = 0;

        wb2_m_ena = 1;
        wb2_m_addra = 0;
        wb2_m_dina = 0;
        wb2_m_wea = 0;

        wb2_v_ena = 1;
        wb2_v_addra = 0;
        wb2_v_dina = 0;
        wb2_v_wea = 0;

        wb3_ena = 1;
        wb3_addra = 0;
        wb3_dina = 0;
        wb3_wea = 0;

        xin_ena = 1;
        xin_addra = 0;
        xin_dina = 0;
        xin_wea = 0;

        xout_enb = 0;
        xout_addrb = 0;
        
        rst_n = 0;
        #(T*1);
        rst_n = 1;
        
        // *** Testvector 1 ***
        // Write weight and bias

        // CLOCK 1
        wb2_m_wea = 8'hff;
        wb2_m_addra = 0;
        wb2_m_dina = 64'sb0000000000000000__111111_1111111101__111111_0100010111__111111_0011100001;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 0;
        wb2_v_dina = 64'sb111111_0001010100__111110_1110001101__111110_0000001001__111101_1101001111;

        wb3_wea = 8'hff;
        wb3_addra = 0;
        wb3_dina = 64'sb000001_0100001110__000010_1100101111__000100_0011101110__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 0;
        xin_dina = 16'sb000001_0000000000;
        #T;  

        // CLOCK 2
        wb2_m_wea = 8'hff;
        wb2_m_addra = 1;
        wb2_m_dina = 64'sb111111_1111111101__000000_0000000100__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 1;
        wb2_v_dina = 64'sb111111_1101101101__000000_0000100101__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 1;
        wb3_dina = 64'sb000101_1010000101__111110_0011111110__111111_1011010000__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 1;
        xin_dina = 16'sb000001_0000000000;
        #T;

        // CLOCK 3
        wb2_m_wea = 8'hff;
        wb2_m_addra = 2;  
        wb2_m_dina = 64'sb000000_0000000000__111111_1111111101__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 2;
        wb2_v_dina = 64'sb111111_0011100000__111110_1100101000__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 2;
        wb3_dina = 64'sb000001_0011101110__000010_1010010001__000100_0100010111__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 2;
        xin_dina = 16'sb000001_0000000000;
        #T;

        // CLOCK 4
        wb2_m_wea = 8'hff;
        wb2_m_addra = 3;  
        wb2_m_dina = 64'sb111111_1111111111__000000_0000000011__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 3;
        wb2_v_dina = 64'sb000000_0001001011__111111_1111111111__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 3;
        wb3_dina = 64'sb000101_1001010110__111110_0010010111__111111_1011100110__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 3;
        xin_dina = 16'sb000001_0000000000;
        #T;

        // CLOCK 5
        wb2_m_wea = 8'hff;
        wb2_m_addra = 4;  
        wb2_m_dina = 64'sb000000_0000000010__111111_1111111010__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 4;
        wb2_v_dina = 64'sb111111_1001011000__111111_1011110010__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 4;
        wb3_dina = 64'sb111010_1100101011__000010_1011110101__000000_0001100110__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 4;
        xin_dina = 16'sb000000_0000000000;
        #T;

        // CLOCK 6
        wb2_m_wea = 8'hff;
        wb2_m_addra = 5;  
        wb2_m_dina = 64'sb111111_1111111100__000000_0000000100__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 5;
        wb2_v_dina = 64'sb111111_0110100111__111111_0010111110__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 5;
        wb3_dina = 64'sb000101_1010110000__111110_0101110001__111111_1010111011__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 5;
        xin_dina = 16'sb000001_0000000000; 
        #T;

        // CLOCK 7
        wb2_m_wea = 8'hff;
        wb2_m_addra = 6;  
        wb2_m_dina = 64'sb111111_1101000001__000000_0111110101__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 6;
        wb2_v_dina = 64'sb111110_1101010101__111111_0101000110__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 6;
        wb3_dina = 64'sb000001_0101000001__000010_1110010000__000100_0011010111__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 6;
        xin_dina = 16'sb000001_0000000000;
        #T;

        // CLOCK 8
        wb2_m_wea = 8'hff;
        wb2_m_addra = 7;  
        wb2_m_dina = 64'sb000001_0011100000__111111_1000011011__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 7;
        wb2_v_dina = 64'sb111111_1011001101__111111_1111001001__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 7;
        wb3_dina = 64'sb000101_1001110100__111110_0011001100__111111_1011011001__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 7;
        xin_dina = 16'sb000001_0000000000;
        #T;

        // CLOCK 9
        wb2_m_wea = 8'hff;
        wb2_m_addra = 8;  
        wb2_m_dina = 64'sb000000_0110001000__000000_1010001000__0000000000000000__0000000000000000;

        wb2_v_wea = 8'hff;
        wb2_v_addra = 8;
        wb2_v_dina = 64'sb111110_1001001110__111110_1001110010__0000000000000000__0000000000000000;

        wb3_wea = 8'hff;
        wb3_addra = 8;
        wb3_dina = 64'sb000001_0010110101__000010_1000110011__000100_0100101101__0000000000000000;

        xin_wea = 8'hff;
        xin_addra = 8;
        xin_dina = 16'sb000001_0000000000;
        #T;

        // CLOCK 10
        wb2_m_ena = 0;
        wb2_v_ena = 0;
        wb3_ena = 0;
        xin_ena = 0;

        wb2_v_wea = 8'd0;
        wb2_v_addra = 0;
        wb2_v_dina = 64'sb0;

        wb3_wea = 8'd0;
        wb3_addra = 8;
        wb3_dina = 64'sb0;

        xin_wea = 8'd0;
        xin_addra = 8;
        xin_dina = 16'sb0;
        #T;

        // CLOCK 11
        start = 1;
        #T

        // ClOCK 12
        start = 0;
        #T;

        #(T*60);

        // Membaca hasilnya
        xout_enb = 1 ;
        xout_addrb = 0 ; #T;
        xout_addrb = 1 ; #T;
        xout_addrb = 2 ; #T;
        xout_addrb = 3 ; #T;
        xout_addrb = 4 ; #T;
        xout_addrb = 5 ; #T;
        xout_addrb = 6 ; #T;
        xout_addrb = 7 ; #T;
        xout_addrb = 8 ; #T;
        xout_enb = 0 ;
        #T

        $stop;
    end
    
endmodule

