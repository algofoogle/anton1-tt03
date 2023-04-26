`default_nettype none

module algofoogle_product (
    input   [7:0]   io_in,
    output  [7:0]   io_out
);
    localparam OP_NIBBLES = 3; // This determines both the size of the input, and the product output.
    localparam OP_BITS = OP_NIBBLES*4;
    localparam MUL_BITS = (OP_BITS*2);

    wire        clk    = io_in[0];
    wire        reset  = io_in[1];
    wire [3:0]  nibble = io_in[7:4];

    reg [3:0]   state;  //SMELL: This should be sized to fit actual number of required states (based on OP_NIBBLES).

    reg [MUL_BITS-1:0]  product;

    assign io_out = product[MUL_BITS-1:MUL_BITS-8];

    always @(posedge clk) begin
        if (reset) begin
            // Reset.
            product <= 0;
            state <= 0;
        end else begin
            if (state < OP_NIBBLES*2) begin
                // We're clocking in nibbles for each of our two operands:
                product <= {product[MUL_BITS-4-1:0],nibble};
            end else if (state == OP_NIBBLES*2) begin
                // We've got the data we need; now calculate the product:
                // product <= { {OP_BITS{1'b0}}, product[OP_BITS-1:0] } * { {OP_BITS{1'b0}}, product[MUL_BITS-1:OP_BITS] };
                product <= { product[OP_BITS-1:0] } * { product[MUL_BITS-1:OP_BITS] };
            end else begin
                // Start clocking out the result, as 2 bytes.
                product <= product << 8;
            end
            state <= (state==OP_NIBBLES*3-1) ? 0 : state+1;
        end
    end

endmodule
