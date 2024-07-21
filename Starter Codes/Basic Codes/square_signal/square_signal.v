module square_signal
#(
    parameter frequency = 90, 
    parameter duration = 5
)
(
    input clk,
    output reg signal
);

    localparam integer count_max = 27000000 / (frequency * 2);
    localparam integer clock_freq = 27000000;

    reg enable = 1'b1;
    reg [24:0] sec_counter = 0; //count a second, reset, another second
    reg [8:0] seconds = 0; //seconds elapsed
    reg [24:0] counter = 0;

    always@(posedge clk) begin 
        if(enable) begin

            sec_counter <= sec_counter + 1'b1;
            if(sec_counter >= clock_freq - 1) begin
                seconds <= seconds + 1'b1;
                sec_counter <= 0;
                if(seconds >= duration) begin
                    enable <= 0;
                    signal <= 0;
                end
            end

            counter <= counter + 1'b1;
            if (counter >= count_max ) begin
                counter <= 0;   
                signal <= ~signal;
            end

        end else begin
            signal <= 0;
        end
        
    end

endmodule