all: test

TOPLEVEL_LANG ?= verilog
include $(shell cocotb-config --makefiles)/Makefile.inc

export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH := test:$(PYTHONPATH)
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)

test: test_simple_480p

test_simple_480p:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s simple_480p -s dump -g2012 src/simple_480p.sv test/dump_simple_480p.v -c test/test_simple_480p.iverilog

	PYTHONOPTIMIZE=${NOASSERT} MODULE=test_simple_480p vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

clean:
	rm -rf *vcd sim_build test/__pycache__ results.xml

.PHONY: clean all test test_simple_480p 
