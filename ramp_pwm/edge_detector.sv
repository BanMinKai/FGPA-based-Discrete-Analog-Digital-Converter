///////////////////////////////////////////////////////////////////////////////
// Module Name: edge_detector
// 
// Description:
// This module detects either rising or falling edges of an input signal based on
// a parameter selection. It generates a single-cycle pulse when the selected edge
// type is detected.
//
// Inputs:
//   - clk   : System clock
//   - reset : System reset
//   - ready : Input signal to monitor for edges
//
// Outputs:
//   - ready_pulse: Single-cycle pulse on edge detection
//
// Parameters:
//   - FALLING_EDGE_ENABLE: When 1, detects falling edges; when 0, rising edges
//
// Internal Signals:
//   - ready_r: Registered version of input signal for edge detection
//
// Operation:
//   1. Input signal is registered to create one-cycle delay
//   2. Edge detection performed by comparing current and delayed signals:
//      - Falling edge: ready_r & ~ready
//      - Rising edge:  ~ready_r & ready
//
// Note: Assumes input signal is already synchronized to the clock domain
///////////////////////////////////////////////////////////////////////////////

module edge_detector
    #( parameter int FALLING_EDGE_ENABLE = 1) // by default falling-edge detector
(
    input logic clk,
    input logic reset,
    input logic ready,
    
    output logic ready_pulse
);
    
    logic ready_r;
    
    always_ff@(posedge clk) begin
        if (reset)
            ready_r <= 0;
        else
            ready_r <= ready;
    end
    
    
    //assume ready signal is synchronized
    if (FALLING_EDGE_ENABLE == 1)
            assign ready_pulse = ready_r & ~ready; // FALLING EDGE DETECTOR, assume ready signal is synchronized
    else 
            assign ready_pulse = ~ready_r & ready; // RISING EDGE DETECTOR

endmodule