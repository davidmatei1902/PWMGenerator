module counter (
    // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output[15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
);
    reg [15:0] internal_count;
    reg [15:0] prescale_count;
    wire tick_enable;
    wire [15:0] prescale_limit;
    
    assign count_val = internal_count;
    // prescale limit (2^prescale - 1)
    assign prescale_limit = (16'b1 << prescale) - 16'b1;
    // prescaler finished flag
    assign tick_enable = (prescale_count == prescale_limit);
    
    
    // prescaler block
    always @(posedge clk or negedge rst_n) begin
        // prescalere reset 
        if (!rst_n) begin
            prescale_count <= 16'b0;
        end else if (count_reset) begin
            prescale_count <= 16'b0;
        // increment prescaler
        end else if (en) begin
            if (tick_enable) begin
                prescale_count <= 16'b0;
            end else begin
                prescale_count <= prescale_count + 1;
            end
        end
    end
    
    // internal block
    always @(posedge clk or negedge rst_n) begin
        // internal reset
        if (!rst_n) begin
            internal_count <= 16'b0;
        end else if (count_reset) begin
            internal_count <= 16'b0;
        // update only if internal block is active and prescaler is en
        end else if (en && tick_enable) begin
            if (upnotdown) begin
                // logic for upwards count
                if (internal_count >= period) begin
                    internal_count <= 16'b0;
                end else begin
                    internal_count <= internal_count + 1;
                end
            end else begin
                // logic for downwards count
                if (internal_count == 0) begin
                    internal_count <= period;
                end else begin
                    internal_count <= internal_count - 1;
                end
            end
        end
    end
endmodule