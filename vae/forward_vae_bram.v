`timescale 1ns / 1ps

module forward_vae_bram
    (
        input wire         clk,
        input wire         rst_n,
        input wire         en,
        input wire         clr,
        // *** Control and status port ***
        output wire        ready,
        input wire         start,
        output wire        done,
        // *** Weight and bias l2 (mean) port ***
        input wire         wb2_m_ena,
        input wire [3:0]   wb2_m_addra,
        input wire [63:0]  wb2_m_dina,
        input wire [7:0]   wb2_m_wea,
        // *** Weight and bias l2 (var) port ***
        input wire         wb2_v_ena,
        input wire [3:0]   wb2_v_addra,
        input wire [63:0]  wb2_v_dina,
        input wire [7:0]   wb2_v_wea,
        // *** Weight and bias l3 port ***
        input wire         wb3_ena,
        input wire [3:0]   wb3_addra,
        input wire [63:0]  wb3_dina,
        input wire [7:0]   wb3_wea,
        // *** Data input port ***
        input wire         xin_ena,
        input wire [3:0]   xin_addra,
        input wire [15:0]  xin_dina,
        input wire [7:0]   xin_wea,
        // *** Data output port ***
        input wire         xout_enb,
        input wire [3:0]   xout_addrb,
        output wire [15:0] xout_doutb
    );

    // *** WIRE TO CONTROL ANOTHER PORT OF BRAM ********************************************************************************************************************************
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

    // *** WIRE TO SAVED BRAM READ OUTPUT TEMPORARELY ********************************************************************************************************************************
    // Wire to saved wb2_m_doutb value per 16 bits
    wire [15:0] wb2_m_doutb_0, wb2_m_doutb_1, wb2_m_doutb_2, wb2_m_doutb_3;
    // Wire to saved wb2_v_doutb value per 16 bits
    wire [15:0] wb2_v_doutb_0, wb2_v_doutb_1, wb2_v_doutb_2, wb2_v_doutb_3;
    // Wire to saved wb3_doutb value per 16 bits
    wire [15:0] wb3_doutb_0, wb3_doutb_1, wb3_doutb_2;

    // *** L2 WEIGHT AND BIAS MEAN BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(576),                   // DECIMAL, size: 8x64bit= 512 bits
        .MEMORY_PRIMITIVE("auto"),           // String
        .CLOCKING_MODE("common_clock"),      // String, "common_clock"
        .MEMORY_INIT_FILE("none"),           // String
        .MEMORY_INIT_PARAM("0"),             // String      
        .USE_MEM_INIT(1),                    // DECIMAL
        .WAKEUP_TIME("disable_sleep"),       // String
        .MESSAGE_CONTROL(0),                 // DECIMAL
        .AUTO_SLEEP_TIME(0),                 // DECIMAL          
        .ECC_MODE("no_ecc"),                 // String
        .MEMORY_OPTIMIZATION("true"),        // String              
        .USE_EMBEDDED_CONSTRAINT(0),         // DECIMAL
        
        // Port A module parameters
        .WRITE_DATA_WIDTH_A(64),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_A(64),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_A(8),              // DECIMAL
        .ADDR_WIDTH_A(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_A("0"),            // String
        .READ_LATENCY_A(1),                  // DECIMAL
        .WRITE_MODE_A("write_first"),        // String
        .RST_MODE_A("SYNC"),                 // String
        
        // Port B module parameters  
        .WRITE_DATA_WIDTH_B(64),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_B(64),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_B(8),              // DECIMAL
        .ADDR_WIDTH_B(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_B("0"),            // String
        .READ_LATENCY_B(1),                  // DECIMAL
        .WRITE_MODE_B("write_first"),        // String
        .RST_MODE_B("SYNC")                  // String
    )
    xpm_memory_tdpram_l2wbmean
    (
        .sleep(1'b0),
        .regcea(1'b1), //do not change
        .injectsbiterra(1'b0), //do not change
        .injectdbiterra(1'b0), //do not change   
        .sbiterra(), //do not change
        .dbiterra(), //do not change
        .regceb(1'b1), //do not change
        .injectsbiterrb(1'b0), //do not change
        .injectdbiterrb(1'b0), //do not change              
        .sbiterrb(), //do not change
        .dbiterrb(), //do not change
        
        // Port A module ports
        .clka(clk),
        .rsta(~rst_n),
        .ena(wb2_m_ena),
        .wea(wb2_m_wea),
        .addra(wb2_m_addra),
        .dina(wb2_m_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(wb2_m_enb),
        .web(0),
        .addrb(wb2_m_addrb),
        .dinb(0),
        .doutb(wb2_m_doutb)
    );
    assign wb2_m_doutb_0 = wb2_m_doutb[63:48] ; // to saved nnl2_mean_w1j values
    assign wb2_m_doutb_1 = wb2_m_doutb[47:32] ; // to saved nnl2_mean_w2j values
    assign wb2_m_doutb_2 = wb2_m_doutb[31:16] ; // to saved nnl2_mean_b1 values
    assign wb2_m_doutb_3 = wb2_m_doutb[15:0] ; // to saved nnl2_mean_b2 values

    // *** L2 WEIGHT AND BIAS VAR BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(576),                   // DECIMAL, size: 8x64bit= 512 bits
        .MEMORY_PRIMITIVE("auto"),           // String
        .CLOCKING_MODE("common_clock"),      // String, "common_clock"
        .MEMORY_INIT_FILE("none"),           // String
        .MEMORY_INIT_PARAM("0"),             // String      
        .USE_MEM_INIT(1),                    // DECIMAL
        .WAKEUP_TIME("disable_sleep"),       // String
        .MESSAGE_CONTROL(0),                 // DECIMAL
        .AUTO_SLEEP_TIME(0),                 // DECIMAL          
        .ECC_MODE("no_ecc"),                 // String
        .MEMORY_OPTIMIZATION("true"),        // String              
        .USE_EMBEDDED_CONSTRAINT(0),         // DECIMAL
        
        // Port A module parameters
        .WRITE_DATA_WIDTH_A(64),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_A(64),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_A(8),              // DECIMAL
        .ADDR_WIDTH_A(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_A("0"),            // String
        .READ_LATENCY_A(1),                  // DECIMAL
        .WRITE_MODE_A("write_first"),        // String
        .RST_MODE_A("SYNC"),                 // String
        
        // Port B module parameters  
        .WRITE_DATA_WIDTH_B(64),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_B(64),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_B(8),              // DECIMAL
        .ADDR_WIDTH_B(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_B("0"),            // String
        .READ_LATENCY_B(1),                  // DECIMAL
        .WRITE_MODE_B("write_first"),        // String
        .RST_MODE_B("SYNC")                  // String
    )
    xpm_memory_tdpram_l2wbvar
    (
        .sleep(1'b0),
        .regcea(1'b1), //do not change
        .injectsbiterra(1'b0), //do not change
        .injectdbiterra(1'b0), //do not change   
        .sbiterra(), //do not change
        .dbiterra(), //do not change
        .regceb(1'b1), //do not change
        .injectsbiterrb(1'b0), //do not change
        .injectdbiterrb(1'b0), //do not change              
        .sbiterrb(), //do not change
        .dbiterrb(), //do not change
        
        // Port A module ports
        .clka(clk),
        .rsta(~rst_n),
        .ena(wb2_v_ena),
        .wea(wb2_v_wea),
        .addra(wb2_v_addra),
        .dina(wb2_v_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(wb2_v_enb),
        .web(0),
        .addrb(wb2_v_addrb),
        .dinb(0),
        .doutb(wb2_v_doutb)
    );
    assign wb2_v_doutb_0 = wb2_v_doutb[63:48] ; // to saved nnl2_var_w1j values
    assign wb2_v_doutb_1 = wb2_v_doutb[47:32] ; // to saved nnl2_var_w2j values
    assign wb2_v_doutb_2 = wb2_v_doutb[31:16] ; // to saved nnl2_var_b1 values
    assign wb2_v_doutb_3 = wb2_v_doutb[15:0] ; // to saved nnl2_var_b2 values

    // *** L3 WEIGHT AND BIAS BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(576),                   // DECIMAL, size: 8x64bit= 512 bits
        .MEMORY_PRIMITIVE("auto"),           // String
        .CLOCKING_MODE("common_clock"),      // String, "common_clock"
        .MEMORY_INIT_FILE("none"),           // String
        .MEMORY_INIT_PARAM("0"),             // String      
        .USE_MEM_INIT(1),                    // DECIMAL
        .WAKEUP_TIME("disable_sleep"),       // String
        .MESSAGE_CONTROL(0),                 // DECIMAL
        .AUTO_SLEEP_TIME(0),                 // DECIMAL          
        .ECC_MODE("no_ecc"),                 // String
        .MEMORY_OPTIMIZATION("true"),        // String              
        .USE_EMBEDDED_CONSTRAINT(0),         // DECIMAL
        
        // Port A module parameters
        .WRITE_DATA_WIDTH_A(64),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_A(64),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_A(8),              // DECIMAL
        .ADDR_WIDTH_A(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_A("0"),            // String
        .READ_LATENCY_A(1),                  // DECIMAL
        .WRITE_MODE_A("write_first"),        // String
        .RST_MODE_A("SYNC"),                 // String
        
        // Port B module parameters  
        .WRITE_DATA_WIDTH_B(64),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_B(64),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_B(8),              // DECIMAL
        .ADDR_WIDTH_B(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_B("0"),            // String
        .READ_LATENCY_B(1),                  // DECIMAL
        .WRITE_MODE_B("write_first"),        // String
        .RST_MODE_B("SYNC")                  // String
    )
    xpm_memory_tdpram_l3wb
    (
        .sleep(1'b0),
        .regcea(1'b1), //do not change
        .injectsbiterra(1'b0), //do not change
        .injectdbiterra(1'b0), //do not change   
        .sbiterra(), //do not change
        .dbiterra(), //do not change
        .regceb(1'b1), //do not change
        .injectsbiterrb(1'b0), //do not change
        .injectdbiterrb(1'b0), //do not change              
        .sbiterrb(), //do not change
        .dbiterrb(), //do not change
        
        // Port A module ports
        .clka(clk),
        .rsta(~rst_n),
        .ena(wb3_ena),
        .wea(wb3_wea),
        .addra(wb3_addra),
        .dina(wb3_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(wb3_enb),
        .web(0),
        .addrb(wb3_addrb),
        .dinb(0),
        .doutb(wb3_doutb)
    );
    assign wb3_doutb_0 = wb3_doutb[63:48] ; // to saved nnl3_wj1 values
    assign wb3_doutb_1 = wb3_doutb[47:32] ; // to saved nnl3_wj2 values
    assign wb3_doutb_2 = wb3_doutb[31:16] ; // to saved nnl3_b values
    
    // *** INPUT BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(144),                   // DECIMAL, size: 8x64bit= 512 bits
        .MEMORY_PRIMITIVE("auto"),           // String
        .CLOCKING_MODE("common_clock"),      // String, "common_clock"
        .MEMORY_INIT_FILE("none"),           // String
        .MEMORY_INIT_PARAM("0"),             // String      
        .USE_MEM_INIT(1),                    // DECIMAL
        .WAKEUP_TIME("disable_sleep"),       // String
        .MESSAGE_CONTROL(0),                 // DECIMAL
        .AUTO_SLEEP_TIME(0),                 // DECIMAL          
        .ECC_MODE("no_ecc"),                 // String
        .MEMORY_OPTIMIZATION("true"),        // String              
        .USE_EMBEDDED_CONSTRAINT(0),         // DECIMAL
        
        // Port A module parameters
        .WRITE_DATA_WIDTH_A(16),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_A(16),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_A(8),              // DECIMAL
        .ADDR_WIDTH_A(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_A("0"),            // String
        .READ_LATENCY_A(1),                  // DECIMAL
        .WRITE_MODE_A("write_first"),        // String
        .RST_MODE_A("SYNC"),                 // String
        
        // Port B module parameters  
        .WRITE_DATA_WIDTH_B(16),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_B(16),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_B(8),              // DECIMAL
        .ADDR_WIDTH_B(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_B("0"),            // String
        .READ_LATENCY_B(1),                  // DECIMAL
        .WRITE_MODE_B("write_first"),        // String
        .RST_MODE_B("SYNC")                  // String
    )
    xpm_memory_tdpram_inp
    (
        .sleep(1'b0),
        .regcea(1'b1), //do not change
        .injectsbiterra(1'b0), //do not change
        .injectdbiterra(1'b0), //do not change   
        .sbiterra(), //do not change
        .dbiterra(), //do not change
        .regceb(1'b1), //do not change
        .injectsbiterrb(1'b0), //do not change
        .injectdbiterrb(1'b0), //do not change              
        .sbiterrb(), //do not change
        .dbiterrb(), //do not change
        
        // Port A module ports
        .clka(clk),
        .rsta(~rst_n),
        .ena(xin_ena),
        .wea(xin_wea),
        .addra(xin_addra),
        .dina(xin_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(xin_enb),
        .web(0),
        .addrb(xin_addrb),
        .dinb(0),
        .doutb(xin_doutb)
    );

    // *** OUTPUT BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(144),                   // DECIMAL, size: 8x64bit= 512 bits
        .MEMORY_PRIMITIVE("auto"),           // String
        .CLOCKING_MODE("common_clock"),      // String, "common_clock"
        .MEMORY_INIT_FILE("none"),           // String
        .MEMORY_INIT_PARAM("0"),             // String      
        .USE_MEM_INIT(1),                    // DECIMAL
        .WAKEUP_TIME("disable_sleep"),       // String
        .MESSAGE_CONTROL(0),                 // DECIMAL
        .AUTO_SLEEP_TIME(0),                 // DECIMAL          
        .ECC_MODE("no_ecc"),                 // String
        .MEMORY_OPTIMIZATION("true"),        // String              
        .USE_EMBEDDED_CONSTRAINT(0),         // DECIMAL
        
        // Port A module parameters
        .WRITE_DATA_WIDTH_A(16),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_A(16),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_A(8),              // DECIMAL
        .ADDR_WIDTH_A(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_A("0"),            // String
        .READ_LATENCY_A(1),                  // DECIMAL
        .WRITE_MODE_A("write_first"),        // String
        .RST_MODE_A("SYNC"),                 // String
        
        // Port B module parameters  
        .WRITE_DATA_WIDTH_B(16),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_B(16),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_B(8),              // DECIMAL
        .ADDR_WIDTH_B(4),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_B("0"),            // String
        .READ_LATENCY_B(1),                  // DECIMAL
        .WRITE_MODE_B("write_first"),        // String
        .RST_MODE_B("SYNC")                  // String
    )
    xpm_memory_tdpram_out
    (
        .sleep(1'b0),
        .regcea(1'b1), //do not change
        .injectsbiterra(1'b0), //do not change
        .injectdbiterra(1'b0), //do not change   
        .sbiterra(), //do not change
        .dbiterra(), //do not change
        .regceb(1'b1), //do not change
        .injectsbiterrb(1'b0), //do not change
        .injectdbiterrb(1'b0), //do not change              
        .sbiterrb(), //do not change
        .dbiterrb(), //do not change
        
        // Port A module ports
        .clka(clk),
        .rsta(~rst_n),
        .ena(xout_ena),
        .wea(xout_wea),
        .addra(xout_addra),
        .dina(xout_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(xout_enb),
        .web(0),
        .addrb(xout_addrb),
        .dinb(0),
        .doutb(xout_doutb)
    );

    // *** REGISTER TO SAVE INPUT AND OUTPUT VALUES OF FORWARD VAE MODULE'S INPUT ******************************************************************************************************************************
    // Input and layer 2 parameters
    reg signed [15:0] xj_reg ;
    reg signed [15:0] nnl2_mean_w1j_reg, nnl2_mean_w2j_reg, nnl2_mean_b1_reg, nnl2_mean_b2_reg ;
    reg signed [15:0] nnl2_var_w1j_reg, nnl2_var_w2j_reg, nnl2_var_b1_reg, nnl2_var_b2_reg ;
    reg signed [15:0] nnl3_w1i_reg, nnl3_w2i_reg, nnl3_w3i_reg, nnl3_w4i_reg, nnl3_w5i_reg, nnl3_w6i_reg, nnl3_w7i_reg, nnl3_w8i_reg, nnl3_w9i_reg ;
    reg signed [15:0] nnl3_b1_reg, nnl3_b2_reg, nnl3_b3_reg, nnl3_b4_reg, nnl3_b5_reg, nnl3_b6_reg, nnl3_b7_reg, nnl3_b8_reg, nnl3_b9_reg ;
    // register to save all layer 3 weight and bias values
    reg signed [15:0] w3_11_reg,  w3_12_reg;
    reg signed [15:0] w3_21_reg,  w3_22_reg;
    reg signed [15:0] w3_31_reg,  w3_32_reg;
    reg signed [15:0] w3_41_reg,  w3_42_reg;
    reg signed [15:0] w3_51_reg,  w3_52_reg;
    reg signed [15:0] w3_61_reg,  w3_62_reg;
    reg signed [15:0] w3_71_reg,  w3_72_reg;
    reg signed [15:0] w3_81_reg,  w3_82_reg;
    reg signed [15:0] w3_91_reg,  w3_92_reg;
    reg signed [15:0] b3_1_reg, b3_2_reg, b3_3_reg, b3_4_reg, b3_5_reg, b3_6_reg, b3_7_reg, b3_8_reg, b3_9_reg;
    // Output 
    reg signed [15:0] a3_reg;

    // *** WIRE TO OBSERVE VALUES ********************************************************************************************
    // all l3 parameters
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

    // *** CONNECTION TO FORWARD VAE MODULE ********************************************************************************************************************************
    // Input connection
    wire start_vae ; 
    wire signed [15:0] xj ;
    wire signed [15:0] nnl2_mean_w1j, nnl2_mean_w2j, nnl2_mean_b1, nnl2_mean_b2 ;
    wire signed [15:0] nnl2_var_w1j, nnl2_var_w2j, nnl2_var_b1, nnl2_var_b2 ;
    wire signed [15:0] nnl3_w1i, nnl3_w2i, nnl3_w3i, nnl3_w4i, nnl3_w5i, nnl3_w6i, nnl3_w7i, nnl3_w8i, nnl3_w9i ;
    wire signed [15:0] nnl3_b1, nnl3_b2, nnl3_b3, nnl3_b4, nnl3_b5, nnl3_b6, nnl3_b7, nnl3_b8, nnl3_b9 ;
    // Output connection
    wire signed [15:0] sys2x1_mean_res1, sys2x1_mean_res2 , z1_mean, z2_mean ;
    wire signed [15:0] sys2x1_var_res1, sys2x1_var_res2 , z1_var, z2_var ;
    wire signed [15:0] sys9x1_res1, sys9x1_res2 , sys9x1_res3, sys9x1_res4, sys9x1_res5, sys9x1_res6, sys9x1_res7, sys9x1_res8, sys9x1_res9;
    wire signed [15:0] a3_1, a3_2, a3_3, a3_4, a3_5, a3_6, a3_7, a3_8, a3_9;
    wire done_vae ;

    // *** ASSIGN REGISTER'S VALUES TO A WIRE SO IT'S EASIER TO OBSERVE ******************************************************************************************************************************
    // Assign top forward vae's input
    assign xj = xj_reg ;
    assign nnl2_mean_w1j = nnl2_mean_w1j_reg ;
    assign nnl2_mean_w2j = nnl2_mean_w2j_reg ;
    assign nnl2_mean_b1  = nnl2_mean_b1_reg ;
    assign nnl2_mean_b2  = nnl2_mean_b2_reg ;
    assign nnl2_var_w1j  = nnl2_var_w1j_reg ;
    assign nnl2_var_w2j  = nnl2_var_w2j_reg ;
    assign nnl2_var_b1   = nnl2_var_b1_reg ;
    assign nnl2_var_b2   = nnl2_var_b2_reg ;
    assign nnl3_w1i      = nnl3_w1i_reg ;
    assign nnl3_w2i      = nnl3_w2i_reg ;
    assign nnl3_w3i      = nnl3_w3i_reg ;
    assign nnl3_w4i      = nnl3_w4i_reg ;
    assign nnl3_w5i      = nnl3_w5i_reg ;
    assign nnl3_w6i      = nnl3_w6i_reg ;
    assign nnl3_w7i      = nnl3_w7i_reg ;
    assign nnl3_w8i      = nnl3_w8i_reg ;
    assign nnl3_w9i      = nnl3_w9i_reg ;
    assign nnl3_b1       = nnl3_b1_reg ;
    assign nnl3_b2       = nnl3_b2_reg ;
    assign nnl3_b3       = nnl3_b3_reg ;
    assign nnl3_b4       = nnl3_b4_reg ;
    assign nnl3_b5       = nnl3_b5_reg ;
    assign nnl3_b6       = nnl3_b6_reg ;
    assign nnl3_b7       = nnl3_b7_reg ;
    assign nnl3_b8       = nnl3_b8_reg ;
    assign nnl3_b9       = nnl3_b9_reg ;
    // Register to save all layer 3 weight and bias values
    assign w3_11_w = w3_11_reg ;
    assign w3_21_w = w3_21_reg ;
    assign w3_31_w = w3_31_reg ;
    assign w3_41_w = w3_41_reg ;
    assign w3_51_w = w3_51_reg ;
    assign w3_61_w = w3_61_reg ;
    assign w3_71_w = w3_71_reg ;
    assign w3_81_w = w3_81_reg ;
    assign w3_91_w = w3_91_reg ;
    assign w3_12_w = w3_12_reg ;
    assign w3_22_w = w3_22_reg ;
    assign w3_32_w = w3_32_reg ;
    assign w3_42_w = w3_42_reg ;
    assign w3_52_w = w3_52_reg ;
    assign w3_62_w = w3_62_reg ;
    assign w3_72_w = w3_72_reg ;
    assign w3_82_w = w3_82_reg ;
    assign w3_92_w = w3_92_reg ;
    assign b3_1_w = b3_1_reg ;
    assign b3_2_w = b3_2_reg ;
    assign b3_3_w = b3_3_reg ;
    assign b3_4_w = b3_4_reg ;
    assign b3_5_w = b3_5_reg ;
    assign b3_6_w = b3_6_reg ;
    assign b3_7_w = b3_7_reg ;
    assign b3_8_w = b3_8_reg ;
    assign b3_9_w = b3_9_reg ;
    assign a3_w = a3_reg;

    // *** FORWARD VAE MODULE ********************************************************************************************************************************
    top_forward_vae uut (
        .clk(clk),
        .rst(rst_n),
        .start(start_vae),
        .clr(clr),
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
        .done(done_vae)
    );

    // *** CONTROL & STATUS SIGNAL ********************************************************************************************************************************************************
    // Counter for main controller
    reg [7:0] cntr_main_reg; 
    // FSM for main counter
    always @(posedge clk) begin
        if (!rst_n || clr)
        begin
            cntr_main_reg <= 0;
        end
        else if (start)
        begin
            cntr_main_reg <= cntr_main_reg + 1;
        end
        else if (cntr_main_reg >= 1 && cntr_main_reg <= 58)
        begin
            cntr_main_reg <= cntr_main_reg + 1;
        end
        else if (cntr_main_reg > 59)
        begin
            cntr_main_reg <= 0;
        end
    end

    // *** CONTROL UNIT *****************************************************************************************************************************************************
    assign ready = (cntr_main_reg == 1) ? 1 : 0 ;
    // FSM for pipelining input register to module top_forward_vae
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
        begin
            xj_reg <= 0 ;
            nnl2_mean_w1j_reg <= 0 ; nnl2_mean_w2j_reg <= 0 ; nnl2_mean_b1_reg <= 0 ; nnl2_mean_b2_reg <= 0 ;
            nnl2_var_w1j_reg <= 0 ; nnl2_var_w2j_reg <= 0 ; nnl2_var_b1_reg <= 0 ; nnl2_var_b2_reg <= 0 ;
            nnl3_w1i_reg <= 0 ; nnl3_w2i_reg <= 0 ; nnl3_w3i_reg <= 0 ; nnl3_w4i_reg <= 0 ; nnl3_w5i_reg <= 0 ; nnl3_w6i_reg <= 0 ; nnl3_w7i_reg <= 0 ; nnl3_w8i_reg <= 0 ; nnl3_w9i_reg <= 0 ;
            nnl3_b1_reg <= 0 ; nnl3_b2_reg <= 0 ; nnl3_b3_reg <= 0 ; nnl3_b4_reg <= 0 ; nnl3_b5_reg <= 0 ; nnl3_b6_reg <= 0 ; nnl3_b7_reg <= 0 ; nnl3_b8_reg <= 0 ; nnl3_b9_reg <= 0 ;
            w3_11_reg <= 0;  w3_12_reg <= 0;
            w3_21_reg <= 0;  w3_22_reg <= 0;
            w3_31_reg <= 0;  w3_32_reg <= 0;
            w3_41_reg <= 0;  w3_42_reg <= 0;
            w3_51_reg <= 0;  w3_52_reg <= 0;
            w3_61_reg <= 0;  w3_62_reg <= 0;
            w3_71_reg <= 0;  w3_72_reg <= 0;
            w3_81_reg <= 0;  w3_82_reg <= 0;
            w3_91_reg <= 0;  w3_92_reg <= 0;
            b3_1_reg <= 0; b3_2_reg <= 0; b3_3_reg <= 0; b3_4_reg <= 0; b3_5_reg <= 0; b3_6_reg <= 0; b3_7_reg <= 0; b3_8_reg <= 0; b3_9_reg <= 0;
            a3_reg <= 0 ;
        end 
        else if (cntr_main_reg >= 2 && cntr_main_reg <= 10) 
        begin
            xj_reg <= xin_doutb ; 
            nnl2_mean_w1j_reg <= wb2_m_doutb_0 ;   
            nnl2_mean_w2j_reg <= wb2_m_doutb_1 ;
            nnl2_var_w1j_reg  <= wb2_v_doutb_0 ;
            nnl2_var_w2j_reg  <= wb2_v_doutb_1 ;
            if (cntr_main_reg == 2)
            begin
                w3_11_reg <= wb3_doutb_0 ;
                w3_12_reg <= wb3_doutb_1 ; 
                b3_1_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 3) 
            begin
                w3_21_reg <= wb3_doutb_0 ;
                w3_22_reg <= wb3_doutb_1 ; 
                b3_2_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 4) 
            begin
                w3_31_reg <= wb3_doutb_0 ;
                w3_32_reg <= wb3_doutb_1 ; 
                b3_3_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 5) 
            begin
                w3_41_reg <= wb3_doutb_0 ;
                w3_42_reg <= wb3_doutb_1 ; 
                b3_4_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 6) 
            begin
                w3_51_reg <= wb3_doutb_0 ;
                w3_52_reg <= wb3_doutb_1 ; 
                b3_5_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 7) 
            begin
                w3_61_reg <= wb3_doutb_0 ;
                w3_62_reg <= wb3_doutb_1 ; 
                b3_6_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 8) 
            begin
                w3_71_reg <= wb3_doutb_0 ;
                w3_72_reg <= wb3_doutb_1 ; 
                b3_7_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 9) 
            begin
                w3_81_reg <= wb3_doutb_0 ;
                w3_82_reg <= wb3_doutb_1 ; 
                b3_8_reg  <= wb3_doutb_2 ;
            end
            else if (cntr_main_reg == 10) 
            begin
                w3_91_reg <= wb3_doutb_0 ;
                w3_92_reg <= wb3_doutb_1 ; 
                b3_9_reg  <= wb3_doutb_2 ;
            end
        end 
        else if (cntr_main_reg == 11) 
        begin
            nnl2_mean_b1_reg  <= wb2_m_doutb_2 ;
            nnl2_mean_b2_reg  <= wb2_m_doutb_3 ;
            nnl2_var_b1_reg   <= wb2_v_doutb_2 ;
            nnl2_var_b2_reg   <= wb2_v_doutb_3 ; 
        end
        else if (cntr_main_reg == 28) 
        begin
            nnl3_w1i_reg <= w3_11_reg ;
            nnl3_w2i_reg <= w3_21_reg ; 
            nnl3_w3i_reg <= w3_31_reg ; 
            nnl3_w4i_reg <= w3_41_reg ; 
            nnl3_w5i_reg <= w3_51_reg ; 
            nnl3_w6i_reg <= w3_61_reg ; 
            nnl3_w7i_reg <= w3_71_reg ; 
            nnl3_w8i_reg <= w3_81_reg ; 
            nnl3_w9i_reg <= w3_91_reg ; 
            nnl3_b1_reg  <= b3_1_reg ;
            nnl3_b2_reg  <= b3_2_reg ;
            nnl3_b3_reg  <= b3_3_reg ;
            nnl3_b4_reg  <= b3_4_reg ;
            nnl3_b5_reg  <= b3_5_reg ;
            nnl3_b6_reg  <= b3_6_reg ;
            nnl3_b7_reg  <= b3_7_reg ;
            nnl3_b8_reg  <= b3_8_reg ;
            nnl3_b9_reg  <= b3_9_reg ;
        end
        else if (cntr_main_reg == 28) 
        begin
            nnl3_w1i_reg <= w3_12_reg ;
            nnl3_w2i_reg <= w3_22_reg ; 
            nnl3_w3i_reg <= w3_32_reg ; 
            nnl3_w4i_reg <= w3_42_reg ; 
            nnl3_w5i_reg <= w3_52_reg ; 
            nnl3_w6i_reg <= w3_62_reg ; 
            nnl3_w7i_reg <= w3_72_reg ; 
            nnl3_w8i_reg <= w3_82_reg ; 
            nnl3_w9i_reg <= w3_92_reg ; 
        end
        else if (cntr_main_reg == 48) 
        begin
            a3_reg <= a3_1 ;    
        end
        else if (cntr_main_reg == 49) 
        begin
            a3_reg <= a3_2 ;    
        end
        else if (cntr_main_reg == 50) 
        begin
            a3_reg <= a3_3 ;    
        end
        else if (cntr_main_reg == 51) 
        begin
            a3_reg <= a3_4 ;    
        end
        else if (cntr_main_reg == 52) 
        begin
            a3_reg <= a3_5 ;    
        end
        else if (cntr_main_reg == 53) 
        begin
            a3_reg <= a3_6 ;    
        end
        else if (cntr_main_reg == 54) 
        begin
            a3_reg <= a3_7 ;    
        end
        else if (cntr_main_reg == 55) 
        begin
            a3_reg <= a3_8 ;    
        end
        else if (cntr_main_reg == 56) 
        begin
            a3_reg <= a3_9 ;    
        end
    end
    // Read bram l2 weight and bias mean every clock from address 0 to 8 (read 9 64-bit values, assign value to wb2_m_doutb)
    assign wb2_m_enb   = (cntr_main_reg >= 1 && cntr_main_reg <= 10) ? 1 : 0 ;
    assign wb2_m_addrb = (cntr_main_reg == 1) ? 0 :
                         (cntr_main_reg == 2) ? 1 :
                         (cntr_main_reg == 3) ? 2 :
                         (cntr_main_reg == 4) ? 3 :
                         (cntr_main_reg == 5) ? 4 : 
                         (cntr_main_reg == 6) ? 5 :
                         (cntr_main_reg == 7) ? 6 :
                         (cntr_main_reg == 8) ? 7 : 
                         (cntr_main_reg == 9) ? 8 :
                         (cntr_main_reg == 10) ? 0 : 0;
    // Read bram l2 weight and bias var every clock from address 0 to 8 (read 9 64-bit values, assign value to wb2_v_doutb)
    assign wb2_v_enb   = (cntr_main_reg >= 1 && cntr_main_reg <= 10) ? 1 : 0 ;
    assign wb2_v_addrb = (cntr_main_reg == 1) ? 0 :
                         (cntr_main_reg == 2) ? 1 :
                         (cntr_main_reg == 3) ? 2 :
                         (cntr_main_reg == 4) ? 3 :
                         (cntr_main_reg == 5) ? 4 : 
                         (cntr_main_reg == 6) ? 5 :
                         (cntr_main_reg == 7) ? 6 :
                         (cntr_main_reg == 8) ? 7 : 
                         (cntr_main_reg == 9) ? 8 :
                         (cntr_main_reg == 10) ? 0 : 0;
    // Read bram l3 weight and bias every clock from address 0 to 8 (read 9 64-bit values, assign value to wb3_doutb)       
    assign wb3_enb   = (cntr_main_reg >= 1 && cntr_main_reg <= 9) ? 1 : 0 ;
    assign wb3_addrb = (cntr_main_reg == 1) ? 0 :
                       (cntr_main_reg == 2) ? 1 :
                       (cntr_main_reg == 3) ? 2 :
                       (cntr_main_reg == 4) ? 3 :
                       (cntr_main_reg == 5) ? 4 : 
                       (cntr_main_reg == 6) ? 5 :
                       (cntr_main_reg == 7) ? 6 :
                       (cntr_main_reg == 8) ? 7 : 
                       (cntr_main_reg == 9) ? 8 : 0;
    // Read bram input every clock from address 0 to 8 (read 9 64-bit values, assign value to xin_doutb)
    assign xin_enb   = (cntr_main_reg >= 1 && cntr_main_reg <= 9) ? 1 : 0 ;
    assign xin_addrb = (cntr_main_reg == 1) ? 0 :
                       (cntr_main_reg == 2) ? 1 :
                       (cntr_main_reg == 3) ? 2 :
                       (cntr_main_reg == 4) ? 3 :
                       (cntr_main_reg == 5) ? 4 : 
                       (cntr_main_reg == 6) ? 5 :
                       (cntr_main_reg == 7) ? 6 :
                       (cntr_main_reg == 8) ? 7 : 
                       (cntr_main_reg == 9) ? 8 : 0;

    // Set signal control of vae
    assign start_vae = (cntr_main_reg == 3) ? 1 : 0 ;
    assign done = (cntr_main_reg > 57) ? 1 : 0 ;

    // Saved output to BRAM output
    assign xout_ena = (cntr_main_reg >= 49 && cntr_main_reg <= 57) ? 1: 0 ;
    assign xout_wea = (cntr_main_reg >= 49 && cntr_main_reg <= 57) ? 8'b11111111: 0 ;
    assign xout_addra = (cntr_main_reg == 49) ? 0 :
                        (cntr_main_reg == 50) ? 1 :
                        (cntr_main_reg == 51) ? 2 :
                        (cntr_main_reg == 52) ? 3 :
                        (cntr_main_reg == 53) ? 4 : 
                        (cntr_main_reg == 54) ? 5 :
                        (cntr_main_reg == 55) ? 6 :
                        (cntr_main_reg == 56) ? 7 : 
                        (cntr_main_reg == 57) ? 8 : 0;
    assign xout_dina =  (cntr_main_reg >= 49 && cntr_main_reg <= 57) ? a3_w : 0 ;
    
endmodule

    
    
   






