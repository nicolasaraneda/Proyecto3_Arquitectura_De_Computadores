# Copyright 2026 Universidad de los Andes.
# Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
# you may not use this file except in compliance with the License.
# SPDX-License-Identifier: SHL-0.51
#
# Course: Arquitectura de Computadores (2026)
#
# Authors:
# - Nicolás Villegas <navillegas@miuandes.cl>

# RTL Sources
# rtl/gen/ no entra en SRC: la ROM generada depende del programa, y cada
# simulación usa la de su propio programa (build/<programa>/pochoco_rom.v).
SRC  := $(wildcard ./rtl/*.v ./rtl/espino_core/*.v)

# Firmware. En el ASIC no hay $readmemh: el programa entra al RTL como
# código Verilog que el assembler genera desde sw/game.s (sección 3.2):
#   rtl/gen/pochoco_rom.v   la ROM combinacional de la estrategia 1 (--rom)
#   rtl/gen/game_image.vh   la imagen que usa la estrategia 2 como valor de
#                           reset de la memoria en flip-flops (--vh)
# Están versionados para que LibreLane los encuentre sin correr make;
# `make image` los regenera después de cambiar game.s. sw/game.hex se sigue
# generando con `make asm`, pero el RTL ya no lo lee.
ASMSRC := sw/game.s
HEX    := sw/game.hex
IMAGE  := rtl/gen/game_image.vh
ROM    := rtl/gen/pochoco_rom.v

# Our own assembler (no external RISC-V toolchain is ever invoked -- see
# docs/assembler.md section 1). Listing its sources as prerequisites means
# a fix in the assembler also regenerates the firmware.
PYTHON ?= python3
ASM    := assembler/asm.py
ASMDEP := $(wildcard assembler/*.py)

# Simulación
#
# Cada programa simulado tiene su propia ROM e imagen en build/<programa>/:
# la ROM se compila junto al RTL y la imagen se toma con -I. Las imágenes del juego salen del MISMO sw/game.s con
# constantes pisadas desde la línea de comandos (opción -D del assembler), no
# de una copia del programa que se pueda desincronizar del original.
#
#   build/game_sim       CYCLES_PER_TENTH=2500  -- décima 1000x más corta,
#                        para que las diez rondas corran en segundos de
#                        simulación en vez de minutos.
#   build/game_sim_r4    además RONDAS=4        -- regresión del bug del
#                        divisor: el promedio se calcula con una división
#                        genérica por RONDAS, no con un /10 clavado.
#   build/buttons_leds   sw/buttons_leds.s, para tb/game_top_tb.v.
IVERILOG ?= iverilog
VVP      ?= vvp
BUILD    := build

SIM_CPT    := 2500
SIM_RONDAS := 4
IMG_SIM    := $(BUILD)/game_sim/game_image.vh
IMG_SIM_R4 := $(BUILD)/game_sim_r4/game_image.vh
IMG_BTN    := $(BUILD)/buttons_leds/game_image.vh

.PHONY: all image asm asm-all test sim sim1 sim2 check equiv clean post-synth sim-netlist post-synth-final final layout

# Default target: todo lo verificable sin LibreLane (el flujo de la FPGA se
# eliminó en el Proyecto 3; ver docs/decisiones.md, D5)
all: image check

# Step 0: Assemble. Esta es la unión de los dos frentes: sw/*.s se escribe
# a mano, assembler/ lo traduce, y el resto del flujo hornea el resultado
# en el bitstream. `make asm` regenera solo el firmware del juego, que es
# lo que uno quiere tras cambiar un .equ.
#
# La regla es genérica para que `make asm-all` pueda regenerar TODOS los
# .hex de sw/ con el assembler del grupo. Antes había un sw/Makefile que
# llamaba a riscv64-unknown-elf-as; su regla "%.hex: %.s" también alcanzaba
# a game.s, o sea que un `make` dentro de sw/ habría regenerado el firmware
# del juego con la herramienta que el enunciado prohíbe.
sw/%.hex: sw/%.s $(ASMDEP)
	$(PYTHON) $(ASM) $< -o $@

asm: $(HEX)

ASM_ALL := $(patsubst sw/%.s,sw/%.hex,$(wildcard sw/*.s))

asm-all: $(ASM_ALL)

# ROM e imagen del programa para el RTL del ASIC (versionadas). Se
# regeneran siempre: el assembler tarda milisegundos, y así las dos salidas
# nunca quedan de programas distintos.
image:
	@mkdir -p $(BUILD)
	$(PYTHON) $(ASM) $(ASMSRC) -o $(BUILD)/game.hex --vh $(IMAGE) --rom $(ROM)

# Imágenes de simulación.
$(IMG_SIM): $(ASMSRC) $(ASMDEP)
	@mkdir -p $(dir $@)
	$(PYTHON) $(ASM) $< -o $(dir $@)game.hex --vh $@ --rom $(dir $@)pochoco_rom.v -D CYCLES_PER_TENTH=$(SIM_CPT)

$(IMG_SIM_R4): $(ASMSRC) $(ASMDEP)
	@mkdir -p $(dir $@)
	$(PYTHON) $(ASM) $< -o $(dir $@)game.hex --vh $@ --rom $(dir $@)pochoco_rom.v -D CYCLES_PER_TENTH=$(SIM_CPT) -D RONDAS=$(SIM_RONDAS)

$(IMG_BTN): sw/buttons_leds.s $(ASMDEP)
	@mkdir -p $(dir $@)
	$(PYTHON) $(ASM) $< -o $(dir $@)buttons_leds.hex --vh $@ --rom $(dir $@)pochoco_rom.v

# Assembler test suite (77 tests: golden .hex comparisons and the Verilog image)
test:
	cd assembler && $(PYTHON) -m unittest discover -s tests -t .

# Simulación: los dos testbenches más una tercera corrida del testbench del
# juego con RONDAS=4, para cada estrategia de memoria (sim1: ROM + RAM de
# datos, sim2: unificada en flip-flops). La tercera corrida es la regresión
# del divisor: el tiempo de reacción inyectado es el mismo (12 décimas), así
# que el promedio tiene que seguir dando 12. Con un div10 fijo daría 48/10 = 4.
#
# Los testbenches llaman a $fatal si algún check falla, así que vvp devuelve
# un código de salida distinto de cero y make se detiene.
define run_sims
	$(IVERILOG) -g2012 -DMEM_STRATEGY=$(1) -I $(BUILD)/buttons_leds \
	            -o $(BUILD)/game_top_tb_m$(1) tb/game_top_tb.v $(SRC) $(BUILD)/buttons_leds/pochoco_rom.v
	$(VVP) $(BUILD)/game_top_tb_m$(1)
	$(IVERILOG) -g2012 -DMEM_STRATEGY=$(1) -I $(BUILD)/game_sim \
	            -o $(BUILD)/game_tb_m$(1) tb/game_tb.v $(SRC) $(BUILD)/game_sim/pochoco_rom.v
	$(VVP) $(BUILD)/game_tb_m$(1)
	$(IVERILOG) -g2012 -DMEM_STRATEGY=$(1) -I $(BUILD)/game_sim_r4 \
	            -DPROGRAMA=\"game.s,CYCLES_PER_TENTH=$(SIM_CPT),RONDAS=$(SIM_RONDAS)\" -DRONDAS_N=$(SIM_RONDAS) \
	            -o $(BUILD)/game_tb_r$(SIM_RONDAS)_m$(1) tb/game_tb.v $(SRC) $(BUILD)/game_sim_r4/pochoco_rom.v
	$(VVP) $(BUILD)/game_tb_r$(SIM_RONDAS)_m$(1)
endef

sim1: $(IMG_SIM) $(IMG_SIM_R4) $(IMG_BTN)
	$(call run_sims,1)

sim2: $(IMG_SIM) $(IMG_SIM_R4) $(IMG_BTN)
	$(call run_sims,2)

sim: sim1 sim2

# Equivalencia del core con una versión anterior del RTL (Proyecto 3, D18).
# Corre sw/isa_test.s, que ejecuta todas las instrucciones que soporta el
# assembler, con el RTL actual y con el del commit REF, para las dos
# estrategias de memoria, y compara las trazas de tb/core_trace_tb.v
# (escrituras al banco de registros, accesos al bus de datos y salidas, con
# su ciclo). Si son idénticas, el cambio no alteró el comportamiento.
REF ?= 116fa20
IMG_ISA := $(BUILD)/isa_test/game_image.vh
# MODO=ciclo (por defecto): las trazas deben ser idénticas ciclo a ciclo.
# MODO=funcional: se comparan las secuencias de eventos sin el número de ciclo
# (misma secuencia de escrituras al banco, accesos al bus y salidas), para
# variantes que cambian los ciclos por instrucción (experimento B4). En ambos
# modos se imprime el CPI de cada versión.
MODO ?= ciclo

$(IMG_ISA): sw/isa_test.s $(ASMDEP)
	@mkdir -p $(dir $@)
	$(PYTHON) $(ASM) $< -o $(dir $@)isa_test.hex --vh $@ --rom $(dir $@)pochoco_rom.v

equiv: $(IMG_ISA)
	rm -rf $(BUILD)/ref && git worktree prune
	git worktree add --detach $(BUILD)/ref $(REF)
	@for m in 1 2; do \
	  for v in ref act; do \
	    if [ $$v = ref ]; then d=$(BUILD)/ref; else d=.; fi; \
	    $(IVERILOG) -g2012 -DMEM_STRATEGY=$$m -DTRAZA=\"$(BUILD)/traza_$${v}_m$$m.txt\" \
	      -I $(BUILD)/isa_test -o $(BUILD)/core_trace_$${v}_m$$m tb/core_trace_tb.v \
	      $$d/rtl/*.v $$d/rtl/espino_core/*.v $(BUILD)/isa_test/pochoco_rom.v || exit 1; \
	    $(VVP) $(BUILD)/core_trace_$${v}_m$$m | grep "CPI" | sed "s/^/equiv ($$v, estrategia $$m): /" || exit 1; \
	  done; \
	  if [ "$(MODO)" = funcional ]; then \
	    cut -d" " -f2- $(BUILD)/traza_ref_m$$m.txt > $(BUILD)/traza_ref_m$${m}_f.txt; \
	    cut -d" " -f2- $(BUILD)/traza_act_m$$m.txt > $(BUILD)/traza_act_m$${m}_f.txt; \
	    a=$(BUILD)/traza_ref_m$${m}_f.txt; b=$(BUILD)/traza_act_m$${m}_f.txt; que="secuencias de eventos identicas (sin ciclos)"; \
	  else \
	    a=$(BUILD)/traza_ref_m$$m.txt; b=$(BUILD)/traza_act_m$$m.txt; que="trazas identicas ciclo a ciclo"; \
	  fi; \
	  if cmp -s $$a $$b; then \
	    echo "equiv: estrategia $$m, $$que ($$(wc -l < $$b) eventos) entre $(REF) y el RTL actual"; \
	  else \
	    echo "equiv: estrategia $$m, las trazas DIFIEREN ($(MODO)):"; \
	    diff $$a $$b | head -20; exit 1; \
	  fi; \
	done
	git worktree remove --force $(BUILD)/ref

$(BUILD):
	mkdir -p $(BUILD)

# Simulación post-síntesis (Proyecto 3, sección 3.7).
#
# El mismo testbench (tb/post_synth_tb.v, solo puertos de asic_top) y el mismo
# archivo de estímulos (asic/sim/estimulos.txt, generado por
# asic/sim/calibrar.py corriendo el RTL por etapas) se aplican al RTL y al
# netlist de celdas estándar, y las dos trazas tienen que ser idénticas.
#
# Configuración común a las dos simulaciones (documentada en asic/sim/README.md):
#   - game.s ensamblado con -D CYCLES_PER_TENTH=1: una "décima" es un ciclo,
#     así que el display muestra directamente los ciclos medidos (saturados
#     en 99) y las esperas de 30, 12 y 10 décimas duran decenas de ciclos;
#   - DebounceDivBits=2 (tick cada 4 ciclos; un botón se acepta en ~12 ciclos),
#     por SYNTH_PARAMETERS en el netlist y por parámetro en el RTL.
# El netlist sale de LibreLane hasta Yosys.Synthesis con asic/sim/config.yaml,
# que se genera desde la configuración final (asic/sim/generar_config.py) y
# solo cambia la ROM y ese parámetro.
PDK_ROOT ?= $(HOME)/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee
PDK      ?= gf180mcuD
SCL      := gf180mcu_fd_sc_mcu7t5v0
CELDAS_V := $(PDK_ROOT)/$(PDK)/libs.ref/$(SCL)/verilog/primitives.v \
            $(PDK_ROOT)/$(PDK)/libs.ref/$(SCL)/verilog/$(SCL).v
LIBRELANE ?= $(HOME)/herramientas/librelane/bin/librelane --dockerized --pdk $(PDK)
SIM_DIVBITS := 2
PS          := $(BUILD)/post_synth
ROM_SIM     := asic/sim/gen/pochoco_rom.v
NETLIST_SIM := asic/sim/runs/sim_rom/06-yosys-synthesis/asic_top.nl.v
EST         := asic/sim/estimulos.txt
PS_CICLOS   := 4500

$(ROM_SIM): $(ASMSRC) $(ASMDEP)
	@mkdir -p asic/sim/gen $(PS)
	$(PYTHON) $(ASM) $< -o $(PS)/game_sim1.hex --vh asic/sim/gen/game_image.vh --rom $@ -D CYCLES_PER_TENTH=1

asic/sim/config.yaml: asic/rom/config.yaml asic/sim/generar_config.py
	$(PYTHON) asic/sim/generar_config.py --div-bits $(SIM_DIVBITS)

# Síntesis del netlist de simulación (necesita Docker; ~1 minuto).
$(NETLIST_SIM): asic/sim/config.yaml $(ROM_SIM) $(SRC)
	$(LIBRELANE) asic/sim/config.yaml --run-tag sim_rom --overwrite --to Yosys.Synthesis

sim-netlist: $(NETLIST_SIM)

# Regenera los estímulos corriendo el RTL por etapas (solo si cambia el
# programa o el escenario; el archivo está versionado).
$(EST): asic/sim/calibrar.py tb/post_synth_tb.v $(ROM_SIM)
	$(PYTHON) asic/sim/calibrar.py --salida $@

post-synth: $(ROM_SIM) $(NETLIST_SIM) $(EST)
	@mkdir -p $(PS)
	$(IVERILOG) -g2012 -I asic/sim/gen -DESTIMULOS=\"$(EST)\" -DTRAZA=\"$(PS)/traza_rtl.txt\" \
	            -DCICLOS=$(PS_CICLOS) -DDIV_BITS=$(SIM_DIVBITS) \
	            -o $(PS)/tb_rtl tb/post_synth_tb.v $(SRC) $(ROM_SIM)
	$(VVP) $(PS)/tb_rtl
	$(IVERILOG) -g2012 -DNETLIST -DFUNCTIONAL -DESTIMULOS=\"$(EST)\" -DTRAZA=\"$(PS)/traza_netlist.txt\" \
	            -DCICLOS=$(PS_CICLOS) \
	            -o $(PS)/tb_netlist tb/post_synth_tb.v $(NETLIST_SIM) $(CELDAS_V)
	$(VVP) $(PS)/tb_netlist
	$(PYTHON) asic/sim/comparar.py $(PS)/traza_rtl.txt $(PS)/traza_netlist.txt --md asic/sim/resultado.md

# Extra: el netlist de la corrida final (constantes reales del juego) debe
# llegar a la pantalla de inicio igual que el RTL con la ROM real. Sin
# estímulos, 5000 ciclos: la pantalla de inicio aparece en los primeros
# ciclos y después el programa espera una pulsación. El RTL usa
# DebounceDivBits=15 (el valor real) para que las dos simulaciones sean
# el mismo circuito.
NETLIST_FINAL ?= asic/rom/runs/final/final/nl/asic_top.nl.v
post-synth-final: $(NETLIST_FINAL)
	@mkdir -p $(PS)
	printf '# sin estimulos: solo reset y pantalla de inicio\n' > $(PS)/sin_estimulos.txt
	$(IVERILOG) -g2012 -I rtl/gen -DESTIMULOS=\"$(PS)/sin_estimulos.txt\" -DTRAZA=\"$(PS)/traza_rtl_final.txt\" \
	            -DCICLOS=5000 -DDIV_BITS=15 -o $(PS)/tb_rtl_final tb/post_synth_tb.v $(SRC) rtl/gen/pochoco_rom.v
	$(VVP) $(PS)/tb_rtl_final
	$(IVERILOG) -g2012 -DNETLIST -DFUNCTIONAL -DESTIMULOS=\"$(PS)/sin_estimulos.txt\" -DTRAZA=\"$(PS)/traza_netlist_final.txt\" \
	            -DCICLOS=5000 -o $(PS)/tb_netlist_final tb/post_synth_tb.v $(NETLIST_FINAL) $(CELDAS_V)
	$(VVP) $(PS)/tb_netlist_final
	$(PYTHON) asic/sim/comparar.py $(PS)/traza_rtl_final.txt $(PS)/traza_netlist_final.txt --md asic/sim/resultado_final.md

# Todo lo verificable de una: los tests del assembler y los testbenches.
check: test sim

# Corrida final del ASIC (sección 2) y todo lo que depende de ella: criterios
# de cierre, tablas, síntesis jerárquica, figuras del layout, segundo DRC,
# simulación post-síntesis y versiones. Ver asic/final.sh. Necesita Docker.
final:
	bash asic/final.sh

# Figuras anotadas del layout de una corrida (KLayout en la imagen de Docker):
#   make layout RUN=asic/rom/runs/final
RUN ?= asic/rom/runs/final
layout:
	bash asic/layout/anotar.sh $(RUN)

# Clean up generated files.
#
# $(IMAGE), $(ROM) y $(HEX) NO se borran: están versionados. Las imágenes de
# simulación viven en build/.
clean:
	rm -f *.vcd
	rm -rf $(BUILD)
