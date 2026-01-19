///////////////////////////////////////////////////////////////////////////////
// Module Name: pulser
// 
// Description:
// This module implements a rising edge detector that generates a single-cycle
// pulse when a rising edge is detected on the input signal.
//
// Inputs:
//   - clk   : System clock
//   - reset : System reset
//   - ready : Input signal to monitor for rising edges
//
// Outputs:
//   - ready_pulse: Single-cycle pulse on rising edge detection
//
// Internal Signals:
//   - ready_r: Registered version of input signal for edge detection
//
// Operation:
//   1. Input signal is registered to create one-cycle delay
//   2. Rising edge detected by comparing: ~ready_r & ready
//   3. Generates single-cycle pulse when rising edge detected
//
// Note: Assumes input signal is already synchronized to the clock domain
///////////////////////////////////////////////////////////////////////////////


module pulser(
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
    
    assign ready_pulse = ~ready_r & ready; // RISING EDGE DETECTOR
endmodule
