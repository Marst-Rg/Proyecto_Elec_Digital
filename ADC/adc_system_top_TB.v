`timescale 1ns/1ps

module adc_system_top_TB;

    
    parameter CLK_PERIOD = 40;  

  
    reg clk;
    reg reset;
    reg init_signal;
    reg eoc;
    reg [11:0] analog_in;
    reg address_in;
    
    wire done_pulse;
    wire [7:0] data_out;
    wire clk_adc;
    wire ale;
    wire oe;
    wire address_out;

 
    adc_system_top DUT (
        .clk(clk),
        .reset(reset),
        .init_signal(init_signal),
        .eoc_in(eoc),
        .analog_in(analog_in),
        .address_in(address_in),
        .done_pulse(done_pulse),
        .data_out(data_out),
        .clk_adc(clk_adc),
        .ale(ale),
        .oe(oe),
        .address_out(address_out)
    );


    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    initial eoc = 0;

    always @(posedge ale) begin
     
        #2000;
        eoc = 1'b1;
       
        #(CLK_PERIOD*4);
        eoc = 1'b0;
    end

    initial begin
        $dumpfile("adc_system_top_TB.vcd");
        $dumpvars(0, adc_system_top_TB);

 
        reset = 1;
        init_signal = 0;
        analog_in = 12'h000;
        address_in = 0;

        repeat(5) @(posedge clk);
        reset = 0; 
        repeat(5) @(posedge clk);

        $display("\n========================================");
        $display("   TEST ADC SYSTEM - CONVERSION");
        $display("========================================\n");

        // Test 1: 0V
        $display("Test 1: 0V (analog_in = 0x000)");
        realizar_conversion(1'b0, 12'h000);
        
        // Test 2: 1.25V
        $display("\nTest 2: 1.25V (analog_in = 0x400)");
        realizar_conversion(1'b0, 12'h400);
        
        // Test 3: 2.5V
        $display("\nTest 3: 2.5V (analog_in = 0x800)");
        realizar_conversion(1'b1, 12'h800);
        
        $display("\n========================================");
        $display("   TESTS COMPLETED");
        $display("========================================\n");

        repeat(20) @(posedge clk);
        $finish;
    end

  
    task realizar_conversion;
        input canal;
        input [11:0] voltaje_analog;
        integer expected_digital;
        begin
            address_in = canal;
            analog_in = voltaje_analog;
            expected_digital = voltaje_analog >> 4;
            
            @(posedge clk);
            init_signal = 1;
            @(posedge clk);
            init_signal = 0;

            fork : wait_block
                wait(done_pulse);
                begin
                    #10000; 
                    $display("ERROR: Timeout - El sistema no respondió 'done_pulse'");
                    disable wait_block;
                end
            join_any

            @(posedge clk);

          
            if (data_out == expected_digital)
                $display("  Status: PASS (Exp: %h, Got: %h)", expected_digital, data_out);
            else
                $display("  Status: FAIL (Exp: %h, Got: %h)", expected_digital, data_out);

            repeat(10) @(posedge clk);
        end
    endtask

endmodule