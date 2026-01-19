///////////////////////////////////////////////////////////////////////////////
// Module Name: sample_capture
// 
// Description:
// This module captures ADC samples based on comparator transitions. It includes
// input synchronization, edge detection, and data capture functionality.
//
// Inputs:
//   - clk           : System clock
//   - reset         : System reset
//   - compare_match : Active-LOW comparator input from LM311
//   - R2R_input    : Current 8-bit R2R ladder value
//
// Outputs:
//   - u8_raw_data : Captured 8-bit ADC value
//   - ready_pulse : Active-HIGH sample valid indicator
//
// Internal Signals:
//   - sync_compare_match: Synchronized comparator input
//
// Operation:
//   1. Comparator input is synchronized to system clock
//   2. Falling edge detection on synchronized comparator signal
//   3. R2R value is captured on falling edge of comparator
//   4. Ready pulse indicates valid sample capture
//
// Note: Uses modular design with separate synchronizer, edge detector,
//       and capture register components for improved maintainability
///////////////////////////////////////////////////////////////////////////////

module sample_capture (
    input  logic        clk,
    input  logic        reset,
    input  logic        compare_match,    // From LM311 (active-LOW)
    input  logic [7:0]  R2R_input,       // Current R2R ladder value
    output logic [7:0]  u8_raw_data,     // Captured ADC value
    output logic        ready_pulse       // Active-HIGH sample valid pulse
);



    // modular cleanup
    // internal signal
    logic sync_compare_match;
    
    synchronizer
    #(.WIDTH(1)) 
    SYNCHRONIZER
    (
        .clk(clk),
        .async_inputs(compare_match),
        .sync_outputs(sync_compare_match)
    );
    
    // edge detector
    edge_detector 
    #(.FALLING_EDGE_ENABLE(1)) // FALLING_EDGE_ENABLE(0) = rising edge detector
    FALLING_EDGE_DETECTOR
    (
        .clk(clk),
        .reset(reset),
        .ready(sync_compare_match),
        .ready_pulse(ready_pulse)
    );
    
    // register to capture duty cycle when crossing happens
    register_r_en 
    #(.width(8))
    CAPTURE_REG
    (
        .clk(clk),
        .reset(reset),
        .en(ready_pulse),
        
        .d(R2R_input),
        .q(u8_raw_data)
    );
    
endmodule
