module combinational(input i_btn_a, i_btn_b, output o_led_1, o_led_2, o_led_3);

    //first, invert the outputs for power the led at 1 logic
    assign o_led_1 = ~led1;
    assign o_led_2 = ~led2;
    assign o_led_3 = ~led3;
    
    //do not invert the inputs, they are already 1 logic when pressed
    assign btn_a = i_btn_a;
    assign btn_b = i_btn_b;

    //combinational operations
    assign led1 = btn_a & btn_b; //on when two btn pressed
    assign led2 = btn_a | btn_b;//on when whatever btn is pressed 
    assign led3 = btn_a ^ btn_b; //on only when 1 btn is pressed
endmodule