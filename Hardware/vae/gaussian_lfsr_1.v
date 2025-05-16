`timescale 1ns / 1ps

module gaussian_lfsr_1
(
    input wire clk,         
    input wire rst,
    input wire gauss_en,
    output reg [15:0] random_number  
);

    reg [15:0] lfsr1, lfsr2; 
    reg [15:0] counter;     
    reg [15:0] combined_random;
    reg sign_toggle; // Register untuk mengganti tanda positif dan negatif

    // Feedback untuk lfsr1 (XOR bit ke-16, 14, 13, dan 11)
    wire feedback1 = lfsr1[15] ^ lfsr1[13] ^ lfsr1[12] ^ lfsr1[10];

    // Feedback untuk lfsr2 (XOR bit ke-16, 15, 13, dan 1)
    wire feedback2 = lfsr2[15] ^ lfsr2[14] ^ lfsr2[12] ^ lfsr2[0];

    // Logika LFSR dan random number generation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            lfsr1 <= 16'd37;   
            lfsr2 <= 16'd62;   
            counter <= 16'd1; 
            combined_random <= 16'd17;
            random_number <= 16'd0; // Reset output
            sign_toggle <= 1'b0; // Reset toggle
        end else if (gauss_en) begin
            // Update LFSR
            lfsr1 <= {lfsr1[14:0], feedback1}; 
            lfsr2 <= {lfsr2[14:0], feedback2}; 

            // Update counter
            counter <= (counter + lfsr1[7:0]) ^ lfsr2[15:8];

            // Kombinasi nilai dari lfsr1, lfsr2, dan counter

            combined_random <= (lfsr1 ^ {lfsr2[7:0], lfsr2[15:8]})
                             ^ {counter[7:0], counter[15:8]};

            // Pemetaan nilai ke rentang yang ditentukan tanpa modulo
            if (combined_random[15:14] == 2'b00) begin
                // Rentang 0 <= random_number <= 3072
                random_number <= combined_random[12:0] & 16'd3072; // Batasi dengan masking
            end else begin
                // Rentang 62464 <= random_number <= 65535
                random_number <= 16'd62464 | (combined_random[12:0] & 16'd2891); // Tambahkan offset dengan masking
            end

            // Terapkan tanda negatif atau positif berdasarkan sign_toggle
            if (sign_toggle) begin
                random_number <= -random_number; // Ubah menjadi negatif jika toggle aktif
            end

            // Ganti nilai toggle di setiap clock
            sign_toggle <= ~sign_toggle;
        end else begin
            random_number <= random_number;
            combined_random <= combined_random;
            counter <= counter;
            lfsr1 <= lfsr1;
            lfsr2 <= lfsr2;
            sign_toggle <= sign_toggle;
        end
    end

endmodule
