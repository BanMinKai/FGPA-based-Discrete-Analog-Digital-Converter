///////////////////////////////////////////////////////////////////////////////
// Module Name: pwm_adc_system
// 
// Description:
// This module implements a top-level ADC system that can switch between two ADC 
// implementations: a PWM-based ramp ADC and a PWM-based SAR ADC. The system allows
// runtime selection between these two conversion methods and provides configurable
// binary/BCD output format.
//
// Inputs:
//   - compare_match_n : Active-low comparator input
//   - clk            : System clock
//   - reset          : System reset
//   - bin_bcd_select : 2-bit selector for output format
//   - algorithm_select: ADC algorithm selector (0:Ramp, 1:SAR)
//
// Outputs:
//   - sample_control : Control signal for external Sample & Hold circuit
//   - adc_outputs   : 16-bit conversion result
//   - pwm_out       : PWM output signal
//
// Internal Signals:
//   - ramp_outputs    : Output from ramp ADC subsystem
//   - ramp_pwm_out    : PWM output from ramp subsystem
//   - sar_outputs     : Output from SAR ADC subsystem
//   - sar_pwm_out     : PWM output from SAR subsystem
//   - sar_sample_control: Sample control from SAR subsystem
//
// Operation:
//   1. Both ADC subsystems operate continuously in parallel
//   2. algorithm_select determines which subsystem's outputs are selected:
//      - 0: Ramp ADC (default)
//      - 1: SAR ADC
//   3. Sample control is fixed high for ramp ADC, dynamic for SAR ADC
//
// Note: The system maintains both ADC subsystems active but only outputs
//       the selected algorithm's results.
///////////////////////////////////////////////////////////////////////////////


module pwm_adc_system(
    input logic compare_match_n,
    input logic clk,
    input logic reset,
    input logic [1:0] bin_bcd_select, 
    input logic algorithm_select,
    
    
    output logic sample_control, // to S&H external circuit
    output logic [15:0] adc_outputs,
    output logic pwm_out
    );
    
    
    logic [15:0] ramp_outputs;
    logic ramp_pwm_out;
    pwm_ramp_adc_subsystem PWM_RAMP_ADC
(
        .clk(clk),
        .reset(reset),
        .compare_match(compare_match_n),

        .bin_bcd_select(bin_bcd_select), 
        .pwm_out(ramp_pwm_out),
        .adc_outputs(ramp_outputs)
);

    logic [15:0] sar_outputs;
    logic sar_pwm_out;
    logic sar_sample_control;
    pwm_sar_adc_subsystem PWM_SAR_ADC
(
        .clk(clk),
        .reset(reset),
        .compare_match_n(compare_match_n),
        .bin_bcd_select(bin_bcd_select),
        
        .sample_control(sar_sample_control),
        .pwm_out(sar_pwm_out),
        .adc_outputs(sar_outputs)
);

  // which-ADC algorithm 
  always_comb begin
    case(algorithm_select)
        1'b0: begin
                adc_outputs= ramp_outputs;
                pwm_out = ramp_pwm_out;
                sample_control = 'b1;  // o for rample, 1 for SAR
            end
        1'b1: begin
                adc_outputs = sar_outputs;
                pwm_out = sar_pwm_out;
                sample_control = sar_sample_control;
            end
        default: begin // default ramp
                adc_outputs= ramp_outputs;
                pwm_out = ramp_pwm_out;
                sample_control = 'b1;  // o for rample, 1 for SAR
            end
    endcase
  end    


endmodule
