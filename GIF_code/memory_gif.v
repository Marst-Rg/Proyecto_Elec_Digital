module memory_gif #(
    parameter SIZE_FRAME = 2047,     
    parameter WIDTH = 11,            
    parameter NUM_FRAMES = 4         
)(
    input wire clk,
    input wire [WIDTH-1:0] address,  
    input wire [1:0] frame_sel,      
    input wire rd,                   
    output reg [23:0] rdata          
);

    
    // Frame 0
    reg [11:0] FRAME0_MEM0 [0:SIZE_FRAME];  
    reg [11:0] FRAME0_MEM1 [0:SIZE_FRAME];
    
    // Frame 1
    reg [11:0] FRAME1_MEM0 [0:SIZE_FRAME];
    reg [11:0] FRAME1_MEM1 [0:SIZE_FRAME];
    
    // Frame 2
    reg [11:0] FRAME2_MEM0 [0:SIZE_FRAME];
    reg [11:0] FRAME2_MEM1 [0:SIZE_FRAME];
    
    // Frame 3
    reg [11:0] FRAME3_MEM0 [0:SIZE_FRAME];
    reg [11:0] FRAME3_MEM1 [0:SIZE_FRAME];

   
    initial begin
        // Frame 0
        $readmemh("frame0_image0.hex", FRAME0_MEM0);
        $readmemh("frame0_image1.hex", FRAME0_MEM1);
        
        // Frame 1
        $readmemh("frame1_image0.hex", FRAME1_MEM0);
        $readmemh("frame1_image1.hex", FRAME1_MEM1);
        
        // Frame 2
        $readmemh("frame2_image0.hex", FRAME2_MEM0);
        $readmemh("frame2_image1.hex", FRAME2_MEM1);
        
        // Frame 3
        $readmemh("frame3_image0.hex", FRAME3_MEM0);
        $readmemh("frame3_image1.hex", FRAME3_MEM1);
        
        // Inicializar salida en negro
        rdata = 24'h000000;
    end

   
    always @(posedge clk) begin
        if (rd) begin
            case (frame_sel)
                2'd0: rdata <= {FRAME0_MEM0[address], FRAME0_MEM1[address]};
                2'd1: rdata <= {FRAME1_MEM0[address], FRAME1_MEM1[address]};
                2'd2: rdata <= {FRAME2_MEM0[address], FRAME2_MEM1[address]};
                2'd3: rdata <= {FRAME3_MEM0[address], FRAME3_MEM1[address]};
                default: rdata <= 24'h000000; 
            endcase
        end
        else begin
            rdata <= 24'h000000;  
        end
    end

endmodule