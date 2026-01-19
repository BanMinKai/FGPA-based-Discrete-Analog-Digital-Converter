///////////////////////////////////////////////////////////////////////////////
// Module Name: sawtooth_waveform
// 
// Description:
// Generates a sawtooth waveform using PWM with configurable frequency and
// resolution. Includes both PWM output and parallel digital output for
// R2R ladder conversion.
//
// Parameters:
//   - WIDTH      : Output resolution in bits (default: 8)
//   - CLOCK_FREQ : System clock frequency in Hz (default: 100MHz)
//   - WAVE_FREQ  : Desired sawtooth frequency in Hz (default: 1.0)
//
// Inputs:
//   - clk   : System clock
//   - reset : Active-high reset
//   - enable: Waveform generation enable
//
// Outputs:
//   - pwm_out : PWM output signal
//   - R2R_out : Parallel digital output [WIDTH-1:0]
//
// Operation:
//   1. Counter increments at calculated rate based on desired frequency
//   2. Counter wraps from maximum value to zero
//   3. Current count value drives both PWM and R2R outputs
//   4. PWM module converts count to pulse-width modulated signal
//
// Note: Module validates timing parameters at initialization to ensure
//       proper frequency generation
///////////////////////////////////////////////////////////////////////////////

module sawtooth_waveform
    #(
        parameter int WIDTH = 8,                   // Bit width for duty_cycle
        parameter int CLOCK_FREQ = 100_000_000,    // System clock frequency in Hz
        parameter real WAVE_FREQ = 1.0             // Desired sawtooth wave frequency in Hz
    )
    (
        input  logic clk,      // System clock (100 MHz)
        input  logic reset,    // Active-high reset
        input  logic enable,   // Active-high enable
        output logic pwm_out,  // PWM output signal
        output logic [WIDTH-1:0] R2R_out // R2R ladder output
    );

    // Calculate maximum duty cycle value based on WIDTH
    localparam int MAX_DUTY_CYCLE = (2 ** WIDTH) - 1;  // 255 for WIDTH = 8
    
    // For sawtooth, we only count up, then reset
    localparam int TOTAL_STEPS = MAX_DUTY_CYCLE + 1;   // 256 steps (0-255)
    
    // Calculate downcounter PERIOD to achieve desired wave frequency
    // Since we only count up (not up and down), we need half the period of triangle wave
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ / (WAVE_FREQ * TOTAL_STEPS));

    // Ensure DOWNCOUNTER_PERIOD is positive
    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be positive. Adjust CLOCK_FREQ or WAVE_FREQ.");
        end
    end

    // Internal signals
    logic zero;                   // Output from downcounter (enables duty_cycle update)
    logic [WIDTH-1:0] duty_cycle; // Duty cycle value for PWM
    
    assign R2R_out = duty_cycle; // R2R ladder resistor circuit automatically generates the analog voltage

    // Instantiate downcounter module
    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)  // Set downcounter period based on calculations
    ) downcounter_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .zero(zero)
    );

    // Duty cycle counter logic - only counts up, then resets
    always_ff @(posedge clk) begin
        if (reset) begin
            duty_cycle <= 0;    // Initialize duty_cycle to 0 on reset
        end else if (enable) begin
            if (zero) begin
                if (duty_cycle == MAX_DUTY_CYCLE) begin
                    duty_cycle <= 0;           // Reset to 0 when reaching max
                end else begin
                    duty_cycle <= duty_cycle + 1; // Increment duty_cycle
                end
            end
        end else begin
            duty_cycle <= 0;    // Reset when disabled
        end
    end

    // Instantiate PWM module
    pwm #(
        .WIDTH(WIDTH)
    ) pwm_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

endmodule
