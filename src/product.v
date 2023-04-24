`default_nettype none

module algofoogle_product (
    input   [7:0]   io_in,
    output  [7:0]   io_out
);
    wire        clk    = io_in[0];
    wire        reset  = io_in[1];
    wire [3:0]  nibble = io_in[7:4];

    reg [3:0]   state;

    reg [31:0]  product;

    assign io_out = product[31:24];

    always @(posedge clk) begin
        if (reset) begin
            // Reset.
            product <= 0;
            state <= 0;
        end else begin
            if (state < 8) begin
                // We're clocking in 8 nibbles (2 16-bit values):
                product <= {product[27:0],nibble};
            end else if (state == 8) begin
                // We've got the data we need; now calculate the product:
                product <= {16'b0,product[15:0]} * {16'b0,product[31:16]};
            end else begin
                // Start clocking out the result, as 4 bytes.
                product <= product << 8;
            end
            state <= (state==11) ? 0 : state+1;
        end
    end

endmodule
