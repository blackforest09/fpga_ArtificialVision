/*  OBJECTIVES
  - Synchronize signals with double buffers
  - Catch RGB 565 pixels in two steps (two bytes)
  - Convert the 16 bits pixel to 6 bits grey value
  - Form a 32 bits pixel 
  - Form a 21 bits address (with position of the pixel)
  - Signal when the all frame is captured
*/

module pixel_capture_ov7670(
  input wire quartz_clk,
  input wire reset_n,
  input wire [7:0] ov_data,
  input wire ov_vsync,
  input wire ov_href,
  input wire ov_pclk,
  input wire start_capture,

  output wire ov_rst,
  output wire ov_pwdn,
  output wire [31:0] pixel, // gray pixel 6
  output wire pixel_valid, //signal for sdram write
  output wire [20:0] address,
  output wire capture_done
);

  // INTERNAL REGISTERS 
  reg [3:0]   state_q = 0,    state_d;
  reg [15:0]  pixel_rgb_q,    pixel_rgb_d;
  reg [9:0]   row_counter_q,  row_counter_d;
  reg [9:0]   col_counter_q,  col_counter_d;
  reg         pixel_valid_q,  pixel_valid_d;
  reg         capture_done_q, capture_done_d;


  // OUTPUTS ASSIGNATIONS
  assign pixel        = {24'h000000, 2'b00, gray6_value};
  assign address      = {1'b0, row_counter_q, col_counter_q};
  assign pixel_valid  = pixel_valid_q;
  assign capture_done = capture_done_q;  
  assign ov_pwdn      = 1'b0;
  assign ov_rst       = 1'b1;

  // buffer for inputs coming from the camera (for perfect sync)
  reg pclk, pclk_prev, vsync, vsync_prev, href, href_prev;

  //FSM states
  localparam  idle        = 0,
              vsync_nedge = 1,
              href_pedge  = 2,
              byte1       = 3,
              byte2       = 4,
              stopping    = 5;


  // RGB to GRAY conversion
  wire [5:0] pxl_R6 = {pixel_rgb_q[15:11], 1'b0};
  wire [5:0] pxl_G6 = pixel_rgb_q[10:6];
  wire [5:0] pxl_B6 = {pixel_rgb_q[4:0], 1'b0};
  
  wire [12:0] gray_calc = (19 * pxl_R6) + (38 * pxl_G6) + (7 * pxl_B6);
  wire [5:0]  gray6_value = gray_calc >> 6;

  // ------------ SECUENTIAL LOGIC, REGISTER OPERATIONS -----------
  always_ff @(posedge quartz_clk, negedge reset_n) begin
    if (!reset_n) begin
      state_q         <= idle;
      pixel_rgb_q     <= 0;
      row_counter_q   <= 0;
      col_counter_q   <= 0;
      pixel_valid_q   <= 0;
      capture_done_q  <= 0;
    end
    else begin
      // buffers for sync corretly the ov_signals
      pclk            <= ov_pclk;
      pclk_prev       <= pclk;
      vsync           <= ov_vsync; 
      vsync_prev      <= vsync;
      href            <= ov_href;
      href_prev       <= href;
      state_q         <= state_d;
      pixel_rgb_q     <= pixel_rgb_d;
      row_counter_q   <= row_counter_d;
      col_counter_q   <= col_counter_d;
      pixel_valid_q   <= pixel_valid_d;
      capture_done_q  <= capture_done_d;
    end
  end
  // **************************************************************





  // ------------ FSM NEXT-STATE COMBINATIONAL LOGICS -------------
  always @* begin
    state_d         = state_q;
    row_counter_d   = row_counter_q;
    col_counter_d   = col_counter_q;
    pixel_valid_d   = 1'b0;
    capture_done_d  = 1'b0;
    pixel_rgb_d     = pixel_rgb_q;
    

    case(state_q) // state of secuential logic

      //waits until the start signal
      idle: begin 
        if (start_capture) begin
          state_d = vsync_nedge;
        end
      end

  
      vsync_nedge: begin
        // detect vsync negative edge, new frame
        if (vsync == 0 && vsync_prev == 1) begin
          col_counter_d = 0;
          row_counter_d = 10'b1111111111;
          state_d = href_pedge;
        end
      end

      // waits the start of a new line
      href_pedge: begin
        col_counter_d = 0;
        // if detect a new line pulse
        if (href == 1 && href_prev == 0) begin
          row_counter_d = row_counter_q + 1'b1;
          state_d = byte1;
        end 
        else if (vsync && !vsync_prev) begin // a new frame detected, stop
          capture_done_d = 1'b1;
          row_counter_d = 0;
          col_counter_d = 0;
          state_d = stopping;
        end
      end

      byte1: begin
        // if the line transmision ends
        if (href == 0 && href_prev == 1) begin
          state_d = href_pedge;
        end
        // if pclk positive edge while line transmission is high
        else if (pclk == 1 && pclk_prev == 0 && href == 1) begin
          pixel_rgb_d[15:8] = ov_data;
          state_d = byte2;
        end
      end

      byte2: begin
        // if the line transmision ends
        if (href == 0 && href_prev == 1) begin
          state_d = href_pedge;
        end
        // if pclk positive edge while line transmission is high
        else if (pclk == 1 && pclk_prev == 0 && href == 1) begin
          pixel_rgb_d[7:0] = ov_data;
          pixel_valid_d = 1'b1;
          col_counter_d = col_counter_q + 1'b1;
          state_d = byte1;
        end
      end

    stopping: begin
        capture_done_d = 1'b1;
        if (start_capture == 0) begin
            state_d = idle;
        end
    end

    default: state_d = idle;
    endcase
  end
  // **************************************************************
endmodule