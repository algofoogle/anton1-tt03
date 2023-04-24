import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


def product_of_nibbles(value):
    return (value>>4) * (value&15)


@cocotb.test()
async def test_plus_minus(dut):
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

    # Now clock in some 8-bit values, as pairs of nibbles (high first, then low):
    feed = [169, 168, 167, 166]
    for i in feed:
        dut.read.value = 0
        # Clock in one value as 2 nibbles:
        hi_nibble = i >> 4
        lo_nibble = i & 15
        dut.nibble.value = hi_nibble
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.nibble.value = lo_nibble
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        # Make sure our current value is what we're seeing on the outputs:
        result = int(dut.result.value)
        assert result == i
        # Now get the product of the 2 nibbles:
        dut.read.value = 1
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        result = int(dut.result.value)
        assert result == hi_nibble * lo_nibble

    # Now prove that if we keep 'read' high, we continue to modify the product:
    dut.read.value = 1
    for i in range(5):
        result = int(dut.result.value)
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        assert product_of_nibbles(result) == int(dut.result.value)
