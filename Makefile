SIM=sim
SRC=src/*.v
WAVE = waves.vcd
TB=tb/testbench.v

all: run

$(SIM): $(SRC) $(TB)
	iverilog -o $(SIM) $(SRC) $(TB)

run: $(SIM)
	vvp $(SIM)

wave: $(SIM)
	vvp $(SIM)
	gtkwave $(WAVE)

clean:
	rm -f $(SIM) $(WAVE)
