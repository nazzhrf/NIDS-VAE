`timescale 1ns / 1ps

module forward_nn_classification_bram
    (
        input wire         clk,
        input wire         rst_n,
        input wire         en,
        input wire         clr,
        // *** Control and status port ***
        output wire        ready,
        input wire         start,
        output wire        done,
        // *** Data Input port ***
        input wire         xij_ena,
        input wire [3:0]   xij_addra,
        input wire [63:0]  xij_dina,
        input wire [7:0]   xij_wea,
        // *** Weight and bias port ***
        input wire         wb_ena,
        input wire [3:0]   wb_addra,
        input wire [63:0]  wb_dina,
        input wire [7:0]   wb_wea,
        // *** Data output port ***
        input wire         xout_enb,
        input wire [3:0]   xout_addrb,
        output wire [15:0] xout_doutb
    );

    // *** WIRE TO CONTROL ANOTHER PORT OF BRAM ********************************************************************************************************************************
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

    // *** WIRE TO SAVED BRAM READ OUTPUT TEMPORARELY ********************************************************************************************************************************
    // Wire to saved xij_doutb value per 16 bits
    wire [15:0] xij_doutb_0, xij_doutb_1, xij_doutb_2, xij_doutb_3 ;
    // Wire to saved wb2_doutb value per 16 bits
    wire [15:0] wb_doutb_0, wb_doutb_1, wb_doutb_2, wb_doutb_3 ;

    // *** INPUT BRAM ******************************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(640),                   // DECIMAL, size: 8x64bit= 512 bits
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
    xpm_memory_tdpram_input
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
        .ena(xij_ena),
        .wea(xij_wea),
        .addra(xij_addra),
        .dina(xij_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(xij_enb),
        .web(0),
        .addrb(xij_addrb),
        .dinb(0),
        .doutb(xij_doutb)
    );
    assign xij_doutb_0 = xij_doutb[63:48] ; // to saved x1-x9 (x1j)
    assign xij_doutb_1 = xij_doutb[47:32] ; // to saved x10-x18 (x2j)
    assign xij_doutb_2 = xij_doutb[31:16] ; // to saved x19-x27 (x3j)
    assign xij_doutb_3 = xij_doutb[15:0] ; // to saved x19-x27 (x4j)

    // *** WEIGHT AND BIAS BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(640),                   // DECIMAL, size: 8x64bit= 512 bits
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
    xpm_memory_tdpram_wb
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
        .ena(wb_ena),
        .wea(wb_wea),
        .addra(wb_addra),
        .dina(wb_dina),
        .douta(),
        
        // Port B module ports
        .clkb(clk),
        .rstb(~rst_n),
        .enb(wb_enb),
        .web(0),
        .addrb(wb_addrb),
        .dinb(0),
        .doutb(wb_doutb)
    );
    assign wb_doutb_0 = wb_doutb[63:48] ; // to saved 9 weight and 1 bias values
    assign wb_doutb_1 = wb_doutb[47:32] ;
    assign wb_doutb_2 = wb_doutb[31:16] ;
    assign wb_doutb_3 = wb_doutb[15:0] ;
    
    // *** OUTPUT BRAM ********************************************************************************************************************************
    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2018.3
    xpm_memory_tdpram
    #(
        // Common module parameters
        .MEMORY_SIZE(64),                   // DECIMAL, size: 8x64bit= 512 bits
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
        .ADDR_WIDTH_A(2),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
        .READ_RESET_VALUE_A("0"),            // String
        .READ_LATENCY_A(1),                  // DECIMAL
        .WRITE_MODE_A("write_first"),        // String
        .RST_MODE_A("SYNC"),                 // String
        
        // Port B module parameters  
        .WRITE_DATA_WIDTH_B(16),             // DECIMAL, data width: 64-bit
        .READ_DATA_WIDTH_B(16),              // DECIMAL, data width: 64-bit
        .BYTE_WRITE_WIDTH_B(8),              // DECIMAL
        .ADDR_WIDTH_B(2),                    // DECIMAL, clog2(512/64)=clog2(8)= 3
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

    // *** REGISTER AND WIRE TO SAVE INPUT AND OUTPUT VALUES OF FORWARD VAE MODULE'S INPUT ******************************************************************************************************************************
    // Input and layer 2 parameters
    reg signed [15:0] x1j_reg, x2j_reg, x3j_reg, x4j_reg;
    reg signed [15:0] w1j_reg, w2j_reg, w3j_reg, w4j_reg;
    reg signed [15:0] b1_reg, b2_reg, b3_reg, b4_reg ;
    reg signed [15:0] out_reg ;
    // Output 
    reg signed [15:0] z1_reg, z2_reg, z3_reg, z4_reg;
    reg signed [15:0] a1_reg, a2_reg, a3_reg, a4_reg;
    reg signed [15:0] dos_detected_reg, portscan_detected_reg, ddos_detected_reg, patator_detected_reg;
    // Wire
    wire signed [15:0] a1_w, a2_w, a3_w , a4_w;
    wire signed [15:0] dos_detected_w, portscan_detected_w, ddos_detected_w, patator_detected_w;
    wire signed [15:0] out_w;
    
    // *** CONNECTION TO NN CLASSIFICATION MODULE ********************************************************************************************************************************
    // Input connection
    wire start_nn_classification ; 
    wire signed [15:0] x1j, x2j, x3j, x4j ;
    wire signed [15:0] w1j, w2j, w3j, w4j ;
    wire signed [15:0] b1, b2, b3, b4 ;
    // Output connection
    wire signed [15:0] sys2x1_res1, sys2x1_res2 , sys2x1_res3, sys2x1_res4 ;
    wire signed [15:0] z1, z2, z3, z4 ;
    wire signed [15:0] a1, a2, a3, a4 ;
    wire signed [15:0] dos_detected, portscan_detected, ddos_detected, patator_detected ;
    wire done_nn_classification ;

    // *** ASSIGN REGISTER'S VALUES TO A WIRE ******************************************************************************************************************************
    // Assign top forward vae's input
    assign x1j = x1j_reg ;
    assign x2j = x2j_reg ;
    assign x3j = x3j_reg ;
    assign x4j = x4j_reg ;
    assign a1_w = a1_reg;
    assign a2_w = a2_reg;
    assign a3_w = a3_reg;
    assign a4_w = a4_reg;
    assign w1j  = w1j_reg;
    assign w2j  = w2j_reg;
    assign w3j  = w3j_reg;
    assign w4j  = w4j_reg;
    assign b1  = b1_reg;
    assign b2  = b2_reg;
    assign b3  = b3_reg;
    assign b4  = b4_reg;
    assign dos_detected_w = dos_detected_reg;
    assign portscan_detected_w = portscan_detected_reg;
    assign ddos_detected_w = ddos_detected_reg;
    assign patator_detected_w = patator_detected_reg;
    assign out_w = out_reg;

    // *** FORWARD VAE MODULE ********************************************************************************************************************************
    top_forward_nn_classification uut (
        .clk(clk),
        .rst(rst_n),
        .start(start_nn_classification),
        .clr(clr),
        .x1j(x1j),
        .x2j(x2j),
        .x3j(x3j),
        .x4j(x4j),
        .w1j(w1j),
        .w2j(w2j),
        .w3j(w3j),
        .w4j(w4j),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .b4(b4),
        .sys2x1_res1(sys2x1_res1),
        .sys2x1_res2(sys2x1_res2),
        .sys2x1_res3(sys2x1_res3),
        .sys2x1_res4(sys2x1_res4),
        .z1(z1),
        .z2(z2),
        .z3(z3),
        .z4(z4),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .a4(a4),
        .dos_detected(dos_detected),
        .portscan_detected(portscan_detected),
        .ddos_detected(ddos_detected),
        .patator_detected(patator_detected),
        .done(done_nn_classification)
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
        else if (cntr_main_reg >= 1 && cntr_main_reg <= 28)
        begin
            cntr_main_reg <= cntr_main_reg + 1;
        end
        else if (cntr_main_reg > 29)
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
            x1j_reg <= 0 ; x2j_reg <= 0 ; x3j_reg <= 0 ; x4j_reg <= 0 ;
            w1j_reg <= 0 ; w2j_reg <= 0 ; w3j_reg <= 0 ; w4j_reg <= 0 ;
            b1_reg <= 0 ;  b2_reg <= 0 ;  b3_reg <= 0 ;  b4_reg <= 0 ;
        end 
        else if (cntr_main_reg >= 2 && cntr_main_reg <= 10) 
        begin
            x1j_reg <= xij_doutb_0 ; 
            x2j_reg <= xij_doutb_1 ; 
            x3j_reg <= xij_doutb_2 ; 
            x4j_reg <= xij_doutb_3 ; 
            w1j_reg <= wb_doutb_0 ;   
            w2j_reg <= wb_doutb_1 ;  
            w3j_reg <= wb_doutb_2 ;  
            w4j_reg <= wb_doutb_3 ;  
        end 
        else if (cntr_main_reg == 11) 
        begin
            b1_reg <= wb_doutb_0 ; 
            b2_reg <= wb_doutb_1 ;
            b3_reg <= wb_doutb_2 ;
            b4_reg <= wb_doutb_3 ;
        end
        else if (cntr_main_reg == 21) 
        begin
            a1_reg = a1 ;
            a2_reg = a2 ;
            a3_reg = a3 ;
            a4_reg = a4 ;
            dos_detected_reg  <= dos_detected;
            portscan_detected_reg  <= portscan_detected ;
            ddos_detected_reg  <= ddos_detected ;
            patator_detected_reg  <= patator_detected ;
        end
        else if (cntr_main_reg == 22) 
        begin
            out_reg = dos_detected_reg ;
        end
        else if (cntr_main_reg == 23) 
        begin
            out_reg = portscan_detected_reg ;
        end
        else if (cntr_main_reg == 24) 
        begin
            out_reg = ddos_detected_reg ;    
        end
        else if (cntr_main_reg == 25) 
        begin
            out_reg = patator_detected_reg ;    
        end
    end

    // Read bram input every clock from address 0 to 8 (read 9 64-bit values, assign value to xij_doutb)
    assign xij_enb   = (cntr_main_reg >= 1 && cntr_main_reg <= 9) ? 1 : 0 ;
    assign xij_addrb = (cntr_main_reg == 1) ? 0 :
                       (cntr_main_reg == 2) ? 1 :
                       (cntr_main_reg == 3) ? 2 :
                       (cntr_main_reg == 4) ? 3 :
                       (cntr_main_reg == 5) ? 4 : 
                       (cntr_main_reg == 6) ? 5 :
                       (cntr_main_reg == 7) ? 6 :
                       (cntr_main_reg == 8) ? 7 : 
                       (cntr_main_reg == 9) ? 8 : 0;
    // Read bram weight and bias every clock from address 0 to 9 (read 10 64-bit values, assign value to wb_doutb)
    assign wb_enb   = (cntr_main_reg >= 1 && cntr_main_reg <= 10) ? 1 : 0 ;
    assign wb_addrb = (cntr_main_reg == 1) ? 0 :
                      (cntr_main_reg == 2) ? 1 :
                      (cntr_main_reg == 3) ? 2 :
                      (cntr_main_reg == 4) ? 3 :
                      (cntr_main_reg == 5) ? 4 : 
                      (cntr_main_reg == 6) ? 5 :
                      (cntr_main_reg == 7) ? 6 :
                      (cntr_main_reg == 8) ? 7 : 
                      (cntr_main_reg == 9) ? 8 :
                      (cntr_main_reg == 10) ? 9 : 0;

    // Set signal control of nn_classification
    assign start_nn_classification = (cntr_main_reg == 3) ? 1 : 0 ;
    assign done = (cntr_main_reg > 27) ? 1 : 0 ;

    // Saved output to BRAM output
    assign xout_ena = (cntr_main_reg >= 23 && cntr_main_reg <= 26) ? 1: 0 ;
    assign xout_wea = (cntr_main_reg >= 23 && cntr_main_reg <= 26) ? 8'b11111111: 0 ;
    assign xout_addra = (cntr_main_reg == 23) ? 0 :
                        (cntr_main_reg == 24) ? 1 :
                        (cntr_main_reg == 25) ? 2 :
                        (cntr_main_reg == 26) ? 3 : 0;
    assign xout_dina =  (cntr_main_reg >= 23 && cntr_main_reg <= 26) ? out_w : 0 ;
    
endmodule






