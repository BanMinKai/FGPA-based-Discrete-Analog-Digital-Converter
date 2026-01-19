/*
    this is the main file for the whole project
    4 different adcs
      ramp r2r vs sar r2r
      ramp PWM vs ramp R2R
    a mux is used to select which adc to use,
    the select signal for the mux should come from an FSM-based menu selection system

    Vanalog_input is within the range of 0V-1V for all ADCs

*/

///////////////////////////////////////////////////////////////////////////////
// Module Name: lab_7_top_level
// 
// Description:
// Top-level module integrating four different ADC implementations and display
// functionality. Supports comparison between PWM and R2R-based ADCs using both
// ramp and SAR architectures. Takes analog input in 0-1V range and provides
// multiple display formats.
//
// Inputs:
//   - clk                     : System clock
//   - reset                   : System reset
//   - bin_bcd_select         : 2-bit output format selector
//   - switches_inputs        : 12-bit switch inputs
//   - FSM_outputs           : 2-bit ADC selection (from FSM/switches)
//   - DecimalBaseSelectButton: Binary/BCD format selector
//   - compare_match_pwm      : PWM comparator input
//   - compare_match_r2r      : R2R comparator input
//   - vauxp15, vauxn15      : XADC analog inputs
//
// Outputs:
//   - pwm_out               : PWM waveform output
//   - r2r_out[7:0]         : R2R ladder network output
//   - CA-CG, DP            : Seven-segment segment controls
//   - AN1-AN4              : Seven-segment digit enables
//
// Internal Systems:
//   1. XADC Subsystem (Golden Reference)
//   2. PWM-based ADC System:
//      - Ramp and SAR architectures
//      - Selectable via algorithm_select
//   3. R2R-based ADC System:
//      - Ramp and SAR architectures
//      - Selectable via algorithm_select
//   4. Switch Input System
//
// Operation:
//   1. ADC Selection via FSM_outputs:
//      00: Switch inputs display
//      01: XADC outputs
//      10: PWM ADC outputs
//      11: R2R ADC outputs
//   2. Decimal point control via bin_bcd_select
//   3. All ADCs operate in parallel
//   4. Selected output displayed on seven-segment display
//
// Note: Future enhancement planned for FSM-based menu selection system
//       Currently using switches for ADC selection
///////////////////////////////////////////////////////////////////////////////


