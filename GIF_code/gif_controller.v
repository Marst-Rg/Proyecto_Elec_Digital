module gif_controller #(
    parameter TOTAL_FRAMES = 4,
    parameter FRAME_SPEED = 12500000  // Ciclos @ 25MHz = 0.5 segundos
)(
    input wire clk,           
    input wire rst,           
    input wire enable,        
    output reg [1:0] frame_actual,   
    output reg frame_changed        
);

  
    reg [31:0] frame_counter;
    reg [1:0] next_frame;
    
  
    always @(posedge clk) begin
        if (rst) begin
           
            frame_counter <= 32'd0;
            frame_actual <= 2'd0;      
            frame_changed <= 1'b0;
            next_frame <= 2'd1;        
        end
        else if (enable) begin
          
            
        
            frame_changed <= 1'b0;
            
           
            if (frame_counter >= FRAME_SPEED - 1) begin
               
                frame_counter <= 32'd0;          
                frame_actual <= next_frame;       
                frame_changed <= 1'b1;           
                
               
                if (next_frame >= TOTAL_FRAMES - 1)
                    next_frame <= 2'd0;           // Volver a frame 0
                else
                    next_frame <= next_frame + 1'b1;
            end
            else begin
              
                frame_counter <= frame_counter + 1'b1;
            end
        end
        else begin
      
            frame_counter <= 32'd0;
            frame_actual <= 2'd0;
            frame_changed <= 1'b0;
            next_frame <= 2'd1;
        end
    end

 
    `ifdef SIMULATION
    initial begin
        $display("=== GIF Controller Inicializado ===");
        $display("TOTAL_FRAMES = %0d", TOTAL_FRAMES);
        $display("FRAME_SPEED  = %0d ciclos", FRAME_SPEED);
        $display("Duración por frame @ 25MHz = %0d ms", FRAME_SPEED / 25000);
    end
    
    always @(posedge frame_changed) begin
        $display("[%0t] Frame cambió a: %0d", $time, frame_actual);
    end
    `endif

endmodule