/*
This module connects the pixel data with the indexs and writes at the sdram_pixels
Also, is used for read them.
*/

module sdram_pixels (
  input wire quartz_clk,
  input wire sdram_clk,
  input wire sdram_clk_p,
  input wire reset_n,

  input wire [7:0] write_data,
  input wire write_enable,

  input wire read_enable,        // enable signal from lcd_pixels
  input wire [20:0] read_address,
  input wire [20:0] write_address,

  output reg read_ready,
  output reg [31:0] read_data,
  
  // MAGIC PORTS FOR SDRAM (internal)
  output reg O_sdram_clk,
  output reg O_sdram_cke,
  output reg O_sdram_cs_n,
  output reg O_sdram_cas_n,
  output reg O_sdram_ras_n,
  output reg O_sdram_wen_n,
  inout wire [31:0] IO_sdram_dq,
  output reg [10:0] O_sdram_addr,
  output reg [1:0] O_sdram_ba,
  output reg [3:0] O_sdram_dqm
);
  
  reg [20:0] address;
  reg sdram_read;
  reg sdram_write;
  reg [31:0] sdram_data_in;
  reg [31:0] sdram_data_out;
  reg sdram_busy;
  reg sdram_fail;

  always_ff @(posedge sdram_clk) begin
    sdram_data_in <= write_data;
    read_data     <= sdram_data_out;
    sdram_read    <= read_enable;
    sdram_write   <= write_enable;        // pixel_valid
    //address       <= address_sdram;
    if (write_enable && !read_enable) begin
      address <= write_address;
    end
    else if (read_enable && !write_enable) begin
      address <= read_address;
    end
  end

  sdram_protocol #(.FREQ(108_000_000)) sdram_protocol_instance (
    //inputs
    .clk        (sdram_clk), 
    .clk_sdram  (sdram_clk_p), 
    .resetn     (reset_n),
    .addr       (address), 
    .rd         (sdram_read), 
    .wr         (sdram_write),
    .din        (sdram_data_in), 
    .refresh    (0),

    //outputs
    .busy       (sdram_busy),
    .dout32     (sdram_data_out), 
    .data_ready (read_ready),

    // MAGIC PORTS FOR SDRAM (internal)
    .SDRAM_DQ   (IO_sdram_dq),    .SDRAM_A    (O_sdram_addr),   .SDRAM_BA   (O_sdram_ba), 
    .SDRAM_nCS  (O_sdram_cs_n),   .SDRAM_nWE  (O_sdram_wen_n),  .SDRAM_nRAS (O_sdram_ras_n),
    .SDRAM_nCAS (O_sdram_cas_n),  .SDRAM_CLK  (O_sdram_clk),    .SDRAM_CKE  (O_sdram_cke),
    .SDRAM_DQM  (O_sdram_dqm)
  );

endmodule