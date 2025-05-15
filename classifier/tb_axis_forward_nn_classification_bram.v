`timescale 1ns / 1ps

module tb_axis_forward_nn_classification_bram();
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
    wire        nn_classification_ready;
    wire        nn_classification_start;
    wire        nn_classification_done;
    // *** Weight and bias l2 (mean) port ***
    wire         xij_ena;
    wire [3:0]   xij_addra;
    wire [63:0]  xij_dina;
    wire [7:0]   xij_wea;
    // *** Weight and bias l2 (var) port ***
    wire         wb_ena;
    wire [3:0]   wb_addra;
    wire [63:0]  wb_dina;
    wire [7:0]   wb_wea;
    // *** Data output port ***
    wire         xout_enb;
    wire [3:0]   xout_addrb;
    wire [15:0]  xout_doutb;

    wire [8:0] mm2s_data_count;
    wire start_from_mm2s;
    wire [63:0] mm2s_data;

    wire s2mm_ready;
    wire [63:0] s2mm_data;
    wire s2mm_last;
    wire s2mm_valid;

    axis_forward_nn_classification_bram dut
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

    assign nn_classification_ready = dut.nn_classification_ready;
    assign nn_classification_start = dut.nn_classification_start;
    assign nn_classification_done = dut.nn_classification_done;

    assign xij_ena = dut.xij_ena;
    assign xij_addra = dut.xij_addra;
    assign xij_dina = dut.xij_dina;
    assign xij_wea = dut.xij_wea;

    assign wb_ena = dut.wb_ena;
    assign wb_addra = dut.wb_addra;
    assign wb_dina = dut.wb_dina ;
    assign wb_wea = dut.wb_wea ;

    assign xout_enb = dut.xout_enb;
    assign xout_addrb = dut.xout_addrb;
    assign xout_doutb = dut.xout_doutb;

    assign mm2s_data_count = dut.mm2s_data_count;
    assign start_from_mm2s = dut.start_from_mm2s;
    assign mm2s_data = dut.mm2s_data;

    assign s2mm_ready = dut.s2mm_ready;
    assign s2mm_data = dut.s2mm_data;
    assign s2mm_last = dut.s2mm_last;
    assign s2mm_valid = dut.s2mm_valid;

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

        // *** Input *** //
        // Input x1j__x2j__x3j__16'x4j (j = 1)
        s_axis_tdata = 64'h0316_0B57_03D1_01ED;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 2)
        s_axis_tdata = 64'h0171__0B92__0378__05E9;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 3)
        s_axis_tdata = 64'h02A2__0C7B__0148__05FA;
        #T; 
        // Input x1j__x2j__x3j__16'd0 (j = 4)
        s_axis_tdata = 64'h02FF__09BA__0391__03DE;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 5)
        s_axis_tdata = 64'h0446__0BD5__00D0__030A;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 6)
        s_axis_tdata = 64'h00D8__0A1F__023C__01AF;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 7)
        s_axis_tdata = 64'h0325__0C89__0369__044A;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 8)
        s_axis_tdata = 64'h03CA__0DB2__021C__0416;
        #T;
        // Input x1j__x2j__x3j__16'd0 (j = 9)
        s_axis_tdata = 64'h0123__0D03__014F__0406;
        #T;
        // Bias
        s_axis_tdata = 64'h3C00__3C00__3C00__3C00;
        #T;
        
        // 64'hF1B3__CBC6__FE00__039D;

        // *** Weight and bias *** //
        // Weight (1)
        s_axis_tdata = 64'h01B5__0000__0282__021F;
        #T;
        // Weight (2)
        s_axis_tdata = 64'h01B5__0000__0281__021E;
        #T;
        // Weight (3)
        s_axis_tdata = 64'h00EC__0000__0281__021E;
        #T; 
        // Weight (4)
        s_axis_tdata = 64'h00E4__0000__0281__021E;
        #T;
        // Weight (5)
        s_axis_tdata = 64'h012E__0000__0281__021E;
        #T;
        // Weight (6)
        s_axis_tdata = 64'h0355__0000__0282__021F;
        #T;
        // Weight (7)
        s_axis_tdata = 64'h01D0__0000__0282__021F;
        #T;
        // Weight (8)
        s_axis_tdata = 64'h0355__0000__0281__021D;
        #T;
        // Weight (9)
        s_axis_tdata = 64'h0355__0000__0282__021E;
        #T;
        // Bias (10)
        // s_axis_tdata = 64'sb111100_1110100011__0000000000000000__0000000000000000__0000000000000000;
        // s_axis_tlast = 1;
        // #T;
        
        s_axis_tvalid = 0;
        s_axis_tdata = 0; 
        s_axis_tlast = 0;

    end
        
endmodule
