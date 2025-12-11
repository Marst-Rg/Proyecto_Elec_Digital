module led_panel_4k(
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

    // Señales internas
    wire w_ZR, w_ZC, w_ZD, w_ZI;
    wire w_LD, w_SHD;
    wire w_RST_R, w_RST_C, w_RST_D, w_RST_I;
    wire w_INC_R, w_INC_C, w_INC_D, w_INC_I;
    wire [10:0] count_delay;
    wire [10:0] delay;
    wire [1:0] index;
    
    // Señales de reloj y contadores
    reg clk1;
    reg [4:0] clk_counter;

    // ======== Caracteristicas de la matriz ========
    parameter NUM_COLS = 64;
    parameter NUM_ROWS = 64;
    parameter NUM_PIXELS = NUM_COLS*NUM_ROWS;
    parameter HALF_SCREEN = NUM_PIXELS/2;
    parameter BIT_DEPTH = 4;
    parameter TOTAL_BIT_DEPTH = 3*BIT_DEPTH;
    parameter DELAY = 20;

    wire [($clog2(NUM_COLS)-1):0] COL;
    // ----------------------------------------------

    wire [11:0] PIX_ADDR;
    wire [23:0] mem_data;
    
    // Señales temporales
    wire tmp_noe;
    wire tmp_latch;
    wire PX_CLK_EN; // Asegúrate de que esta señal venga del ctrl_lp4k

    // Asignaciones de salida
    assign LATCH = ~tmp_latch;
    assign NOE = tmp_noe;
    assign PIX_ADDR = {ROW, COL};
    assign LP_CLK = clk1 & PX_CLK_EN;

    // Divisor de reloj
    always @(posedge clk) begin
        if (rst) begin
            clk_counter <= 0;
            clk1        <= 0;
        end else begin
            if(clk_counter == 2) begin
                clk1    <= ~clk1;
                clk_counter <= 0;
            end
            else
                clk_counter <= clk_counter + 1;
        end
    end

    // Instancias de los módulos
    count #(.width(( $clog2(HALF_SCREEN) -1) )) count_row (
        .clk(clk1), .reset(w_RST_R), .inc(w_INC_R), .outc(ROW), .zero(w_ZR)
    );

    count #(.width(($clog2(NUM_COLS) -1) )) count_col (
        .clk(clk1), .reset(w_RST_C), .inc(w_INC_C), .outc(COL), .zero(w_ZC)
    );

    count #(.width (10)) cnt_delay (
        .clk(clk1), .reset(w_RST_D), .inc(w_INC_D), .outc(count_delay)
    );

    count #(.width (1)) count_index (
        .clk(clk1), .reset(w_RST_I), .inc(w_INC_I), .outc(index), .zero(w_ZI)
    );

    lsr_led #(.init_value(DELAY), .width(10)) lsr_led0 (
        .clk(clk1), .load(w_LD), .shift(w_SHD), .s_A(delay)
    );

    comp_4k #(.width(10)) compa (
        .in1(delay), .in2(count_delay), .out(w_ZD)
    );

    // =========================================================
    // CORRECCIÓN AQUÍ:
    // Antes tenías "module memory..." aquí. Eso estaba mal.
    // Ahora instanciamos (conectamos) el módulo correctamente.
    // =========================================================
    memory #(
        .size(NUM_PIXELS/2 - 1),
        .width($clog2(NUM_PIXELS) - 2)
    ) mem0 (
        .clk(clk1),
        .address(PIX_ADDR),
        .rd(1'b1),
        .rdata(mem_data)
    );
    // =========================================================

    mux_led mux0 (
        .in0(mem_data), .out0({RGB0, RGB1}), .sel(index) 
    );

    ctrl_lp4k ctrl0 (
        .clk(clk1), 
        .rst(rst), 
        .init(1'b1), 
        .ZR(w_ZR), .ZC(w_ZC), .ZD(w_ZD), .ZI(w_ZI),
        .RST_R(w_RST_R), .RST_C(w_RST_C), .RST_D(w_RST_D), .RST_I(w_RST_I),
        .INC_R(w_INC_R), .INC_C(w_INC_C), .INC_D(w_INC_D), .INC_I(w_INC_I),
        .LD(w_LD), .SHD(w_SHD),
        .LATCH(tmp_latch), .NOE(tmp_noe), .PX_CLK_EN(PX_CLK_EN)
    );

endmodule




