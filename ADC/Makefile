TARGET=adc_system_top
TOP=adc

OBJS = adc.v wait_signal.v clock_generator.v adc_system_top.v
PER_OBJS = perip_adc_system_top.v $(OBJS)

BUILD_DIR = build

all: sim

sim:
	rm -f a.out *.vcd
	iverilog $(TARGET)_TB.v $(OBJS)
	vvp a.out
	gtkwave $(TARGET)_TB.vcd

sim_per:
	rm -f a.out *.vcd
	iverilog perip_adc_system_top_TB.v $(PER_OBJS)
	vvp a.out
	gtkwave perip_adc_system_top_TB.vcd

svg: $(OBJS)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" ${OBJS}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg
	yosys -p "prep -top ${TARGET} -flatten; write_json ${TARGET}_flat.json" ${OBJS}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg

clean:
	rm -rf *.out *.vcd *.svg *.json