module lab_7_top_level(
    input  logic   clk,
    input  logic   reset,
    input  logic [1:0] bin_bcd_select, // btnU
    
    input logic [11:0] switches_inputs,
    input logic [1:0] FSM_outputs, // for now I would use switches_inputs[15:14] to subsitute for this
    input logic DecimalBaseSelectButton,

    // input signal from the external comparator LM311
    input logic compare_match_pwm, // pwm
    input logic compare_match_r2r,

    // xadc 
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    
    // waveform outputs
    output logic pwm_out,
    output logic [7:0] r2r_out,

    // seven-segment outputs
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,
    output logic   AN1, AN2, AN3, AN4
);

    // Internal signal declarations -----------------------------------------------------------------------------
    logic [3:0]  decimal_pt; // vector to control the decimal point, 1 = DP on, 0 = DP off
                             // [0001] DP right of seconds digit        
                             // [0010] DP right of tens of seconds digit
                             // [0100] DP right of minutes digit        
                             // [1000] DP right of tens of minutes digit
    logic [15:0] xadc_outputs;
    logic [15:0] adc_mux_outputs;
    logic [15:0] switches_subsystem_outputs;
    

  // XADC SUBSYSTEM (GOLDEN MODEL)--------------------------------------------------------------------------------------------
  
  xadc_subsystem_with_decimal_converter XADC_SUBSYSTEM
  (
      .clk(clk),
      .reset(reset),
      .bin_bcd_select(bin_bcd_select),
      .vauxp15(vauxp15), // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
      .vauxn15(vauxn15), // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
      .xadc_outputs(xadc_outputs)
  
  );


  // PWM AND R2R ADCs integration -----------------------------------------------------------------------------------------------
  logic sample_control_pwm; // make it internal for now, doesnot really matter since not using it
  logic sample_control_r2r;
 
  logic algorithm_select;
  assign algorithm_select = switches_inputs[0];  // switches[0] is used to switch between SAR and RAMP
 
  logic [15:0] pwm_adc_outputs;
  logic [15:0] r2r_adc_outputs;

  // PWM SYSTEM ---------------------------------------------------------------
  pwm_adc_system PWM_SYSTEM
  (
        .clk(clk),
        .reset(reset),
        .compare_match_n(compare_match_pwm),
        .bin_bcd_select(bin_bcd_select), 
        .algorithm_select(algorithm_select),
        
        .sample_control(sample_control_pwm),
        .pwm_out(pwm_out),
        .adc_outputs(pwm_adc_outputs)
  );
  
  // R2R SYSTEM ---------------------------------------------------------------
  r2r_adc_system R2R_SYSTEM
  (
        .clk(clk),
        .reset(reset),
        .compare_match_n(compare_match_r2r),
        .bin_bcd_select(bin_bcd_select), 
        .algorithm_select(algorithm_select),
        
        .sample_control(sample_control_r2r),
        .r2r_outputs(r2r_out),
        .adc_outputs(r2r_adc_outputs)
  );
  
  
  // SWITCHES INPUT -------------------------------------------------------
  
  switches_subsystem SWITCHES_SUBSYSTEM(
    .clk(clk),
    .reset(reset),
    .switches_inputs(switches_inputs),
    .DecimalBaseSelectButton(DecimalBaseSelectButton),
    .switches_subsystem_outputs(switches_subsystem_outputs)
    );
    
  // WHICH-ADC DETERMINATION MUX ----------------------------------------------------------------------------------
  // the mux select signal should come from an FSM_based menu selection subsystem if the subsystem is designed
  always_comb begin
    case(FSM_outputs)
        2'b00: adc_mux_outputs= switches_subsystem_outputs;  // 12 switches slides
        2'b01: adc_mux_outputs = xadc_outputs;  // xadc
        2'b10: adc_mux_outputs = pwm_adc_outputs;  
        2'b11: adc_mux_outputs = r2r_adc_outputs;
        default: adc_mux_outputs = switches_subsystem_outputs;  // Default case: output all zeros
    endcase
  end    

  // DECIMAL POINT DETERMINATION MUX ------------------------------------------------------------
  always_comb begin
    case(bin_bcd_select)
        2'b00: decimal_pt = 4'b0000;  // averaged ADC with extra 4 bits
        2'b01: decimal_pt = 4'b0010;  // averaged and scaled voltage
        2'b10: decimal_pt = 4'b0000;  // raw ADC (12-bits)
        2'b11: decimal_pt = 4'b0000;
        default: decimal_pt = 16'h0000;  // Default case: output all zeros
    endcase
  end    
  
  //assign decimal_pt = 4'b0010; // vector to control the decimal point, 1 = DP on, 0 = DP off
                               // [0001] DP right of seconds digit        
                               // [0010] DP right of tens of seconds digit
                               // [0100] DP right of minutes digit        
                               // [1000] DP right of tens of minutes digit
  
  // Seven Segment Display Subsystem
  seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk), 
        .reset(reset), 
        .sec_dig1(adc_mux_outputs[3:0]),     // Lowest digit
        .sec_dig2(adc_mux_outputs[7:4]),     // Second digit
        .min_dig1(adc_mux_outputs[11:8]),    // Third digit
        .min_dig2(adc_mux_outputs[15:12]),   // Highest digit
        .decimal_point(decimal_pt),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), 
        .CE(CE), .CF(CF), .CG(CG), .DP(DP), 
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
endmodule