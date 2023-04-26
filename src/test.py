import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


OP_NIBBLES = 3


async def send_nibble(dut, value):
    dut.nibble.value = value
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

async def send_operand(dut, value):
    for i in range(OP_NIBBLES):
        await send_nibble(dut, (value >> ((OP_NIBBLES-1)*4))&0xF)
        value <<= 4

async def get_product(dut):
    word = 0
    for i in range(OP_NIBBLES): #NOTE: This gets a BYTE at a time (i.e. product width is sum of 2 operand widths).
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
        # Tests that fit in 1 nibble (4-bit operands):
        [
            [    0,     0],
            [    0,     1],
            [    1,     0],
            [    1,     1],
            [    1,     2],
            [    2,     3],
            [    9,     3],
            [    3,     9],
            [   15,    14],
            [   13,    12],
            [   12,     9],
            [   10,     5],
            [   10,    10],
            [   11,    11],
        ],
        # Tests that fit in 2 nibbles (8-bit operands):
        [
            [  123,   234],
            [  255,   255],
            [    0,   189],
            [   88,   111],
        ],
        # Tests that fit in 3 nibbles (12-bit operands):
        [
            [    0,  4095],
            [ 4095,     0],
            [ 4095,     1],
            [    1,  4095],
            [ 4095,  4095],
            [ 1234,  3210],
            [   25,  3456],
            [  167,   256],
            [  256,  1024],
        ],
    ]

    n = 0
    for batch in data:
        n += 1
        if n > OP_NIBBLES: break
        dut._log.info("Testing {}-nibble operands".format(n))
        for pair in batch:
            a = pair[0]
            b = pair[1]
            await send_operand(dut, a)
            await send_operand(dut, b)
            p = await get_product(dut)
            dut._log.info("Product {a:9d} * {b:9d} => {p:9d}".format(a=a, b=b, p=p))
            assert p == a*b, "Expected {ab:08x} but got {p:08x}".format(ab=a*b, p=p)
