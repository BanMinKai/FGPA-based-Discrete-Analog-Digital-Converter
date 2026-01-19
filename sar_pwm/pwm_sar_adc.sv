///////////////////////////////////////////////////////////////////////////////
// Module Name: pwm_sar_adc
// 
// Description:
// PWM-based Successive Approximation Register (SAR) ADC module with integrated
// signal processing. Performs binary search conversion and provides multiple
// output formats with averaging capability.
//
// Inputs:
//   - clk            : System clock
//   - reset          : System reset
//   - compare_match  : Active-high comparator input
//   - bin_bcd_select : 2-bit output format selector
//   - adc_en         : ADC operation enable
//
// Outputs:
//   - sample_control : Sample & Hold control signal
//   - pwm_out       : PWM output signal
//   - adc_outputs   : 16-bit processed ADC output
//
// Internal Signals:
//   - u8_raw_data    : 8-bit raw ADC sample
//   - ave_data       : 16-bit averaged data
//   - scaled_ave_hex : Scaled averaged data in hex
//   - scaled_ave_dec : Scaled averaged data in BCD
//
// Operation:
//   1. SAR controller performs binary search conversion
//   2. Raw 8-bit samples captured on valid conversion
//   3. Samples averaged over 64 measurements (2^6)
//   4. Averaged data scaled by 120 with +150 offset
//   5. PWM output generated from current SAR value
//   6. Output format selected via bin_bcd_select:
//      00: Scaled average (hex)
//      01: Scaled average (BCD)
//      10: Raw ADC data
//      11: Averaged data
//
// Note: Includes signal averaging and scaling for improved accuracy
///////////////////////////////////////////////////////////////////////////////

module pwm_sar_adc(
    input logic clk,
    input logic reset,
    input logic compare_match, // active-high
    input logic [1:0] bin_bcd_select, 
    input logic adc_en,
    
    output logic sample_control, 
    output logic pwm_out,
    output logic [15:0] adc_outputs
);
    
            
    logic [7:0] u8_raw_data;              // Raw ADC data
    logic [15:0] ave_data;
    logic [15:0] scaled_data;
    logic [15:0] scaled_ave_hex; // Scaled ADC data for display, plus pipelinging register
    logic [15:0] scaled_ave_dec; // Scaled ADC data for display, plus pipelinging register

    // Output assignments
    assign raw_adc_data_out = u8_raw_data;
    assign ave_adc_data_out = ave_data;
    assign scaled_adc_data_out = scaled_data;

    logic [7:0] R2R_out_internal;
    logic [7:0] result;
    
    sar_adc_controller_with_strobe_en SAR(
        .clk    (clk),
        .reset  (reset),
        .go     ('b1),
        .en(adc_en),
        
        .valid  (valid),
        .result (result),
        .sample (sample_control),  // sample & hold controll signal
        .value  (R2R_out_internal),  // to DAC
        .cmp    (compare_match) // active-high
    );

    register_r_en 
    #(.width(8))
    CAPTURE_REG
    (
        .clk(clk),
        .reset(reset),
        .en(valid),
        
        .d(result),
        .q(u8_raw_data)
    );
    
    // Instantiate PWM module
    logic [7:0] duty_cycle;
    assign duty_cycle = R2R_out_internal;
    pwm #(
        .WIDTH(8)
    ) pwm_inst (
        .clk(clk),
        .reset(reset),
        .enable('b1),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    
    // average data is scaled and stored
    always_ff @(posedge clk) begin
        if (reset)
            scaled_ave_hex <= '0;
        else if (valid)
            scaled_ave_hex <= (ave_data * 120 + 150);  // Approximate scaling factor
    end
    
    bin_to_bcd  DECIMAL_CONVERTER
    (
        .clk(clk),
        .reset(reset),
        .bin_in(scaled_ave_hex),
        .bcd_out(scaled_ave_dec)
    );


        
    // average
    averager #(
        .power(6), // 2**(power) samples, default is 2**8 = 256 samples (4^4 = 256 samples, adds 4 bits of ADC resolution)
        .N(12)     // # of bits to take the average of
    ) AVERAGER (
        .reset(reset),
        .clk(clk),
        .EN(valid),
        .Din(u8_raw_data),
        .Q(ave_data)
    );
    
 
    logic [15:0] adc_mux_outputs;

    always_comb begin
        case(bin_bcd_select)
            2'b00: adc_mux_outputs= scaled_ave_hex;  // averaged ADC with extra 4 bits
            2'b01: adc_mux_outputs = scaled_ave_dec;  // averaged and scaled voltage
        
            2'b10: adc_mux_outputs = u8_raw_data;  // raw ADC (12-bits)
            2'b11: adc_mux_outputs = ave_data;
        default: adc_mux_outputs = scaled_ave_hex;  // Default case: output all zeros
    endcase
  end
  
  assign  adc_outputs = adc_mux_outputs;   
  
endmodule
      