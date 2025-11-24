`timescale 1ns / 1ps

module double_TB;

  
    reg         clk;
    reg         rst;
    reg         init;
    reg  [15:0] A;
    wire [15:0] C;
    wire        done;

 
    double dut (
        .clk(clk),
        .rst(rst),
        .init(init),
        .A(A),
        .C(C),
        .done(done)
    );

  
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
   
        $dumpfile("double_TB.vcd");
        $dumpvars(0, double_TB);

        rst  = 1;
        init = 0;
        A    = 16'd0;

      
        #20;
        rst = 0;

        A = 16'b1111; 
        #10 init = 1;
        #10 init = 0;

        wait(done);
        #10;
        $display("Tiempo=%0t | A=0x%h | C=0x%h | done=%b", $time, A, C, done);

   
        A = 16'b00100111; 
        #10 init = 1;
        #10 init = 0;

        wait(done);
        #10;
        $display("Tiempo=%0t | A=0x%h | C=0x%h | done=%b", $time, A, C, done);

    
        #50;
        $finish;
    end


    initial begin
        $monitor("T=%0t | clk=%b | rst=%b | init=%b | A=0x%h | C=0x%h | done=%b",
                  $time, clk, rst, init, A, C, done);
    end

endmodule

