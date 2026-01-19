///////////////////////////////////////////////////////////////////////////////
// Module Name: r2r_adc_system
// 
// Description:
// This module implements a top-level R2R ADC system with two selectable conversion
// algorithms: R2R-based ramp ADC and R2R-based SAR ADC. Each subsystem uses an R2R
// ladder network for digital-to-analog conversion, with configurable output formats
// and runtime algorithm selection.
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
//   - r2r_outputs   : 8-bit output to R2R ladder network
//
// Internal Signals:
//   - ramp_outputs     : Output from ramp ADC subsystem
//   - ramp_r2r_outputs : R2R output from ramp subsystem
//   - sar_outputs      : Output from SAR ADC subsystem
//   - sar_r2r_outputs  : R2R output from SAR subsystem
//   - sar_sample_control: Sample control from SAR subsystem
//
// Operation:
//   1. Both ADC subsystems operate continuously in parallel
//   2. algorithm_select determines which subsystem's outputs are selected:
//      - 0: Ramp ADC (default)
//      - 1: SAR ADC
//   3. Sample control is fixed high for ramp ADC, dynamic for SAR ADC
//
// Note: The system provides both digital conversion results and direct R2R ladder
//       control signals for analog conversion.
///////////////////////////////////////////////////////////////////////////////


module r2r_adc_system(
    input logic compare_match_n,
    input logic clk,
    input logic reset,
    input logic [1:0] bin_bcd_select, 
    input logic algorithm_select,
    
    
    output logic sample_control, // to S&H external circuit
    output logic [15:0] adc_outputs,
    output logic [7:0] r2r_outputs
);
    
      // R2R  ramp adc subsystem
    logic [15:0] ramp_outputs;
    logic [7:0]  ramp_r2r_outputs;
    r2r_ramp_adc_subsystem R2R_RAMP_ADC
(
        .clk(clk),
        .reset(reset),
        .compare_match(compare_match_n),

        .bin_bcd_select(bin_bcd_select), 
        .r2r_outputs(ramp_r2r_outputs),
        .adc_outputs(ramp_outputs)
);


    // R2R sar system
    logic [15:0] sar_outputs;
    logic [7:0]  sar_r2r_outputs;
    logic sar_sample_control;
    
    r2r_sar_adc_subsystem R2R_SAR_ADC
(
        .clk(clk),
        .reset(reset),
        .compare_match_n(compare_match_n),
        .bin_bcd_select(bin_bcd_select),
        
        .sample_control(sar_sample_control),
        .R2R_out(sar_r2r_outputs),
        .adc_outputs(sar_outputs)
);

  // which-ADC algorithm 
  always_comb begin
    case(algorithm_select)
        1'b0: begin
                adc_outputs= ramp_outputs;
                r2r_outputs = ramp_r2r_outputs;
                sample_control = 'b1;  // o for rample, 1 for SAR
            end
        1'b1: begin
                adc_outputs = sar_outputs;
                r2r_outputs = sar_r2r_outputs;
                sample_control = sar_sample_control;
            end
        default: begin // default ramp
                adc_outputs= ramp_outputs;
                r2r_outputs = ramp_r2r_outputs;
                sample_control = 'b1;  // o for rample, 1 for SAR
            end
    endcase
  end    


endmodule
