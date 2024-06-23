module counter(input i_clk, output o_led);

    //the counter of 32 bits needs 4.294.967.295 cycles to reset
    //the clock goes to 27.000.000 cycles/second
    //the first bit position changes every 27M / 2
    //the second changes every 27M / 4
    //the n position changes every 27M / 2^n
    
    reg[31:0] counter = 0;

    assign o_led = ~led;
    assign led = counter [24]; //every 27M/2^24 = 1,6 seconds changes

    //in every uprising clock summ 1 to the counter
    always @(posedge i_clk)
        counter <= counter + 1;

endmodule 