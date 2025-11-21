module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output pwm_out
);
    reg pwm_logic_out;
    reg pwm_out_reg;
    
    always @(*) begin
        // check unaligned mode (window)
        if (functions[1]) begin
            // square window pwm logic - 001111100
            if (count_val >= compare1 && count_val < compare2) begin
                pwm_logic_out = 1'b1;
            end else begin
                pwm_logic_out = 1'b0;
            end
        end else begin
            // aligned mode
            if (functions[0] == 1'b0) begin
                //  left alignment - 111110000
                pwm_logic_out = (count_val < compare1) ? 1'b1 : 1'b0;
            end else begin
                // right alignment - 000001111
                pwm_logic_out = (count_val < compare1) ? 1'b0 : 1'b1;
            end
        end
    end

    // clk sync
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_out_reg <= 1'b0;
        end else begin
            // update exit if pwm is enable - rest of logic above
            if (pwm_en) begin
                pwm_out_reg <= pwm_logic_out;
            end else begin
                pwm_out_reg <= 1'b0;
            end
        end
    end

    assign pwm_out = pwm_out_reg;
endmodule