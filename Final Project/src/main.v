//`default_nettype none // need to explicity declare the variable type
`timescale 1ns / 1ps

module main (

  // OTHER SIGNALS
  input wire quartz_clk, // 27MHz internal clock
  input wire start_btn,  // S1
  input wire reset_btn,  // S2


  // CAMERA OV7670
  input wire ov_pclk, ov_vsync, ov_href,
  input wire [7:0] ov_data,
  inout wire ov_sda, ov_sclk,
  output wire ov_xclk,
  output wire ov_rst, ov_pwdn,


  // LCD 
  output wire [4:0] lcd_r,
  output wire [5:0] lcd_g,
  output wire [4:0] lcd_b,
  output wire lcd_clk,
  output wire lcd_den,


  // MAGIC PORTS FOR SDRAM (internal)
  output wire O_sdram_clk, 
  output wire O_sdram_cke,
  output wire O_sdram_cs_n,        // chip select
  output wire O_sdram_cas_n,       // columns address select
  output wire O_sdram_ras_n,       // row address select
  output wire O_sdram_wen_n,       // write enable
  inout  wire [31:0] IO_sdram_dq,  // 32 bit bidirectional data bus
  output wire [10:0] O_sdram_addr, // 11 bit multiplexed address bus
  output wire [1:0] O_sdram_ba,    // two banks
  output wire [3:0] O_sdram_dqm    // 32/4
);


// ----------------------- DENOISE SIGNALS -----------------------
  wire ov_vsync2;
  denoise dn1 (
    .data_in (ov_vsync),
    .clock(sdram_clk),
    .data_out (ov_vsync2)
  );

  wire ov_href2;
  denoise dn2 (
    .data_in (ov_href),
    .clock(sdram_clk),
    .data_out (ov_href2)
  );

  wire ov_pclk2;
  denoise dn3 (
    .data_in (ov_pclk),
    .clock(sdram_clk),
    .data_out (ov_pclk2)
  );
// ****************************************************************





// ---------------------- CLOCKS GENERATION -----------------------
  
  /*
    quartz_clk --> 27 MHz tang internal clock  
    sdram_clk  --> 108 MHz for sdram and for all the modules govern
    ov_xclk    --> 13.5 MHz master clock for camera
    lcd_clk    --> 13.5 MHz for master the TFT LCD
  */
  
  // Generate the sdram_clk at 108MHz and provide 180º phased clock
  wire sdram_clk;
  wire sdram_clk_p;
  sdram_clk_pll sdram_clk_pll_instance(
    .clkout   (sdram_clk),    //output clkout 108MHz
    .clkoutp  (sdram_clk_p),  //output clkoutp 108MHz 180º phased
    .clkin    (quartz_clk)    //input clkin 
  );

  // Generate the half_quartz_clk
  reg half_quartz_clk;
  always_ff @(posedge quartz_clk) begin
    half_quartz_clk <= !half_quartz_clk;
  end

  // Assign the xclk 
  assign ov_xclk = half_quartz_clk;

  // Assign the lcd_clk 
  wire displaying;
  assign lcd_clk = displaying ? half_quartz_clk : 0;


// ****************************************************************





// --------------------------- BUTTONS ----------------------------
  wire reset_n;
  assign reset_n = ~reset_btn;
// ****************************************************************





// ------------------- OV7670 SCCB CONFIGURATION ------------------
  // configures the Serial Camera Control Bus with defined registers
  wire sccb_done;
  sccb_config sccb_config_instance(
    //inputs
    .sdram_clk    (sdram_clk),
    .quartz_clk   (quartz_clk),
    .start_config (1),
    .reset_n      (reset_n),

    //inouts
    .sda          (ov_sda),
    .sclk         (ov_sclk),

    //outputs
    .rst_n        (ov_rst),
    .pwdn         (ov_pwdn),
    .config_done  (sccb_done)
  );
// ****************************************************************





// --------------------- OV7670 PIXEL CAPUTRE ---------------------
  wire [7:0] pixel_ov7670; //gray
  wire [9:0]  row_counter_ov7670;
  wire [9:0]  col_counter_ov7670;
  wire        pixel_valid_ov7670;
  //assign      start_capture = sccb_done | display_done;
  assign start_capture = ( state_main == capture ) ? 1 : 0;
  wire capture_done;

  // reads the pixels that the camera process
  pixel_capture_ov7670 pixel_capture_ov7670_instance( 
    //inputs
    .sdram_clk      (sdram_clk),
    .quartz_clk     (quartz_clk),
    .reset_n        (reset_n),
    .ov_data        (ov_data),
    .ov_vsync       (ov_vsync2),
    .ov_href        (ov_href2),
    .ov_pclk        (ov_pclk),
    .start_capture  (start_capture),
    
    //outputs
    .ov_rst         (ov_rst),
    .ov_pwdn        (ov_pwdn),
    .pixel          (pixel_ov7670),
    .pixel_valid    (pixel_valid_ov7670),
    .row_counter    (row_counter_ov7670), 
    .col_counter    (col_counter_ov7670),
    .capture_done   (capture_done)
  );
// ****************************************************************





// -------------- SDRAM INSTANCE & PIXEL WRITE/READ ---------------
  wire read_ready;
  wire read_enable;
  wire [31:0] pixel_read;
  sdram_pixels sdram_pixels_instance (  // module for write and read pixels from sdram
    //inputs
    .quartz_clk     (quartz_clk),
    .sdram_clk      (sdram_clk),        //same as clk_108M
    .sdram_clk_p    (sdram_clk_p),
    .reset_n        (reset_n),

    .write_data     (pixel_ov7670),
    .write_enable   (pixel_valid_ov7670),
    .write_row      (row_counter_ov7670),
    .write_col      (col_counter_ov7670),  

    .read_enable    (read_enable), 
    .read_row       (lcd_y),
    .read_col       (lcd_x),

    //outputs
    .read_ready     (read_ready),
    .read_data      (pixel_read),

    // MAGIC PORTS FOR SDRAM (internal)
    .O_sdram_clk    (O_sdram_clk),
    .O_sdram_cke    (O_sdram_cke),
    .O_sdram_cs_n   (O_sdram_cs_n),
    .O_sdram_cas_n  (O_sdram_cas_n),
    .O_sdram_ras_n  (O_sdram_ras_n),
    .O_sdram_wen_n  (O_sdram_wen_n),
    .IO_sdram_dq    (IO_sdram_dq),
    .O_sdram_addr   (O_sdram_addr),
    .O_sdram_ba     (O_sdram_ba),
    .O_sdram_dqm    (O_sdram_dqm)    
  );
// ****************************************************************





// -------------------------- LCD Screen --------------------------
  wire [9:0] lcd_x;   // indicate the horizontal position 
  wire [9:0] lcd_y;   // indicate the vertical position

  // data enable signal
  wire hde;
  wire vde;
  assign lcd_den = hde & vde; // Enable when the two are enabled
  wire lcd_hsync;
  wire frame_finish;
  wire display_done;

  lcd_hsync lcd_hsync_instance(
    .lcd_clk    (lcd_clk),   // counter clock
    .lcd_hsync  (lcd_hsync), // signal for the vsync module
    .hde        (hde),       // horizontal signal in active zone
    .lcd_x      (lcd_x)      // x pixel position (columns)
  );

  lcd_vsync lcd_vsync_instance(
    .lcd_hsync    (lcd_hsync), // is the generated in the lcd_hsync
    .vde          (vde),       // vertical signal in active zone
    .lcd_y        (lcd_y),     // y pixel position (rows)
    .frame_finish (frame_finish)
  );



  lcd_pixels lcd_pixels_instance( // module for send pixels to lcd
    // inputs
    .lcd_clk        (lcd_clk),
    .quartz_clk     (quartz_clk),
    .reset_n        (reset_n),
    .start_display  (start_display),
    .read_ready     (read_ready),
    .pixel_sdram    (pixel_read),
        //.lcd_x          (lcd_x),
        //.lcd_y          (lcd_y),
    .frame_finish   (frame_finish),

    // outputs
    .read_enable    (read_enable),
    .red            (lcd_r),
    .green          (lcd_g),
    .blue           (lcd_b),
    .displaying     (displaying),
    .display_done   (display_done)
  );
// ****************************************************************





// ---------------------- Main state machine ----------------------
  localparam  init = 0,
              capture = 1,
              display = 2;

  reg [2:0] state_main = 0;
  reg [2:0] next_state;
  reg start_btn_prev;
  reg start_display;
  wire button_pressed;

  wire start_btn2;
  monostable mono (
      .pulse_in(start_btn),
      .clock(quartz_clk),
      .pulse_out(start_btn2)
  );

  assign button_pressed = ( start_btn2 == 1 && start_btn_prev == 0 ) ? 1 : 0;
  reg frame_finish_prev;

  always @ (posedge quartz_clk, negedge reset_n) begin
    if (!reset_n) begin
      state_main <= init;
      start_display <= 0;
    end
    else begin
      start_btn_prev <= start_btn2;
      frame_finish_prev <= frame_finish;
      
      case(state_main) 
        
        init: begin
          start_display <= 0;
          if (sccb_done == 1) begin
            state_main <= capture;
          end
        end

        capture: begin
          start_display <= 0;
          if (capture_done == 1) begin
            start_display <= 1;
            state_main <= display; 
          end
        end

        display: begin
          start_display <= 0;
          if (display_done) begin
            state_main <= capture;
          end
        end

      default: state_main = init;
      endcase
    end
  end
// *********************************************************

endmodule