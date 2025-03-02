//MCP3004/3008 controller
/*
This module is for control the ADC MCP3004/3008 chip, 10bit resolution.
The input clock must be double the serial clock.
The serial clock must be in function of the supply voltage. 
Inside the module, generates the serial clock SCLK.
The MOSI signal is set before the MCP can read for better stability.
From the start_protocol signal until receive the dataReady with the analogValue, takes 37 cycles. 
*/ 

module mcp300x
(
  input clk_doubleSCLK,
  input reset,
  input start_protocol,
  input [2:0] channel,
  input MISO,

  output [9:0] analog_value,
  output data_ready,
  output SCLK,
  output CS,
  output MOSI
);


  localparam STATE_LOAD_CMD_TO_SEND = 2'b00;
  localparam STATE_SEND = 2'b01;
  localparam STATE_READ_DATA = 2'b10;
  localparam STATE_DONE = 2'b11;

  localparam CMD_READ_SINGLE = 1'b1;
  localparam CMD_READ_DIFFERENTIAL = 1'b0; 

  // INTERNAL REGISTERS
  reg r_MOSI = 0;
  reg r_CS = 1;
  reg r_SCLK = 0;  
  reg r_data_ready = 0;

  reg [2:0] read_address = 0;
  reg [9:0] shift_register  = 0;
  reg [9:0] r_analog_value = 0;

  reg [4:0] data_to_send = 0;
  reg [4:0] bits_to_send= 0;

  reg [5:0] counter = 0;
  reg [2:0] state = STATE_LOAD_CMD_TO_SEND; //initial

  always @(posedge clk_doubleSCLK or posedge reset) begin
    if (reset) begin
      state <= STATE_LOAD_CMD_TO_SEND;
      shift_register  <= 0;
      counter <= 0;
    end else begin



      case (state)

        STATE_LOAD_CMD_TO_SEND: begin
          r_data_ready <= 0;
          r_analog_value <= 0;
          if (start_protocol == 1) begin  
            r_CS <= 0;
            data_to_send <= {1'b1, CMD_READ_SINGLE, channel}; //5 bits de datos
            bits_to_send <= 6; // must be send 5 bits (data) + 1 bit (wait) 
            state <= STATE_SEND;
          end
        end



        STATE_SEND: begin
          if (counter == 6'd0) begin
            r_SCLK <= 0;
            r_MOSI <= data_to_send[4]; // high value position, the 1st digit of 5
            data_to_send <= {data_to_send[3:0],1'b0}; // move to the left
            bits_to_send <= bits_to_send - 1; // on the next cycle, i will have sent 1 bit
            counter <= 6'd1;
          end else begin
            counter <= 6'd0;
            r_SCLK <= 1;
            if (bits_to_send == 0) // when i sent all, end the state
              state <= STATE_READ_DATA;
            end
          end



        STATE_READ_DATA: begin
          counter <= counter + 1'b1;
          if (counter[0] == 1'd0) begin //the less value digit control the SCLK
            r_SCLK <= 0;
            if (counter[5:0] == 5'd22 ) begin // 11 cycle for SCLK
              state <= STATE_DONE;
            end
          end else begin
            r_SCLK <= 1;
            shift_register  <= {shift_register [8:0], MISO}; //here is added the MISO value to the previous 9 bits
          end
        end 



        STATE_DONE: begin
          r_data_ready <= 1;
          r_CS <= 1;
          r_analog_value <= shift_register ;
          counter <= 6'd0;
          state <= STATE_LOAD_CMD_TO_SEND;
        end

      endcase
    end
  end

  assign MOSI = r_MOSI;
  assign CS =  r_CS;
  assign SCLK = r_SCLK;
  assign data_ready = r_data_ready;
  assign analog_value = r_analog_value;

endmodule