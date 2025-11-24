module contador(
    input  wire clk,
    input  wire ld,      
    input  wire dec,       
    output reg Z   
    
);

  reg [3:0] m;  

  always @(posedge clk) begin
    if (ld) begin    
        m <= 4'd15;       
        Z <= 1'b1;        
    end
    else  
    if (dec && m > 0) begin
        m <= m - 4'd1;    
        Z <= 1'b1;        
      end
      else if(m==0) begin
        Z <= 1'b0;        
      end
    
  end

endmodule

