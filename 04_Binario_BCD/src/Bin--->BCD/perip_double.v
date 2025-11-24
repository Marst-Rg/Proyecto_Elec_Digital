module peripheral_double(
  input  wire        clk,
  input  wire        reset,
  input  wire [15:0] d_in,
  input  wire        cs,
  input  wire [4:0]  addr,
  input  wire        rd,
  input  wire        wr,
  output reg  [15:0] d_out
);

  reg [4:0]  s;        
  reg [15:0] A;        
  reg        init, init_pulse;     
  wire [15:0] C;       
  wire       done;     


  always @(*) begin
    if (cs) begin
      case (addr)
        5'h04: s = 5'b00001; 
        5'h08: s = 5'b00010; 
        5'h0C: s = 5'b00100; 
        5'h10: s = 5'b01000; 
        default: s = 5'b00000;
      endcase
    end else begin
      s = 5'b00000;
    end
  end


  always @(posedge clk) begin
    if (reset) begin
      A          <= 16'd0;
      init       <= 1'b0;
      init_pulse <= 1'b0;
    end else begin
      init_pulse <= 1'b0;
      if (cs && wr) begin
        if (s[0]) A <= d_in;       
        if (s[1] && d_in[0]) init_pulse <= 1'b1;  
      end
    end
  end


  always @(posedge clk) begin
    if (reset) begin
      d_out <= 16'd0;
    end else if (cs && rd) begin
      case (s)
        5'b00100: d_out <= C; 
        5'b01000: d_out <= {15'd0, done};    
        default:  d_out <= 16'd0;
      endcase
    end
  end

 
  double double1 (
    .clk(clk),
    .rst(reset),
    .init(init_pulse),
    .A(A),
    .C(C),
    .done(done)
  );

endmodule
