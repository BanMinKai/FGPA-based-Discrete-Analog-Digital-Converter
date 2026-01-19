module pwm #( 
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             reset,
    input  logic             enable,
    input  logic [WIDTH-1:0] duty_cycle,
    output logic             pwm_out
);

    logic [WIDTH-1:0] counter;

    always_ff @(posedge clk) begin  // counter
        if (reset)
            counter <= 0;
        else if (enable)
            counter <= counter + 1;
    end

    always_comb begin  // compare-match
        if (!enable)
            pwm_out = 1'b0;  // Output low when not enabled
        else if (duty_cycle == {WIDTH{1'b1}}) // always ON
            pwm_out = 1'b1;
        else if (counter < duty_cycle) // counter not get reset when >= duty_cycle => variable duty cycle   
                                        // if get reset => must be 50% duty cycle
                                        // reset by assuming that bits automatically become zeros when overflowing!
            pwm_out = 1'b1;
        else 
            pwm_out = 1'b0; 
    end

endmodule
