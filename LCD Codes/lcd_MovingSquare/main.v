/*

This is the controller for a LCD display 800x480 pixels resolution.
The connector is a 40 pin of VGA Layout, is controlled by a 5/6 bits of resolution each color,
a data enable signal, and a clock signal.

The LCD_CLK may be high enought for write all the pixels plus the time needed for sync. 
Could be calculated as [ (800 + h_sync_pixels) * 480 + v_sync_pixels ] * 60 Hz ~= 28MHz
In one frame needs the screen resolution and horizontal sync pixels for each line, 
plus the vertical sync pixels each frame. 
But as a standard, 33 MHz is a good clock signal, exceeding the 60Hz.

This code is a variation from, "electronicayciencia.com" with the blog post about the LCD coding
"https://www.electronicayciencia.com/2021/11/lcd_tang_nano_I_patrones.html"
*/

module main (
    input clk27M,       
    input left_but,
    input right_but,
    input up_but,
    input down_but,

    output [4:0] LCD_R,
    output [5:0] LCD_G,
    output [4:0] LCD_B,
    output LCD_CLK,
    output LCD_DEN
);

    Gowin_rPLL PLL(
        .clkout   (LCD_CLK),    // 33MHz
        .clkin    (clk27M)       // 27MHz
    );

    wire [9:0] x;   // indicate the horizontal position 
    wire [9:0] y;   // indicate the vertical position

    //Data enable signal
    wire hde;
    wire vde;       
    assign LCD_DEN = hde & vde;  // Enable when the two are enabled

    hsync hsync(
        .i_clk     (LCD_CLK),    // counter clock

        .o_hsync   (LCD_HSYNC),  // signal for the vsync module
        .o_hde     (hde),        // horizontal signal in active zone
        .o_x       (x)           // x pixel position
    );

    vsync vsync(
        .i_clk     (LCD_HSYNC),  // clk is the generated in the hsync module

        .o_vde     (vde),        // vertical signal in active zone
        .o_y       (y)           // y pixel position
    );

    square sq1(
        .i_clk     (LCD_CLK),
        .i_x       (x),
        .i_y       (y),
        .left      (left_but),
        .right     (right_but),
        .up        (up_but),
        .down      (down_but),

        .o_R       (LCD_R),
        .o_G       (LCD_G),
        .o_B       (LCD_B)

    );

endmodule