import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout


@cocotb.test()
async def test_max_active_positions(dut):

    H_LAST_POSITION = dut.H_ACTIVE.value \
    + dut.H_FRONT_PORCH.value \
    + dut.H_SYNC_PULSE.value \
    + dut.H_BACK_PORCH.value - 1

    V_LAST_POSITION = dut.V_ACTIVE.value \
    + dut.V_FRONT_PORCH.value \
    + dut.V_SYNC_PULSE.value \
    + dut.V_BACK_PORCH.value - 1


    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    dut.rst_pix.value = 1
    await RisingEdge(dut.clk_pix)

    dut.rst_pix.value = 0
    await RisingEdge(dut.clk_pix)
    await RisingEdge(dut.clk_pix)

    highest_horizontal_position = -1
    highest_vertical_position = -1

    while dut.vsync.value.integer == 1: # active low: Not yet vsync
        highest_horizontal_position = max(dut.sx.value.integer, highest_horizontal_position)
        highest_vertical_position = max(dut.sy.value.integer, highest_vertical_position)
        await RisingEdge(dut.clk_pix)

    
    while dut.vsync.value.integer == 0: # active low: vsync
        highest_horizontal_position = max(dut.sx.value.integer, highest_horizontal_position)
        highest_vertical_position = max(dut.sy.value.integer, highest_vertical_position)
        await RisingEdge(dut.clk_pix)

    while dut.de.value.integer == 0: # vertical back porch
        highest_horizontal_position = max(dut.sx.value.integer, highest_horizontal_position)
        highest_vertical_position = max(dut.sy.value.integer, highest_vertical_position)
        await RisingEdge(dut.clk_pix)

    assert highest_horizontal_position == H_LAST_POSITION
    assert highest_vertical_position == V_LAST_POSITION



@cocotb.test()
async def test_hsync(dut):


    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    dut.rst_pix.value = 1
    await ClockCycles(dut.clk_pix, 1)

    dut.rst_pix.value = 0
    await ClockCycles(dut.clk_pix, 1)
    assert dut.hsync.value == 1

    while dut.hsync.value == 1:
        await ClockCycles(dut.clk_pix, 1)

    assert dut.hsync.value.integer == 0
    assert dut.sx.value.integer == dut.H_ACTIVE.value + dut.H_FRONT_PORCH.value - 1

    while dut.hsync.value == 0:
        await ClockCycles(dut.clk_pix, 1)

    assert dut.hsync.value.integer == 1
    assert dut.sx.value.integer == dut.H_ACTIVE.value + dut.H_FRONT_PORCH.value + dut.H_SYNC_PULSE.value - 1
