module sum (

    input  wire [3:0] A,
    input  wire       bm,
    output reg  [3:0] A_new
    
);
    
    always @(*) begin
        if (bm) begin
            A_new <= A + 4'd3;  
 
        end else begin
            A_new <= 4'd0;        

        end
    end
endmodule