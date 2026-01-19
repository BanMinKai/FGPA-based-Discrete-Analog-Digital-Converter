// ADC controller
module sar_adc_controller (
    input  logic        clk,    // clock input
    input  logic        reset,
    input  logic        go,     // go=1 to perform conversion
    output logic        valid,  // valid=1 when conversion finished
    output logic [7:0]  result, // 8 bit result output
    output logic        sample, // to S&H circuit
    output logic [7:0]  value,  // to DAC
    input  logic        cmp     // from comparitor, active high
);
    // State type definition
    typedef enum logic [1:0] {
        sWait   = 2'b00,
        sSample = 2'b01,
        sConv   = 2'b10,
        sDone   = 2'b11
    } state_t;
    
    // State registers
    state_t state;           // current state in state machine
    logic [7:0] mask;       // bit to test in binary search
    
    // synchronous design
    always_ff @(posedge clk) begin
        if (reset)
            state <= sWait;
        else if (!go) 
            state <= sWait;  // stop and reset if go=0
        else case (state)    // choose next state in state machine
            sWait: begin
                state <= sSample;
            end
            
            sSample: begin
                // start new conversion so
                state <= sConv;     // enter convert state next
                mask <= 8'b1000_0000; // reset mask to MSB only
                result <= 8'b0;     // clear result
            end
            
            sConv: begin
                // set bit if comparitor indicates input larger than
                // value currently under consideration, else leave bit clear
                if (cmp) 
                    result <= result | mask;
                // shift mask to try next bit next time
                mask <= mask >> 1;
                // finished once LSB has been done
                if (mask[0]) 
                    state <= sDone;
            end
            
            sDone: begin
                // When done and go still high, start new conversion
                state <= sSample;
            end
        endcase
    end
    
    // Continuous assignments
    assign sample = (state == sSample); // drive sample and hold
    assign value = result | mask;       // (result so far) OR (bit to try)
    assign valid = (state == sDone);    // indicate when finished

endmodule
