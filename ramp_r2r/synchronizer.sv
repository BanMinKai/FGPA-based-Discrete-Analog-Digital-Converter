///////////////////////////////////////////////////////////////////////////////
// Module Name: synchronizer
// 
// Description:
// Parameterized two-stage synchronizer for crossing clock domains or
// synchronizing asynchronous inputs. Implements double-flopping technique
// to reduce metastability risks.
//
// Parameters:
//   - WIDTH: Bit width of signals to synchronize (default: 16)
//
// Inputs:
//   - clk          : Destination clock domain
//   - async_inputs : Asynchronous input signals [WIDTH-1:0]
//
// Outputs:
//   - sync_outputs : Synchronized output signals [WIDTH-1:0]
//
// Internal Signals:
//   - n1: First stage synchronizer registers [WIDTH-1:0]
//
// Operation:
//   1. First flip-flop captures asynchronous input
//   2. Second flip-flop resolves potential metastability
//   3. Output is synchronized to destination clock domain
//
// Note: Assumes input remains stable for at least two clock cycles
//       for reliable synchronization
///////////////////////////////////////////////////////////////////////////////

module synchronizer
    #(parameter int WIDTH = 16)
    (
        input logic clk,
        input logic [WIDTH-1:0] async_inputs,
        output logic [WIDTH-1:0] sync_outputs
    );
    
    logic [WIDTH-1:0] n1; // internal signal, a bit safer than, 
                     // make sure has the same bit resolution as inputs 
    always_ff @ (posedge clk) begin
        n1 <= async_inputs;
        sync_outputs <= n1;
    end
endmodule
