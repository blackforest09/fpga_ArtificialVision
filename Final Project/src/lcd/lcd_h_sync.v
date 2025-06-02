module lcd_hsync (
  input  wire lcd_clk,
  output reg lcd_hsync,
  output reg hde,
  output reg [9:0] lcd_x
);

  localparam hactive      =800;
  localparam hback_porch  = 40;
  localparam hsync_len    = 10;
  localparam hfront_porch = 40;

  localparam maxcount  = hactive + hfront_porch + hsync_len + hback_porch;
  localparam syncstart = hactive + hfront_porch;
  localparam syncend   = syncstart + hsync_len;

  reg [9:0] counter = 0;

  always @(posedge lcd_clk) begin
    if (counter == maxcount - 1) begin
      counter <= 0;
    end else begin
      counter <= counter + 1'b1;
    end

    lcd_hsync <= ~(counter >= syncstart & counter < syncend);
    lcd_x     <= counter[9:0];
    hde       <= (counter < hactive);
  end
endmodule