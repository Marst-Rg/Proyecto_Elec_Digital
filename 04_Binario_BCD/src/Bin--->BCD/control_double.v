module control_double(
    input  wire clk,
    input  wire rst,
    input  wire init,
    input  wire [3:0] msb,
    input  wire z,
    output reg  done,
    output reg  sh,
    output reg  ld,
    output reg  ldr2,
    output reg  dec
);

 
    localparam IDLE      = 3'b000;
    localparam SHIFT     = 3'b001;
    localparam CHECK_MSB = 3'b010;
    localparam SUMA      = 3'b011;
    localparam DEC_ST    = 3'b100;
    localparam END1      = 3'b101;

    reg [2:0] state, next_state;


    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (init)
                    next_state = SHIFT;
            end

            SHIFT: next_state = CHECK_MSB;
            

            CHECK_MSB: begin
    
                if (msb != 0 && z)
                    next_state = SUMA;
                else if (z)
                    next_state = DEC_ST;
                else
                    next_state = END1;
            end

           

            SUMA: begin
                next_state = DEC_ST;
            end

            DEC_ST: begin
                if (!z)
                    next_state = END1;
                else
                    next_state = SHIFT;
            end

            END1: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end


    always @(*) begin
     
        done  = 0;
        sh    = 0;
        ld    = 0;
        ldr2  = 0;
        dec   = 0;

        case (state)
            IDLE: begin
                ld   = 1; 
            end

            SHIFT: begin
                sh   = 1; 
            end

            CHECK_MSB: begin
              
            end

            SUMA: begin
                ldr2 = 1; 
            end

            DEC_ST: begin
                dec = 1;  
            end

            END1: begin
                done = 1; 
            end
        endcase
    end

  
`ifdef BENCH
    reg [8*40:1] state_name;
    always @(*) begin
        case (state)
            IDLE      : state_name = "IDLE";
            SHIFT     : state_name = "SHIFT";
            CHECK_MSB : state_name = "CHECK_MSB";
            SUMA      : state_name = "SUMA";
            DEC_ST    : state_name = "DEC_ST";
            END1      : state_name = "END1";
            default   : state_name = "UNKNOWN";
        endcase
    end
`endif

endmodule
