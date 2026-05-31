module uart_rx(
    input clk,
    input reset,
    input baud_tick,
    input rx,

    output reg [7:0] rx_data,
    output reg rx_done
);

reg [3:0] bit_index;
reg [7:0] data_reg;

reg [1:0] state;

parameter IDLE  = 2'b00;
parameter DATA  = 2'b01;
parameter STOP  = 2'b10;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state <= IDLE;
        rx_done <= 0;
        bit_index <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            rx_done <= 0;
            if(rx == 0 && baud_tick) // Sync with baud generator
            begin
                bit_index <= 0;
                state <= DATA;
            end
        end

        DATA:
        begin
            if(baud_tick)
            begin
                data_reg[bit_index] <= rx;

                if(bit_index == 7)
                    state <= STOP;
                else
                    bit_index <= bit_index + 1;
            end
        end

        STOP:
        begin
            if(baud_tick)
            begin
                rx_data <= data_reg;
                rx_done <= 1;
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule