/*
This module is the governor of the submodule mcp300x.
The main objective is:
    - Set a defined channel of change it
    - Start the protocol of the submodule
    - When the data is ready, store it at the right register
Is configured for ask two analog channels, taking 76 cycles to have stored that two analog values.
*/

module joystick_controller (
  input wire clk_27MHz,
  input wire reset_btn,
  input wire spi_MISO,

  output wire spi_CLK,
  output wire mcp_CS,
  output wire spi_MOSI
);

  // Use a PLL for obtain the desired frequency.
  // NOTE: That freq. must be double of the SERIAL_CLOCK for the mcp chip
  wire clk_4MHz;

  Gowin_rPLL pll_clock(
    .clkoutd(clk_4MHz), //output clk out divided
    .clkin(clk_27MHz)   //input clk in
  );


  //CONTROL SIGNALS / REGISTERS FOR mcp300x submodule
  reg r_start_mcp = 0;
  reg [2:0] r_channel = 3'b000;
  wire [9:0] analog_value;
  wire data_ready;

  mcp300x mcp(
    .clk_doubleSCLK(clk_4MHz),
    .reset(reset_btn),
    .MISO(spi_MISO),
    .channel(r_channel),
    .start_protocol(r_start_mcp),
    .MOSI(spi_MOSI),
    .CS(mcp_CS),
    .analog_value(analog_value),
    .data_ready(data_ready),  
    .SCLK(spi_CLK)
  );



  //STATES AND PARAMETERS
  localparam STATE_WAIT = 1'b0;
  localparam STATE_READ = 1'b1;
  localparam MAX_CHANNEL = 3'b001;
  reg [9:0] analog_x;
  reg [9:0] analog_y;
  reg state;


  // TIMER 60Hz TRIGGER
  reg [16:0] timer_counter = 0;
  wire timer_done = (timer_counter == 66666);

  always @(posedge clk_4MHz or posedge reset_btn) begin
    if (reset_btn) begin
      r_start_mcp <= 0;
      analog_x <= 0;
      analog_y <= 0;
      state <= STATE_WAIT;
      r_channel <= 3'b000;
    end else begin

      if(timer_done) begin
        timer_counter <= 0;
      end else begin
        timer_counter <= timer_counter + 1'b1;
      end

      case (state)

        STATE_WAIT: begin
          if (timer_done) begin
            r_channel <= 3'b000;
            r_start_mcp <= 1;
            state <= STATE_READ;
          end
        end



        STATE_READ: begin
          r_start_mcp <= 0;
          if (data_ready) begin
            if (r_channel == 3'b000) analog_x <= analog_value;
            if (r_channel == 3'b001) analog_y <= analog_value;
            if (r_channel < MAX_CHANNEL) begin
              r_channel <= r_channel + 1'b1;
              r_start_mcp <= 1;
            end else begin
              r_start_mcp <= 0;
              state <= STATE_WAIT;
            end
          end
        end

      endcase
    end
  end
endmodule
