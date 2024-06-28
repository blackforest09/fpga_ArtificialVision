/*
From the code of 7-segments, do some modifications for use it with a dual 7 segments.
The main counter is of 8 bits, for count minimum up to 99.
This counter value in binary is converted to bcd for divide the digits, and assigned to a bcd register. 
bcd[7:4] are for the tens, bcd[3:0] are for units.

There is a chronometer of 90 Hz for toggle the digits, the select pin in the pmod.
Once is toggled check the sel register value, and assign the digit register the right bcd.
This digit register is assigned to a 7 bit wire "display" that finally connects to the leds (A-G). 

Credits to AmeerAbdelhadi for the bin2bcd converter. 
https://github.com/AmeerAbdelhadi/Binary-to-BCD-Converter
*/

module dual7seg(
    input i_clk, i_btn_a, i_btn_b, i_btn_r,
    output o_a, o_b, o_c, o_d, o_e, o_f, o_g, o_sel
    );

    reg [20:0] chrono = 0; //chronometer for toggle the digits 
    reg [7:0] counter = 0; //8 bits counter
    reg [9:0] bcd; //bcd, for tens and ones, also hundreds but not used

//binary to bcd converter
    integer i,j;
    always @(counter) begin
        for(i = 0; i <= 8+(4)/3; i = i+1) bcd[i] = 0;       // initialize with zeros
        bcd[7:0] = counter;                                 // initialize with input vector
        for(i = 0; i <= 4; i = i+1)                         // iterate on structure depth
          for(j = 0; j <= i/3; j = j+1)                     // iterate on structure width
            if (bcd[8-i+4*j -: 4] > 4)                      // if > 4
              bcd[8-i+4*j -: 4] = bcd[8-i+4*j -: 4] + 4'd3; // add 3
    end

    reg [3:0] digit; //is stored the right bcd value (tens or units)
    wire [6:0] display; //instance a wire of 7 bits, for the 7 segments
    
//sets the 7 bit number of the wire depending on the counter
    assign display = (digit==4'd0) ? 7'b0111111 : 
                     (digit==4'd1) ? 7'b0000110 :
                     (digit==4'd2) ? 7'b1011011 : 
                     (digit==4'd3) ? 7'b1001111 : 
                     (digit==4'd4) ? 7'b1100110 :
                     (digit==4'd5) ? 7'b1101101 : 
                     (digit==4'd6) ? 7'b1111101 :
                     (digit==4'd7) ? 7'b0000111 :
                     (digit==4'd8) ? 7'b1111111 :
                     (digit==4'd9) ? 7'b1100111 : 7'b1000000;


    //for enter the I/O variables to internal ones, and instance it as a wire
    wire btn_a;    
    assign btn_a = i_btn_a;
    wire btn_a_mono;

    wire btn_b;
    assign btn_b = i_btn_b;
    wire btn_b_mono;

    wire btn_r;
    assign btn_r = i_btn_r;
    wire btn_r_mono;

    reg sel = 0;
    assign o_sel = sel;

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
    reg btn_r_old;

//here the assignations to each inside output refered to the position of the display 7 bits number
    assign a = display[0];
    assign b = display[1];
    assign c = display[2];
    assign d = display[3];
    assign e = display[4];
    assign f = display[5];
    assign g = display[6];

//with the monostable vhdl module attached
    monostable mono1 (.pulse_in (btn_a), .clock (i_clk), .pulse_out (btn_a_mono));
    monostable mono2 (.pulse_in (btn_b), .clock (i_clk), .pulse_out (btn_b_mono));
    monostable mono3 (.pulse_in (btn_r), .clock (i_clk), .pulse_out (btn_r_mono));



//dinamic behaviour, clock
    always @(posedge i_clk) begin   

    //chronometer for toggle sel pin
        chrono <= chrono + 1'b1;
        if (chrono == 27000000 / 90) begin   
            sel <= ~sel;
            chrono <= 0;
            if(sel == 1)
                digit <= bcd[7:4];
            else    
                digit <= bcd[3:0];
        end

    //the buttons behaviour / counter
        btn_a_old <= btn_a_mono;
        btn_b_old <= btn_b_mono;
        btn_r_old <= btn_r_mono;
    
        if(btn_a_mono == 1 && btn_a_old == 0) //if detected a positive edge from btn a, sum 1 bit to the counter
            if(counter == 99) counter <= 0;
            else counter <= counter + 1'b1;

        else if (btn_b_mono == 1 && btn_b_old == 0) //if detected a pos edge from the btn b, rest 1 bit from the counter
            if(counter == 0) counter <= 99;
            else counter <= counter - 1'b1;
    
        else if (btn_r_mono == 1 && btn_r_old == 0) //also, if the reset button is pressed, put at 0 the counter.
            counter <= 0;
    end

endmodule