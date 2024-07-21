module square(
    input i_clk,
    input [9:0] i_x,
    input [9:0] i_y,
    input left,
    input right,
    input up,   
    input down,

    output [4:0] o_R,
    output [5:0] o_G,
    output [4:0] o_B
);

    //parameters
    localparam integer SQUARE_SIZE = 50;
    localparam integer WIDTH = 800;
    localparam integer HEIGHT = 480;
   

    //registers
    reg [9:0] xpos = (WIDTH - SQUARE_SIZE) / 2;
    reg [9:0] ypos = (HEIGHT - SQUARE_SIZE) / 2;
    reg on;

    //buttons
    wire left_mono;
    wire right_mono;
    wire up_mono;
    wire down_mono;

    reg left_old;
    reg right_old;
    reg up_old;
    reg down_old;
    
    monostable mono1 (.pulse_in (left),  .clock (i_clk), .pulse_out (left_mono));
    monostable mono2 (.pulse_in (right), .clock (i_clk), .pulse_out (right_mono));
    monostable mono3 (.pulse_in (up),    .clock (i_clk), .pulse_out (up_mono));
    monostable mono4 (.pulse_in (down),  .clock (i_clk), .pulse_out (down_mono));

    
    always @(posedge i_clk) begin
        
        left_old  <= left_mono;
        right_old <= right_mono;
        up_old    <= up_mono;
        down_old  <= down_mono;

        if(left_mono == 1 && left_old == 0)
            if(xpos >= 1)
                xpos <= xpos - 1'b1;
        if(right_mono == 1 && right_old == 0)
            if(xpos < WIDTH-SQUARE_SIZE)
                xpos <= xpos + 1'b1;
        if(up_mono == 1 && up_old == 0)
            if(ypos >= 1)
                ypos <= ypos - 1'b1;
        if(down_mono == 1 && down_old == 0)
            if(ypos < HEIGHT-SQUARE_SIZE)
                ypos <= ypos + 1'b1;

        if(i_x >= xpos && i_x < xpos + SQUARE_SIZE && i_y >= ypos && i_y < ypos + SQUARE_SIZE) begin
            on = 1;
        end else begin
            on = 0;
        end
    end

    assign o_R = 5'b0;
    assign o_G = (on==1) ? 6'b111111 : 6'b0;
    assign o_B = (on==1) ? 5'b11111 : 5'b0;

endmodule