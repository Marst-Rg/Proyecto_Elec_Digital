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
    parameter NUM_ROWS = 64;
    parameter NUM_PIXELS = NUM_COLS * NUM_ROWS;
    parameter HALF_SCREEN = NUM_PIXELS / 2;
    parameter BIT_DEPTH = 4;
    parameter DELAY = 20;
    
    // Parámetros del GIF
    parameter TOTAL_FRAMES = 4;
    parameter FRAME_SPEED = 12500000;  // 0.5 segundos por frame @ 25MHz
    
    // Señales del controlador original
    wire w_ZR, w_ZC, w_ZD, w_ZI;
    wire w_LD, w_SHD;
    wire w_RST_R, w_RST_C, w_RST_D, w_RST_I;
    wire w_INC_R, w_INC_C, w_INC_D, w_INC_I;
    wire [10:0] count_delay;
    wire [10:0] delay;
    wire [1:0] index;
    wire [5:0] COL;  // 6 bits para columnas (0-63)
    wire [10:0] PIX_ADDR;  // 11 bits para 2048 direcciones
    wire [23:0] mem_data;
    wire tmp_noe, tmp_latch;
    wire PX_CLK_EN;
    
    // Señales del GIF
    wire [1:0] frame_actual;
    wire frame_changed;
    
    // Wire interno para el contador de filas completo
    wire [10:0] count_row_full;
    
    reg clk1;
    reg [4:0] clk_counter;
    
    // Asignaciones
    assign LATCH = ~tmp_latch;
    assign NOE = tmp_noe;
    assign PIX_ADDR = count_row_full;  // Usar el contador completo directamente
    assign LP_CLK = clk1 & PX_CLK_EN;
    
    // Divisor de reloj
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
    
    // Instanciación del controlador de GIF
    gif_controller #(
        .TOTAL_FRAMES(TOTAL_FRAMES),
        .FRAME_SPEED(FRAME_SPEED)
    ) gif_ctrl (
        .clk(clk),
        .rst(!rst),
        .enable(init),
        .frame_actual(frame_actual),
        .frame_changed(frame_changed)
    );
    
    // Contadores
    // count_row genera la dirección completa de 11 bits
    count #(
        .width(10)  // 11 bits de salida (0-2047)
    ) count_row (
        .clk(clk1),
        .reset(w_RST_R),
        .inc(w_INC_R),
        .outc(count_row_full),
        .zero(w_ZR)
    );
    
    // Tomar solo los bits necesarios para ROW (bits superiores)
    assign ROW = count_row_full[10:6];  // 5 bits para las filas (0-31)
    
    count #(
        .width($clog2(NUM_COLS) - 1)
    ) count_col (
        .clk(clk1),
        .reset(w_RST_C),
        .inc(w_INC_C),
        .outc(COL),
        .zero(w_ZC)
    );
    
    count #(
        .width(10)
    ) cnt_delay (
        .clk(clk1),
        .reset(w_RST_D),
        .inc(w_INC_D),
        .outc(count_delay)
    );
    
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
    
    // CORREGIDO: Instanciación correcta de memoria con múltiples frames
    memory_gif #(
        .SIZE_FRAME(2047),
        .WIDTH(11),
        .NUM_FRAMES(4)
    ) mem_inst (
        .clk(clk),
        .address(PIX_ADDR),
        .frame_sel(frame_actual),  // Usar frame_actual del controlador GIF
        .rd(1'b1),                 // Siempre leyendo
        .rdata(mem_data)
    );
    
    // Multiplexor
    mux_led mux0 (
        .in0(mem_data),
        .out0({RGB0, RGB1}),
        .sel(index)
    );
    
    // Controlador de la matriz LED
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