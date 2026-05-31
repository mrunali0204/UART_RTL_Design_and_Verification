module uart_tx(
    input clk,
    input reset,
    input tx_start,
    input baud_tick,
    input [7:0] tx_data,

    output reg tx,
    output reg tx_busy
);

reg [7:0] data_reg;
reg [3:0] bit_index;

reg [1:0] state;

parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state <= IDLE;
        tx <= 1'b1;
        tx_busy <= 0;
        bit_index <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            tx <= 1'b1;
            tx_busy <= 0;

            if(tx_start)
            begin
                data_reg <= tx_data;
                tx_busy <= 1;
                state <= START;
            end
        end

        START:
        begin
            if(baud_tick)
            begin
                tx <= 0;
                bit_index <= 0;
                state <= DATA;
            end
        end

        DATA:
        begin
            if(baud_tick)
            begin
                tx <= data_reg[bit_index];

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
                tx <= 1;
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule