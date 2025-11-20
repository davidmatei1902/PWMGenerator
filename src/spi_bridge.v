module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    input mosi,
    output miso,
    // internal facing 
    output byte_sync,
    output[7:0] data_in,
    input[7:0] data_out
);
    
    reg [2:0] bit_cnt;    // bit counter
    reg [7:0] shift_reg;  // shift register for MOSI
    reg sclk_d;           // used for SCLK edge detection
    reg miso_r;
    reg byte_sync_r;
    reg [7:0] data_in_r;

    always @(posedge clk or negedge rst_n) begin
        // reset block
        if (!rst_n) begin
            shift_reg <= 8'b0;
            bit_cnt <= 3'b0;
            data_in_r <= 8'b0;
            byte_sync_r <= 0;
            miso_r <= 0;
            sclk_d <= 0;
        end else begin
            byte_sync_r <= 0;
            // active only when CS is low
            if (!cs_n) begin   
                shift_reg <= {shift_reg[6:0], mosi};  // actual shifting
                bit_cnt <= bit_cnt + 1;

                // send the corresponding bit from data_out on MISO
                miso_r <= data_out[7 - bit_cnt];
                
                // if we have received the whole byte
                if (bit_cnt == 3'd7) begin
                    data_in_r <= {shift_reg[6:0], mosi}; // complete received byte
                    byte_sync_r <= 1;                    // signal with the sync flag
                    bit_cnt <= 0;
                end
            end else begin
                bit_cnt <= 0; // reset when CS is HIGH
            end
        end
    end

    assign miso = miso_r;
    assign byte_sync = byte_sync_r;
    assign data_in = data_in_r;

endmodule
