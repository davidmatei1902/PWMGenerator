module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output[7:0] data_read,
    input[7:0] data_write,
    // counter programming signals
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // PWM signal programming values
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

/*
    All registers that appear in this block should be similar to this. Please try to abide
    to sizes as specified in the architecture documentation.
*/

// internal registers
reg[15:0] period_reg;
reg en_reg;
reg[15:0] compare1_reg;
reg[15:0] compare2_reg;
reg count_reset_reg;
reg upnotdown_reg;
reg[7:0] prescale_reg;
reg pwm_en_reg;
reg[7:0] functions_reg;

// read mux
reg[7:0] data_out_reg;

// output assignments
assign period      = period_reg;
assign en          = en_reg;
assign compare1    = compare1_reg;
assign compare2    = compare2_reg;
assign count_reset = count_reset_reg;
assign upnotdown   = upnotdown_reg;
assign prescale    = prescale_reg;
assign pwm_en      = pwm_en_reg;
assign functions   = functions_reg;
assign data_read   = data_out_reg;

// for data_read logic
always @(*) begin
    data_out_reg = 8'h00;

    case (addr)
        // period
        6'h00: data_out_reg = period_reg[7:0];
        6'h01: data_out_reg = period_reg[15:8];
        
        // for counter
        6'h02: data_out_reg = {7'b0, en_reg};

        // cmp 1
        6'h03: data_out_reg = compare1_reg[7:0];
        6'h04: data_out_reg = compare1_reg[15:8];

        // cmp 2
        6'h05: data_out_reg = compare2_reg[7:0];
        6'h06: data_out_reg = compare2_reg[15:8];
        
        // counter val
        6'h08: data_out_reg = counter_val[7:0];
        6'h09: data_out_reg = counter_val[15:8];
        
        // prescale 
        6'h0A: data_out_reg = prescale_reg;
        
        // up not down bit
        6'h0B: data_out_reg = {7'b0, upnotdown_reg};
        
        // pwm en bit
        6'h0C: data_out_reg = {7'b0, pwm_en_reg};
        
        // functions
        6'h0D: data_out_reg = functions_reg;

        default: data_out_reg = 8'h00;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        period_reg      <= 16'h0000;
        en_reg          <= 1'b0;
        compare1_reg    <= 16'h0000;
        compare2_reg    <= 16'h0000;
        count_reset_reg <= 1'b0;
        upnotdown_reg   <= 1'b1;
        prescale_reg    <= 8'h00;
        pwm_en_reg      <= 1'b0;
        functions_reg   <= 8'h00;

    end else begin
        //TODO
    end
end

endmodule
