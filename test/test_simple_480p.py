import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout


HORIZONTAL_LAST_ACTIVE_POSITION = 639
HORIZONTAL_SYNC_START = HORIZONTAL_LAST_ACTIVE_POSITION + 16
HORIZONTAL_SYNC_END = HORIZONTAL_SYNC_START + 96
HORIZONTAL_LAST_POSITION   = 799           # last pixel on line (after back porch)

VERTICAL_LAST_ACTIVE_POSITION = 479
VERTICAL_SYNC_START = VERTICAL_LAST_ACTIVE_POSITION + 10
VERTICAL_SYNC_END = VERTICAL_SYNC_START + 2
VERTICAL_LAST_POSITION = 524

@cocotb.test()
async def test_max_active_positions(dut):

    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    dut.rst_pix.value = 1
    await RisingEdge(dut.clk_pix)

    dut.rst_pix.value = 0
    await RisingEdge(dut.clk_pix)
    await RisingEdge(dut.clk_pix)

    highest_horizontal_position = -1
    highest_vertical_position = -1

    while dut.vsync.value.integer == 1: # active low
        highest_horizontal_position = max(dut.sx.value.integer, highest_horizontal_position)
        highest_vertical_position = max(dut.sy.value.integer, highest_vertical_position)
        await RisingEdge(dut.clk_pix)

    
    while dut.vsync.value.integer == 0: # vsyc
        highest_horizontal_position = max(dut.sx.value.integer, highest_horizontal_position)
        highest_vertical_position = max(dut.sy.value.integer, highest_vertical_position)
        await RisingEdge(dut.clk_pix)

    while dut.de.value.integer == 0: # vertical back porch
        highest_horizontal_position = max(dut.sx.value.integer, highest_horizontal_position)
        highest_vertical_position = max(dut.sy.value.integer, highest_vertical_position)
        await RisingEdge(dut.clk_pix)

    assert highest_horizontal_position == HORIZONTAL_LAST_POSITION
    assert highest_vertical_position == VERTICAL_LAST_POSITION



@cocotb.test()
async def test_simple_480p(dut):


    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    dut.rst_pix.value = 1
    await ClockCycles(dut.clk_pix, 1)

    dut.rst_pix.value = 0
    await ClockCycles(dut.clk_pix, 1)
    

    await ClockCycles(dut.clk_pix, 639 +15)
    assert dut.hsync == 1

    await ClockCycles(dut.clk_pix,1)
    assert dut.hsync == 0


