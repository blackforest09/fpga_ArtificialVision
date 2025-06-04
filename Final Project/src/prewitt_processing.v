module prewitt_processing(
  input wire quartz_clk,
  input wire reset_n,
  input wire start,
  input wire read_ready,
  input wire [31:0] pixel_sdram,

  output wire read_enable,
  output wire write_enable,
  output wire [31:0] write_pixel,
  output wire [20:0] read_address,
  output wire [20:0] write_address,
  output wire prewitt_done
);

  // OUTPUTS ASSIGNATIONS
  assign write_enable   = write_enable_q;
  assign write_pixel    = write_pixel_q;
  assign write_address  = write_address_q;
  assign read_address   = read_address_q;
  assign prewitt_done   = prewitt_done_q;

  // INTERNAL REGISTERS

  reg [5:0]   rows_buffer [0:2][0:639]; //stores 3 consecutives rows
  reg [3:0]   state_q,        state_d;
  reg [9:0]   x_pos_q,        x_pos_d;
  reg [9:0]   y_pos_q,        y_pos_d;
  reg [9:0]   shift_idx_q,    shift_idx_d;
  reg         read_enable_q,  read_enable_d;
  reg         write_enable_q, write_enable_d;
  reg [20:0]  read_address_q, read_address_d;
  reg [20:0]  write_address_q,write_address_d;
  reg [31:0]  write_pixel_q,  write_pixel_d;
  reg [5:0]   a, b, c, d, e, f, g, h, i; //kernel positions
  reg signed [10:0] gx, gy;
  reg [10:0]  grad;
  reg         result_edge;
  reg         prewitt_done_q, prewitt_done_d;

  /* KERNEL MATRIX DISTRIBUTION
            a   b   c 
            d   e   f
            g   h   i
  */
  

  // FSM STATES
  localparam  idle            = 0,
              load_row        = 1,
              ask_pixel       = 2,
              receive_pixel   = 3,
              finish_row      = 4,
              shift_first_row = 5,
              shift_second_row= 11,
              buffer_matrix   = 6,
              convolution     = 7,
              rewrite_pixel   = 8,
              move_kernel     = 9,
              finish          = 10;


  parameter THRESHOLD = 8'd100;
  integer i;

  always @(posedge quartz_clk, negedge reset_n) begin
    if (!reset_n) begin
      state_q <= idle;
      x_pos_q <= 0;
      y_pos_q <= 0;
      write_address_q <= 0;
      read_address_q <= 0;
      read_enable_q <= 0;
      write_enable_q <= 0;
      write_pixel_q <= 0;
      prewitt_done_q <= 0;
      shift_idx_q <= 0;
    end
    else begin
      state_q <= state_d;
      x_pos_q <= x_pos_d;
      y_pos_q <= y_pos_d;
      write_address_q <= write_address_d;
      read_address_q  <= read_address_d;
      read_enable_q   <= read_enable_d;
      write_enable_q  <= write_enable_d;
      write_pixel_q   <= write_pixel_d;
      prewitt_done_q  <= prewitt_done_d;
      shift_idx_q     <= shift_idx_d;
    end
  end

  always_comb begin
    state_d = state_q;
    x_pos_d = x_pos_q;
    y_pos_d = y_pos_q;
    write_address_d = write_address_q;
    read_address_d  = read_address_q;
    read_enable_d   = read_enable_q;
    write_enable_d  = write_enable_q;
    write_pixel_d   = write_pixel_q;
    shift_idx_d     = shift_idx_q;
    

    case (state_q)

      idle: begin
        y_pos_d = 0;
        x_pos_d = 0;
        if (start) state_d = load_row;
      end

      shift_first_row: begin      
        for (i = 0; i < 639; i = i + 1'b1) begin
          rows_buffer[0][i] = rows_buffer[1][i];
        end
        state_d = shift_second_row;
      end

      shift_second_row: begin      
        for (i = 0; i < 639; i = i + 1'b1) begin
          rows_buffer[1][i] = rows_buffer[2][i];
        end
        state_d = load_row;
      end

      load_row: begin //start loading the row that matches the y_pos index
        state_d = ask_pixel;
      end

      ask_pixel: begin
        read_address_d  = {1'b0, y_pos_q, x_pos_q}; 
        read_enable_d   = 1;
        state_d = receive_pixel;
      end

      receive_pixel: begin
        read_enable_d = 0;
        if (read_ready) begin // store at third buffer row
          rows_buffer[2][x_pos_q] = pixel_sdram[5:0];
          x_pos_d = x_pos_q + 1'b1;
          if (x_pos_q >= 639) state_d = finish_row;
          else state_d = ask_pixel;
        end
      end

      finish_row: begin
        if (y_pos_q < 2) begin
          y_pos_d = y_pos_q + 1'b1;
          state_d = shift_first_row;
        end
        else begin  
          x_pos_d = 0;
          state_d = buffer_matrix;
        end
      end


      buffer_matrix: begin
        // assignations of kernel pixels
        if (x_pos_q >= 1 && x_pos_q <= 638) begin
          a = rows_buffer[0][x_pos_q-1];  
          b = rows_buffer[0][x_pos_q];  
          c = rows_buffer[0][x_pos_q+1];  
          d = rows_buffer[1][x_pos_q-1];  
          e = rows_buffer[1][x_pos_q];   //center
          f = rows_buffer[1][x_pos_q+1];  
          g = rows_buffer[2][x_pos_q-1];  
          h = rows_buffer[2][x_pos_q];  
          i = rows_buffer[2][x_pos_q+1];  
        end 
        else begin
          a = 0; b = 0; c = 0;
          d = 0; e = 0; f = 0;
          g = 0; h = 0; i = 0;
        end
        state_d = convolution;
      end

      convolution: begin
        gx = c + f + i - a - d - g;
        gy = a + b + c - g - h - i;

        grad =  (gx < 0 ? -gx : gx) + 
                (gy < 0 ? -gy : gy);

        result_edge = (grad > THRESHOLD) ? 1'b1 : 1'b0;

        state_d = rewrite_pixel;
      end

      rewrite_pixel: begin
        write_enable_d = 1;
        write_address_d = {1'b0, y_pos_q-1, x_pos_q};
        write_pixel_d = {24'h000000, 2'b00, result_edge ? 6'b111111 : 6'b000000};
        state_d = move_kernel;
      end

      move_kernel: begin
        write_enable_d = 0;
        if (x_pos_q < 639) begin
          x_pos_d = x_pos_q + 1'b1;
          state_d = buffer_matrix;
        end
        else begin
          if (y_pos_q >= 479) begin
            prewitt_done_d = 1;
            state_d = finish;
          end else begin
            y_pos_d = y_pos_q + 1'b1;
            state_d = shift_first_row;
          end
        end
      end

      finish: begin
        prewitt_done_d = 0;
        state_d = idle;
      end
    default: state_d = idle;
    endcase
  end
endmodule