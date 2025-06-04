/*
Ask to sdram_pixels the right pixel
*/
module lcd_pixels(
  input wire        lcd_clk,        // clock for lcd
  input wire        quartz_clk,
  input wire        reset_n,
  input wire        start_display,  // 
  input wire        read_ready,     // pixel is ready
  input wire [31:0] pixel_sdram,    // pixel read from sdram
  input wire [9:0]  lcd_x,          // column lcd position
  input wire [9:0]  lcd_y,          // row lcd position
  input wire        frame_done,

  output wire       read_enable,    // signal for enabling the pixel reading
  output wire [20:0]address,
  output wire [4:0] red,
  output wire [5:0] green,
  output wire [4:0] blue,
  output wire       displaying,
  output wire       display_done
);

  // INTERNAL REGISTERS
  reg [1:0] state_q, state_d;
  reg display_done_q, display_done_d;
  reg displaying_q, displaying_d;
  reg read_enable_q, read_enable_d;
  //reg [15:0] pixel_read_q, pixel_read_d;
  reg lcd_clk_sync, lcd_clk_prev;
  reg frame_done_sync, frame_done_prev;

  wire [15:0] pixel_read;



  // OUPTUTS ASSIGNATIONS
  assign red    = pixel_sdram[5:1]; 
  assign green  = {pixel_sdram[5:0]};
  assign blue   = pixel_sdram[5:1];

  assign read_enable  = (state_q == !idle) ? lcd_clk : 0;
  assign address      = {1'b0, lcd_y, lcd_x};
  assign displaying   = displaying_q;
  assign display_done = display_done_q;

  localparam  idle    = 0,
              ask     = 1,
              receive = 2;
              

  // SEQUENTIAL LOGIC
  always_ff @(posedge quartz_clk, negedge reset_n) begin
    if (!reset_n) begin 
      state_q           <= idle;
      display_done_q    <= 1'b0;
      displaying_q      <= 1'b0;
      read_enable_q     <= 1'b0;
      //pixel_read_q      <= 16'd0;
      lcd_clk_sync      <= 1'b0;
      lcd_clk_prev      <= 1'b0;
      frame_done_sync <= 1'b0;
      frame_done_prev <= 1'b0;
    end
    else begin
      // update edge registers
      lcd_clk_sync      <= lcd_clk;
      lcd_clk_prev      <= lcd_clk_sync;
      frame_done_sync <= frame_done;
      frame_done_prev <= frame_done_sync;
      
      state_q           <= state_d; 
      display_done_q    <= display_done_d;
      displaying_q      <= displaying_d;
      read_enable_q     <= read_enable_d;
      //pixel_read_q      <= pixel_read_d;
    end
  end



  // COMBINATIONAL LOGIC
  always @* begin
    state_d         = state_q;
    displaying_d    = displaying_q;
    display_done_d  = 1'b0;
    read_enable_d   = 1'b0;
    //pixel_read_d = pixel_read_q;

    if (!frame_done_sync && frame_done_prev) begin // negedge frame_finish
      //displaying_d    = 0; // this cause error
      display_done_d  = 1;
      state_d         = idle;
    end

    case(state_q) 
      
      idle: begin
        displaying_d = 0;
        display_done_d = 0;
        if (start_display) begin
          displaying_d = 1;
          state_d = ask;
        end
      end

      ask: begin
        state_d = receive;
      end    

      receive: begin
        //pixel_read_d = pixel_sdram[15:0];
        state_d = ask;
      end
    default: state_d = idle;
    endcase
  end 
endmodule