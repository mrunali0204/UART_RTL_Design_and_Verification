module uart_top(
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,

    output tx,
    output [7:0] rx_data,
    output rx_done
);

wire baud_tick;
wire tx_line;

baud_gen bg(
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick)
);

uart_tx tx_unit(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .baud_tick(baud_tick),
    .tx_data(tx_data),
    .tx(tx_line),
    .tx_busy()
);

uart_rx rx_unit(
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick),
    .rx(tx_line),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

assign tx = tx_line;

endmodule