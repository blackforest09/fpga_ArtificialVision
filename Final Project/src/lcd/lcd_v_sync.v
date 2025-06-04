module lcd_vsync (
  input  wire lcd_hsync,
  output reg vde,
  output reg [9:0] lcd_y,
  output wire frame_done
);

  assign frame_done = frame_done_q;
  reg frame_done_q;

  localparam vactive      = 480;
  localparam vback_porch  = 20;
  localparam vsync_len    = 10;
  localparam vfront_porch = 20;

  localparam maxcount  = vactive + vfront_porch + vsync_len + vback_porch;
  localparam syncstart = vactive + vfront_porch;
  localparam syncend   = syncstart + vsync_len;

  reg [9:0] counter = 0;

  always @(posedge lcd_hsync) begin
    if (counter == maxcount - 1) begin
      frame_done_q  <= 1;
      counter       <= 0;
    end else begin
      counter       <= counter + 1'b1;
      frame_done_q  <= 0;
    end
    lcd_y <= counter[9:0];
    vde   <= (counter < vactive);
  end
endmodule