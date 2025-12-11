module clock_generator(
input wire clk,        
input wire reset,     
input wire init,       
input wire eoc_signal,  
input wire wait_tx,    
output reg start_tx,    
output reg clk_adc     
);


parameter [1:0] S_IDLE   = 2'b00;
parameter [1:0] S_CLK_HI = 2'b01;
parameter [1:0] S_CLK_LO = 2'b10;

reg [1:0] current_state;


always @(posedge clk or posedge reset) begin
    if (reset) begin
       
        current_state <= S_IDLE;
        start_tx      <= 1'b0;
        clk_adc       <= 1'b0;
    end
    else begin
    
        case (current_state)
            S_IDLE: begin
                start_tx <= 1'b0;
                clk_adc  <= 1'b0;
                if (init) begin
                    current_state <= S_CLK_HI;
                end
              
            end

            S_CLK_HI: begin
                start_tx <= 1'b1;
                clk_adc  <= 1'b1;
                if (wait_tx) begin
                    current_state <= S_CLK_LO;
                end
            end

            S_CLK_LO: begin
                start_tx <= 1'b1;
                clk_adc  <= 1'b0;
                if (eoc_signal) begin
                    current_state <= S_IDLE;
                end else if (wait_tx) begin
                    current_state <= S_CLK_HI;
                end
            end

            default: begin
                current_state <= S_IDLE;
                start_tx      <= 1'b0;
                clk_adc       <= 1'b0;
            end
        endcase
    end
end
endmodule
