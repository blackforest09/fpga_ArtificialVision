module ff_btnled(input i_clk, i_btn, output o_led);

    reg state_led = 0;        //starts off
    assign o_led = ~led;  //at 0 is off, at 1 is on
    assign led = state_led;
        
    always @(posedge i_btn)
        state_led <= ~state_led;
    
endmodule