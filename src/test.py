import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


async def send_nibble(dut, value):
    dut.nibble.value = value
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

@cocotb.test()
async def test_product(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 100, units="us") # 10kHz clock.
    cocotb.start_soon(clock.start())

    dut.read.value = 0

    # Assert reset for 10 clocks:
    dut._log.info("reset")
    dut.reset.value = 1
    await ClockCycles(dut.clk, 10)
    dut.reset.value = 0

    # Advance to the next falling edge of the clock:
    await FallingEdge(dut.clk)

    # Make sure reset has cleared our accumulator:
    assert dut.result.value == 0

    # Make sure clocking in nibbles shifts things as expected
    # and reveals the accumulator on our `result` output:
    dut.read.value = 0
    await send_nibble(dut, 0b1101) # 13
    assert dut.result.value == 0b0000_1101
    await send_nibble(dut, 0b0110) # 6
    assert dut.result.value == 0b1101_0110
    await send_nibble(dut, 0b1011) # 11
    assert dut.result.value == 0b0110_1011

    # Make sure `read` signal causes product(s) to be calculated:
    dut.read.value = 1
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.result.value == 0b0100_0010 # 66, product of 6 and 11.
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.result.value == 0b0000_1000 # 8, product of 4 and 2.
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.result.value == 0b0000_0000 # 0, product of 0 and 8.


