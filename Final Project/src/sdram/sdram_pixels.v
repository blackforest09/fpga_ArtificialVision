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
  input wire [9:0] write_row,
  input wire [9:0] write_col,

  input wire read_enable,        // enable signal from lcd_pixels
  input wire [9:0] read_row,     // pos_y of the lcd
  input wire [9:0] read_col,     // pos_x of the lcd

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
  
  reg [20:0] sdram_address;
  reg sdram_read;
  reg sdram_write;
  reg [31:0] sdram_din;
  reg [31:0] sdram_dout;
  reg sdram_busy;
  reg sdram_fail;

  // sdram refresh signal
  wire sdram_refresh;  
  clk_generator #(.INPUT_FREQ(27000), .OUTPUT_FREQ(67)) sdram_refersh_gen (
    .i_clk(quartz_clk),
    .o_clk(sdram_refresh)
  );


  always_ff @(posedge sdram_clk) begin
    sdram_din     <= {16'h0000, 8'h00, 2'b00, write_data};    // 32 bits
    read_data     <= sdram_dout;
    sdram_read    <= read_enable;
    sdram_write   <= write_enable;        // pixel_valid

    if (write_enable && !read_enable) begin
      sdram_address <= {1'b0, write_row,  write_col}; // 21 bits
    end
    else if (read_enable && !write_enable) begin
      sdram_address <= {1'b0, read_row, read_col};
    end
  end

  sdram_protocol #(.FREQ(108_000_000)) sdram_protocol_instance (
    //inputs
    .clk        (sdram_clk), 
    .clk_sdram  (sdram_clk_p), 
    .resetn     (reset_n),
    .addr       (sdram_address), 
    .rd         (sdram_read), 
    .wr         (sdram_write),
    .din        (sdram_din), 
    .refresh    (0), //sdram_refresh),

    //outputs
    .busy       (sdram_busy),
    .dout32     (sdram_dout), 
    .data_ready (read_ready),

    // MAGIC PORTS FOR SDRAM (internal)
    .SDRAM_DQ   (IO_sdram_dq),    .SDRAM_A    (O_sdram_addr),   .SDRAM_BA   (O_sdram_ba), 
    .SDRAM_nCS  (O_sdram_cs_n),   .SDRAM_nWE  (O_sdram_wen_n),  .SDRAM_nRAS (O_sdram_ras_n),
    .SDRAM_nCAS (O_sdram_cas_n),  .SDRAM_CLK  (O_sdram_clk),    .SDRAM_CKE  (O_sdram_cke),
    .SDRAM_DQM  (O_sdram_dqm)
  );

endmodule