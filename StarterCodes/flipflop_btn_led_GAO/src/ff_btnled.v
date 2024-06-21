module btnled(input i_btn, i_clk, output o_led);
    
    wire btn;
    //transfer the btn input to a inside wire
    assign btn = i_btn; 

    //a register is normal a flipflop component to store a value
    reg trigger; 
    reg btn_old;
    
//for give GAO the trigger data
    always @(posedge i_clk) begin
        btn_old <= btn; //d-ff, updates the previous value
        if (btn == 1 && btn_old == 0) //when old and new btn values are different
            trigger <= 1;
        else 
            trigger <= 0;
    end


//for alternate the led status
    reg led = 0;
    assign o_led = ~led;

    always @(posedge btn)
        led <= ~led;

endmodule 