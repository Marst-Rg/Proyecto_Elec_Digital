module A_reg (
    input  wire        clk,
    input  wire [15:0] X,
    input  wire        ldr2,
    input  wire        ld, 
    input  wire        sh,
    input  wire [15:0] A_new,
    output reg  [15:0] resultado
);

    reg [31:0] A = 32'd0;

    always @(negedge clk) begin
        if (ld) begin
  
            A <= {16'd0, X};              
        end 
        else begin
           
            if (sh)
                A <= {A[30:0], 1'b0};

            if (ldr2) begin
                if (A_new[15:12] != 4'd0)
                    A[31:28] <= A_new[15:12];
                else
                    A[31:28] <= A[31:28];

                if (A_new[11:8] != 4'd0)
                    A[27:24] <= A_new[11:8];
                else
                    A[27:24] <= A[27:24];

                if (A_new[7:4] != 4'd0)
                    A[23:20] <= A_new[7:4];
                else
                    A[23:20] <= A[23:20];

                if (A_new[3:0] != 4'd0)
                    A[19:16] <= A_new[3:0];
                else
                    A[19:16] <= A[19:16];
            end
        end

        resultado <= A[31:16];
    end

endmodule
