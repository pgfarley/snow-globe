import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout


async def reset(dut):
    dut.rst_pix.value =  1
    await RisingEdge(dut.clk_pix)

    dut.rst_pix.value = 0
    await RisingEdge(dut.clk_pix)

    await RisingEdge(dut.clk_pix)

def is_hsync(dut) -> bool:
    return  dut.hsync.value.integer == 0 # active low: vsync

def is_vsync(dut) -> bool:
    return  dut.vsync.value.integer == 0 # active low: vsync

def is_visible(dut) -> bool:
    return dut.de.value.integer == 1


@cocotb.test()
async def test_max_active_positions(dut):

    expected_max_horizontal_position = dut.H_ACTIVE.value \
    + dut.H_FRONT_PORCH.value \
    + dut.H_SYNC_PULSE.value \
    + dut.H_BACK_PORCH.value - 1

    expected_max_vertical_position = dut.V_ACTIVE.value \
    + dut.V_FRONT_PORCH.value \
    + dut.V_SYNC_PULSE.value \
    + dut.V_BACK_PORCH.value - 1


    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())

    await reset(dut)

    actual_max_horizontal_position = -1
    actual_max_vertical_position = -1
    one_vsync_seen = False

    while not (one_vsync_seen and is_visible(dut)):
        one_vsync_seen = one_vsync_seen or is_vsync(dut)
        actual_max_horizontal_position = max(dut.sx.value.integer, actual_max_horizontal_position)
        actual_max_vertical_position = max(dut.sy.value.integer, actual_max_vertical_position)
        await RisingEdge(dut.clk_pix)

    assert expected_max_horizontal_position == actual_max_horizontal_position
    assert expected_max_vertical_position == actual_max_vertical_position



@cocotb.test()
async def test_hsync(dut):

    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    await reset(dut)

    await FallingEdge(dut.hsync)
    assert dut.sx.value.integer == dut.H_ACTIVE.value + dut.H_FRONT_PORCH.value - 1

    await RisingEdge(dut.hsync)
    assert dut.sx.value.integer == dut.H_ACTIVE.value + dut.H_FRONT_PORCH.value + dut.H_SYNC_PULSE.value - 1


@cocotb.test()
async def test_vsync(dut):

    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    await reset(dut)

    await FallingEdge(dut.vsync)
    assert dut.sy.value.integer == dut.V_ACTIVE.value + dut.V_FRONT_PORCH.value - 1

    await RisingEdge(dut.vsync)
    assert dut.sy.value.integer == dut.V_ACTIVE.value + dut.V_FRONT_PORCH.value + dut.V_SYNC_PULSE.value - 1


@cocotb.test()
async def test_display_enabled(dut):

    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    await reset(dut)

    await FallingEdge(dut.de)
    assert dut.sx.value.integer == dut.H_ACTIVE.value 
    assert dut.sy.value.integer == 0

    for _i in range(0, dut.V_ACTIVE.value - 1):
        await FallingEdge(dut.de)

    assert dut.sx.value.integer == dut.H_ACTIVE.value
    assert dut.sy.value.integer == dut.V_ACTIVE.value - 1

    await RisingEdge(dut.de)
    assert dut.sx.value.integer == 0
    assert dut.sy.value.integer == 0
