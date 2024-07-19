module counter(input i_clk, output reg o_led = 1);

    //create a 32bit counter, inicialized at 0
    //this size could be reduced if the total counting amount is less. 
    reg[31:0] counter = 0;

    //in every uprising clock summ 1 bit to the counter
    always @(posedge i_clk) begin
        counter <= counter + 1'b1;

        //in every clock rise check the counter
        //every 0.5 seconds altern the output
        if(counter == 5*27000000/10) begin 
            //flip the output and reset the counter
            o_led <= ~o_led;
            counter <= 0;
        end
    end

endmodule