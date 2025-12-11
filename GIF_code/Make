TARGET = led_panel_gif
TOP    = led_panel_gif

# Celdas de simulación para Ice40
ICE40_SIM_CELLS=$(shell yosys-config --datdir/ice40/cells_sim.v)

# Archivos comunes del proyecto
COMM_OBJS += count.v 
COMM_OBJS += ctrl_lp4k.v
COMM_OBJS += comp.v
COMM_OBJS += lsr_led.v
COMM_OBJS += mux_led.v
COMM_OBJS += gif_controller.v
COMM_OBJS += memory_gif.v
COMM_OBJS += led_panel_gif.v

BUILD_DIR = build

# Script TCL para Gowin
TCL_SCRIPT = auto_generated.tcl
GOWIN_BOARD ?= primer_25k

# Configuración del dispositivo según la tarjeta
ifeq ($(GOWIN_BOARD),nano_20k)
    DEVICE = GW2AR-LV18QN88C8/I7
    FAMILY = GW2AR-18C
else ifeq ($(GOWIN_BOARD),primer_25k)
    DEVICE = GW5A-LV25MG121NC1/I0
    FAMILY = GW5A-25A
else
    $(error GOWIN_BOARD=$(GOWIN_BOARD) no válido. Usa: nano_20k o primer_25k)
endif

.PHONY: all sim clean help convert_gif check_hex_files clean_all clean_gowin
.PHONY: lattice configure_lattice configure_icebreaker
.PHONY: configure_tang_nano_20k configure_tang_primer_25k

all: help

help:
	@echo "=== LED Panel GIF Project ==="
	@echo "Comandos disponibles:"
	@echo ""
	@echo "Simulación:"
	@echo "  make sim                    - Simular el diseño"
	@echo "  make sim_post_syn           - Simulación post-síntesis"
	@echo ""
	@echo "Conversión de datos:"
	@echo "  make convert_gif GIF=<file> - Convertir GIF a archivos HEX"
	@echo ""
	@echo "Síntesis y configuración:"
	@echo "  make lattice                - Sintetizar para Lattice ECP5"
	@echo "  make configure_lattice      - Programar Lattice ECP5"
	@echo "  make configure_icebreaker   - Programar iCEBreaker"
	@echo "  make configure_tang_nano_20k    - Programar Tang Nano 20K"
	@echo "  make configure_tang_primer_25k  - Programar Tang Primer 25K"
	@echo ""
	@echo "Limpieza:"
	@echo "  make clean                  - Limpiar archivos generados"
	@echo "  make clean_all              - Limpiar todo (incluye HEX)"
	@echo ""
	@echo "Antes de simular, asegúrate de tener los archivos:"
	@echo "  frame0_image0.hex, frame0_image1.hex"
	@echo "  frame1_image0.hex, frame1_image1.hex"
	@echo "  frame2_image0.hex, frame2_image1.hex"
	@echo "  frame3_image0.hex, frame3_image1.hex"

########################################################
##                 CONVERSIÓN GIF                     ##
########################################################

convert_gif:
	@if [ -z "$(GIF)" ]; then \
		echo "Error: Especifica el archivo GIF"; \
		echo "Uso: make convert_gif GIF=tu_animacion.gif"; \
		exit 1; \
	fi
	python3 gif_to_hex.py $(GIF) 4

check_hex_files:
	@echo "Verificando archivos HEX..."
	@for i in 0 1 2 3; do \
		if [ ! -f "frame$${i}_image0.hex" ] || [ ! -f "frame$${i}_image1.hex" ]; then \
			echo "Error: Faltan archivos frame$${i}_image0.hex o frame$${i}_image1.hex"; \
			echo "Ejecuta: make convert_gif GIF=tu_animacion.gif"; \
			exit 1; \
		fi \
	done
	@echo "✓ Todos los archivos HEX están presentes"

########################################################
##                   SIMULACIÓN                       ##
########################################################

sim: check_hex_files
	@echo "=== Compilando simulación ==="
	rm -f a.out *.vcd sim.out
	iverilog -DBENCH -o sim.out $(TARGET)_TB.v $(COMM_OBJS)
	@echo "=== Ejecutando simulación ==="
	vvp sim.out
	@echo "=== Abriendo GTKWave ==="
	gtkwave $(TARGET)_TB.vcd

sim_post_syn: $(TOP).json check_hex_files
	@echo "=== Simulación post-síntesis ==="
	iverilog -g2012 -DSYNTH -o sim_post_syn.vpp -s $(TOP)_TB $(TARGET)_TB.v $(TOP)_synth.v $(ICE40_SIM_CELLS)
	vvp sim_post_syn.vpp
	gtkwave $(TOP)_TB.vcd &

########################################################
##            SÍNTESIS LATTICE ECP5                   ##
########################################################

$(TARGET).json: $(COMM_OBJS) check_hex_files
	@mkdir -p $(BUILD_DIR)
	@echo "=== Sintetizando con Yosys ==="
	yosys -v3 -l synth.log -p "synth_ecp5 -top $(TOP); write_json $(BUILD_DIR)/$(TARGET).json" \
		$(COMM_OBJS) -l $(BUILD_DIR)/$(TARGET).rpt

