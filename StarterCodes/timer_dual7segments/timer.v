/*
From the code of dual 7-segments, do some modifications for use it as a tiemr of 60 seconds.
The buttons operation will pause, resume and reset the timer.

First, the inicialization of the counter is 59
Add a new register enable for activate the downcounting or pause it. 
Add a new reg zero that says the counting has end, and lights the leds.
Add a new reg temp to count 1 second
*/

module timer(
    input i_clk, i_btn_a, i_btn_b,
    output o_a, o_b, o_c, o_d, o_e, o_f, o_g, o_sel, o_0, o_1, o_2, o_3, o_4, o_5
    );

    reg [20:0] chrono = 0; //chronometer for toggle the digits, 90Hz
    reg [24:0] temp = 0;  //for count 1 second
    reg [6:0] counter = 59; //8 bits counter, init at 59
    wire [11:0] bcd; //bcd, for tens and ones, also hundreds but not used
    reg enable = 0; //1, temp is running. Also it lights a led. 
    reg zero = 0; //indicates the finish of the timer

//binary to bcd converter
    bin2bcd converter (.bin(counter), .bcd(bcd));

    wire [6:0] display; //instance a wire of 7 bits, for the 7 segments
    reg [3:0] digit; //is stored the right bcd value (tens or units)
    
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

    assign o_0 = ~zero;
    assign o_1 = ~zero;
    assign o_2 = ~zero;
    assign o_3 = ~zero;
    assign o_4 = ~zero;
    assign o_5 = ~zero;

//theese registers are for see if the btn state has changed from previous clock
    reg btn_a_old;
    reg btn_b_old;

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

//dinamic behaviour, clock
    always @(posedge i_clk) begin   

    //chronometer for toggle sel pin
        chrono <= chrono + 1'b1;
        if (chrono == 27000000 / 90 - 1) begin   
            sel <= ~sel;
            chrono <= 0;
            if(sel==1)
                digit <= bcd[7:4];
            else    
                digit <= bcd[3:0];
        end

    //temp counting
        if(enable == 1) begin
            temp <= temp + 1'b1;
            if (temp == 27000000-1) begin 
                if(counter == 0) begin  
                    enable <= 0;
                    zero <= 1;
                end
                else begin
                    counter <= counter - 1'b1;
                    temp <= 0;
                end
            end
        end

    //the buttons behaviour / counter
        btn_a_old <= btn_a_mono;
        btn_b_old <= btn_b_mono;
    
        if(btn_a_mono == 1 && btn_a_old == 0) //if detected a positive edge from btn a, sum 1 bit to the counter
            enable <= ~enable;
        else if (btn_b_mono == 1 && btn_b_old == 0) begin//if detected a pos edge from the btn b, rest 1 bit from the counter
            counter <= 59;
            enable <= 0;
            zero <= 0;
        end
    end

endmodule