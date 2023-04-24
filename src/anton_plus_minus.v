`default_nettype none

//  *   Simple design that accepts 8-bit numbers (one nibble at a time).
//  *   First 8-bit input clocked in via 2 nibbles will be added to a 24-bit accumulator.
//  *   Next 8-bit input is subtracted from the accumulator.
//  *   Subsequent inputs follow this same add/subtract order.
//  *   While READ is NOT asserted, output the product of the lowest 2 nibbles in the accumulator.
//  *   While READ IS asserted, shift accumulator out 8 bits at a time to the outputs (little-endian).
//      Nibble load and arithmetic operation are suspended during READ.
module anton_plus_minus (
    input   [7:0]   io_in,
    output  [7:0]   io_out
);
    wire        clk    = io_in[0];
    wire        reset  = io_in[1];
    wire        read   = io_in[2];
    wire [3:0]  nibble = io_in[7:4];

    reg [7:0]   result;
    assign io_out = result;

    reg [3:0]   lower_nibble;
    reg [23:0]  accumulator;
    wire [3:0]  a           = accumulator[7:4];
    wire [3:0]  b           = accumulator[3:0];
    wire [7:0]  product     = {4'b0,a} * {4'b0,b};

    // Re state:
    // - Upper bit: 0 = add mode; 1 = subtract mode.
    // - Lower bit: 0 = loading lower nibble; 1 = loading upper nibble; perform arithmetic.
    reg [1:0] state;

    always @(posedge clk) begin
        if (reset) begin
            accumulator <= 0;
            state <= 0;
            lower_nibble <= 0;
            result <= 0;
        end else begin
            if (read) begin
                result = accumulator[7:0];
                accumulator <= accumulator >> 8;
            end else begin
                result <= product;
                if (state[0] == 0) begin
                    // Loading lower nibble.
                    lower_nibble <= nibble;
                end else begin
                    // Loading upper nibble; ready for arithmetic operation.
                    if (state[1] == 0) begin
                        // Add mode.
                        accumulator <= accumulator + {nibble, lower_nibble};
                    end else begin
                        // Subtract mode.
                        accumulator <= accumulator - {nibble, lower_nibble};
                    end
                end
                state <= state + 1;
            end
        end
    end

endmodule

