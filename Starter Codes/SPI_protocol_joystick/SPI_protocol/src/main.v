module main ( 
  input wire clk_27MHz, 
  input wire reset_btn,
  input wire spi_MISO,

  output wire spi_CLK,
  output wire spi_MOSI,
  output wire mcp_CS
);

  joystick_controller joystk(
    .clk_27MHz(clk_27MHz),
    .reset_btn(reset_btn),
    .spi_MISO(spi_MISO),
    
    .spi_CLK(spi_CLK),
    .mcp_CS(mcp_CS),
    .spi_MOSI(spi_MOSI)
  );

endmodule