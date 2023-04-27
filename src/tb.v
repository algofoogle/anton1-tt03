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

// This testbench just instantiates the module and makes some convenient wires
// that can be driven/tested by the cocotb test.py

`default_nettype none
`timescale 1ns/1ps

module tb (
    // Testbench is controlled by test.py
    input clk,
    input reset,
    input [3:0] nibble,
    output [7:0] result
);

    // This part dumps the trace to a .vcd file that can be viewed with GTKWave:
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // Wire up the inputs and outputs to our respective test signals:
    wire [7:0] inputs = {nibble, 2'b0, reset, clk};
    wire [7:0] outputs;
    assign result = outputs;

    // Instantiate the DUT (Device Under Test):
    algofoogle_product algofoogle_product(
        `ifdef GL_TEST
            .vccd1( 1'b1),
            .vssd1( 1'b0),
        `endif
        .io_in  (inputs),
        .io_out (outputs)
    );

endmodule
