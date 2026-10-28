# Avisos que quedan en la corrida final (asic/rom/runs/final/warning.log)

Revisión aviso por aviso de la corrida final nueva (D23: RTL del pipeline más el modelo de cable
del resizer). El `warning.log` tiene 58 líneas, de las que 30 son el mismo aviso repetido de
OpenSTA al cargar los liberty. Para comparar: la corrida final de v1 tenía 51 líneas
(`asic/rom/resultados/v1_final/warning.log`) y su revisión está en
`asic/rom/resultados/v1_final/avisos.md`.

**Lo único que cambió en la lista de avisos distintos respecto de v1 es que desapareció
`Max Slew violations found in the following corners:`**: la corrida nueva tiene 0 violaciones de
max slew en las nueve esquinas (`design__max_slew_violation__count = 0` en `metrics.json`,
`max slew violation count 0` en `max_ss_125C_4v50_checks.rpt`), contra 546 en v1. Ningún aviso
nuevo apareció. Los números de paso sí cambian: la configuración de D23 agrega
`OpenROAD.RepairDesignPostGRT` (paso 41) y `OpenROAD.ResizerTimingPostGRT` (paso 44), así que todo
lo que viene después se corre dos lugares (el STA final pasa de 55 a 57,
`checkantennas-1` de 46 a 48, el informe de caída de tensión de 56 a 58, `magic-writelef` de 60 a
62 y el chequeo de antenas del LEF de 61 a 63).

## 1. `Cell 'asic_top' has (3) input pin(s) without antenna gate information. They might not be connected to a gate.`

- Paso: `63-odb-checkdesignantennaproperties` (revisa el LEF del macro escrito por Magic,
  `62-magic-writelef/asic_top.lef`).
- Evidencia: en ese LEF, los pines de entrada `spi_sclk`, `spi_mosi` y `spi_cs_n` no tienen
  `ANTENNAGATEAREA`, mientras que `btn[0]`, `rst_n` y `clk` sí lo tienen. En el netlist final
  (`final/nl/asic_top.nl.v`) cada uno de esos tres puertos aparece solo en la lista de puertos y en
  su declaración `input`: ninguna celda los lee. El STA final lo dice por su lado:
  `report_parasitic_annotation` informa `Found 81 unannotated drivers` y los tres primeros de la
  lista son `spi_cs_n`, `spi_mosi` y `spi_sclk`
  (`nom_tt_025C_5v00_checks.rpt`).
