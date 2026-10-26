# Avisos que quedan en la corrida final (asic/rom/runs/final/warning.log)

Los tres avisos que siguen apareciendo en la corrida final, con la evidencia de cada uno.

## 1. `Cell 'asic_top' has (3) input pin(s) without antenna gate information. They might not be connected to a gate.`

- Paso: `61-odb-checkdesignantennaproperties` (revisa el LEF del macro escrito por Magic, `60-magic-writelef/asic_top.lef`).
- Evidencia: en ese LEF, los pines de entrada `spi_sclk`, `spi_mosi` y `spi_cs_n` no tienen `ANTENNAGATEAREA`, mientras que `btn[0]` (1,102 µm²), `rst_n` (1,102 µm²) y `clk` (4,738 µm²) sí lo tienen. En el netlist final (`final/nl/asic_top.nl.v`) cada uno de esos tres puertos aparece solo en la lista de puertos y en su declaración `input`: ninguna celda los lee.
- Causa: el juego no usa el SPI y `pochoco_spi_slave` no se instancia (D7); `pochoco_soc.v` deja las tres entradas en un `wire _unused_spi` que la síntesis elimina. Un pin que no llega a ninguna compuerta no tiene área de compuerta que informar, y el aviso lo dice ("might not be connected to a gate").
- Efecto: ninguno en el macro. Si el macro se integrara en un chip, el integrador no tendría datos de antena para esos tres pines, que de todos modos no tienen compuerta que dañar. `spi_miso` es salida fija en 1 (`tieh`) y sí tiene `ANTENNADIFFAREA`.

## 2. `[RSZ-0020] found 2 floating nets.`

- Paso: `32-openroad-repairdesignpostgpl` (`repair_design` del resizer), log líneas 52 a 54: los dos nets son `VDD` y `VSS`.
- Causa: en el netlist lógico los nets de alimentación no tienen celda que los maneje (ningún pin de salida los alimenta); los conecta la red de distribución de potencia (`21-openroad-generatepdn`) y los pines de alimentación de las celdas se conectan por nombre (`16-odb-setpowerconnections`). El chequeo de nets flotantes del resizer mira drivers lógicos, así que los reporta.
- Efecto: ninguno; LVS limpio (`design__lvs_error__count = 0`) y la verificación de la grilla de potencia sin violaciones (`design__power_grid_violation__count = 0`) confirman que VDD y VSS están conectados.

## 3. `'VSRC_LOC_FILES' was not given a value, which may make the results of IR drop analysis inaccurate. If you are not integrating a top-level chip for manufacture, you may ignore this warning`

- Paso: `56-openroad-irdropreport` (análisis de caída de tensión con `analyze_power_grid`).
- Causa: `VSRC_LOC_FILES` da la posición de los puntos por donde entra la alimentación (los pads o bumps de un chip completo). Sin ese dato OpenROAD supone fuentes en el borde de la grilla, lo que subestima la caída real de un chip. Este diseño es un macro sin pads, así que el dato no existe: es el caso que el propio aviso dice que se puede ignorar.
- Resultado del análisis igual: caída máxima 0,148 mV en VDD y 0,248 mV en VSS (`irdrop.rpt`), con un consumo total estimado de 35 mW a 10 MHz (`power__total`), frente a 5 V de alimentación: irrelevante aun con un error grande.

## Otros avisos del log

- `11 Lint warnings found.` (Verilator): señales sin uso declaradas a propósito (`_unused`), ancho de constantes y similares; la lista está en `01-verilator-lint/verilator-lint.log`.
- `[STA-1140] ... library ... already exists`: OpenSTA carga cada liberty una vez por esquina y avisa cuando se repite el nombre; no afecta el análisis.
- `KLAYOUT_DRC_RUNSET is unset. KLayout.DRC may not be supported for the gf180mcuD PDK.`: el PDK de ciel no trae las reglas del deck de KLayout; el segundo DRC se corrió aparte con el deck de GlobalFoundries (`asic/drc_klayout.sh`, `asic/drc/ORIGEN.md`).
- `[RSZ-0062] Unable to repair all setup violations` (solo en las corridas a período chico): el resizer no alcanza el margen de 10 ns de `PL_RESIZER_SETUP_SLACK_MARGIN` (D20); el cierre real lo da el STA final de 9 esquinas.
- `Max Slew violations found` y `Max Cap violations found`: las violaciones de transición y capacitancia de `checks.rpt`, informadas en `asic/sintesis.md` y en el experimento B1.
