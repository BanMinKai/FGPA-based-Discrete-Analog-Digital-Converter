///////////////////////////////////////////////////////////////////////////////
// Module Name: pwm_sar_adc_subsystem
// 
// Description:
// This module implements a PWM-based SAR ADC subsystem with integrated clock
// division for timing control. It coordinates the sampling, comparison, and
// conversion processes for successive approximation conversion using PWM.
//
// Inputs:
//   - compare_match_n : Active-low comparator input
//   - clk            : System clock
//   - reset          : System reset
//   - bin_bcd_select : 2-bit selector for output format
//
// Outputs:
//   - sample_control : Control signal for external Sample & Hold circuit
//   - adc_outputs   : 16-bit conversion result
//   - pwm_out       : PWM output signal
//
// Internal Signals:
//   - strobe_signal : Clock divider output for ADC timing control
//
// Operation:
//   1. Clock divider generates 1MHz timing signal (1,000,000 division ratio)
//   2. PWM SAR ADC performs conversion when enabled by strobe signal
//   3. Sample & Hold control coordinates analog input sampling
//   4. Conversion results available in selected format (binary/BCD)
//
// Note: Configured for operation with R=550Ω and C=10µF timing components.
//       The clock division ratio is critical for proper ADC timing.
///////////////////////////////////////////////////////////////////////////////


module pwm_sar_adc_subsystem(
    input logic compare_match_n, // active-low compare signal
    input logic clk,
    input logic reset,
    input logic [1:0] bin_bcd_select, 
    
    output logic sample_control, // to S&H external circuit
    output logic [15:0] adc_outputs,
    output logic pwm_out
);


    // clk divider with strobe signal
    logic strobe_signal;
    integer_divider CLK_DIVIDER
    (
        .i_clk(clk),
        .i_div(32'd1_000_000), // works with R = 550; C = 10u

        .o_stb(strobe_signal)
    );
 
    //-------------
    
    pwm_sar_adc PWM_SAR_ADC
(
        .clk(clk),
        .reset(reset),
        .compare_match(compare_match_n), // active-low
        .adc_en(strobe_signal),
        
        .sample_control(sample_control),
        .bin_bcd_select(bin_bcd_select), 
//        .R2R_outputs(R2R_out),
        .adc_outputs(adc_outputs),
        .pwm_out(pwm_out)
);
      

    
    
    
endmodule
