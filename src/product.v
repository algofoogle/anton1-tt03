// SPDX-FileCopyrightText: 2023 Anton Maurovic <anton@maurovic.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// This is the main source for a Tiny Tapeout 3 submission, that
// implements a simple multiplier. It gets nibbles clocked in
// (configurable via `OP_NIBBLES`), for each of two operands, and
// then the product can be clocked out as bytes.

`default_nettype none
`timescale 1ns/1ps

module algofoogle_product (
    input   [7:0]   io_in,
    output  [7:0]   io_out
);
    localparam OP_NIBBLES = 2; // Determines size of the input, and product output.
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
                product <= product[OP_BITS-1:0] * product[MUL_BITS-1:OP_BITS];
            end else begin
                // Clocking out the result, as bytes.
                product[MUL_BITS-1:8] <= product[MUL_BITS-9:0];
            end
            state <= (state==OP_NIBBLES*3-1) ? 0 : state+1;
        end
    end

endmodule
