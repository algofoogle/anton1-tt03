import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


async def send_nibble(dut, value):
    dut.nibble.value = value
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

async def send_byte(dut, value):
    for i in range(2):
        await send_nibble(dut, (value & 0xF0) >> 4)
        value <<= 4

async def get_word(dut):
    word = 0
    for i in range(2):
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        word <<= 8
        word |= int(dut.result.value)
    return word

@cocotb.test()
async def test_product(dut):
    dut._log.info("Starting clock...")
    clock = Clock(dut.clk, 100, units="us") # 10kHz clock.
    cocotb.start_soon(clock.start())

    # Assert reset for 10 clocks:
    dut._log.info("Assert reset")
    dut.reset.value = 1
    await ClockCycles(dut.clk, 10)
    dut.reset.value = 0

    # Advance to the next falling edge of the clock:
    await FallingEdge(dut.clk)

    # Make sure reset has cleared our accumulator:
    assert dut.result.value == 0

    # Test multiplies
    data = [
        [10,10],
        [123,234],
        [255,255],
        [0,189],
        [88,111]
    ]

    for pair in data:
        a = pair[0]
        b = pair[1]
        await send_byte(dut, a)
        await send_byte(dut, b)
        p = await get_word(dut)
        dut._log.info("Product {a:09d}*{b:09d}:".format(a=a, b=b))
        assert p == a*b, "Expected {ab:08x} but got {p:08x}".format(ab=a*b, p=p)
