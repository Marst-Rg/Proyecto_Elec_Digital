module peripheral_adc_system_top(clk , reset , d_in,init_signal ,eoc, cs ,data_out, channel, data_gen, addr , rd , wr, d_out, data_adc, clk_adc,leds_out);
  
  input clk;
  input reset;
  input [7:0] d_in;
  input init_signal;
  input cs;
  input eoc;
  input [5:0]  addr;
  input data_gen;
  input rd;
  input data_out;
  input wr;
  output reg [7:0]d_out;
  output clk_adc;
  output reg channel;
  output reg [2:0] leds_out;
  input [7:0] data_adc;//---mult_32 input registers


//------------------------------------ regs and wires-------------------------------
reg [5:0] s; 	//selector mux_4  and write registers

reg init;
wire done;


//------------------------------------ regs and wires-------------------------------
always @(*) begin//------address_decoder------------------------------
if (cs) begin
  case (addr)
    6'h04: s =  6'b000001; // data_adc_in
    6'h08: s =  6'b000010; // channel
    6'h0C: s =  6'b000100; // init
    6'h10: s =  6'b001000; // data_adc_in
    6'h14: s =  6'b010000; // leds_out
    6'h18: s =  6'b100000; // done
    default: s = 6'b000000;
  endcase
end
else 
  s = 6'b000000;
end//------------------address_decoder--------------------------------




always @(posedge clk) begin//-------------------- escritura de registros 

  if(reset) begin
    init     <= 1'b0;
    channel  <= 2'b0;
    leds_out <= 3'b0;
  end
  else begin
    if (cs && wr) begin
		   channel    = s[1] ? d_in [1:0]     : channel;	//Write Registers
		   init = s[2] ? d_in[0] : init;
       leds_out = s[4] ? d_in [2:0] : leds_out;
       
    end
  end

end//------------------------------------------- escritura de registros


//-----------------------mux_4 :  multiplexa salidas del periferico
always @(posedge clk) begin
    if (reset) begin
        d_out <= 8'h00;
    end else if (cs && rd) begin
        case (s)
            6'b000001: d_out <= data_adc;//---mult_32 input registers
            // Pone el bit 'done' en el LSB del bus de salida.
            6'b100000: d_out <= {7'b0, done};
            default:  d_out <= 8'h00; 
        endcase
    end
end//-----------------------------------------------mux_4




adc_system_top adc_top(
  .clk(clk),
  .reset(reset),
  .init_signal(init),
  .eoc_in(eoc),
  .address_in(channel),
  .done_pulse(done),
  .data_out (data_adc),
  .clk_adc(clk_adc)
);


endmodule

