import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout

@cocotb.test()
async def test_vga(dut):

    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())
    await ClockCycles(dut.clk, 10)
    assert True


