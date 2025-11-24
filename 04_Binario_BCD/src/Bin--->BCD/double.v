module double(
    input  wire       clk,
    input  wire       rst,   
    input  wire       init,
    input  wire [15:0] A,
    output wire [15:0] C,
    output wire       done
);

wire w_sh;
wire w_ldr2;
wire w_Z;
wire w_dec;
wire w_ld;
wire [3:0]w_bm;



wire [15:0]  w_A_new;




A_reg A_reg0    (.clk(clk), .ld(w_ld), .sh(w_sh), .ldr2(w_ldr2), .X(A), .A_new(w_A_new), .resultado(C));
check checkm (.A(C[15:12]), .bm(w_bm[3]), .value(4'd5));
check checkc (.A(C[11:8]), .bm(w_bm[2]), .value(4'd5));
check checkd (.A(C[7:4]), .bm(w_bm[1]), .value(4'd5));
check checku (.A(C[3:0]), .bm(w_bm[0]), .value(4'd5));
sum   summ  (.A(C[15:12]), .bm(w_bm[3]),  .A_new(w_A_new[15:12])); 
sum   sumc  (.A(C[11:8]), .bm(w_bm[2]),  .A_new(w_A_new[11:8])); 
sum   sumd  (.A(C[7:4]), .bm(w_bm[1]),  .A_new(w_A_new[7:4]));  
sum   sumu  (.A(C[3:0]), .bm(w_bm[0]),  .A_new(w_A_new[3:0])); 
contador contador0  (.clk(clk), .ld(w_ld),  .dec(w_dec), .Z(w_Z));
control_double control0 (.clk(clk), .rst(rst), .dec(w_dec), .msb (w_bm), .init(init), .z(w_Z), .done(done), .sh(w_sh), .ld(w_ld), .ldr2(w_ldr2));



endmodule
