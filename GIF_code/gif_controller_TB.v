`timescale 1ns/1ps

module gif_controller_TB;

reg clk;
reg rst;
reg enable;

wire [1:0] frame_actual;
wire frame_changed;

localparam SIM_SPEED = 20;  

gif_controller #(
    .TOTAL_FRAMES(4),
    .VELOCIDAD(SIM_SPEED)
) dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .frame_actual(frame_actual),
    .frame_changed(frame_changed)
);

initial clk = 0;
always #20 clk = ~clk;   

initial begin
    $dumpfile("gif_controller_TB.vcd");
    $dumpvars(0, gif_controller_TB);

    rst = 1;
    enable = 0;
    #200;

    rst = 0;
    enable = 1;

    $display("=== Inicio de Testbench GIF Controller ===");

    
    repeat (20) begin
        @(posedge frame_changed);
        $display("t=%0t  Frame = %0d", $time, frame_actual);
    end

    $finish;
end

endmodule
