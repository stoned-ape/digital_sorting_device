INC=/usr/local/Cellar/icarus-verilog/10.2_1/include/iverilog/

all: sym main.vpi


main.vpi: main.c makefile
	iverilog-vpi main.c

sym: main.v makefile
	iverilog -o sym -g2012 -Wall main.v

run: sym main.vpi
	vvp -M. -mmain sym

preprocess:
	clang -E main.c -I $(PATH)

a.out: main.c
	clang main.c -I $(PATH)
