module main
    (
    input i_clk, i_btn_a, i_btn_b,
    output signalpin
    );
    
    assign signalpin = signaloutput;
    
    wire signaloutput;
    square_signal #(.frequency(1100), .duration(10)) signalinstance (.clk(i_clk), .signal(signaloutput));
    
endmodule