module adc_system_top(
    input wire       clk,
    input wire       reset,
    input wire       init_signal,
    input wire      eoc_in,
    input wire     address_in,
    output wire      done_pulse,
    output wire [7:0] data_out,
    output            clk_adc

);
  
    wire s_start_tx;
    wire s_wait_tx;
    wire s_eoc_signal;


    clock_generator CLK_GEN_inst (
        .clk(clk),
        .reset(reset),
        .init(init_signal),      
        .eoc_signal(s_eoc_signal),       
        .wait_tx(s_wait_tx),
        .clk_adc(clk_adc),       
        .start_tx(s_start_tx)  
    );


    
    wait_signal WAIT_SIG_inst (
        .clk_sys(clk),
        .reset(reset),
        .wait_tx(s_wait_tx),
        .start_tx(s_start_tx)
    );

    
    adc adc_inst (
        .clk(clk),
        .reset(reset),
        .start_tx(s_start_tx),
        .done_pulse(done_pulse),
        .data_out(data_out),
        .eoc_signal(s_eoc_signal),
        .eoc(eoc_in)
    );

endmodule
