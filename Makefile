export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH := test:$(PYTHONPATH)
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)

all: test
test: test_simple_480p

test_simple_480p:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s simple_480p -s dump -g2012 src/simple_480p.sv test/dump_simple_480p.v -Psimple_480p.H_ACTIVE=16 -Psimple_480p.H_FRONT_PORCH=1 -Psimple_480p.H_SYNC_PULSE=4 -Psimple_480p.H_BACK_PORCH=3 -Psimple_480p.V_ACTIVE=16 -Psimple_480p.V_FRONT_PORCH=1 -Psimple_480p.V_SYNC_PULSE=4 -Psimple_480p.V_BACK_PORCH=3
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test_simple_480p vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

clean:
	rm -rf *vcd sim_build test/__pycache__

.PHONY: clean
