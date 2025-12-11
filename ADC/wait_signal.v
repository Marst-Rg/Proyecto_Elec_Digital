module wait_signal (
    input wire clk_sys,
    input wire reset,
    input wire start_tx,
    output reg wait_tx
);

 
    parameter [1:0] S_IDLE      = 2'b00;
    parameter [1:0] S_COUNTING  = 2'b01;
    parameter [1:0] S_PULSE     = 2'b10;

    reg [1:0] state;
    reg [3:0] counter; 

 
    always @(posedge clk_sys or posedge reset) begin
        if (reset) begin
            
            state   <= S_IDLE;
            counter <= 0;
            wait_tx <= 1'b0;
        end 
        else begin
            case (state)
                S_IDLE: begin
                    wait_tx <= 1'b0;
                    if (start_tx) begin
                        state   <= S_COUNTING;
                        counter <= 0; 
                    end
                end

                S_COUNTING: begin
                    if (counter == 12) begin
                        state <= S_PULSE;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                S_PULSE: begin
                    wait_tx <= 1'b1;
                    state   <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
    
endmodule