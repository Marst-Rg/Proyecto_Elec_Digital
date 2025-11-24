module peripheral_div(clk , rst , d_in , cs , addr , rd , wr, d_out );
  
  input clk;
  input rst;
  input [15:0]d_in;
  input cs;
  input [3:0]addr;
  input rd;
  input wr;
  output reg [15:0]d_out;



reg [5:0] s; 	

reg [15:0] A=0;
reg [15:0] B=0;
reg init=0;

wire [15:0] C;	
wire done;







always @(*) begin
case (addr)
4'h0:begin s = (cs && wr) ? 6'b000001 : 6'b000000 ;end 
4'h2:begin s = (cs && wr) ? 6'b000010 : 6'b000000 ;end 
4'h4:begin s = (cs && wr) ? 6'b000100 : 6'b000000 ;end 

4'h6:begin s = (cs && rd) ? 6'b001000 : 6'b000000 ;end 
4'h8:begin s = (cs && rd) ? 6'b010000 : 6'b000000 ;end 
default:begin s = 6'b000000 ; end
endcase
end




always @(negedge clk) begin

A    = (s[0]) ? d_in : A;	
B    = (s[1]) ? d_in : B;	
init = s[2] ; 

end




always @(negedge clk) begin
case (s[5:3])
3'b001: d_out[0] = done ;
3'b010: d_out    = C ;
default: d_out   = 0 ;
endcase

end

div_16 d_16(.clk(clk), .rst(rst), .init_in(init) , .A(A), .B(B), .Result(C), .done(done));

endmodule
