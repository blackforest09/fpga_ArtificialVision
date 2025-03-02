module gw_gao(
    \joystk/timer_counter[16] ,
    \joystk/timer_counter[15] ,
    \joystk/timer_counter[14] ,
    \joystk/timer_counter[13] ,
    \joystk/timer_counter[12] ,
    \joystk/timer_counter[11] ,
    \joystk/timer_counter[10] ,
    \joystk/timer_counter[9] ,
    \joystk/timer_counter[8] ,
    \joystk/timer_counter[7] ,
    \joystk/timer_counter[6] ,
    \joystk/timer_counter[5] ,
    \joystk/timer_counter[4] ,
    \joystk/timer_counter[3] ,
    \joystk/timer_counter[2] ,
    \joystk/timer_counter[1] ,
    \joystk/timer_counter[0] ,
    \joystk/timer_done ,
    \joystk/r_start_mcp ,
    \joystk/mcp/start_protocol ,
    \joystk/r_channel[2] ,
    \joystk/r_channel[1] ,
    \joystk/r_channel[0] ,
    \joystk/mcp/channel[2] ,
    \joystk/mcp/channel[1] ,
    \joystk/mcp/channel[0] ,
    \joystk/mcp/data_to_send[4] ,
    \joystk/mcp/data_to_send[3] ,
    \joystk/mcp/data_to_send[2] ,
    \joystk/mcp/data_to_send[1] ,
    \joystk/mcp/data_to_send[0] ,
    \joystk/data_ready ,
    \joystk/analog_value[9] ,
    \joystk/analog_value[8] ,
    \joystk/analog_value[7] ,
    \joystk/analog_value[6] ,
    \joystk/analog_value[5] ,
    \joystk/analog_value[4] ,
    \joystk/analog_value[3] ,
    \joystk/analog_value[2] ,
    \joystk/analog_value[1] ,
    \joystk/analog_value[0] ,
    \joystk/mcp/analog_value[9] ,
    \joystk/mcp/analog_value[8] ,
    \joystk/mcp/analog_value[7] ,
    \joystk/mcp/analog_value[6] ,
    \joystk/mcp/analog_value[5] ,
    \joystk/mcp/analog_value[4] ,
    \joystk/mcp/analog_value[3] ,
    \joystk/mcp/analog_value[2] ,
    \joystk/mcp/analog_value[1] ,
    \joystk/mcp/analog_value[0] ,
    \joystk/analog_x[9] ,
    \joystk/analog_x[8] ,
    \joystk/analog_x[7] ,
    \joystk/analog_x[6] ,
    \joystk/analog_x[5] ,
    \joystk/analog_x[4] ,
    \joystk/analog_x[3] ,
    \joystk/analog_x[2] ,
    \joystk/analog_x[1] ,
    \joystk/analog_x[0] ,
    \joystk/analog_y[9] ,
    \joystk/analog_y[8] ,
    \joystk/analog_y[7] ,
    \joystk/analog_y[6] ,
    \joystk/analog_y[5] ,
    \joystk/analog_y[4] ,
    \joystk/analog_y[3] ,
    \joystk/analog_y[2] ,
    \joystk/analog_y[1] ,
    \joystk/analog_y[0] ,
    \joystk/mcp/shift_register[9] ,
    \joystk/mcp/shift_register[8] ,
    \joystk/mcp/shift_register[7] ,
    \joystk/mcp/shift_register[6] ,
    \joystk/mcp/shift_register[5] ,
    \joystk/mcp/shift_register[4] ,
    \joystk/mcp/shift_register[3] ,
    \joystk/mcp/shift_register[2] ,
    \joystk/mcp/shift_register[1] ,
    \joystk/mcp/shift_register[0] ,
    spi_MISO,
    spi_CLK,
    spi_MOSI,
    mcp_CS,
    \joystk/clk_4MHz ,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \joystk/timer_counter[16] ;
input \joystk/timer_counter[15] ;
input \joystk/timer_counter[14] ;
input \joystk/timer_counter[13] ;
input \joystk/timer_counter[12] ;
input \joystk/timer_counter[11] ;
input \joystk/timer_counter[10] ;
input \joystk/timer_counter[9] ;
input \joystk/timer_counter[8] ;
input \joystk/timer_counter[7] ;
input \joystk/timer_counter[6] ;
input \joystk/timer_counter[5] ;
input \joystk/timer_counter[4] ;
input \joystk/timer_counter[3] ;
input \joystk/timer_counter[2] ;
input \joystk/timer_counter[1] ;
input \joystk/timer_counter[0] ;
input \joystk/timer_done ;
input \joystk/r_start_mcp ;
input \joystk/mcp/start_protocol ;
input \joystk/r_channel[2] ;
input \joystk/r_channel[1] ;
input \joystk/r_channel[0] ;
input \joystk/mcp/channel[2] ;
input \joystk/mcp/channel[1] ;
input \joystk/mcp/channel[0] ;
input \joystk/mcp/data_to_send[4] ;
input \joystk/mcp/data_to_send[3] ;
input \joystk/mcp/data_to_send[2] ;
input \joystk/mcp/data_to_send[1] ;
input \joystk/mcp/data_to_send[0] ;
input \joystk/data_ready ;
input \joystk/analog_value[9] ;
input \joystk/analog_value[8] ;
input \joystk/analog_value[7] ;
input \joystk/analog_value[6] ;
input \joystk/analog_value[5] ;
input \joystk/analog_value[4] ;
input \joystk/analog_value[3] ;
input \joystk/analog_value[2] ;
input \joystk/analog_value[1] ;
input \joystk/analog_value[0] ;
input \joystk/mcp/analog_value[9] ;
input \joystk/mcp/analog_value[8] ;
input \joystk/mcp/analog_value[7] ;
input \joystk/mcp/analog_value[6] ;
input \joystk/mcp/analog_value[5] ;
input \joystk/mcp/analog_value[4] ;
input \joystk/mcp/analog_value[3] ;
input \joystk/mcp/analog_value[2] ;
input \joystk/mcp/analog_value[1] ;
input \joystk/mcp/analog_value[0] ;
input \joystk/analog_x[9] ;
input \joystk/analog_x[8] ;
input \joystk/analog_x[7] ;
input \joystk/analog_x[6] ;
input \joystk/analog_x[5] ;
input \joystk/analog_x[4] ;
input \joystk/analog_x[3] ;
input \joystk/analog_x[2] ;
input \joystk/analog_x[1] ;
input \joystk/analog_x[0] ;
input \joystk/analog_y[9] ;
input \joystk/analog_y[8] ;
input \joystk/analog_y[7] ;
input \joystk/analog_y[6] ;
input \joystk/analog_y[5] ;
input \joystk/analog_y[4] ;
input \joystk/analog_y[3] ;
input \joystk/analog_y[2] ;
input \joystk/analog_y[1] ;
input \joystk/analog_y[0] ;
input \joystk/mcp/shift_register[9] ;
input \joystk/mcp/shift_register[8] ;
input \joystk/mcp/shift_register[7] ;
input \joystk/mcp/shift_register[6] ;
input \joystk/mcp/shift_register[5] ;
input \joystk/mcp/shift_register[4] ;
input \joystk/mcp/shift_register[3] ;
input \joystk/mcp/shift_register[2] ;
input \joystk/mcp/shift_register[1] ;
input \joystk/mcp/shift_register[0] ;
input spi_MISO;
input spi_CLK;
input spi_MOSI;
input mcp_CS;
input \joystk/clk_4MHz ;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \joystk/timer_counter[16] ;
wire \joystk/timer_counter[15] ;
wire \joystk/timer_counter[14] ;
wire \joystk/timer_counter[13] ;
wire \joystk/timer_counter[12] ;
wire \joystk/timer_counter[11] ;
wire \joystk/timer_counter[10] ;
wire \joystk/timer_counter[9] ;
wire \joystk/timer_counter[8] ;
wire \joystk/timer_counter[7] ;
wire \joystk/timer_counter[6] ;
wire \joystk/timer_counter[5] ;
wire \joystk/timer_counter[4] ;
wire \joystk/timer_counter[3] ;
wire \joystk/timer_counter[2] ;
wire \joystk/timer_counter[1] ;
wire \joystk/timer_counter[0] ;
wire \joystk/timer_done ;
wire \joystk/r_start_mcp ;
wire \joystk/mcp/start_protocol ;
wire \joystk/r_channel[2] ;
wire \joystk/r_channel[1] ;
wire \joystk/r_channel[0] ;
wire \joystk/mcp/channel[2] ;
wire \joystk/mcp/channel[1] ;
wire \joystk/mcp/channel[0] ;
wire \joystk/mcp/data_to_send[4] ;
wire \joystk/mcp/data_to_send[3] ;
wire \joystk/mcp/data_to_send[2] ;
wire \joystk/mcp/data_to_send[1] ;
wire \joystk/mcp/data_to_send[0] ;
wire \joystk/data_ready ;
wire \joystk/analog_value[9] ;
wire \joystk/analog_value[8] ;
wire \joystk/analog_value[7] ;
wire \joystk/analog_value[6] ;
wire \joystk/analog_value[5] ;
wire \joystk/analog_value[4] ;
wire \joystk/analog_value[3] ;
wire \joystk/analog_value[2] ;
wire \joystk/analog_value[1] ;
wire \joystk/analog_value[0] ;
wire \joystk/mcp/analog_value[9] ;
wire \joystk/mcp/analog_value[8] ;
wire \joystk/mcp/analog_value[7] ;
wire \joystk/mcp/analog_value[6] ;
wire \joystk/mcp/analog_value[5] ;
wire \joystk/mcp/analog_value[4] ;
wire \joystk/mcp/analog_value[3] ;
wire \joystk/mcp/analog_value[2] ;
wire \joystk/mcp/analog_value[1] ;
wire \joystk/mcp/analog_value[0] ;
wire \joystk/analog_x[9] ;
wire \joystk/analog_x[8] ;
wire \joystk/analog_x[7] ;
wire \joystk/analog_x[6] ;
wire \joystk/analog_x[5] ;
wire \joystk/analog_x[4] ;
wire \joystk/analog_x[3] ;
wire \joystk/analog_x[2] ;
wire \joystk/analog_x[1] ;
wire \joystk/analog_x[0] ;
wire \joystk/analog_y[9] ;
wire \joystk/analog_y[8] ;
wire \joystk/analog_y[7] ;
wire \joystk/analog_y[6] ;
wire \joystk/analog_y[5] ;
wire \joystk/analog_y[4] ;
wire \joystk/analog_y[3] ;
wire \joystk/analog_y[2] ;
wire \joystk/analog_y[1] ;
wire \joystk/analog_y[0] ;
wire \joystk/mcp/shift_register[9] ;
wire \joystk/mcp/shift_register[8] ;
wire \joystk/mcp/shift_register[7] ;
wire \joystk/mcp/shift_register[6] ;
wire \joystk/mcp/shift_register[5] ;
wire \joystk/mcp/shift_register[4] ;
wire \joystk/mcp/shift_register[3] ;
wire \joystk/mcp/shift_register[2] ;
wire \joystk/mcp/shift_register[1] ;
wire \joystk/mcp/shift_register[0] ;
wire spi_MISO;
wire spi_CLK;
wire spi_MOSI;
wire mcp_CS;
wire \joystk/clk_4MHz ;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(\joystk/timer_done ),
    .data_i({\joystk/timer_counter[16] ,\joystk/timer_counter[15] ,\joystk/timer_counter[14] ,\joystk/timer_counter[13] ,\joystk/timer_counter[12] ,\joystk/timer_counter[11] ,\joystk/timer_counter[10] ,\joystk/timer_counter[9] ,\joystk/timer_counter[8] ,\joystk/timer_counter[7] ,\joystk/timer_counter[6] ,\joystk/timer_counter[5] ,\joystk/timer_counter[4] ,\joystk/timer_counter[3] ,\joystk/timer_counter[2] ,\joystk/timer_counter[1] ,\joystk/timer_counter[0] ,\joystk/timer_done ,\joystk/r_start_mcp ,\joystk/mcp/start_protocol ,\joystk/r_channel[2] ,\joystk/r_channel[1] ,\joystk/r_channel[0] ,\joystk/mcp/channel[2] ,\joystk/mcp/channel[1] ,\joystk/mcp/channel[0] ,\joystk/mcp/data_to_send[4] ,\joystk/mcp/data_to_send[3] ,\joystk/mcp/data_to_send[2] ,\joystk/mcp/data_to_send[1] ,\joystk/mcp/data_to_send[0] ,\joystk/data_ready ,\joystk/analog_value[9] ,\joystk/analog_value[8] ,\joystk/analog_value[7] ,\joystk/analog_value[6] ,\joystk/analog_value[5] ,\joystk/analog_value[4] ,\joystk/analog_value[3] ,\joystk/analog_value[2] ,\joystk/analog_value[1] ,\joystk/analog_value[0] ,\joystk/mcp/analog_value[9] ,\joystk/mcp/analog_value[8] ,\joystk/mcp/analog_value[7] ,\joystk/mcp/analog_value[6] ,\joystk/mcp/analog_value[5] ,\joystk/mcp/analog_value[4] ,\joystk/mcp/analog_value[3] ,\joystk/mcp/analog_value[2] ,\joystk/mcp/analog_value[1] ,\joystk/mcp/analog_value[0] ,\joystk/analog_x[9] ,\joystk/analog_x[8] ,\joystk/analog_x[7] ,\joystk/analog_x[6] ,\joystk/analog_x[5] ,\joystk/analog_x[4] ,\joystk/analog_x[3] ,\joystk/analog_x[2] ,\joystk/analog_x[1] ,\joystk/analog_x[0] ,\joystk/analog_y[9] ,\joystk/analog_y[8] ,\joystk/analog_y[7] ,\joystk/analog_y[6] ,\joystk/analog_y[5] ,\joystk/analog_y[4] ,\joystk/analog_y[3] ,\joystk/analog_y[2] ,\joystk/analog_y[1] ,\joystk/analog_y[0] ,\joystk/mcp/shift_register[9] ,\joystk/mcp/shift_register[8] ,\joystk/mcp/shift_register[7] ,\joystk/mcp/shift_register[6] ,\joystk/mcp/shift_register[5] ,\joystk/mcp/shift_register[4] ,\joystk/mcp/shift_register[3] ,\joystk/mcp/shift_register[2] ,\joystk/mcp/shift_register[1] ,\joystk/mcp/shift_register[0] ,spi_MISO,spi_CLK,spi_MOSI,mcp_CS}),
    .clk_i(\joystk/clk_4MHz )
);

endmodule
