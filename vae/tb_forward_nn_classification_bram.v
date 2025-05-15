`timescale 1ns / 1ps

module tb_forward_nn_classification_bram();
    localparam T = 10;

    // INPUT OUTPUT
    
    reg clk;
    reg rst_n;
    reg en;
    reg clr;

    wire ready;
    reg start;
    wire done;

    reg xij_ena;
    reg [3:0]  xij_addra;
    reg [63:0] xij_dina;
    reg [7:0]  xij_wea;  

    reg wb_ena;
    reg [3:0]  wb_addra;
    reg [63:0] wb_dina;
    reg [7:0]  wb_wea;       

    reg xout_enb;
    reg [3:0]   xout_addrb;
    wire [15:0] xout_doutb;

    // SINYAL ANTARA //
    // Wire for port b of BRAM xij
    wire xij_enb;
    wire [3:0] xij_addrb;
    wire [63:0] xij_doutb;
    // Wire for port b of BRAM wb
    wire wb_enb;
    wire [3:0] wb_addrb;
    wire [63:0] wb_doutb;
    // Wire for port a of BRAM output
    wire xout_ena;
    wire [3:0] xout_addra;
    wire [7:0] xout_wea;
    wire [15:0] xout_dina;

    // Wire to saved xij_doutb value per 16 bits
    wire [15:0] xij_doutb_0, xij_doutb_1, xij_doutb_2 ;
    // Wire to saved wb2_doutb value per 16 bits
    wire [15:0] wb_doutb_0 ;

    // Input connection
    wire start_nn_classification ; 
    wire signed [15:0] x1j, x2j, x3j ;
    wire signed [15:0] wj, b1 ;
    // Output connection
    wire signed [15:0] sys2x1_res1, sys2x1_res2 , sys2x1_res3 ;
    wire signed [15:0] z1, z2, z3 ;
    wire signed [15:0] a1, a2, a3 ;
    wire unhealthy ;
    wire done_nn_classification ;

    // Wire to observe values
    wire signed [15:0] a1_w, a2_w, a3_w;
    wire signed [15:0] unhealty_w;
    wire signed [15:0] out_w;

    forward_nn_classification_bram dut
    (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .clr(clr),
        .ready(ready),
        .start(start),
        .done(done),

        .xij_ena(xij_ena),
        .xij_addra(xij_addra),
        .xij_dina(xij_dina),
        .xij_wea(xij_wea),

        .wb_ena(wb_ena),
        .wb_addra(wb_addra),
        .wb_dina(wb_dina),
        .wb_wea(wb_wea),

        .xout_enb(xout_enb),
        .xout_addrb(xout_addrb),
        .xout_doutb(xout_doutb)
    );

    assign xij_enb = dut.xij_enb;
    assign xij_addrb = dut.xij_addrb;
    assign xij_doutb = dut.xij_doutb;
    assign wb_enb = dut.wb_enb;
    assign wb_addrb = dut.wb_addrb;
    assign wb_doutb = dut.wb_doutb;
    assign xout_ena = dut.xout_ena;
    assign xout_addra = dut.xout_addra;
    assign xout_wea = dut.xout_wea;
    assign xout_dina = dut.xout_dina;

    assign xij_doutb_0 = dut.xij_doutb_0;
    assign xij_doutb_1 = dut.xij_doutb_1;
    assign xij_doutb_2 = dut.xij_doutb_2;
    assign wb_doutb_0 = dut.wb_doutb_0;

    assign start_nn_classification = dut.start_nn_classification;
    assign x1j = dut.x1j;
    assign x2j = dut.x2j;
    assign x3j = dut.x3j;
    assign wj = dut.wj;
    assign b1 = dut.b1;
    assign sys2x1_res1 = dut.sys2x1_res1;
    assign sys2x1_res2 = dut.sys2x1_res2;
    assign sys2x1_res3 = dut.sys2x1_res3;
    assign z1 = dut.z1;
    assign z2 = dut.z2;
    assign z3 = dut.z3;
    assign a1 = dut.a1;
    assign a2 = dut.a2;
    assign a3 = dut.a3;
    assign unhealthy = dut.unhealthy;
    assign done_nn_classification = dut.done_nn_classification;

    assign a1_w = dut.a1_w ;
    assign a2_w = dut.a2_w ;
    assign a3_w = dut.a3_w ;
    assign unhealty_w = dut.unhealty_w ;
    assign out_w = dut.out_w ;

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

        xij_ena = 1;
        xij_addra = 0;
        xij_dina = 0;
        xij_wea = 0;

        wb_ena = 1;
        wb_addra = 0;
        wb_dina = 0;
        wb_wea = 0;

        xout_enb = 0;
        xout_addrb = 0;
        
        rst_n = 0;
        #(T*1);
        rst_n = 1;
        
        // *** Testvector 1 ***
        // Write weight and bias

        // CLOCK 1
        xij_wea = 8'hff;
        xij_addra = 0;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 0;
        wb_dina = 64'sb000000_1101001100__0000000000000000__0000000000000000__0000000000000000;

        #T;  

        // CLOCK 2
        xij_wea = 8'hff;
        xij_addra = 1;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 1;
        wb_dina = 64'sb000001_1001001111__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 3
        xij_wea = 8'hff;
        xij_addra = 2;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 2;
        wb_dina = 64'sb000001_1001111101__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 4
        xij_wea = 8'hff;
        xij_addra = 3;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 3;
        wb_dina = 64'sb000001_0010001010__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 5
        xij_wea = 8'hff;
        xij_addra = 4;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 4;
        wb_dina = 64'sb000001_0001001111__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 6
        xij_wea = 8'hff;
        xij_addra = 5;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 5;
        wb_dina = 64'sb000000_1111001001__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 7
        xij_wea = 8'hff;
        xij_addra = 6;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 6;
        wb_dina = 64'sb000001_0101100011__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 8
        xij_wea = 8'hff;
        xij_addra = 7;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 7;
        wb_dina = 64'sb000001_0010111010__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 9
        xij_wea = 8'hff;
        xij_addra = 8;
        xij_dina = 64'sb000000_0000000000__000000_0000000000__000000_0000000000__0000000000000000;

        wb_wea = 8'hff;
        wb_addra = 8;
        wb_dina = 64'sb000001_1010011101__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 10
        wb_wea = 8'hff;
        wb_addra = 9;
        wb_dina = 64'sb111100_1110100011__0000000000000000__0000000000000000__0000000000000000;

        #T;

        // CLOCK 11
        xij_ena = 0;
        wb_ena = 0;

        xij_wea = 8'd0;
        xij_addra = 0;
        xij_dina = 64'sb0;

        wb_wea = 8'd0;
        wb_addra = 8;
        wb_dina = 64'sb0;

        #T;

        // CLOCK 12
        start = 1;
        #T

        // ClOCK 13
        start = 0;
        #T;

        #(T*30);

        // Membaca hasilnya
        xout_enb = 1 ;
        xout_addrb = 0 ; #T;
        xout_addrb = 1 ; #T;
        xout_addrb = 2 ; #T;
        xout_addrb = 3 ; #T;
        xout_enb = 0 ;
        #T

        $stop;
    end
    
endmodule

