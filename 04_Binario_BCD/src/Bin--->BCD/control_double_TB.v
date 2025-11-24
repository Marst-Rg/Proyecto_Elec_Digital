`timescale 1ns/1ps

module control_double_TB;

    reg clk;
    reg rst;
    reg init;
    reg [3:0] msb;
    reg z;

    
    wire ld;
    wire sh;
    wire ldr2;
    wire done;
    wire dec;
    wire [7:0] state_ascii;

    control_double uut (
        .clk(clk),
        .rst(rst),
        .init(init),
        .msb(msb),
        .z(z),
        .ld(ld),
        .sh(sh),
        .ldr2(ldr2),
        .done(done),
        .dec(dec),
        .state_ascii(state_ascii)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("control_double_TB.vcd");
        $dumpvars(0, control_double_TB);

        rst  = 1;
        init = 0;
        msb  = 4'b0000;
        z    = 1;

        #20;
        rst = 0;

        #10 init = 1;
        #10 init = 0;

        #20 msb = 4'b0000; z = 1; 

        
        #40 msb = 4'b1000; z = 1; 

      
        #40 msb = 4'b0000; z = 0;  

   
        #40 init = 1;
        #10 init = 0;
        #20 msb = 4'b0100; z = 1; 
        #40 msb = 4'b0000; z = 0;

      
        #50;
        $display("Fin de simulación a %0dns", $time);
        $finish;
    end

    
    initial begin
        $display("Tiempo | rst init msb z | ld sh ldr2 dec done | state_ascii (ASCII)");
        $display("-------------------------------------------------------------------");
        $monitor("%4dns | %b   %b   %b   %b |  %b  %b   %b    %b    %b   |  %s",
                 $time, rst, init, msb[3], z, ld, sh, ldr2, dec, done, state_ascii);
    end

endmodule
