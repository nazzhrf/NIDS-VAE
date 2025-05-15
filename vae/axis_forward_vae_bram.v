`timescale 1ns / 1ps
 
module axis_forward_vae_bram
    (
        input wire         aclk,
        input wire         aresetn,
        // *** AXIS slave port ***
        output wire        s_axis_tready,
        input wire [63:0]  s_axis_tdata,
        input wire         s_axis_tvalid,
        input wire         s_axis_tlast,
        // *** AXIS master port ***
        input wire         m_axis_tready,
        output wire [63:0] m_axis_tdata,
        output wire        m_axis_tvalid,
        output wire        m_axis_tlast
    );

    // State machine
    reg [8:0] state_reg, state_next;
    reg [8:0] cnt_word_reg, cnt_word_next;

    // MM2S FIFO    
    wire [8:0] mm2s_data_count;
    wire start_from_mm2s;
    reg mm2s_ready_reg, mm2s_ready_next;
    wire [63:0] mm2s_data;
    
    // *** VAE ******************************************************************************************************
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

    // S2MM FIFO
    wire s2mm_ready;
    wire [63:0] s2mm_data;
    wire s2mm_valid, s2mm_valid_reg;
    wire s2mm_last, s2mm_last_reg;

    // *** MM2S FIFO ************************************************************
    // xpm_fifo_axis: AXI Stream FIFO
    // Xilinx Parameterized Macro, version 2018.3
    xpm_fifo_axis
    #(
        .CDC_SYNC_STAGES(2),                 // DECIMAL
        .CLOCKING_MODE("common_clock"),      // String
        .ECC_MODE("no_ecc"),                 // String
        .FIFO_DEPTH(256),                   // DECIMAL, depth 256 elemen 
        .FIFO_MEMORY_TYPE("auto"),           // String
        .PACKET_FIFO("false"),               // String
        .PROG_EMPTY_THRESH(10),              // DECIMAL
        .PROG_FULL_THRESH(10),               // DECIMAL
        .RD_DATA_COUNT_WIDTH(1),             // DECIMAL
        .RELATED_CLOCKS(0),                  // DECIMAL
        .SIM_ASSERT_CHK(0),                  // DECIMAL
        .TDATA_WIDTH(64),                    // DECIMAL, data width 64 bit
        .TDEST_WIDTH(1),                     // DECIMAL
        .TID_WIDTH(1),                       // DECIMAL
        .TUSER_WIDTH(1),                     // DECIMAL
        .USE_ADV_FEATURES("0004"),           // String, write data count
        .WR_DATA_COUNT_WIDTH(9)              // DECIMAL, width log2(256)+1=9 
    )
    xpm_fifo_axis_0
    (
        .almost_empty_axis(), 
        .almost_full_axis(), 
        .dbiterr_axis(), 
        .prog_empty_axis(), 
        .prog_full_axis(), 
        .rd_data_count_axis(), 
        .sbiterr_axis(), 
        .injectdbiterr_axis(1'b0), 
        .injectsbiterr_axis(1'b0), 
    
        .s_aclk(aclk), // aclk
        .m_aclk(aclk), // aclk
        .s_aresetn(aresetn), // aresetn
        
        .s_axis_tready(s_axis_tready), // ready    
        .s_axis_tdata(s_axis_tdata), // data
        .s_axis_tvalid(s_axis_tvalid), // valid
        .s_axis_tdest(1'b0), 
        .s_axis_tid(1'b0), 
        .s_axis_tkeep(8'hff), 
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tstrb(8'hff), 
        .s_axis_tuser(1'b0), 
        
        .m_axis_tready(mm2s_ready_reg), // ready  
        .m_axis_tdata(mm2s_data), // data
        .m_axis_tvalid(), // valid
        .m_axis_tdest(), 
        .m_axis_tid(), 
        .m_axis_tkeep(), 
        .m_axis_tlast(), 
        .m_axis_tstrb(), 
        .m_axis_tuser(),  
        
        .wr_data_count_axis(mm2s_data_count) // data count
    );
    
    // *** Main control *********************************************************
    // Start signal from DMA MM2S
    assign start_from_mm2s = (mm2s_data_count >= 36); // Weight = 27 word, input = 9 word, total = 36 word
    
    // State machine for AXI-Stream protocol
    always @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_reg <= 0;
            mm2s_ready_reg <= 0;
            cnt_word_reg <= 0;
        end
        else
        begin
            state_reg <= state_next;
            mm2s_ready_reg <= mm2s_ready_next;
            cnt_word_reg <= cnt_word_next;
        end
    end
    
    always @(*)
    begin
        state_next = state_reg;
        mm2s_ready_next = mm2s_ready_reg;
        cnt_word_next = cnt_word_reg;
        case (state_reg)
            0: // Wait until data from MM2S is ready (7 words)
            begin
                if (start_from_mm2s)
                begin
                    state_next = 1;
                    mm2s_ready_next = 1; // Tell the MM2S FIFO that it is ready to accept data
                end
            end
            1: // Write data to weight mean BRAM of the NN
            begin
                if (cnt_word_reg == 8)
                begin
                    state_next = 2;
                    cnt_word_next = 0;
                end
                else
                begin
                    cnt_word_next = cnt_word_reg + 1;
                end
            end
            2: // Write data to weight var BRAM of the NN
            begin
                if (cnt_word_reg == 8)
                begin
                    state_next = 3;
                    cnt_word_next = 0;
                end
                else
                begin
                    cnt_word_next = cnt_word_reg + 1;
                end                
            end
            3: // Write data to weight l3 BRAM of the NN
            begin
                if (cnt_word_reg == 8)
                begin
                    state_next = 4;
                    cnt_word_next = 0;
                end
                else
                begin
                    cnt_word_next = cnt_word_reg + 1;
                end                
            end
            4: // Write data to input BRAM of the NN
            begin
                if (cnt_word_reg == 8)
                begin
                    state_next = 5;
                    mm2s_ready_next = 0;
                    cnt_word_next = 0;
                end
                else
                begin
                    cnt_word_next = cnt_word_reg + 1;
                end                
            end
            5: // Start the NN
            begin
                state_next = 6;
            end
            6: // Wait until VAE computation done and S2MM FIFO is ready to accept data
            begin
                if (vae_done && s2mm_ready)
                begin
                    state_next = 7;
                end
            end
            7: // Read data output from BRAM of the VAE
            begin
                if (cnt_word_reg == 8)
                begin
                    state_next = 0;
                    cnt_word_next = 0;
                end
                else
                begin
                    cnt_word_next = cnt_word_reg + 1;
                end
            end
        endcase
    end

    // Control weight mean port VAE
    assign wb2_m_ena = (state_reg == 1) ? 1 : 0;
    assign wb2_m_addra = cnt_word_reg;
    assign wb2_m_dina = mm2s_data;
    assign wb2_m_wea = (state_reg == 1) ? 8'hff : 0;

    // Control weight var port VAE
    assign wb2_v_ena = (state_reg == 2) ? 1 : 0;
    assign wb2_v_addra = cnt_word_reg;
    assign wb2_v_dina = mm2s_data;
    assign wb2_v_wea = (state_reg == 2) ? 8'hff : 0;

    // Control weight l3 port VAE
    assign wb3_ena = (state_reg == 3) ? 1 : 0;
    assign wb3_addra = cnt_word_reg;
    assign wb3_dina = mm2s_data;
    assign wb3_wea = (state_reg == 3) ? 8'hff : 0;
    
    // Control data input port VAE
    assign xin_ena = (state_reg == 4) ? 1 : 0;
    assign xin_addra = cnt_word_reg;
    assign xin_dina = mm2s_data[63:48];
    assign xin_wea = (state_reg == 4) ? 8'hff : 0;
    
    // Start NN
    assign vae_start = (state_reg == 5) ? 1 : 0;
    
    // Control data output port NN
    assign xout_enb = (state_reg == 7) ? 1 : 0;
    assign xout_addrb = cnt_word_reg;

    // Control S2MM FIFO
    assign s2mm_data = {xout_doutb, 48'd0} ;
    assign s2mm_valid = xout_enb;
    register #(1) reg_s2mm_valid(aclk, aresetn, 1'b0, s2mm_valid, s2mm_valid_reg); 
    assign s2mm_last = ((state_reg == 7) && (xout_addrb == 8)) ? 1 : 0;
    register #(1) reg_s2mm_last(aclk, aresetn, 1'b0, s2mm_last, s2mm_last_reg);

    // *** VAE **********************************************************************************************************************************************
    forward_vae_bram vae_0
    (
        .clk(aclk),
        .rst_n(aresetn),
        .en(1'b1),
        .clr(1'b0),
        .ready(vae_ready),
        .start(vae_start),
        .done(vae_done),

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

    // *** S2MM FIFO ************************************************************
    // xpm_fifo_axis: AXI Stream FIFO
    // Xilinx Parameterized Macro, version 2018.3
    xpm_fifo_axis
    #(
        .CDC_SYNC_STAGES(2),                 // DECIMAL
        .CLOCKING_MODE("common_clock"),      // String
        .ECC_MODE("no_ecc"),                 // String
        .FIFO_DEPTH(256),                    // DECIMAL, depth 256 elemen 
        .FIFO_MEMORY_TYPE("auto"),           // String
        .PACKET_FIFO("false"),               // String
        .PROG_EMPTY_THRESH(10),              // DECIMAL
        .PROG_FULL_THRESH(10),               // DECIMAL
        .RD_DATA_COUNT_WIDTH(1),             // DECIMAL
        .RELATED_CLOCKS(0),                  // DECIMAL
        .SIM_ASSERT_CHK(0),                  // DECIMAL
        .TDATA_WIDTH(64),                    // DECIMAL, data width 64 bit
        .TDEST_WIDTH(1),                     // DECIMAL
        .TID_WIDTH(1),                       // DECIMAL
        .TUSER_WIDTH(1),                     // DECIMAL
        .USE_ADV_FEATURES("0004"),           // String, write data count
        .WR_DATA_COUNT_WIDTH(9)              // DECIMAL, width log2(256)+1=9 
    )
    xpm_fifo_axis_1
    (
        .almost_empty_axis(), 
        .almost_full_axis(), 
        .dbiterr_axis(), 
        .prog_empty_axis(), 
        .prog_full_axis(), 
        .rd_data_count_axis(), 
        .sbiterr_axis(), 
        .injectdbiterr_axis(1'b0), 
        .injectsbiterr_axis(1'b0), 
    
        .s_aclk(aclk), // aclk
        .m_aclk(aclk), // aclk
        .s_aresetn(aresetn), // aresetn
        
        .s_axis_tready(s2mm_ready), // ready    
        .s_axis_tdata(s2mm_data), // data
        .s_axis_tvalid(s2mm_valid_reg), // valid
        .s_axis_tdest(1'b0), 
        .s_axis_tid(1'b0), 
        .s_axis_tkeep(8'hff), 
        .s_axis_tlast(s2mm_last_reg),
        .s_axis_tstrb(8'hff), 
        .s_axis_tuser(1'b0), 
        
        .m_axis_tready(m_axis_tready), // ready  
        .m_axis_tdata(m_axis_tdata), // data
        .m_axis_tvalid(m_axis_tvalid), // valid
        .m_axis_tdest(), 
        .m_axis_tid(), 
        .m_axis_tkeep(), 
        .m_axis_tlast(m_axis_tlast), 
        .m_axis_tstrb(), 
        .m_axis_tuser(),  
        
        .wr_data_count_axis() // data count
    );

endmodule
