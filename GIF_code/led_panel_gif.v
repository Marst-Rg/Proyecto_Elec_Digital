module led_panel_gif(
    input wire clk,
    input wire rst,
    input wire init,
    output wire LP_CLK,
    output wire LATCH,
    output wire NOE,
    output wire [4:0] ROW,
    output wire [2:0] RGB0,
    output wire [2:0] RGB1
);

    // Parámetros de la matriz
    parameter NUM_COLS = 64;
    parameter NUM_ROWS = 32;  // CORREGIDO: Solo 32 filas físicas (scan 1:32)
    parameter NUM_PIXELS_PER_HALF = NUM_COLS * NUM_ROWS;  // 2048 por mitad
    parameter BIT_DEPTH = 4;
    parameter DELAY = 20;
    
    // Parámetros del GIF
    parameter TOTAL_FRAMES = 4;
    parameter FRAME_SPEED = 12500000;  // 500ms por frame @ 25MHz
    
    // Señales del controlador
    wire w_ZR, w_ZC, w_ZD, w_ZI;
    wire w_LD, w_SHD;
    wire w_RST_R, w_RST_C, w_RST_D, w_RST_I;
    wire w_INC_R, w_INC_C, w_INC_D, w_INC_I;
    wire [10:0] count_delay;
    wire [10:0] delay;
    wire [1:0] index;
    wire [5:0] COL;
    wire [23:0] mem_data;
    wire tmp_noe, tmp_latch;
    wire PX_CLK_EN;
    
    // Señales del GIF
    wire [1:0] frame_actual;
    wire frame_changed;
    reg [1:0] frame_actual_sync;
    
    /
    wire [4:0] row_addr;      // 5 bits para 32 filas (0-31)
    wire [5:0] col_addr;      // 6 bits para 64 columnas (0-63)
    wire [10:0] pixel_addr;   
    
    reg clk1;
    reg [4:0] clk_counter;
    
   
    assign pixel_addr = {row_addr, col_addr};  
    assign ROW = row_addr;  /
    
   
    assign LATCH = ~tmp_latch;
    assign NOE = tmp_noe;
    assign LP_CLK = clk1 & PX_CLK_EN;
    
   
    always @(posedge clk) begin
        if (!rst) begin
            clk_counter <= 0;
            clk1 <= 0;
        end 
        else begin
            if (clk_counter == 2) begin
                clk1 <= ~clk1;
                clk_counter <= 0;
            end
            else
                clk_counter <= clk_counter + 1;
        end
    end
    
    
    always @(posedge clk1) begin
        if (!rst)
            frame_actual_sync <= 2'd0;
        else
            frame_actual_sync <= frame_actual;
    end
    
    // Controlador de GIF
    gif_controller #(
        .TOTAL_FRAMES(TOTAL_FRAMES),
        .FRAME_SPEED(FRAME_SPEED)
    ) gif_ctrl (
        .clk(clk),
        .rst(~rst),         
        .enable(1'b1),      
        .frame_actual(frame_actual),
        .frame_changed(frame_changed)
    );
    

    count #(
        .width(4)  // 5 bits de salida (0-31)
    ) count_row (
        .clk(clk1),
        .reset(w_RST_R),
        .inc(w_INC_R),
        .outc(row_addr),
        .zero(w_ZR)
    );
 
    count #(
        .width(5)  // 6 bits de salida (0-63)
    ) count_col (
        .clk(clk1),
        .reset(w_RST_C),
        .inc(w_INC_C),
        .outc(col_addr),
        .zero(w_ZC)
    );
    
    // Contador de delay
    count #(
        .width(10)
    ) cnt_delay (
        .clk(clk1),
        .reset(w_RST_D),
        .inc(w_INC_D),
        .outc(count_delay)
    );
    
    // Contador de índice
    count #(
        .width(1)
    ) count_index (
        .clk(clk1),
        .reset(w_RST_I),
        .inc(w_INC_I),
        .outc(index),
        .zero(w_ZI)
    );
    
    // Load-Shift Register para delays
    lsr_led #(
        .init_value(DELAY),
        .width(10)
    ) lsr_led0 (
        .clk(clk1),
        .load(w_LD),
        .shift(w_SHD),
        .s_A(delay)
    );
    
    // Comparador
    comp_4k #(
        .width(10)
    ) compa (
        .in1(delay),
        .in2(count_delay),
        .out(w_ZD)
    );
    
    // Memoria con múltiples frames
    memory_gif #(
        .SIZE_FRAME(2047),
        .WIDTH(11),
        .NUM_FRAMES(4)
    ) mem_inst (
        .clk(clk),
        .address(pixel_addr),  // CORREGIDO: Usar dirección calculada
        .frame_sel(frame_actual_sync),
        .rd(1'b1),
        .rdata(mem_data)
    );
    
    // Multiplexor
    mux_led mux0 (
        .in0(mem_data),
        .out0({RGB0, RGB1}),
        .sel(index)
    );
    
    // Controlador de la matriz LE
    ctrl_lp4k ctrl0 (
        .clk(clk1),
        .rst(!rst),
        .init(1'b1),
        .ZR(w_ZR),
        .ZC(w_ZC),
        .ZD(w_ZD),
        .ZI(w_ZI),
        .RST_R(w_RST_R),
        .RST_C(w_RST_C),
        .RST_D(w_RST_D),
        .RST_I(w_RST_I),
        .INC_R(w_INC_R),
        .INC_C(w_INC_C),
        .INC_D(w_INC_D),
        .INC_I(w_INC_I),
        .LD(w_LD),
        .SHD(w_SHD),
        .LATCH(tmp_latch),
        .NOE(tmp_noe),
        .PX_CLK_EN(PX_CLK_EN)
    );

endmodule