import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_plus_minus(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 100, units="us") # 10kHz clock.
    cocotb.start_soon(clock.start())

    dut.read = 0

    # Assert reset for 10 clocks:
    dut._log.info("reset")
    dut.reset.value = 1
    await ClockCycles(dut.clk, 10)
    dut.reset.value = 0

    # Try feeding a sequence of 110, 109, 108, 107,
    # which should accumulate 110-109+108-107 = 2
    # First, 110, which gets added to accumulator's 0:
    feed = [110, 109, 108, 107]
    for value in feed:
        dut.nibble.value = value & 15   # Low nibble first.
        await ClockCycles(dut.clk, 1)
        dut.nibble.value = value >> 4   # Then high nibble.
        await ClockCycles(dut.clk, 1)
    # Now try to read the result:
    dut.read.value = 1
    await ClockCycles(dut.clk, 2)
    # Check it matches what we expect:
    result = int(dut.result.value)
    assert result == 2, "Expected result to be {} but got {}".format(2, result)







    # dut._log.info("check all segments")
    # for i in range(10):
    #     dut._log.info("check segment {}".format(i))
    #     await ClockCycles(dut.clk, 1000)
    #     assert int(dut.segments.value) == segments[i]
