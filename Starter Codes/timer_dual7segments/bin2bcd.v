module bin2bcd(
    input [6:0] bin,
    output reg [11:0] bcd
    );

    integer i; 
    integer s;

    always @(bin) begin 
        bcd = 0; //init at 0 in every change of bin
        for (i = 6; i >= 0; i = i - 1) begin    
            if (bcd[3:0] >= 4'd5) bcd[3:0] = bcd[3:0] + 4'd3;
            if (bcd[7:4] >= 4'd5) bcd[7:4] = bcd[7:4] + 4'd3;
            if (bcd[11:8] >= 4'd5) bcd[11:8] = bcd[11:8] + 4'd3;
            
            for(s = 11; s >= 1; s = s - 1) begin
                bcd[s] = bcd[s-1];
            end
            bcd[0] = bin[i];
        end
    end

endmodule