///////////////////////////////////////////////////////////////////////////////
// Module Name: r2r_sar_adc_subsystem
// 
// Description:
// This module implements an R2R-based SAR ADC subsystem that uses an R2R ladder
// network for digital-to-analog conversion in the successive approximation process.
// Includes integrated clock division for conversion timing control.
//
// Inputs:
//   - compare_match_n : Active-low comparator input (Vanalog > Vdac)
//   - clk            : System clock
//   - reset          : System reset
//   - bin_bcd_select : 2-bit selector for output format
//
// Outputs:
//   - sample_control : Control signal for external Sample & Hold circuit
//   - R2R_out       : 8-bit output to R2R ladder network
//   - adc_outputs   : 16-bit conversion result
//
// Internal Signals:
//   - strobe_signal : Clock divider output for ADC timing control
//
// Operation:
//   1. Clock divider generates 10kHz timing signal (100,000 division ratio)
//   2. R2R SAR ADC performs conversion when enabled by strobe signal
//   3. Sample & Hold control coordinates analog input sampling
//   4. R2R ladder converts digital approximations to analog for comparison
//
// Note: The comparator input is configured for comparing Vanalog (positive) 
//       against Vdac (negative) from the R2R network.
///////////////////////////////////////////////////////////////////////////////


module r2r_sar_adc_subsystem(
    input logic compare_match_n, // active_low, aka Vanalog => (+), Vdac => (-)
    input logic clk,
    input logic reset,
    input logic [1:0] bin_bcd_select, 
   
    output logic sample_control, // to S&H external circuit
    output logic [7:0] R2R_out,
    output logic [15:0] adc_outputs
);

    
    logic strobe_signal;
    integer_divider CLK_DIVIDER
    (
        .i_clk(clk),          
        .i_div(32'd100_000), // r2r is a faster DAC. thus faster clk
        .o_stb(strobe_signal)
    );
 
    //-------------
    
    r2r_sar_adc R2R_SAR_ADC
(
        .clk(clk),
        .reset(reset),
        .compare_match(compare_match_n), // active-low
        .adc_en(strobe_signal),
        
        .sample_control(sample_control),
        .bin_bcd_select(bin_bcd_select), 
        .R2R_outputs(R2R_out),
        .adc_outputs(adc_outputs)
);
      
endmodule
