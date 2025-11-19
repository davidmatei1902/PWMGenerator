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
    
    reg [2:0] bit_cnt;    // counter pt biti
    reg [7:0] shift_reg;  // registru de shift pentru MOSI
    reg sclk_d;           // pentru detectarea fronturilor SCLK

    always @(posedge clk or negedge rst_n) begin
        // blocul de reset
        if (!rst_n) begin
            shift_reg <= 8'b0;
            bit_cnt <= 3'b0;
            data_in <= 8'b0;
            byte_sync <= 0;
            miso <= 0;
            sclk_d <= 0;
        end else begin
            sclk_d <= sclk;    // salvam starea anterioara SCLK pentru detec?ia frontului
            byte_sync <= 0;    // flag pentru dcd

            // activ doar cand CS este low
            if (!cs_n) begin   
                // detectam frontul crescator al SCLK
                if (~sclk_d & sclk) begin
                    shift_reg <= {shift_reg[6:0], mosi};  // shift propriu zis
                    bit_cnt <= bit_cnt + 1;

                    // trimitem bitul corespunz?tor din data_out pe MISO
                    miso <= data_out[7 - bit_cnt];
                    
                    // daca cumva am transmis tot
                    if (bit_cnt == 3'd7) begin
                        data_in <= {shift_reg[6:0], mosi}; // byte complet primit
                        byte_sync <= 1;                    // semnalam cu flag ul sync
                        bit_cnt <= 0;
                    end
                end
            end else begin
                bit_cnt <= 0; // reset cand CS este HIGH
            end
        end
    end
endmodule