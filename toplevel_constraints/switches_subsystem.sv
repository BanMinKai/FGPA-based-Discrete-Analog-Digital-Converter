///////////////////////////////////////////////////////////////////////////////
// Module Name: switches_subsystem
// 
// Description:
// This module handles the conversion between binary and BCD representation of 
// switch inputs. It takes 12-bit switch inputs, zero-extends them to 16 bits,
// and provides optional BCD conversion based on a selector button.
//
// Inputs:
//   - clk                    : System clock
//   - reset                  : System reset
//   - switches_inputs[11:0]  : Raw switch inputs
//   - DecimalBaseSelectButton: Binary/BCD format selector
//
// Outputs:
//   - switches_subsystem_outputs[15:0] : Switch values in selected format
//
// Internal Signals:
//   - bcd_outputs                  : Converted BCD value
//   - zero_extended_switches_inputs: 16-bit zero-extended switch inputs
//
// Operation:
//   1. Switch inputs are zero-extended from 12 to 16 bits
//   2. Binary-to-BCD conversion is performed continuously
//   3. DecimalBaseSelectButton selects output format:
//      - 0: Binary (zero-extended) format
//      - 1: BCD format
//
// Note: The binary-to-BCD conversion is always active, allowing immediate
//       format switching without conversion delay.
///////////////////////////////////////////////////////////////////////////////

module switches_subsystem(
    input logic clk,
    input logic reset,
    input logic [11:0] switches_inputs,
    input logic DecimalBaseSelectButton,
    output logic [15:0] switches_subsystem_outputs

    );
    
    logic [15:0] bcd_outputs;
    
    logic [15:0] zero_extended_switches_inputs;
    assign zero_extended_switches_inputs = {4'b0000, switches_inputs};
        
    bin_to_bcd BIN2BCD (
            .clk(    clk),
            .reset(  reset),
            .bin_in(zero_extended_switches_inputs),
            .bcd_out(bcd_outputs)
    );

       
  always_comb begin

    case(DecimalBaseSelectButton)
        0: switches_subsystem_outputs = zero_extended_switches_inputs ; 
        1: switches_subsystem_outputs = bcd_outputs;
        default: switches_subsystem_outputs = zero_extended_switches_inputs;  
    endcase
  end 
      
endmodule
