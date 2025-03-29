/* David Vega
USES THIS FORMULA FOR GET THE OUTPUT SIGNAL
CHECK THE REAL OUTPUT FREQ 
--> freq_output = freq_input / (2 * ticks)
--> ticks = freq_input / (2 * freq_output)

EXEMPLE OF INSTANCE
  clk_generator #(.INPUT_FREQ(27000), .OUTPUT_FREQ(200)) clk_200k_i2c (
    .i_clk(clk_27M),
    .o_clk(ov_sclk)
  );
*/

module clk_generator #(parameter int INPUT_FREQ, parameter int OUTPUT_FREQ) (
  input i_clk,
  output reg o_clk
);


  localparam int MAX_COUNT = INPUT_FREQ / (2 * OUTPUT_FREQ) - 1;
  localparam int COUNTER_WIDTH = $clog2(MAX_COUNT + 1);
  logic [COUNTER_WIDTH:0] counter = 0;
  initial o_clk = 0;

  always @(posedge i_clk) begin
    if (counter >= MAX_COUNT) begin
      counter <= 1'b0;
      o_clk <= !o_clk;
    end else begin
      counter <= counter + 1'b1;
    end
  end
endmodule