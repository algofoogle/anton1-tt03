`default_nettype none
`timescale 1ns/1ps


// This testbench just instantiates the module and makes some convenient wires
// that can be driven/tested by the cocotb test.py

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
