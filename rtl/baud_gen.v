module baud_gen(
    input clk,
    input reset,
    output reg baud_tick
);

parameter DIVISOR = 10;

reg [12:0] counter;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        counter <= 0;
        baud_tick <= 0;
    end
    else
    begin
        if(counter == DIVISOR-1)
        begin
            counter <= 0;
            baud_tick <= 1;
        end
        else
        begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end
end

endmodule