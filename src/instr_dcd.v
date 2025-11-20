module instr_dcd (
    // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input [7:0] data_in,
    output [7:0] data_out,
    
    // register access signals
    output read,
    output write,
    output [5:0] addr,
    input [7:0] data_read,
    output [7:0] data_write
);

    // internal registers
    reg rw_reg;
    reg hl_reg;
    reg [5:0] addr_reg;
    
    
    reg phase;

    reg read_r;
    reg write_r;
    reg [5:0] addr_r;
    reg [7:0] data_out_r;
    reg [7:0] data_write_r;

    // logic
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rw_reg <= 0;
            hl_reg <= 0; 
            addr_reg <= 0; 
            phase <= 0;
            read_r <= 0; 
            write_r <= 0; 
            addr_r <= 0; 
            data_out_r <= 0; 
            data_write_r <= 0;
            
        end else begin
        
            // default vals
            read_r  <= 0;
            write_r <= 0;

            if(byte_sync) begin
                if(phase == 0) begin
                    // setup phase
                    rw_reg   <= data_in[7];
                    hl_reg   <= data_in[6];
                    addr_reg <= data_in[5:0];
                    phase <= 1;
                end else begin
                    // data phase
                    addr_r <= addr_reg;
                    if(rw_reg) begin
                        write_r      <= 1;
                        data_write_r <= data_in;
                    end else begin
                        read_r       <= 1;
                        data_out_r   <= data_read;
                    end
                    phase <= 0; // back to setup
                end
            end
        end
    end

    // final assignment to outputs
    assign read       = read_r;
    assign write      = write_r;
    assign addr       = addr_r;
    assign data_out   = data_out_r;
    assign data_write = data_write_r;

endmodule
