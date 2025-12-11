module adc (

input wire  clk,
input wire  reset,
input wire  start_tx,
input wire  eoc,
output reg  done_pulse,
output wire [7:0] data_out,
output reg  eoc_signal
);


parameter S_IDLE      = 2'b00;
parameter S_WAIT_EOC  = 2'b01;
parameter S_DONE      = 2'b10;


reg [1:0] current_state;
reg [4:0] count; 


always @(posedge clk or posedge reset) begin
    if (reset) begin
       
        current_state <= S_IDLE;
        done_pulse    <= 1'b0;
        eoc_signal    <= 1'b0;
        count         <= 0;
    end
    else begin
        
        done_pulse <= 1'b0;

        case (current_state)
            S_IDLE: begin
                eoc_signal <= 1'b0;
                if (start_tx) begin
                    current_state <= S_WAIT_EOC;
                    count <= 0; 
                end
            end

            S_WAIT_EOC: begin
                if (eoc) begin
                    
                    current_state <= S_DONE;

                end
            end

            S_DONE: begin
                if (count == 25) begin
                   
                    done_pulse    <= 1'b1;
                    eoc_signal    <= 1'b1;
                    current_state <= S_IDLE;
                end else begin
                   
                    count <= count + 1;
                end
            end

            default: begin
                current_state <= S_IDLE;
            end
        endcase
    end
end
endmodule