- Causa: el juego no usa el SPI y `pochoco_spi_slave` no se instancia (D7); `pochoco_soc.v` deja
  las tres entradas en un `wire _unused_spi` que la síntesis elimina. Un pin que no llega a ninguna
  compuerta no tiene área de compuerta que informar, y el aviso lo dice ("might not be connected to
  a gate").
- Efecto: ninguno en el macro. Si se integrara en un chip, el integrador no tendría datos de antena
  para esos tres pines, que de todos modos no tienen compuerta que dañar. `spi_miso` es salida fija
  en 1 (`tieh`) y sí tiene `ANTENNADIFFAREA`.
- **No cambia con D23**: es el mismo aviso de v1, por la misma causa.

## 2. `[RSZ-0020] found 2 floating nets.`

- Paso: `32-openroad-repairdesignpostgpl` (`repair_design` del resizer). Los dos nets son `VDD` y
  `VSS`.
- Causa: en el netlist lógico los nets de alimentación no tienen celda que los maneje; los conecta
  la red de distribución de potencia (`21-openroad-generatepdn`) y los pines de alimentación de las
  celdas se conectan por nombre (`16-odb-setpowerconnections`). El chequeo de nets flotantes del
  resizer mira drivers lógicos, así que los reporta.
- Efecto: ninguno. LVS limpio (`design__lvs_error__count = 0`) y la verificación de la grilla de
  potencia sin violaciones (`design__power_grid_violation__count = 0`) confirman que VDD y VSS están
  conectados.
- **No cambia con D23.** Importante: el aviso aparece una sola vez aunque ahora el flujo corra
  `repair_design` dos veces (paso 32 y paso 41): el del post-GRT no lo repite.

## 3. `'VSRC_LOC_FILES' was not given a value, which may make the results of IR drop analysis inaccurate...`

- Paso: `58-openroad-irdropreport` (`analyze_power_grid`).
- Causa: `VSRC_LOC_FILES` da la posición de los puntos por donde entra la alimentación (los pads o
  bumps de un chip completo). Sin ese dato OpenROAD supone fuentes en el borde de la grilla, lo que
  subestima la caída real. Este diseño es un macro sin pads, así que el dato no existe: es el caso
  que el propio aviso dice que se puede ignorar.
- Resultado igual: caída máxima **0,611 mV en VDD** y **0,219 mV en VSS**, con una potencia total de
  **9,620 mW** a 10 MHz en la esquina típica
  (`58-openroad-irdropreport/openroad-irdropreport.log`), frente a 5 V de alimentación: 0,01 por
  ciento. Irrelevante aun con un error grande.
- **Cambia respecto de v1**: la caída de VDD pasa de 0,148 a 0,611 mV y la potencia sin actividad de
  8,971 a 9,620 mW (+7,2 por ciento), porque el diseño nuevo tiene más celdas y más buffers. Sigue
  siendo 0,01 por ciento de los 5 V.

## 4. `Max Cap violations found in the following corners:` (las nueve)

- Paso: `Checker.MaxCapViolations` sobre el STA final (paso 57).
- **Es un solo pin, el mismo en las nueve esquinas: `clkbuf_0_clk/Z`**, la raíz del árbol de reloj
  (un `clkbuf_16` que `OpenROAD.CTS` insertó por `CTS_ROOT_BUFFER`). Maneja 0,428234 pF contra un
  límite de 0,2 pF, es decir un slack de -0,228234 pF en `max_ss_125C_4v50` (0,401561 pF y
  -0,201561 en `nom_tt_025C_5v00`). Archivos: `max_ss_125C_4v50_checks.rpt` y
  `nom_tt_025C_5v00_checks.rpt`, sección `max capacitance`.
- Causa y análisis completo, con la respuesta a si se puede quitar sin costo: `docs/datos_informe.md`
  sección 3.6. En corto: el límite de 0,2 pF es `MAX_CAPACITANCE_CONSTRAINT`, una restricción que
  pone LibreLane a todos los pines del diseño, no el límite de la celda, que en el liberty de la
  esquina lenta es **3,93 pF** para el pin Z del `clkbuf_16`; la celda maneja nueve veces menos de
  lo que puede. Y `repair_design` no toca la red de reloj, así que ni el repair del placement ni el
  del post-GRT la pueden arreglar.
- **Cambia respecto de v1**: eran 36 pines con violación de capacitancia y ahora es 1, el único que
  el repair no puede tocar.

## 5. Avisos del flujo que no son del diseño

- `12 Lint warnings found.` (Verilator, paso `01-verilator-lint`): 4 `UNUSEDPARAM`, 7
  `UNUSEDSIGNAL` y 1 `WIDTHEXPAND`, todos señales y parámetros declarados a propósito (`_unused`,
  los parámetros de la ALU que la variante no usa) y un ancho de constante. En v1 eran 11: el aviso
  nuevo, comparando las dos listas, es
  `espino_id_stage.v:59:22: Signal is not used: 'rst_ni'`. Es correcto y vale decirlo: con la
  lectura anticipada, los registros del decode y las salidas registradas del banco no tienen reset
  (salen en X tras el reset), y todo lo que los consume está condicionado a `instr_valid_i`, que es
  0 el primer ciclo. Eso es lo que verifica el monitor de valores desconocidos usados: 0 en 620.217
  escrituras al banco del juego completo (`docs/verificacion/integracion.md`). Lista completa en
  `01-verilator-lint/verilator-lint.log`.
- `'PNR_SDC_FILE' is not defined` y `'SIGNOFF_SDC_FILE' is not defined`: el flujo usa su SDC
  genérico, que es lo que el proyecto quiere (el reloj y las restricciones las fija la
  configuración, no un SDC a mano). Igual que en v1.
- `[STA-1140] ... library ... already exists` (30 líneas): OpenSTA carga cada liberty una vez por
  esquina y avisa cuando se repite el nombre. No afecta el análisis.
- `LEF57_ENCLOSURE with no CUTCLASS is not supported. Skipping for layer Via<n>` (8 líneas): el
  tech LEF del PDK trae reglas de encierro de vía en un formato que OpenROAD no interpreta; las
  salta y el DRC de Magic y el de KLayout, que sí las aplican, salen en 0.
- `KLAYOUT_DRC_RUNSET is unset. KLayout.DRC may not be supported for the gf180mcuD PDK.`, con
  `klayout__drc_error__count not reported` y `The KLayout DRC errors metric was not found`: el PDK
  de ciel no trae el deck de KLayout, así que el paso del flujo se salta. El segundo DRC se corre
  aparte con el deck de GlobalFoundries (`asic/drc_klayout.sh`, origen en `asic/drc/ORIGEN.md`), con
  su control positivo. Resultado en `drc_klayout/resumen.md` y `drc_klayout/control_positivo.md`.
- `Threshold for Threshold-surpassing long wires is not set. The checker will be skipped.`: no se
  fijó un largo máximo de cable para ese chequeo; el largo del cable más largo se informa igual en
  `metrics.json` (`route__wirelength__max`).

## 6. Avisos que aparecen en otras corridas y no en esta

- `[RSZ-0062] Unable to repair all setup violations`: aparece en las corridas de período chico
  (`f2_*` bajas), donde el resizer no alcanza el margen de 10 ns de
  `PL_RESIZER_SETUP_SLACK_MARGIN` (D20). El cierre real lo da el STA final de las nueve esquinas, no
  ese aviso. A 100 ns no aparece.
- `Max Slew violations found`: ya no aparece en la corrida final, y es el cambio que trae D23.
