/*
AUTHOR: David Vega

OBJECTIVES:
This module communicates from the master to the slave with the SCCB protocol, similar to i2c but without ACKs.
--> Works with a signal that doubles the sclk for i2c. Also generates the real sclk inside
--> Only needs a start signal, and the 3 bytes of data (address, register and value)
--> Busy and write_done can be used for see the status of this module. 

This module is based on official documentation form OmniVision: 
--> https://people.ece.cornell.edu/land/courses/ece4760/FinalProjects/f2021/jfw225_aei23_dsb298/jfw225_aei23_dsb298/SCCBSpec_AN.pdf
*/

module sccb_communication(
  input logic double_sclk,
  input logic start,
  input logic reset,
  input logic [7:0] addr,
  input logic [7:0] register,
  input logic [7:0] value,
  inout wire sda,
  output logic busy,
  output logic write_done,
  output logic sclk
);


  // DATA SEND REGISTERS
  logic [7:0] buffer_data;                  // for store the correct byte before send
  logic [3:0] bit_count;                    // for count the bits sended of the byte data
  logic [1:0] send_data_phase = 2'b00;      // indicates the phase of send, address -> register -> value


  // CONFIGURATION OF SDA                   // sda in standby must be high and driven by the master
  logic sda_out = 1'b1;                     // value of sda when sda_enable is true
  logic sda_enable = 1'b1;                  // enables the sda bus as an output. Else sda is high z
  assign sda = sda_enable ? sda_out : 1'bz;


  // FINITE STATE MACHINE
  typedef enum logic [2:0] {
    STATE_IDLE,                             // prepare the data and wait until the start signal
    STATE_START_COND,                       // init the protocol correctly, sda from 1 to 0 when sclk is 1
    STATE_SEND_BYTE,                        // modular state for send one byte
    STATE_END_COND,                         // finish the protocol correctly, sda from 0 to 1 when sclk is 1
    STATE_DONE                              // give feedback to upper-module that write is done
  } state_t;
  state_t state;

  initial sclk = 0;

  always_ff @(posedge double_sclk or posedge reset) begin
    if (reset) begin
      state <= STATE_IDLE;
      sda_enable <= 1'b1;
      sda_out <= 1'b1;
      bit_count <= 0;
      write_done <= 1'b0;
      busy <= 1'b0;
      send_data_phase <= 2'b00;
    end else begin
      sclk <= !sclk;

      case (state)



        STATE_IDLE: begin
          sda_enable <= 1'b1;
          sda_out <= 1'b1;
          write_done <= 1'b0;
          busy <= 1'b0;
          send_data_phase <= 2'b00;
          if (start) begin
            buffer_data <= addr;
            busy <= 1'b1;
            state <= STATE_START_COND;
          end
        end



        STATE_START_COND: begin
          if (!sclk) begin
            sda_out <= 1'b0;
            state <= STATE_SEND_BYTE;
            send_data_phase <= 2'b01;
          end
        end



        STATE_SEND_BYTE: begin
          if (!sclk) begin
            if (bit_count >= 8) begin
              if (send_data_phase == 2'b11) begin
                state <= STATE_END_COND;
                sda_out <= 1'b0;
                bit_count <= 0;
                send_data_phase <= 2'b00;
              end else begin
                buffer_data <= (send_data_phase == 2'b01) ? register : 
                (send_data_phase == 2'b10) ? value : 
                8'h00; // Valor por defecto si send_data_phase tiene otro valor
                sda_out <= 1'b0;
                bit_count <= 0;
                send_data_phase <= send_data_phase + 1'b1;
              end
            end else begin
              sda_out <= buffer_data[7];
              buffer_data <= buffer_data << 1;
              bit_count <= bit_count + 1'b1;
            end
          end
        end



        STATE_END_COND: begin
          if (!sclk) begin
            sda_out <= 1'b1;
            send_data_phase <= 2'b00;
            state <= STATE_DONE;
          end
        end



        STATE_DONE: begin
          write_done <= 1'b1;
          state <= STATE_IDLE;
        end



        default: state <= STATE_IDLE;
      endcase
    end
  end
endmodule