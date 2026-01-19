///////////////////////////////////////////////////////////////////////////////
// Module Name: integer_divider
// 
// Description:
// Clock divider module that generates a periodic strobe signal based on a
// configurable division ratio. Uses a down-counter to create periodic pulses.
//
// Inputs:
//   - i_clk   : Input clock signal
//   - i_div   : 32-bit division ratio
//
// Outputs:
//   - o_stb   : Single-cycle strobe output pulse
//
// Internal Signals:
//   - counter : 32-bit down counter for timing
//
// Operation:
//   1. Counter loads division value when reaching zero
//   2. Counter decrements each clock cycle
//   3. Strobe output pulses high for one cycle when counter reaches 1
//
// Note: Division ratio must be > 1 for proper operation. Output strobe
//       frequency = input clock frequency / division ratio
///////////////////////////////////////////////////////////////////////////////

module integer_divider (
    input  logic        i_clk,
    input  logic [31:0] i_div,
    output logic        o_stb
);

    logic [31:0] counter;

    always_ff @(posedge i_clk) begin
        if (counter == '0)
            counter <= i_div;
        else
            counter <= counter - 1'b1;
    end

    always_ff @(posedge i_clk) begin
        o_stb <= (counter == 1'b1);
    end

endmodule