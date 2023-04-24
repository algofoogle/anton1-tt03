`default_nettype none

module algofoogle_product (
    input   [7:0]   io_in,
    output  [7:0]   io_out
);
    wire        clk    = io_in[0];
    wire        reset  = io_in[1];
    wire        read   = io_in[2];
    wire [3:0]  nibble = io_in[7:4];

    reg [7:0]   result;
    assign io_out = result;

    always @(posedge clk) begin
        if (reset) begin
            // Reset.
            result <= 0;
        end else if (read) begin
            // Read; don't clock in any more data,
            // and instead set our result to the product of
            // the high and low nibbles:
            result <= {4'b0,result[7:4]} * {4'b0,result[3:0]};
        end else begin
            // Clock in a new nibble:
            result <= {result[3:0], nibble};
        end
    end

endmodule

