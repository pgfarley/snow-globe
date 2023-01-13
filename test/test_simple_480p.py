import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout

@cocotb.test()
async def test_simple_480p(dut):


    clock = Clock(dut.clk_pix, 1, units="us")
    cocotb.start_soon(clock.start())
    
    dut.rst_pix = 1
    await ClockCycles(dut.clk_pix, 1)

    dut.rst_pix = 0
    await ClockCycles(dut.clk_pix, 1)
    

    await ClockCycles(dut.clk_pix, 639 +15)
    assert dut.hsync == 1

    await ClockCycles(dut.clk_pix,1)
    assert dut.hsync == 0


