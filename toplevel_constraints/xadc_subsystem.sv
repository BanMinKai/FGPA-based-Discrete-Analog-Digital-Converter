///////////////////////////////////////////////////////////////////////////////
// Module Name: xadc_subsystem_with_decimal_converter
// 
// Description:
// This module implements an XADC-based subsystem with multiple output formats
// and data processing options. It provides raw ADC data, averaged data, scaled
// data, and optional BCD conversion of the results.
//
// Inputs:
//   - clk           : System clock
//   - reset         : System reset
//   - bin_bcd_select: 2-bit output format selector
//   - vauxp15       : XADC positive analog input (JXAC4:N2 PMOD pin)
//   - vauxn15       : XADC negative analog input (JXAC10:N1 PMOD pin)
//
// Outputs:
//   - xadc_outputs[15:0]: ADC result in selected format
//
// Internal Signals:
//   - data            : Raw ADC data
//   - ave_data        : Averaged ADC data
//   - scaled_adc_data : Scaled ADC data
//   - bcd_value       : BCD-converted scaled data
//
// Operation:
//   1. XADC samples analog input continuously
//   2. Data processing includes:
//      - Raw 12-bit ADC conversion
//      - Data averaging for noise reduction
//      - Scaling of averaged data
//      - BCD conversion of scaled data
//   3. Output format selected via bin_bcd_select:
//      - 00: Scaled data in hexadecimal
//      - 01: Scaled data in BCD
//      - 10: Raw 12-bit ADC data
//      - 11: Averaged 16-bit data
//
// Note: The system provides multiple data representation options for
//       different display and processing requirements.
///////////////////////////////////////////////////////////////////////////////


module xadc_subsystem_with_decimal_converter(

    input  logic   clk,
    input  logic   reset,
    input  logic [1:0] bin_bcd_select,
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    
    output logic [15:0] xadc_outputs
    );
    
    logic [15:0] data, ave_data;              // Raw ADC data
    logic [15:0] scaled_adc_data;

    logic [15:0] bcd_value;
    
    adc_subsystem ADC_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vauxp15(vauxp15),
        .vauxn15(vauxn15),
        
        .raw_adc_data_out(data),
        .ave_adc_data_out(ave_data),
        .scaled_adc_data_out(scaled_adc_data)
    );

    
    bin_to_bcd BIN2BCD (
            .clk(    clk),
            .reset(  reset),
            .bin_in( scaled_adc_data),
            .bcd_out(bcd_value)
        );
    
    mux4_16_bits MUX4 (
        .in0(scaled_adc_data), // hexadecimal, scaled and averaged
        .in1(bcd_value),       // decimal, scaled and averaged
        .in2(data[15:4]),      // raw 12-bit ADC hexadecimal
        .in3(ave_data),        // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
        .select(bin_bcd_select),
        .mux_out(xadc_outputs)
    );

    
endmodule
