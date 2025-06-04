/*
  sccb_config govern the register configuration of the ov7670
  Uses sccb protocol based on I2C
  There is a list of register address and values for rewrite them
*/

`timescale 1ns / 1ps

module sccb_config (
  input wire sdram_clk,
  input wire quartz_clk,
  input wire start_config,
  input wire reset_n,     //from button, active on low

  inout wire sda, sclk,   //i2c wires
  output wire rst_n,
  output wire pwdn,
  output wire config_done  // signal for start other modules
);

  // OUTPUTS ASSIGNATIONS
  assign pwdn = 0;
  assign rst_n = 1;
  assign config_done = config_done_q;


  // LIST OF REGISTERS AND VALUES FOR MODIFY
  reg [15:0] message[250:0];
  localparam MSG_INDEX = 77;
  initial begin
    message[0]=16'h12_80;  //reset all register to default values
    message[1]=16'h12_04;  //set output format to RGB
    message[2]=16'h15_20;  //pclk will not toggle during horizontal blank
    message[3]=16'h40_d0;	//RGB565
	 
    // These are values scalped from https://github.com/jonlwowski012/OV7670_NEXYS4_Verilog/blob/master/ov7670_registers_verilog.v
    message[4]= 16'h12_04; // COM7,     set RGB color output
    message[5]= 16'h11_80; // CLKRC     internal PLL matches input clock
    message[6]= 16'h0C_00; // COM3,     default settings
    message[7]= 16'h3E_00; // COM14,    no scaling, normal pclock
    message[8]= 16'h04_00; // COM1,     disable CCIR656
    message[9]= 16'h40_d0; //COM15,     RGB565, full output range
    message[10]= 16'h3a_04; //TSLB       set correct output data sequence (magic)
	  message[11]= 16'h14_18; //COM9       MAX AGC value x4 0001_1000
    message[12]= 16'h4F_B3; //MTX1       all of these are magical matrix coefficients
    message[13]= 16'h50_B3; //MTX2
    message[14]= 16'h51_00; //MTX3
    message[15]= 16'h52_3d; //MTX4
    message[16]= 16'h53_A7; //MTX5
    message[17]= 16'h54_E4; //MTX6
    message[18]= 16'h58_9E; //MTXS
    message[19]= 16'h3D_C0; //COM13      sets gamma enable, does not preserve reserved bits, may be wrong?
    message[20]= 16'h17_14; //HSTART     start high 8 bits
    message[21]= 16'h18_02; //HSTOP      stop high 8 bits //these kill the odd colored line
    message[22]= 16'h32_80; //HREF       edge offset
    message[23]= 16'h19_03; //VSTART     start high 8 bits
    message[24]= 16'h1A_7B; //VSTOP      stop high 8 bits
    message[25]= 16'h03_0A; //VREF       vsync edge offset
    message[26]= 16'h0F_41; //COM6       reset timings
    message[27]= 16'h1E_00; //MVFP       disable mirror / flip //might have magic value of 03
    message[28]= 16'h33_0B; //CHLF       //magic value from the internet
    message[29]= 16'h3C_78; //COM12      no HREF when VSYNC low
    message[30]= 16'h69_00; //GFIX       fix gain control
    message[31]= 16'h74_00; //REG74      Digital gain control
    message[32]= 16'hB0_84; //RSVD       magic value from the internet *required* for good color
    message[33]= 16'hB1_0c; //ABLC1
    message[34]= 16'hB2_0e; //RSVD       more magic internet values
    message[35]= 16'hB3_80; //THL_ST
    //begin mystery scaling numbers
    message[36]= 16'h70_3a;
    message[37]= 16'h71_35;
    message[38]= 16'h72_11;
    message[39]= 16'h73_f0;
    message[40]= 16'ha2_02;
    //gamma curve values
    message[41]= 16'h7a_20;
    message[42]= 16'h7b_10;
    message[43]= 16'h7c_1e;
    message[44]= 16'h7d_35;
    message[45]= 16'h7e_5a;
    message[46]= 16'h7f_69;
    message[47]= 16'h80_76;
    message[48]= 16'h81_80;
    message[49]= 16'h82_88;
    message[50]= 16'h83_8f;
    message[51]= 16'h84_96;
    message[52]= 16'h85_a3;
    message[53]= 16'h86_af;
    message[54]= 16'h87_c4;
    message[55]= 16'h88_d7;
    message[56]= 16'h89_e8;
    //AGC and AEC
    message[57]= 16'h13_e0; //COM8, disable AGC / AEC
    message[58]= 16'h00_00; //set gain reg to 0 for AGC
    message[59]= 16'h10_00; //set ARCJ reg to 0
    message[60]= 16'h0d_40; //magic reserved bit for COM4
    message[61]= 16'h14_18; //COM9, 4x gain + magic bit
    message[62]= 16'ha5_05; // BD50MAX
    message[63]= 16'hab_07; //DB60MAX
    message[64]= 16'h24_95; //AGC upper limit
    message[65]= 16'h25_33; //AGC lower limit
    message[66]= 16'h26_e3; //AGC/AEC fast mode op region
    message[67]= 16'h9f_78; //HAECC1
    message[68]= 16'ha0_68; //HAECC2
    message[69]= 16'ha1_03; //magic
    message[70]= 16'ha6_d8; //HAECC3
    message[71]= 16'ha7_d8; //HAECC4
    message[72]= 16'ha8_f0; //HAECC5
    message[73]= 16'ha9_90; //HAECC6
    message[74]= 16'haa_94; //HAECC7
    message[75]= 16'h13_e5; //COM8, enable AGC / AEC
    message[76]= 16'h1E_00; //23; //Mirror Image
    message[77]= 16'h69_06; //gain of RGB(manually adjusted) 
  end


	//Finite State Machine declarations
	localparam  idle          = 0, //waits initialization of camera
              start_sccb    = 1, //starts protocol
              write_address = 2, //send address
              write_data    = 3, //send the value of register
              digest_loop   = 4, //waits ack from slave
              delay         = 5, //waits until next message
              finish        = 6; //end all module

  //regs *_q are for secuential logic, store the current state
  //regs *_d are for combinational logic, calculate the next state
  reg [3:0] state_q = 0, state_d;
  reg [7:0] addr_q, addr_d;
  reg [7:0] data_q, data_d;
  reg start, stop;
  reg [7:0] wr_data;
  reg [1:0] ack;
  reg [3:0] state;
  reg [27:0] delay_q = 0, delay_d;
  reg start_delay_q = 0, start_delay_d; 
  reg delay_finish;
  reg [7:0] message_index_q = 0, message_index_d;
  reg config_done_q, config_done_d;


  //instance of the raw sccb protocol
  i2c_sccb_protocol #(.freq(100_000)) i2c_sccb_protocol_instance(
    .clk      (sdram_clk),
    .rst_n    (reset_n),
    .start    (start),
    .stop     (stop),
    .wr_data  (wr_data),
    .ack      (ack),      //ack[1] ticks at the ack bit[9th bit],ack[0] asserts when ack bit is ACK,else NACK
    .scl      (sclk),
    .sda      (sda),
    .state    (state)
  ); 


  // register operations
  always @(posedge sdram_clk, negedge reset_n) begin
    
    if (!reset_n) begin
			state_q         <= 0;
			delay_q         <= 0;
			start_delay_q   <= 0;
			message_index_q <= 0;
			
			addr_q          <= 0;
			data_q          <= 0;
      config_done_q   <= 0;
    end
    else begin
			state_q         <= state_d;
			delay_q         <= delay_d;
			start_delay_q   <= start_delay_d;
			message_index_q <= message_index_d;			
			
			addr_q          <= addr_d;
			data_q          <= data_d;
      config_done_q   <= config_done_d;
    end
  end

  always @* begin
    state_d           = state_q;
		start             = 0;
		stop              = 0;
		wr_data           = 0;
		start_delay_d     = start_delay_q;
		delay_d           = delay_q;
		delay_finish      = 0;
		message_index_d   = message_index_q;
		
		addr_d            = addr_q;
		data_d            = data_q;
    config_done_d     = config_done_q;

    // delay logic
		if(start_delay_q) delay_d = delay_q + 1'b1;
		if(delay_q[16] && message_index_q != (MSG_INDEX + 1) && (state_q != start_sccb))  begin  //delay between SCCB transmissions (0.66ms)
			delay_finish  = 1;
			start_delay_d = 0;
			delay_d       = 0;
		end 
		else if((delay_q[26] && message_index_q == (MSG_INDEX + 1)) || (delay_q[26] && state_q == start_sccb)) begin //delay BEFORE SCCB transmission, AFTER SCCB transmission, and BEFORE retrieving pixel data from camera (0.67s)
			delay_finish  = 1;
			start_delay_d = 0;
			delay_d       = 0;
		end

    case(state_q) 

      idle: begin
        if(delay_finish) begin //idle for 0.6s to start-up the camera
          if (start_config) begin
            state_d           = start_sccb; 
            start_delay_d     = 0;
          end
        end 
        else start_delay_d  = 1;
      end

      start_sccb: begin   //start of SCCB transmission
        start   = 1;
        wr_data = 8'h42; //slave address of OV7670 for write
        state_d = write_address;						
      end

      write_address: if(ack == 2'b11) begin 
        wr_data = message[message_index_q][15:8]; //write address
        state_d = write_data;
      end

      write_data: if(ack == 2'b11) begin 
        wr_data = message[message_index_q][7:0]; //write data
        state_d = digest_loop;
      end

      digest_loop: if(ack == 2'b11) begin //stop sccb transmission
        stop            = 1;
        start_delay_d   = 1;
        message_index_d = message_index_q+1'b1;
        state_d         = delay;
      end

      delay: begin
        if(message_index_q == (MSG_INDEX + 1) && delay_finish) begin 
          config_done_d = 1'b1;
          state_d = finish;
        end
        else if(state == 0 && delay_finish) state_d = start_sccb; //small delay before next SCCB transmission(if all messages are not yet digested)
      end
    
      finish: begin
        config_done_d = 1'b1;
      end
    endcase
  end
endmodule
