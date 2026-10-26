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

.PHONY: all image asm asm-all test sim sim1 sim2 check clean

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

$(BUILD):
	mkdir -p $(BUILD)

# Todo lo verificable de una: los tests del assembler y los testbenches.
check: test sim

# Clean up generated files.
#
# $(IMAGE), $(ROM) y $(HEX) NO se borran: están versionados. Las imágenes de
# simulación viven en build/.
clean:
	rm -f *.vcd
	rm -rf $(BUILD)
