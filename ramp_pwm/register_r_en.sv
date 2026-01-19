///////////////////////////////////////////////////////////////////////////////
// Module Name: register_r_en
// 
// Description:
// Parameterized synchronous register with active-high reset and enable signals.
// Provides storage for variable-width data with controlled loading.
//
// Parameters:
//   - width: Bit width of the register (default: 8)
//
// Inputs:
//   - clk   : System clock
//   - reset : Active-high synchronous reset
//   - en    : Active-high load enable
//   - d     : Data input [width-1:0]
//
// Outputs:
//   - q     : Registered output [width-1:0]
//
// Operation:
//   1. On reset, output is cleared to all zeros
//   2. When enabled, input data is registered on clock edge
//   3. When disabled, register maintains current value
//
// Note: Uses synchronous reset for better FPGA implementation
///////////////////////////////////////////////////////////////////////////////

module register_r_en 
    #(parameter width = 8)
(
    input logic clk,
    input logic reset,
    input logic en,
    input logic [width-1:0] d,
    output logic [width-1:0] q
);

    always_ff @(posedge clk) begin // {
        if (reset)
            q <= {width{1'b0}};
        else if (en) 
            q <= d;
    end // }
endmodule