`timescale 1ns / 1ps

module tb_axis_forward_vae_bram();
    localparam T = 10;
    
    reg aclk;
    reg aresetn;
    
    wire s_axis_tready;
    reg [63:0] s_axis_tdata;
    reg s_axis_tvalid;
    reg s_axis_tlast;
    
    reg m_axis_tready;
    wire [63:0] m_axis_tdata;
    wire m_axis_tvalid;
    wire m_axis_tlast;

    // Wire to observe
    // *** Control and status port ***
    wire        vae_ready;
    wire        vae_start;
    wire        vae_done;
    // *** Weight and bias l2 (mean) port ***
    wire         wb2_m_ena;
    wire [3:0]   wb2_m_addra;
    wire [63:0]  wb2_m_dina;
    wire [7:0]   wb2_m_wea;
    // *** Weight and bias l2 (var) port ***
    wire         wb2_v_ena;
    wire [3:0]   wb2_v_addra;
    wire [63:0]  wb2_v_dina;
    wire [7:0]   wb2_v_wea;
    // *** Weight and bias l3 port ***
    wire         wb3_ena;
    wire [3:0]   wb3_addra;
    wire [63:0]  wb3_dina;
    wire [7:0]   wb3_wea;
    // *** Data input port ***
    wire         xin_ena;
    wire [3:0]   xin_addra;
    wire [15:0]  xin_dina;
    wire [7:0]   xin_wea;
    // *** Data output port ***
    wire         xout_enb;
    wire [3:0]   xout_addrb;
    wire [15:0]  xout_doutb;

    wire [8:0] mm2s_data_count;
    wire start_from_mm2s;
    wire [63:0] mm2s_data;

    axis_forward_vae_bram dut
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tlast(m_axis_tlast)
    );

    assign vae_ready = dut.vae_ready;
    assign vae_start = dut.vae_start;
    assign vae_done = dut.vae_done;
    assign wb2_m_ena = dut.wb2_m_ena;
    assign wb2_m_addra = dut.wb2_m_addra;
    assign wb2_m_dina = dut.wb2_m_dina;
    assign wb2_m_wea = dut.wb2_m_wea;
    assign wb2_v_ena = dut.wb2_v_ena;
    assign wb2_v_addra = dut.wb2_v_addra;
    assign wb2_v_dina = dut.wb2_v_dina ;
    assign wb2_v_wea = dut.wb2_v_wea ;
    assign wb3_ena = dut.wb3_ena;
    assign wb3_addra = dut.wb3_addra;
    assign wb3_dina = dut.wb3_dina;
    assign wb3_wea = dut.wb3_wea;
    assign xin_ena = dut.xin_ena;
    assign xin_addra = dut.xin_addra;
    assign xin_dina = dut.xin_dina;
    assign xin_wea = dut.xin_wea;
    assign xout_enb = dut.xout_enb;
    assign xout_addrb = dut.xout_addrb;
    assign xout_doutb = dut.xout_doutb;

    assign mm2s_data_count = dut.mm2s_data_count;
    assign start_from_mm2s = dut.start_from_mm2s;
    assign mm2s_data = dut.mm2s_data;

    always
    begin
        aclk = 0;
        #(T/2);
        aclk = 1;
        #(T/2);
    end

    initial
    begin
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
         m_axis_tready = 1;
                
        aresetn = 0;
        #(T*5);
        aresetn = 1;
        #(T*5);

        s_axis_tvalid = 1;

        // *** Weight and bias l2 mean *** //
        // Weight and bias l2 (1)
        s_axis_tdata = 64'sb0000000000000000__111111_1111111101__111111_0100010111__111111_0011100001;
        #T;
        // Weight and bias l2 (2)
        s_axis_tdata = 64'sb111111_1111111101__000000_0000000100__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (3)
        s_axis_tdata = 64'sb000000_0000000000__111111_1111111101__0000000000000000__0000000000000000;
        #T; 
        // Weight and bias l2 (4)
        s_axis_tdata = 64'sb111111_1111111111__000000_0000000011__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (5)
        s_axis_tdata = 64'sb000000_0000000010__111111_1111111010__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (6)
        s_axis_tdata = 64'sb111111_1111111100__000000_0000000100__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (7)
        s_axis_tdata = 64'sb111111_1101000001__000000_0111110101__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (8)
        s_axis_tdata = 64'sb000001_0011100000__111111_1000011011__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (9)
        s_axis_tdata = 64'sb000000_0110001000__000000_1010001000__0000000000000000__0000000000000000;
        #T;

        // *** Weight and bias l2 var *** //
        // Weight and bias l2 (1)
        s_axis_tdata = 64'sb111111_0001010100__111110_1110001101__111110_0000001001__111101_1101001111;
        #T;
        // Weight and bias l2 (2)
        s_axis_tdata = 64'sb111111_1101101101__000000_0000100101__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (3)
        s_axis_tdata = 64'sb111111_0011100000__111110_1100101000__0000000000000000__0000000000000000;
        #T; 
        // Weight and bias l2 (4)
        s_axis_tdata = 64'sb000000_0001001011__111111_1111111111__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (5)
        s_axis_tdata = 64'sb111111_1001011000__111111_1011110010__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (6)
        s_axis_tdata = 64'sb111111_0110100111__111111_0010111110__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (7)
        s_axis_tdata = 64'sb111110_1101010101__111111_0101000110__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (8)
        s_axis_tdata = 64'sb111111_1011001101__111111_1111001001__0000000000000000__0000000000000000;
        #T;
        // Weight and bias l2 (9)
        s_axis_tdata = 64'sb111110_1001001110__111110_1001110010__0000000000000000__0000000000000000;
        #T;

        // *** Weight and bias l3 *** //
        // Weight and bias l3 (1)
        s_axis_tdata = 64'sb000001_0100001110__000010_1100101111__000100_0011101110__0000000000000000;
        #T;
        // Weight and bias l3 (2)
        s_axis_tdata = 64'sb000101_1010000101__111110_0011111110__111111_1011010000__0000000000000000;
        #T;
        // Weight and bias l3 (3)
        s_axis_tdata = 64'sb000001_0011101110__000010_1010010001__000100_0100010111__0000000000000000;
        #T; 
        // Weight and bias l3 (4)
        s_axis_tdata = 64'sb000101_1001010110__111110_0010010111__111111_1011100110__0000000000000000;
        #T;
        // Weight and bias l3 (5)
        s_axis_tdata = 64'sb111010_1100101011__000010_1011110101__000000_0001100110__0000000000000000;
        #T;
        // Weight and bias l3 (6)
        s_axis_tdata = 64'sb000101_1010110000__111110_0101110001__111111_1010111011__0000000000000000;
        #T;
        // Weight and bias l3 (7)
        s_axis_tdata = 64'sb000001_0101000001__000010_1110010000__000100_0011010111__0000000000000000;
        #T;
        // Weight and bias l3 (8)
        s_axis_tdata = 64'sb000101_1001110100__111110_0011001100__111111_1011011001__0000000000000000;
        #T;
        // Weight and bias l3 (9)
        s_axis_tdata = 64'sb000001_0010110101__000010_1000110011__000100_0100101101__0000000000000000;
        #T;

        // *** Input  *** //
        // Input (1)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (2)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (3)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T; 
        // Input (4)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (5)
        s_axis_tdata = 64'sb000000_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (6)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (7)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (8)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        #T;
        // Input (9)
        s_axis_tdata = 64'sb000001_0000000000__0000000000000000__0000000000000000__0000000000000000;
        s_axis_tlast = 1;
        #T;
        
        s_axis_tvalid = 0;
        s_axis_tdata = 0; 
        s_axis_tlast = 0;

    end
        
endmodule
