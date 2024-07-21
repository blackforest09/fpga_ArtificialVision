module vsync (
    input  i_clk,
    output reg o_vde,
    output reg [9:0] o_y
);

localparam vactive      = 480;
localparam vback_porch  = 20;
localparam vsync_len    = 10;
localparam vfront_porch = 20;

localparam maxcount  = vactive + vfront_porch + vsync_len + vback_porch;
localparam syncstart = vactive + vfront_porch;
localparam syncend   = syncstart + vsync_len;

reg [9:0] counter = 0;

always @(posedge i_clk) begin
    if (counter == maxcount - 1)
        counter <= 0;
    else
        counter <= counter + 1'b1;

    o_y     <= counter[9:0];
    o_vde   <= (counter < vactive);
end

endmodule