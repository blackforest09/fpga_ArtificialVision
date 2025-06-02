module prewitt_processing(
  input wire sdram_clk,
  input wire reset_n,
  input wire start,
  input wire read_ready,
  input wire [31:0] pixel_sdram,

  output wire read_enable,
  output wire write_enable,
  output [31:0] write_pixel,
  output wire [20:0] address
);

  // OUTPUTS ASSIGNATIONS
  assign write_enable = write_enable_q;
  assign write_pixel = write_pixel_q;
  assign address = address_q;

  // INTERNAL REGISTERS
  reg [7:0] lines_buffer [0:2][0:639];
  reg [3:0] state_q, state_d;
  reg [9:0] x_pos_q, x_pos_d;
  reg [9:0] y_pos_q, y_pos_d;
  reg read_enable_q, read_enable_d;
  reg write_enable_q, write_enable_d;
  reg [20:0] address_q, address_d;
  reg [31:0] write_pixel_q, write_pixel_d;
  reg new_line_required_q, new_line_required_d;
  reg [7:0] a, b, c, d, e, f, g, h, i; //kernel positions
  reg signed [10:0] gx, gy;
  reg [10:0] grad;
  reg result_edge;

  /* KERNEL MATRIX DISTRIBUTION
            a   b   c 
            d   e   f
            g   h   i
  */
  

  // FSM STATES
  localparam  idle        = 0,
              new_line_controller = 6,
              shift_rows = 8,
              ask_pixel   = 1,
              store_pixel = 2,
              processing  = 3,
              write_edge_pixel = 4,
              move_kernel = 7,
              finish      = 5;

  parameter THRESHOLD = 8'd100;

  always @(posedge sdram_clk, negedge reset_n) begin
    if (!reset_n) begin
      state_q <= idle;
      x_pos_q <= 0;
      y_pos_q <= 0;
      address_q <= 0;
      read_enable_q <= 0;
      write_enable_q <= 0;
      write_pixel_q <= 0;
      new_line_required_q <= 1'b0;
    end
    else begin
      state_q <= state_d;
      x_pos_q <= x_pos_d;
      y_pos_q <= y_pos_d;
      address_q <= address_d;
      read_enable_q <= read_enable_d;
      write_enable_q <= write_enable_d;
      write_pixel_q <= write_pixel_d;
      new_line_required_q <= new_line_required_d;
    end
  end

  always @* begin
    state_d = state_q;
    x_pos_d = x_pos_q;
    y_pos_d = y_pos_q;
    address_d = address_q;
    read_enable_d = read_enable_q;
    write_enable_d = write_enable_q;
    write_pixel_d = write_pixel_q;
    new_line_required_d = new_line_required_q;

    case (state_q)

      idle: begin
        if (start) begin
          new_line_required_d = 1'b1;
          state_d = new_line_controller;
        end
      end

      new_line_controller: begin    
        if (new_line_required_q) begin
          new_line_required_d = 1'b0;
          x_pos_d = 0;
          state_d = shift_rows;
        end
        else begin
          state_d = processing;
        end
      end        

      shift_rows: begin
        for (i = 0; i < 640; i = i + 1) begin
          lines_buffer[0][i] = lines_buffer[1][i]; 
          lines_buffer[1][i] = lines_buffer[2][i];  
        end
        state_d = ask_pixel; // for fill the third row
      end


      ask_pixel: begin
        address_d = {1'b0, y_pos_d, x_pos_d};
        read_enable_d = 1'b1;
        state_d = store_pixel;       
      end

      store_pixel: begin
        if (read_ready) begin
          lines_buffer[2][x_pos_q] =  pixel_sdram[7:0];
          if (x_pos_q < 639) begin
            x_pos_d = x_pos_q + 1'b1;
            state_d = ask_pixel;
          end 
          else begin
            x_pos_d = 0;
            y_pos_d = y_pos_q + 1'b1;
            state_d = new_line_controller;
          end
        end
      end

      processing: begin
        // assignations of kernel pixels
        a = lines_buffer[0][x_pos_q-1];  
        b = lines_buffer[0][x_pos_q];  
        c = lines_buffer[0][x_pos_q+1];  
        d = lines_buffer[1][x_pos_q-1];  
        e = lines_buffer[1][x_pos_q];  
        f = lines_buffer[1][x_pos_q+1];  
        g = lines_buffer[2][x_pos_q-1];  
        h = lines_buffer[2][x_pos_q];  
        i = lines_buffer[2][x_pos_q+1];  

        gx = c + f + i - a - d - g;
        gy = a + b + c - g - h - i;

        grad =  (gx < 0 ? -gx : gx) + 
                (gy < 0 ? -gy : gy);
      
        result_edge = (grad > THRESHOLD) ? 1'b1 : 1'b0;

        state_d = write_pixel;
      end

      write_edge_pixel: begin
        write_enable_d = 1'b1;
        address_d = {1'b0, y_pos_q, x_pos_q};
        write_pixel_d = {16'h0000, 8'h00, result_edge ? 8'b11111111 : 8'b00000000};
        state_d = move_kernel;
      end

      move_kernel: begin
        if (x_pos_q < 639) begin
          x_pos_d = x_pos_q + 1'b1;
          state_d = processing;
        end
        else begin
          new_line_required_d = 1'b1;
          state_d = new_line_controller;
        end
      end

      finish: begin
        
      end
    default: state_d = idle;
    endcase
  end
endmodule