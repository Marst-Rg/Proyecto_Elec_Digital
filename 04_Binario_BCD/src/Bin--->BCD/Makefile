TARGET= double
TOP= A_reg

OBJS =  A_reg.v \
	check.v \
	sum.v \
	contador.v \
	control_double.v \
	double.v

PER_OBJS = perip_double.v $(OBJS)

BUILD_DIR = build

all: sim

sim:
	rm -f a.out *.vcd
	iverilog -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 \
	$(TARGET)_TB.v $(OBJS)
	vvp a.out
	gtkwave $(TARGET)_TB.vcd

sim_per:
	rm -f a.out *.vcd
	iverilog -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 \
	perip_$(TARGET)_TB.v $(PER_OBJS)
	vvp a.out
	gtkwave perip_$(TARGET)_TB.vcd

svg: $(OBJS)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" ${OBJS}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg  
	yosys -p "prep -top ${TARGET} -flatten; write_json ${TARGET}_flat.json" ${OBJS}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg  

clean:
	rm -rf *.out *.vcd *.svg *.json
