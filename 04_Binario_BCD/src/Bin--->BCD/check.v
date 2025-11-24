module check (
    input  [3:0] A,
    input  [3:0] value,
    output reg bm
);
  
    reg [4:0] diff;  
    reg msb;          

    always @(*) begin
        diff = {1'b0, A} - {1'b0, value};  
        msb = diff[4];                   
        if (!msb)
            bm = 1'b1;
        else
            bm = 1'b0;
    end

endmodule