$(TARGET)_out.config: $(TARGET).json
	@echo "=== Place & Route con nextpnr-ecp5 ==="
	nextpnr-ecp5 --json $(BUILD_DIR)/$(TARGET).json \
		--lpf $(TARGET).lpf \
		--textcfg $(BUILD_DIR)/$(TARGET)_out.config \
		--25k --package CABGA256 --speed 6 \
		--timing-allow-fail --seed 1 \
		--lpf-allow-unconstrained \
		--log $(BUILD_DIR)/$(TARGET)_pnr.log

$(TARGET).bit: $(TARGET)_out.config
	@echo "=== Generando bitstream ==="
	ecppack --bootaddr 0 --compress \
		$(BUILD_DIR)/$(TARGET)_out.config \
		--svf $(BUILD_DIR)/$(TARGET).svf \
		--bit $(BUILD_DIR)/$(TARGET).bit

lattice: $(TARGET).bit
	@echo "✓ Bitstream generado: $(BUILD_DIR)/$(TARGET).bit"

configure_lattice: $(TARGET).bit
	@echo "=== Programando Lattice ECP5 ==="
	sudo openFPGALoader -c ft232RL --pins=TXD:CTS:DTR:RXD -m $(BUILD_DIR)/$(TARGET).bit

########################################################
##              SÍNTESIS ICEBREAKER                   ##
########################################################

configure_icebreaker: check_hex_files
	@echo "=== Sintetizando para iCEBreaker ==="
	yosys -l icebreaker.rpt -p 'verilog_defaults -push; verilog_defaults -add -defer; \
		read_verilog $(COMM_OBJS); verilog_defaults -pop; \
		attrmap -tocase keep -imap keep="true" keep=1 -imap keep="false" keep=0 -remove keep=0; \
		synth_ice40 -dsp -top $(TOP); write_json $(TOP).json'
	@echo "=== Place & Route para iCEBreaker ==="
	nextpnr-ice40 --json $(TOP).json --pcf led_panel_icebreaker.pcf \
		--asc icebreaker.asc --up5k --package sg48 \
		--timing-allow-fail --seed 1 --pcf-allow-unconstrained
	@echo "=== Generando bitstream ==="
	icepack -s icebreaker.asc icebreaker.bin
	@echo "=== Programando iCEBreaker ==="
	iceprog -d i:0x0403:0x6010 icebreaker.bin

########################################################
##                GOWIN TANG NANO/PRIMER              ##
########################################################

del_tcl_script:
	rm -rf $(TCL_SCRIPT)

$(TCL_SCRIPT): del_tcl_script
	@echo "=== Generando script TCL para Gowin ==="
	@echo "# Script TCL generado automáticamente desde Makefile" > $@
	@echo "# Fecha: $$(date)" >> $@
	@echo "" >> $@
	@echo "# Configurar dispositivo" >> $@
	@echo "set_device -name $(FAMILY) $(DEVICE)" >> $@
	@echo "" >> $@
ifeq ($(GOWIN_BOARD),nano_20k)
	@echo "add_file sipeed_tang_nano_20k.cst" >> $@
	@echo "add_file sipeed_tang_nano_20k.sdc" >> $@
else ifeq ($(GOWIN_BOARD),primer_25k)
	@echo "add_file sipeed_tang_primer_25k.cst" >> $@
	@echo "add_file sipeed_tang_primer_25k.sdc" >> $@
endif
	@echo "# Agregar archivos fuente" >> $@
	@for file in $(COMM_OBJS); do \
		echo "add_file -type verilog $$file" >> $@; \
	done
	@echo "" >> $@
	@echo "# Configurar opciones del proyecto" >> $@
	@echo "set_option -use_mspi_as_gpio 1" >> $@
ifeq ($(GOWIN_BOARD),nano_20k)
	@echo "set_option -use_sspi_as_gpio 1" >> $@
else ifeq ($(GOWIN_BOARD),primer_25k)
	@echo "set_option -use_i2c_as_gpio 1" >> $@
	@echo "set_option -use_cpu_as_gpio 1" >> $@
endif
	@echo "set_option -use_ready_as_gpio 1" >> $@
	@echo "set_option -use_done_as_gpio 1" >> $@
	@echo "set_option -rw_check_on_ram 1" >> $@
	@echo "run all" >> $@

configure_tang_nano_20k: clean_gowin $(TCL_SCRIPT) check_hex_files
	@echo "=== Compilando para Tang Nano 20K ==="
	gw_sh $(TCL_SCRIPT)
	@echo "=== Programando Tang Nano 20K ==="
	openFPGALoader --cable ft2232 --bitstream ./impl/pnr/project.fs

configure_tang_primer_25k: clean_gowin $(TCL_SCRIPT) check_hex_files
	@echo "=== Compilando para Tang Primer 25K ==="
	gw_sh $(TCL_SCRIPT)
	@echo "=== Programando Tang Primer 25K ==="
	openFPGALoader --cable ft2232 --bitstream ./impl/pnr/project.fs

clean_gowin:
	rm -rf impl

########################################################
##                    LIMPIEZA                        ##
########################################################

clean:
	rm -rf *.out *.vcd *.svg *.json *.vpp *.asc *_route.v
	rm -rf synth.log *.rpt *.bin build/ *.bit impl/
	rm -rf $(TCL_SCRIPT) icebreaker.asc icebreaker.bin
	@echo "✓ Limpieza completada"

clean_all: clean
	rm -f frame*_image*.hex
	@echo "✓ Limpieza completa (incluyendo archivos HEX)"