`timescale 1ns/1ps

module peripheral_double_TB;

  reg clk;
  reg reset;
  reg [15:0] d_in;
  reg cs;
  reg [4:0] addr;
  reg rd;
  reg wr;
  wire [15:0] d_out;

 
  peripheral_double dut (
    .clk(clk),
    .reset(reset),
    .d_in(d_in),
    .cs(cs),
    .addr(addr),
    .rd(rd),
    .wr(wr),
    .d_out(d_out)
  );

  
  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end


  initial begin
    $dumpfile("perip_double_TB.vcd");
    $dumpvars(0, peripheral_double_TB);


    reset = 1;
    cs = 0;
    rd = 0;
    wr = 0;
    d_in = 0;
    addr = 0;
    #20;
    reset = 0;

   
    @(posedge clk);
    cs = 1; wr = 1; addr = 5'h04; d_in = 16'd12;
    @(posedge clk);
    cs = 0; wr = 0;

;
    cs = 1; wr = 1; addr = 5'h08; d_in = 16'd1;
    @(posedge clk);
    cs = 0; wr = 0;

 
    repeat(50) @(negedge clk);

    
    @(negedge clk);
    cs = 1; rd = 1; addr = 5'h0C;
    


    @(negedge clk);
    cs = 1; rd = 1; addr = 5'h10;
    @(negedge clk);
    $display("Done = %b", d_out[0]);
    cs = 0; rd = 0;

    #50;
    $finish;
  end

endmodule
