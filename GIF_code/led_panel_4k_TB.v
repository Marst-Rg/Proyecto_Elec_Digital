`timescale 1ns / 1ps
`define SIMULATION

module led_panel_4k_TB;

   reg  clk;
   reg  rst;
   reg  init;
   wire LATCH;
   wire NOE;
   wire [4:0] ROW;
   wire [2:0] RGB0;
   wire [2:0] RGB1;

   // Instancia del DUT (Device Under Test)
   led_panel_4k uut (
        .clk(clk),
        .rst(rst),
        .init(init),
        .LATCH(LATCH),
        .NOE(NOE),
        .ROW(ROW),
        .RGB0(RGB0),
        .RGB1(RGB1)
   );

   //----------------- Clock -----------------
   parameter PERIOD = 20;

   initial begin
      clk = 0; 
      rst = 0; 
      init = 0;
   end

   always #(PERIOD/2) clk = ~clk;

   //----------------- Reset & Inicio -----------------
   initial begin
      @(posedge clk);
      rst = 1;
      @(posedge clk);
      rst = 0;
      #(PERIOD*4);
      init = 1;
   end

   //----------------- Simulación -----------------
   initial begin: TEST_CASE
      $dumpfile("led_panel_4k_TB.vcd");
      $dumpvars(-1, led_panel_4k_TB);        // registra señales del TB
      $dumpvars(0, led_panel_4k_TB.uut.mem0); // <<--- solución al error de idx

      // Tiempo de simulación antes de finalizar
      #(PERIOD*100000);
      $finish;
   end

endmodule
