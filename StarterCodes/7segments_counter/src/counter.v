module counter(
    input i_btn_a, i_btn_b, i_clk,
    output o_a, o_b, o_c, o_d, o_e, o_f, o_g
    );

    //instance a wire of 7 bits, for the 7 segments
    wire [6:0] display;
    
    //counter register is a 4 bit counter, for 0-15 values.
    reg [3:0] counter = 0; 

    //sets the 7 bit number of the wire depending on the counter
    assign display = (counter==4'd0) ? 7'b0111111 : 
                     (counter==4'd1) ? 7'b0000110 :
                     (counter==4'd2) ? 7'b1011011 : 
                     (counter==4'd3) ? 7'b1001111 : 
                     (counter==4'd4) ? 7'b1100110 :
                     (counter==4'd5) ? 7'b1101101 : 
                     (counter==4'd6) ? 7'b1111101 :
                     (counter==4'd7) ? 7'b1000111 :
                     (counter==4'd8) ? 7'b1111111 :
                     (counter==4'd9) ? 7'b1100111 :
                     (counter==4'd10)? 7'b1110111 :
                     (counter==4'd11)? 7'b1111100 :
                     (counter==4'd12)? 7'b1011000 :
                     (counter==4'd13)? 7'b1011110 :
                     (counter==4'd14)? 7'b1111011 : 7'b1110001 ;

//for enter the I/O variables to internal ones, and instance it as a wire

    wire btn_a;
    wire btn_b;
    assign btn_a = i_btn_a;
    assign btn_b = i_btn_b;

//here the outputs are inverse logic, needs a 0 to light up. 
//There are toggled
    wire a;
    wire b;
    wire c;
    wire d;
    wire e;
    wire f;
    wire g;
    assign o_a = ~a;    
    assign o_b = ~b;    
    assign o_c = ~c;    
    assign o_d = ~d;    
    assign o_e = ~e;    
    assign o_f = ~f;    
    assign o_g = ~g;

//theese registers are for see if the btn state has changed from previous clock
    reg btn_a_old;
    reg btn_b_old;

//in every clock edge, reload the previous btn state with the new, and check if there is any change
    always @(posedge i_clk) begin   
        btn_a_old <= btn_a;
        btn_b_old <= btn_b;

//if detected a positive edge from btn a, sum 1 bit to the counter
        if(btn_a == 1 && btn_a_old == 0)
            counter <= counter + 1'b1;
//else, if detected a pos edge from the btn b, rest 1 bit from the couter
        else if (btn_b == 1 && btn_b_old == 0)
            counter <= counter - 1'b1;

    end

//here the assignations to each inside output refered to the position of the display 7 bits number
    assign a = display[0];
    assign b = display[1];
    assign c = display[2];
    assign d = display[3];
    assign e = display[4];
    assign f = display[5];
    assign g = display[6];

endmodule