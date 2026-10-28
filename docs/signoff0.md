# Frente C (rama exp/signoff0): cero violaciones de max slew y de max capacitancia

Objetivo: llevar a cero las violaciones de max slew (`design__max_slew_violation__count`) y de
max capacitancia (`design__max_cap_violation__count`) de la corrida a 100 ns solo con
configuración del flujo (LibreLane 3.0.16), sin pasar de 1 % de área de celdas estándar sobre
la base y sin empeorar el período mínimo. Ninguna de las dos es criterio de cierre del enunciado
(el cierre es DRC, LVS, antenas y setup y hold en las 9 esquinas, `asic/verificar_cierre.py`);
son chequeos de calidad de señal (`set_max_transition 3 ns` y `set_max_capacitance 0,2 pF` de la
SDC genérica, `docs/hechos_flujo.md`, sección 1).

RTL y configuración de partida: main 50f8a39 más B2 (offset de byte registrado en la LSU) y B5
(banco de registros con latches `latq_1` y clock gating `icgtp_1`), igual que exp/fmax en su
commit 210b6a7; `asic/rom/config.yaml` con D15, D20, D21 y `LINTER_ERROR_ON_LATCH: false`.
Referencia a 100 ns: main 546 slew / 36 cap (182.265 µm²); B5 solo 312 / 2 (165.369 µm²).

Todas las corridas de este documento están en `asic/barrido_exp.md` (tabla de
`asic/recolectar.py`) y en `asic/rom/resultados/<tag>/` (`metrics.json`, `cierre.md`,
`pines.md`, reportes). Tags `sc_*` y `sc2_*`, 24 corridas.

Resumen del resultado, para no leer el documento completo: la causa es el modelo de cable del
resizer (sección 1) y corregirlo con `LAYERS_RC` cuesta del 4 al 8 % de área de celdas estándar, muy
por encima del 1 % que se fijó el frente, así que **cero violaciones no cabe en el límite de área**.
La configuración recomendada sin ese límite (`LAYERS_RC` más repair post-GRT al 30 % más
`RUN_POST_GRT_RESIZER_TIMING=true`, sección 6b) deja **0 pines de slew en las 9 esquinas y 1 de
capacidad** (la raíz del árbol de reloj) con **+8,15 % de área** a 100 ns, y además **mejora el
período mínimo**: cierra a 22,5 ns contra 23,5 ns de la base. Dentro del 1 % lo mejor es 214 pines
contra 327, y solo en la corrida de 100 ns, porque esa variante pierde el período (sección 6a).

## 1. Por qué el flujo deja violaciones de slew: el modelo de cable del resizer

Quién repara slew y capacitancia en el flujo Classic (`flows/classic.py`): `OpenROAD.RepairDesignPostGPL`
(paso 32, `scripts/openroad/repair_design.tcl`: `estimate_parasitics -placement` y
`repair_design -slew_margin $DESIGN_REPAIR_MAX_SLEW_PCT -cap_margin $DESIGN_REPAIR_MAX_CAP_PCT`,
por defecto 20 % y 20 %) y, si `RUN_POST_GRT_DESIGN_REPAIR` está en true, `OpenROAD.RepairDesignPostGRT`
(`repair_design_postgrt.tcl`: `estimate_parasitics -global_routing`, márgenes
`GRT_DESIGN_REPAIR_MAX_SLEW_PCT` y `GRT_DESIGN_REPAIR_MAX_CAP_PCT`, por defecto 10 %). Los dos
corren sobre las esquinas de `RSZ_CORNERS` (sin definir: las 9 de `STA_CORNERS`), así que sí ven
la esquina lenta. Lo que no ven es el cable real:

- Con `LAYERS_RC` sin definir, `scripts/openroad/common/set_rc.tcl` llama `set_wire_rc` sin
  esquina y OpenROAD promedia los valores del tech LEF de las capas de ruteo (Metal2 a Metal5):
  0,2752 ohm/µm y 64,3 aF/µm, iguales en las 9 esquinas
  (`14-openroad-dumprcvalues/resizer_values_after.rpt`, "Signal Avg").
- La extracción de OpenRCX tras el ruteo detallado (paso 54, reglas `rules.openrcx.gf180mcuD.{max,nom,min}`)
  da, por regresión de la capacidad de cable del SPEF (`final/spef/<rc>/asic_top.<rc>.spef`, sin
  capacidades de pin) contra el largo ruteado (`50-odb-reportwirelength/wire_lengths.csv`) sobre
  los 2.399 nets de más de 20 µm de b5_t100 (`asic/signoff_pines.py`):

| extracción | cap (aF/µm) | R (ohm/µm) | factor sobre la estimación (cap / R) |
|---|---|---|---|
| max | 188,4 | 0,599 | 2,93 / 2,18 |
| nom | 166,3 | 0,549 | 2,59 / 1,99 |
| min | 148,0 | 0,498 | 2,30 / 1,81 |

- Ejemplo (b5_t100, `asic/rom/resultados/.../pines.md` del mismo análisis): el net `_1598_`
  (`nor4_2` hacia 4 selects de `mux2_2` y un `buf_2`) mide 237 µm; el resizer le estima 15 fF de
  cable y la extracción max le da 44,6 fF y 162 ohm; con 51 fF de pines, el `nor4_2` en la esquina
  ss llega a 5,56 ns de slew contra el límite de 3 ns.
- Por eso las violaciones aparecen solo en el STA final y solo en las esquinas ss (b5_t100:
  max_ss 312, nom_ss 173, min_ss 101, tt y ff 0; `metrics.json`,
  `design__max_slew_violation__count__corner:*`): el driver chico más el cable real que el
  resizer no modeló. Los STA intermedios del flujo (`OpenROAD.STAMidPNR`) corren solo en
  `nom_tt_025C_5v00`, así que tampoco las muestran.

Las dos violaciones de capacitancia de B5 son otra cosa: `clknet_0_clk_regs`, la raíz del árbol
de reloj de los flip-flops (`clkbuf_16` que maneja los ocho `clkbuf_16` de nivel 3 del H-tree:
8 x 22,7 fF = 182 fF de pines más 165 fF de 1.170 µm de cable, 347 fF contra 200), y `net520`
(un `buf_2` que lleva `a_rdata_o[15]` del registro de instrucción 1.045 µm por el die: 182 fF de
cable más 30 de pines). La primera la decide el CTS, no el resizer (`CTS_*`); la segunda sí es
del resizer y del mismo problema de modelo de cable.

## 2. Perillas probadas y por qué

| perilla | variable (paso, comando de OpenROAD) | razón |
|---|---|---|
| márgenes del repair de placement | `DESIGN_REPAIR_MAX_SLEW_PCT`, `DESIGN_REPAIR_MAX_CAP_PCT` (RepairDesignPostGPL, `repair_design -slew_margin -cap_margin`) | B1: 30 % dio 260/22 en main (+1,2 %) |
| repair post-GRT | `RUN_POST_GRT_DESIGN_REPAIR=true`, `GRT_DESIGN_REPAIR_MAX_SLEW_PCT`, `GRT_DESIGN_REPAIR_MAX_CAP_PCT` (RepairDesignPostGRT, `estimate_parasitics -global_routing` y `repair_design`) | ve largos y capas del ruteo global; B1: 489/19 en main (+0,5 %) |
| RC de cable medidos | `LAYERS_RC` por esquina (`set_layer_rc -layer -corner` y `set_wire_rc -corner` en todos los pasos de OpenROAD) | corrige la causa: el resizer estima con el cable que después se extrae (sección 1); `asic/rom/config_rc.yaml` |
| SDC de PnR más estricta | `PNR_SDC_FILE` (`set_max_transition 2.0`, `set_max_capacitance 0.15`) con `SIGNOFF_SDC_FILE` = SDC genérica (3 ns, 0,2 pF) | el repair trabaja con colchón sin cambiar el límite con que se mide el signoff; `asic/rom/config_sdc2.yaml`, `pnr_2p0.sdc`, `signoff.sdc` |
| resizer de timing post-GRT | `RUN_POST_GRT_RESIZER_TIMING=true` (ResizerTimingPostGRT, `rsz_timing_postgrt.tcl`: `estimate_parasitics -global_routing` y `repair_timing`) | recupera el período que pierden las variantes que insertan buffers antes del CTS, pero solo si los parásitos que estima se parecen a los que se extraen, o sea con `LAYERS_RC` (secciones 4bis y 4ter) |
| topología del árbol de reloj | `CTS_DISTANCE_BETWEEN_BUFFERS`, `CTS_SINK_CLUSTERING_SIZE`, `CTS_SINK_CLUSTERING_MAX_DIAMETER`, `CTS_ROOT_BUFFER` (CTS, `clock_tree_synthesis -distance_between_buffers -sink_clustering_size -sink_clustering_max_diameter -root_buf`) | la raíz con ocho `clkbuf_16` no la toca el resizer (B1: `CTS_MAX_CAP` sin efecto) |

Descartadas sin correr, con la razón: `MAX_TRANSITION_CONSTRAINT` global más bajo (cambia también
el límite del signoff, así que las cuentas dejan de ser comparables; la SDC de PnR hace lo mismo
sin ese efecto); `MAX_FANOUT_CONSTRAINT` 6 u 8 (B1: +5,3 % y +1,7 % de área en main, fuera del
límite); excluir `buf_2` (B1: 1.979 violaciones); `CTS_MAX_CAP` (B1: sin efecto);
`DESIGN_REPAIR_MAX_WIRE_LENGTH` fijo (con `LAYERS_RC` el resizer calcula solo el largo máximo
de cable por buffer a partir del RC, `RSZ-0058`).

## 3. Corridas a 100 ns, tanda 1

Base: sc_base_t100 (mismo RTL y configuración que fb_t100 del frente B: 165.358 µm², 327 / 1, idénticas).
Límite de área del frente: 1 % sobre la base, 167.012 µm². Fuente de cada fila: `asic/rom/resultados/<tag>/metrics.json`
(`design__max_slew_violation__count`, `design__max_cap_violation__count`, `design__max_fanout_violation__count`,
`design__instance__area__stdcell`, `timing__hold__ws`), `cierre.md` (todas cierran: DRC 0, LVS 0, antenas 0, setup y hold en las 9 esquinas),
`pines.md` (nets y causas) y el log de `32-openroad-repairdesignpostgpl` (buffers insertados, RSZ-0038).
La peor esquina de slew y cap es siempre `max_ss_125C_4v50`; tt y ff tienen 0 pines de slew en todas las corridas.

| tag | variante (VAR=VAL sobre config.yaml) | slew | cap | fanout | área stdcell (µm²) | sobre la base | hold peor (ns) | buffers del repair post-GPL | nets con slew | comentario |
|---|---|---|---|---|---|---|---|---|---|---|
| sc_base_t100 | ninguna | 327 | 1 | 35 | 165.358 | 0 | 0,161 | 565 en 188 nets | 83 | referencia; cap: raíz del árbol de reloj |
| sc_g30_t100 | DESIGN_REPAIR_MAX_SLEW_PCT=30 DESIGN_REPAIR_MAX_CAP_PCT=30 | 214 | 1 | 35 | 166.423 | +0,64 % | 0,174 | 622 en 221 nets | 64 | la mejor dentro del 1 % |
| sc_c30_t100 | RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 | 323 | 1 | 35 | 165.494 | +0,08 % | 0,157 | 565 | 82 | el repair post-GRT ve 70 violaciones con su modelo de cable y mete 8 buffers: casi nada |
| sc_j30_t100 | sc_g30 más sc_c30 | 214 | 1 | 35 | 166.423 | +0,64 % | 0,174 | 622 | 64 | idéntica a sc_g30: el repair post-GRT ve 37 violaciones y no inserta nada |
| sc_rc_t100 | config_rc.yaml (LAYERS_RC por esquina) | 47 | 2 | 10 | 172.560 | +4,36 % | 0,174 | 808 en 354 nets | 19 | el resizer ve el cable real: -86 % de slew; 14 de los 19 nets son enables de clock gate (nor2_1 -> icgtp_1/E) |
| sc_sdc2_t100 | config_sdc2.yaml (PNR_SDC_FILE 2 ns / 0,15 pF, SIGNOFF_SDC_FILE 3 ns / 0,2 pF) | 85 | 2 | 35 | 172.988 | +4,61 % | 0,157 | 1.016 en 356 nets | 32 | +392 buf_2 y +67 clkbuf_1: más caro que LAYERS_RC y limpia menos |
| sc_rcc_t100 | config_rc.yaml RUN_POST_GRT_DESIGN_REPAIR=true (márgenes post-GRT por defecto 10 %) | 2 | 1 | 10 | 174.007 | +5,23 % | 0,174 | 808 + 66 post-GRT | 1 | quedan el enable g_reg[4].en (nor3_1, 3,50 ns) y la raíz del reloj (0,332 pF) |
| sc_rccs_t100 | config_rc.yaml CTS_SINK_CLUSTERING_SIZE=20 CTS_SINK_CLUSTERING_MAX_DIAMETER=100 | 37 | 4 | 0 | 172.639 | +4,40 % | 0,158 | 808 | 16 | el CTS acota los clusters a 10 sumideros (max_fanout de la SDC); 4 nets de reloj con cap: raíz 0,358 y tres de nivel 3 |
| sc_rccd_t100 | config_rc.yaml CTS_DISTANCE_BETWEEN_BUFFERS=100 | 44 | 3 | 10 | 171.520 | +3,73 % | 0,174 | 808 | 17 | el árbol pasa de profundidad 2-3 a 4-5 y la raíz deja de violar; quedan dos nets de nivel 3 (0,209 y 0,205 pF) y g_reg[4].en |

Dónde se va el área de LAYERS_RC (sc_rc contra sc_base, `state_out.json` de cada paso y `53-odb-cellfrequencytables/cell.rpt`):
el repair post-GPL pasa de 152.336 a 157.830 µm² (+5.494: +178 buf_2, +45 buf_4, +8 buf_8, 15 celdas redimensionadas;
encuentra 319 violaciones de slew en vez de 137 y el largo máximo de cable baja de 11.309 a 4.491 µm, RSZ-0058) y el CTS de
+12.947 a +14.660 µm² (+1.713: +27 clkbuf_8 de hoja, 66 en vez de 42, porque también estima con el cable real). Los dos
pasos ven ahora lo que el STA final medirá, así que el costo es el de reparar de verdad los 327 pines, no un artefacto:
por eso no cabe en el 1 % del frente. Contra main (182.265 µm²) sc_rcc sigue 4,5 % abajo.

Regresión RC de la propia sc_rc (`asic/rom/resultados/sc_rc_t100/pines.md`): pendiente de capacidad extraída 185,5 / 164,1 / 146,2 aF/µm
(max / nom / min) contra 166,3 aF/µm que ahora usa el resizer en nom (factores 1,12 / 0,99 / 0,88; en la base eran 2,89 / 2,56 / 2,28).
`14-openroad-dumprcvalues/resizer_values_after.rpt` de sc_rc muestra los valores por capa aplicados (Metal2 0,641 ohm/µm y 217,2 aF/µm en nom).

## 4. Corridas al período mínimo y combinaciones (tanda 2)

Período mínimo de la base, medido por el frente B en `build/exp_fmax` (mismo RTL y `config.yaml`):
fb_t24 cierra, fb_t23p5 cierra y fb_t23 no (23,5 ns). Como el WNS de setup de `metrics.json` vale
0,000 por convención en los diseños con latches (B5), el margen real se lee en la peor ruta que
termina en flip-flop (`asic/ruta_ff.py <run>`, que reordena `max.rpt` de `max_ss_125C_4v50`):
fb_t24 +0,434 ns, fb_t23p5 +0,053 ns, fb_t23 -0,447 ns. Área de celdas de fb_t24: 171.289 µm²;
de fb_t23p5: 172.185 µm². Slew y capacitancia de la base al período mínimo: 351 / 2 (fb_t24),
340 / 2 (fb_t23p5).

R = `RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30
CTS_DISTANCE_BETWEEN_BUFFERS=100` sobre `config_rc.yaml` (LAYERS_RC). Fuente de cada fila:
`asic/rom/resultados/<tag>/metrics.json`, `cierre.md`, `pines.md`, y `ruta_ff.py` para el WNS de
las rutas a flip-flop ("WNS ff"). "sobre la base" compara con la corrida de la base al mismo período
(sc_base_t100 a 100 ns, fb_t24 a 24 ns, fb_t23 a 23 ns).

| tag | variante | T (ns) | cierra | WNS ff max_ss (ns) | hold peor (ns) | área stdcell (µm²) | sobre la base | slew | cap | fanout | skew setup max_ss (ns) | comentario |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sc_full_t100 | config_rc.yaml + R | 100 | sí | > 0 (latches en 0,000) | 0,171 | 177.807 | +7,5 % | 0 | 2 | 10 | 2,911 | cero slew en las 9 esquinas; quedan dos nets de nivel 3 del árbol de reloj (0,234 y 0,209 pF) |
| sc_fulls6_t100 | config_rc.yaml + R + CTS_SINK_CLUSTERING_SIZE=6 | 100 | sí | > 0 | 0,153 | 183.567 | +11,0 % | 0 | 1 | 0 | 2,849 | 322 buffers de reloj (sc_full 202): queda `clknet_4_13_0_clk_regs` en 0,202 pF |
| sc_full0_t100 | config_rc.yaml + R + DESIGN_REPAIR_MAX_SLEW_PCT=0 DESIGN_REPAIR_MAX_CAP_PCT=0 | 100 | sí | > 0 | 0,134 | 176.714 | +6,9 % | 9 | 2 | 12 | 2,891 | sin margen post-GPL el repair post-GRT hace más (420 buffers contra 292) y quedan 3 nets con 3,08 a 3,48 ns |
| sc_full_t24 | config_rc.yaml + R | 24 | no | -0,473 | 0,174 | 182.140 | +6,3 % | 0 | 2 | 10 | 2,853 | setup en max_ss; DRC, LVS, antenas y hold limpios |
| sc_full_t23 | config_rc.yaml + R | 23 | no | -1,221 | 0,174 | 183.354 | +6,5 % | 0 | 2 | 10 | n/d | mismo tipo de ruta que a 24 ns |
| sc_g30_t24 | config.yaml + DESIGN_REPAIR_MAX_SLEW_PCT=30 DESIGN_REPAIR_MAX_CAP_PCT=30 | 24 | no | -2,500 | 0,157 | 169.908 | -0,8 % | 237 | 2 | 35 | 2,542 | la mejor variante dentro del 1 % a 100 ns pierde 2,9 ns de slack a 24 ns respecto de fb_t24 |

Lectura: la combinación completa (sc_full) llega a 0 pines de slew en las 9 esquinas a 100, 24 y
23 ns, pero cuesta 7,5 % de área a 100 ns y no cierra al período mínimo de la base (24 ns: -0,473 ns;
la base cierra a 24 y a 23,5). Ninguna variante baja de 2 pines de capacitancia salvo sc_fulls6
(1 pin, +11 % de área). La variante dentro del 1 % (sc_g30) tampoco cierra a 24 ns.
Las secciones 4bis y 4ter corrigen esta lectura: agregando `RUN_POST_GRT_RESIZER_TIMING=true` la
combinación completa cierra a 24 ns y a 22,5 ns, con más margen que la base y con 0 pines de slew.

### Por qué empeora el período

Peor ruta que termina en flip-flop (`ruta_ff.py`, `max_ss_125C_4v50`; el retardo "en buffers del
repair" suma las etapas cuyas instancias se llaman `fanout*`, `wire*`, `max_cap*`, es decir, las
que insertó `repair_design`):

| corrida | inicio -> fin | etapas | retardo de datos (ns) | en buffers del repair (ns) | buffers del repair en la ruta | slack (ns) |
|---|---|---|---|---|---|---|
| fb_t24 (base) | `_4668_` -> `_4394_` (ALU) | 25 | 25,71 | 7,49 | 7 (5 fanout, 1 max_cap, 1 wire) | +0,434 |
| fb_t23p5 (base) | `_4668_` -> `_4394_` | 25 | 25,61 | 7,51 | 7 | +0,053 |
| sc_full_t24 | `_4670_` (`alu_op_a_sel[2]`) -> `_4424_` (PC, por `alu_cmp_result`) | 43 | 26,64 | 9,09 | 14 (5 fanout, 4 wire, 5 max_cap) | -0,473 |
| sc_full_t23 | `_4670_` -> `_4424_` | 44 | 26,38 | 9,07 | 15 | -1,221 |
| sc_g30_t24 | `_4670_` -> `_4424_` | 36 | 28,65 | 7,45 | 8 (5 fanout, 3 max_cap) | -2,500 |

Tres causas, todas medidas:

1. Buffers del repair en la ruta. Con LAYERS_RC el repair post-GPL ve 319 violaciones de slew en vez
   de 137 e inserta 808 buffers en 354 nets (base: 565 en 188; `32-openroad-repairdesignpostgpl/openroad-repairdesignpostgpl.log`,
   RSZ-0034 y RSZ-0038), y el repair post-GRT con margen 30 % agrega 292 más (sc_full_t100,
   `41-openroad-repairdesignpostgrt`, RSZ-0038; con margen 10 % en sc_rcc fueron 66). En la ruta
   crítica de sc_full_t24 hay 14 de esos buffers (9,1 ns) contra 7 (7,5 ns) en la base: la ruta
   pasa por `alu_op_a_sel[2]` -> tres buffers en serie (`fanout567` buf_3, `fanout566` clkbuf_8,
   `wire1321` clkbuf_8) -> ALU (`max_cap286`, `wire202`, `max_cap201`, `wire191`) -> `alu_cmp_result`
   -> `wire97`, `max_cap76`, `max_cap75`, `fanout69`, `fanout67`, `max_cap1084`, `fanout66` -> PC
   (`asic/rom/resultados/sc_full_t24/layout/ruta_critica.txt`, 37 celdas numeradas; bloques: etapa ID,
   ALU y lógica aplanada). `repair_design` repara slew y capacitancia sin mirar el timing, y el
   `repair_timing` posterior no quita esos buffers (su secuencia es UnbufferMove, SizeUpMove,
   SwapPinsMove, BufferMove, CloneMove, SplitLoadMove: en sc_full_t24 quitó 0, redimensionó 256 e
   insertó 22; `*-openroad-resizertimingpostcts/*.log`, RSZ-0100, RSZ-0040, RSZ-0051).
2. Skew del árbol de reloj. `CTS_DISTANCE_BETWEEN_BUFFERS=100` pasa de 142 a 202 buffers de reloj y
   el skew de setup en max_ss sube de 2,52 a 2,87 a 2,91 ns (`clock__skew__worst_setup__corner:max_ss_125C_4v50`:
   sc_base 2,523, sc_rc 2,491, sc_rccd 2,872, sc_full 2,911; a 24 ns: fb_t24 2,555, sc_full_t24 2,853).
   LAYERS_RC solo no cambia el skew (sc_rc 2,491).
3. El repair_timing post-CTS trabaja con los latches como endpoints en 0,000. Con
   `PL_RESIZER_SETUP_SLACK_MARGIN=10`, los 480 latches del banco (slack 0,000 por préstamo de tiempo)
   cuentan siempre como endpoints violados y el peor endpoint de cada iteración es un latch
   (`g_reg[10].g_bit[0].u_lat`): la tabla de iteraciones termina en 1200 con "Unable to repair all
   setup violations" (RSZ-0062) en fb_t24, sc_full_t24 y sc_g30_t24. El resultado a 24 ns depende de
   qué rutas a flip-flop alcanza a tocar antes de agotarse: en fb_t24 redimensionó 336 instancias, en
   sc_full_t24 256 y en sc_g30_t24 188 (y sc_g30_t24 queda con celdas chicas en la ruta crítica:
   `fanout68` buf_2 con 10 cargas y 1,77 ns de slew). Por eso sc_g30 pierde 2,9 ns con solo 1.065 µm²
   más de buffers a 100 ns: no es el costo de los buffers sino que el repair de timing parte de otro
   netlist y llega a otro punto con el mismo tope de iteraciones. Es una limitación de la base B5 que
   afecta a cualquier variante del flujo que cambie el netlist antes del CTS, y toca al frente B.

## 4bis. Tanda 3: márgenes del repair post-GRT y el resizer de timing post-GRT

Dos preguntas que dejó abiertas la tanda 2: (a) si subir el margen del repair post-GRT por encima
de 30 % limpia más sin pagar el área de `LAYERS_RC`, y (b) si el paso `OpenROAD.ResizerTimingPostGRT`
(`RUN_POST_GRT_RESIZER_TIMING=true`, `scripts/openroad/rsz_timing_postgrt.tcl`:
`estimate_parasitics -global_routing` y `repair_timing`) recupera el período que pierden las
variantes que insertan buffers antes del CTS.

C = `RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30`.
"WNS ff" es el slack de la peor ruta que termina en flip-flop (`asic/ruta_ff.py`, `max_ss_125C_4v50`),
porque los 480 latches de B5 reportan 0,000 en `metrics.json`. "sobre la base" compara con la corrida
de la base al mismo período (sc_base_t100 = 165.358 µm² a 100 ns, fb_t24 = 171.289 µm², fb_t23p5 = 172.185 µm²).
Fuente de cada fila: `asic/rom/resultados/<tag>/{metrics.json,cierre.md,pines.md}` y `asic/barrido_exp.md`
(tercera tanda). Todas cierran: DRC 0, LVS 0, antenas 0, setup y hold en las 9 esquinas.

| tag | variante | T (ns) | cierra | WNS ff max_ss (ns) | hold peor (ns) | área stdcell (µm²) | sobre la base | slew | cap | fanout | skew setup max_ss (ns) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| sc_c50_t100 | config.yaml, post-GRT 50 % | 100 | sí | > 0 (latches en 0,000) | 0,157 | 166.592 | +0,75 % | 321 | 2 | 35 | 2,539 |
| sc_c65_t100 | config.yaml, post-GRT 65 % | 100 | sí | > 0 | 0,174 | 171.316 | +3,60 % | 811 | 1 | 35 | 2,504 |
| sc_c30_t24 | config.yaml + C | 24 | sí | +0,588 | 0,161 | 171.403 | +0,07 % | 342 | 2 | 35 | 2,536 |
| sc_c30_t23p5 | config.yaml + C | 23,5 | sí | +0,243 | 0,158 | 172.290 | +0,06 % | 323 | 1 | 35 | 2,533 |
| sc_fullp_t24 | config_rc.yaml + C + CTS_DISTANCE_BETWEEN_BUFFERS=100 + RUN_POST_GRT_RESIZER_TIMING=true | 24 | sí | +1,249 | 0,174 | 184.698 | +7,83 % | 3 | 1 | 10 | 2,880 |
| sc_rccp_t24 | config_rc.yaml + C + RUN_POST_GRT_RESIZER_TIMING=true | 24 | sí | +1,773 | 0,174 | 185.602 | +8,36 % | 3 | 1 | 10 | 2,485 |

Referencia de la base al mismo período (frente B, `build/exp_fmax`): fb_t24 WNS ff +0,434 ns,
351 slew / 2 cap; fb_t23p5 +0,053 ns, 340 / 2; fb_t23 -0,447 ns (no cierra).

Las dos respuestas, medidas:

1. Subir el margen del repair post-GRT por encima de 30 % EMPEORA el slew del signoff. Con el
   modelo de cable de la estimación (0,5487 ohm/µm y 166,3 aF/µm, 2,3 a 2,9 veces menos capacidad
   que la extracción, sección 1) el repair "ve" cada vez más violaciones que el signoff no tiene y
   las arregla insertando buffers chicos: `41-openroad-repairdesignpostgrt/*.log` (RSZ-0034 y
   RSZ-0038) da 70 violaciones y 8 buffers con margen 30 % (sc_c30), 355 y 70 con 50 % (sc_c50) y
   1.131 y 351 con 65 % (sc_c65). En sc_c65 esos buffers incluyen 58 `clkbuf_1` con nombre `fanout*`
   usados como buffers de datos (`final/nl/asic_top.nl.v`), y 620 de los 811 pines con violación de
   slew de sc_c65 son de nets manejados por `clkbuf_1/Z` (`asic/rom/resultados/sc_c65_t100/pines.md`):
   el repair reparte la carga en buffers de fuerza 1 que después, con el cable real y en la esquina
   ss, violan ellos mismos. Es el mismo error de modelo de la sección 1, ahora con el signo
   contrario. Conclusión: sin `LAYERS_RC`, el margen del repair post-GRT solo sirve hasta 30 %
   (sc_c30: 323 / 1 con +0,08 % de área).
2. `RUN_POST_GRT_RESIZER_TIMING=true` recupera el período y lo mejora. La combinación completa sin
   ese paso no cierra a 24 ns (sc_full_t24, -0,473 ns); con el paso cierra a 24 ns y con más margen
   que la propia base: sc_rccp_t24 +1,773 ns y sc_fullp_t24 +1,249 ns contra fb_t24 +0,434 ns. El
   paso corre `repair_timing` con los parásitos del ruteo global, es decir con el mismo RC medido que
   usa el resto del flujo cuando se define `LAYERS_RC`, y ahí sí redimensiona o deshace los buffers
   que `repair_design` dejó en la ruta crítica. Además baja de 2 a 1 el pin de capacitancia. El
   frente B midió el mismo paso sobre la base sin `LAYERS_RC`: lleva el período mínimo de 23,5 a
   23,25 ns (fb_pgrt_t23p25 cierra, fb_pgrt_t23 no, `build/exp_fmax/asic/barrido_exp.md`), o sea que
   una parte de la ganancia es del paso y otra de `LAYERS_RC` (sin `LAYERS_RC` el paso da 0,25 ns de
   período; con `LAYERS_RC` da 1,34 ns de slack sobre la base al mismo período de 24 ns).
   Esto corrige la lectura de la tanda 2: la configuración que llega a 3 violaciones NO empeora el
   período si se agrega `RUN_POST_GRT_RESIZER_TIMING=true`; lo que empeora el período es insertar
   buffers antes del CTS sin un repair de timing posterior que vea el cable real.

## 4ter. Tanda 4: la configuración recomendada a 100 ns y al período

Tres corridas para cerrar las dos preguntas que quedaban: si el resizer de timing post-GRT le
devuelve el período a la variante que cabe en el 1 % de área (no se lo devuelve), y cuánto cuestan
a 100 ns y hasta qué período llegan `LAYERS_RC` más el repair post-GRT al 30 % más el resizer de
timing post-GRT (la configuración de sc_rccp). Fuente: `asic/rom/resultados/<tag>/{metrics.json,cierre.md,pines.md}`,
`asic/barrido_exp.md` (cuarta tanda) y `asic/ruta_ff.py` para el WNS a flip-flop.

| tag | variante | T (ns) | cierra | WNS ff max_ss (ns) | hold peor (ns) | área stdcell (µm²) | sobre la base | slew | cap | fanout | antena | skew setup max_ss (ns) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sc2_g30p_t24 | config.yaml + DESIGN_REPAIR 30/30 + RUN_POST_GRT_RESIZER_TIMING=true | 24 | no | -2,411 | 0,169 | 169.935 | -0,8 % | 191 | 1 | 35 | 0 | 2,520 |
| sc2_rccp_t100 | config_rc.yaml + C + RUN_POST_GRT_RESIZER_TIMING=true | 100 | no (1 net de antena) | > 0 (latches en 0,000) | 0,174 | 178.834 | +8,15 % | 0 | 1 | 10 | 1 | 2,478 |
| sc2_rccp_t22p5 | config_rc.yaml + C + RUN_POST_GRT_RESIZER_TIMING=true | 22,5 | sí | +1,580 | 0,174 | 186.599 | +8,37 % | 0 | 1 | 10 | 0 | 2,491 |

1. El resizer de timing post-GRT NO rescata a sc_g30. sc2_g30p_t24 no cierra (-2,411 ns contra
   -2,500 de sc_g30_t24 y +0,434 de fb_t24): mejora 0,089 ns, nada frente a los 2,9 ns que pierde.
   La razón es la misma de la sección 1: sin `LAYERS_RC`, `rsz_timing_postgrt.tcl` llama
   `estimate_parasitics -global_routing` con el mismo modelo de cable subestimado, así que el
   `repair_timing` que corre ahí no ve la ruta crítica que medirá el STA final. El paso sirve
   cuando los parásitos que estima se parecen a los que se extraen, es decir junto con `LAYERS_RC`.
   De paso, baja el slew de 214 a 191 pines y sube el área de 169.908 a 169.935 µm² a 24 ns.
2. La configuración recomendada llega a 0 pines de slew en las 9 esquinas también a 100 ns
   (sc2_rccp_t100) y a 22,5 ns (sc2_rccp_t22p5), con 1 pin de capacitancia (siempre la raíz del
   árbol de reloj, `clknet_0_clk_regs`, 0,337 y 0,339 pF contra el límite de 0,2) y 10 de fanout.
3. Y mejora el período mínimo: cierra a 22,5 ns con +1,580 ns en la peor ruta a flip-flop, contra
   23,5 ns de la base (fb_t23p5 +0,053 ns, fb_t23 no cierra). Son 44,4 MHz contra 42,6 MHz, +4,4 %.
   El margen que sobra a 22,5 ns dice que el período mínimo real está por debajo, así que este
   número NO cumple la regla de 0,5 ns: falta correr 22 y 21,5 ns (ver la sección 8).
4. Ruta crítica de la corrida del período mínimo (sc2_rccp_t22p5), con nombres de bloque:
   `bash asic/layout/anotar.sh asic/rom/runs/sc2_rccp_t22p5` deja
   `asic/rom/resultados/sc2_rccp_t22p5/layout/{ruta_critica.txt,bloques.txt,slew.txt}` y las figuras.
   La peor ruta a flip-flop (`asic/ruta_ff.py`) va de `_4439_` (`dffq_4`, el registro
   `u_soc.u_core.u_id.alu_op_b_sel`, que elige el operando B de la ALU) a `_4424_` (`dffrnq_1`, el bit
   21 de la dirección de instrucción `u_soc.g_mem_rom.u_mem.a_addr_i`), o sea el camino
   selección del operando -> ALU -> comparación de salto -> dirección siguiente, el mismo tipo de
   ruta que en la base y en la tanda 2. La figura de slew de esa corrida está vacía: 0 pines, 0 celdas.

5. Lo que no cerró: sc2_rccp_t100 deja 1 net con violación de antena,
   `u_soc.u_core.u_rf/net132` en `_2020_/D`, relación 1,18 (470,95 contra 400 de la regla de Metal2,
   `asic/rom/resultados/sc2_rccp_t100/antenna_summary.rpt`), y por eso esa corrida no cierra. No es
   propio de la configuración: la misma configuración a 22,5 ns cierra con 0 nets de antena, y las
   otras 21 corridas del frente, con y sin estas variables, dieron 0. Es una corrida que hay que
   repetir (o resolver con un diodo) antes de usar esta configuración en la corrida de entrega.

## 5. Pines que quedan y su causa

Esquina `max_ss_125C_4v50` en todos los casos (`<run>/5x-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`;
agrupación por celda que maneja, pin de carga, largo, capacidad de cable extraída (SPEF) y de pines
(liberty) en `asic/rom/resultados/<tag>/pines.md`, generado por `asic/signoff_pines.py`). Los pines
de slew son siempre de la esquina ss (tt y ff tienen 0 en todas las corridas: sc_base max_ss 327,
nom_ss 215, min_ss 145); los de capacitancia son los mismos en las 9 esquinas (metrics.json,
`design__max_*_violation__count__corner:*`).

- sc_base: 327 pines en 83 nets. Celdas que manejan: nor2_1 (14 nets, los enables de clock gate `g_reg[n].en` hacia `icgtp_1/E`, 280 a 390 µm de cable,
  60 a 80 fF de cable contra 3,4 fF de pin), aoi22_1, oai211_1, aoi221_1, nor3_1 (`rf_we`, `g_reg[4].en`), oai21_1; cargas: nand2_1/A2, buf_2/I, dffq_1/D, aoi22_1/A1.
  Cap: `clknet_0_clk_regs` (raíz del H-tree de los 544 flip-flops: clkbuf_16 con ocho clkbuf_16, 181,7 fF de pines más 150 fF de 1.093 µm de cable, 0,338 pF;
  los ocho hijos son clkbuf_16 porque el repair_timing post-CTS los agranda desde los clkbuf_8 que puso el CTS). Fanout: 35 buffers de hoja del reloj con 11 o 12
  sumideros (el CTS agrupa hasta 10 y el post-proceso agrega sumideros aislados).
- sc_g30 (la mejor dentro del 1 %): 214 pines en 64 nets, mismos tipos de driver que la base; a 24 ns (sc_g30_t24) 237 pines, los peores
  `g_reg[4].en` (nor3_1, 361 µm, 6,58 ns), `_0755_` (aoi221_1, 212 µm, 4,54 ns), `rf_we` (nor3_1, 256 µm, 4,46 ns), `rf_wdata[24]` (oai21_1, 387 µm, 4,36 ns).
- sc_rc: 47 pines en 19 nets: 14 enables de clock gate (nor2_1, 3,4 a 4,5 ns), `g_reg[4].en` (nor3_1, 6,05 ns), 2 aoi22_1, nand4_1, nor4_1.
  Cap: la raíz (0,332) y `clknet_3_3__leaf_clk_regs` (clkbuf_16 con 8 buffers de hoja, 580 µm, 0,204 pF).
- sc_rcc: 2 pines (un net): `g_reg[4].en`, nor3_1 -> buf_4 (buffer `wire1198` que insertó el repair), 3,498 ns; el repair post-GRT con margen 10 % no lo toma
  (sí con 30 %: sc_full). Cap: la raíz, 0,332 pF.
- sc_rccd: cap en `clknet_3_3_0_clk_regs` (0,209) y `clknet_3_6_0_clk_regs` (0,205): clkbuf_8 de nivel 3 con 8 clkbuf_8 de hoja (90 fF de pines) y
  590 a 641 µm de cable (114 a 118 fF); y `g_reg[4].en` (0,081 pF contra 0,0799 del pin del nor3_1, no del límite de 0,2 de la SDC).
- sc_full (100, 24 y 23 ns): 0 pines de slew. Cap: `clkbuf_3_3_0_clk_regs/Z` (0,234 pF a 100 ns, 0,209 a 24, 0,231 a 23) y `clkbuf_3_6_0_clk_regs/Z`
  (0,209 / 0,204 / 0,205 pF): los dos nets de nivel 3 del árbol con 8 clkbuf_8 de hoja (90,3 fF de pines) más 118 a 144 fF de cable. Fanout: 10 buffers
  de hoja con 11 o 12 sumideros.
- sc_fulls6 (clusters de 6 sumideros): 0 slew, 0 fanout y 1 cap: `clknet_4_13_0_clk_regs` (clkbuf_8 con 10 buffers de hoja, 101 fF de pines más 100 de
  cable, 0,202 pF). Cuesta 120 buffers de reloj más (322 contra 202) y 5.760 µm² sobre sc_full.
- sc_full0 (margen post-GPL 0 %): 9 pines en 3 nets (`_0721_` aoi22_1 3,48 ns, `data_wdata[4]` dffq_1 3,12 ns, `_0678_` aoi22_1 3,08 ns) y los mismos 2 de cap.
- sc_c50 (post-GRT 50 %): 321 pines en 79 nets. Drivers: aoi21_1 (12 nets, 53 pines), dffq_1/Q (5, 35), nor2_1 (13, 33), aoi22_1 (11, 31), inv_1 (4, 31) y 29 pines en 3 nets que ya maneja un `clkbuf_1` insertado por el repair. Cap: la raíz del reloj (0,335 pF) y un net de datos.
- sc_c65 (post-GRT 65 %): 811 pines en 116 nets, peor que la base. 620 de los 811 son de 58 nets manejados por `clkbuf_1/Z`: los 58 `clkbuf_1` con nombre `fanout*` que insertó el repair post-GRT (`final/nl/asic_top.nl.v`; sección 4bis, punto 1). Los otros 191 son los mismos tipos de driver de la base (nor2_1 35, dffrnq_1/Q 26, dffq_1/Q 22, inv_1 21). Cap: 1 pin.
- sc_fullp_t24 y sc_rccp_t24 (la combinación completa con `RUN_POST_GRT_RESIZER_TIMING=true`, a 24 ns): 3 pines en 1 net, y es marginal. El net es `u_soc.u_core.u_id.u_alu/_0233_`, manejado por `\u_soc.u_core.u_id.u_alu/_0780_` (`aoi221_1`, `final/nl/asic_top.nl.v` línea 30293) con fanout 2 hacia `_0781_/A2` (and2_2) y `_0782_/A2` (aoi21_4): 25,1 fF de capacidad de pines contra 2,4 fF de cable y 32 ohm, o sea que aquí la carga es de pines y no de cable. Slew 3,012 ns en sc_rccp_t24 y 3,031 ns en sc_fullp_t24 contra el límite de 3,0 (slack -0,012 y -0,031 ns, 0,4 % y 1,0 % sobre el límite; `<run>/57-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`). El liberty tiene `aoi221_2` y `aoi221_4`, así que el redimensionado del driver estaba disponible y ni el repair post-GPL ni el post-GRT lo tomaron. Cap: 1 pin, distinto en cada una: en sc_rccp_t24 la raíz `clknet_0_clk_regs` (clkbuf_16 con 8 clkbuf_16, 181,7 fF de pines más 153,1 de cable, 0,335 pF) porque no lleva `CTS_DISTANCE_BETWEEN_BUFFERS`; en sc_fullp_t24 `clknet_3_3_0_clk_regs` (clkbuf_8 con 8 clkbuf_8 de hoja, 90,3 fF de pines más 129,5 de cable, 0,220 pF). Fanout: los mismos 10 buffers de hoja con 11 o 12 sumideros.
- sc2_g30p_t24 (sc_g30 más el resizer de timing post-GRT, a 24 ns): 191 pines en 58 nets, mismos tipos de driver (nor2_1 los enables de clock gate, aoi22_1, oai21_1, aoi221_1) y 1 de capacidad (la raíz).
- sc2_rccp_t100 y sc2_rccp_t22p5 (la configuración recomendada): **0 pines de slew** en las 9 esquinas y 1 de capacidad en las 9 (`metrics.json`, `design__max_slew_violation__count__corner:*` y `design__max_cap_violation__count__corner:*`, verificado en las dos corridas); el pin de capacidad es en las dos: la raíz `clknet_0_clk_regs` (clkbuf_16 con ocho clkbuf_16, 181,7 fF de pines más 154,8 y 157,3 fF de cable: 0,337 y 0,339 pF contra el límite de 0,2). Fanout: los mismos 10 buffers de hoja con 11 o 12 sumideros.

Las dos capacitancias del árbol de reloj no las mueve el resizer (los nets de reloj no se tocan en
`repair_design`): dependen de la topología que construye TritonCTS. Con el árbol por defecto viola
la raíz (0,33 pF); con `CTS_DISTANCE_BETWEEN_BUFFERS=100` la raíz baja pero violan dos nets de nivel
3 (0,20 a 0,23 pF); con clusters de 6 sumideros queda uno (0,202). `CTS_MAX_CAP` no cambia el árbol
(B1) y `CTS_SINK_CLUSTERING_SIZE=20` con diámetro 100 µm lo empeora (sc_rccs: 4 nets). Dejar el
árbol en cero exige pagar área de buffers de reloj (sc_fulls6, +11 %) o aceptar 1 o 2 pines a 0,2 a
0,23 pF contra un límite de la SDC de 0,2 pF (el liberty permite 1,83 pF en clkbuf_8 y 3,93 en clkbuf_16).

## 6. Configuración recomendada

Lo primero, porque condiciona todo lo demás: **el objetivo de cero violaciones no se alcanza
dentro del límite de 1 % de área**, y la razón está medida, no estimada.

1. La causa de las violaciones de slew no es que falte buffering, sino que el resizer estima el
   cable con 2,3 a 2,9 veces menos capacidad de la que después extrae OpenRCX (sección 1). Por eso
   la base cierra con `repair_design` reportando 0 violaciones y el STA final encuentra 327 pines.
   Corregir el modelo (`LAYERS_RC`) hace que el repair repare de verdad: el área sube 7.202 µm²
   (sc_rc_t100, 172.560 contra 165.358 de sc_base_t100, +4,36 %) y todavía quedan 47 pines. El
   presupuesto de 1 % son 1.654 µm²: la corrección mínima del modelo ya cuesta 4,4 veces ese
   presupuesto, y llegar a 0 pines de slew cuesta 12.449 µm² (sc_full_t100, +7,53 %), 7,5 veces el
   presupuesto.
2. Dentro del 1 % la única perilla que sirve es el margen del repair, que trabaja con el modelo de
   cable equivocado: con 30 % en el repair de placement baja de 327 a 214 pines por 1.065 µm²
   (sc_g30_t100, +0,64 %), y subir el margen del repair post-GRT más allá de 30 % empeora el
   resultado (321 pines con 50 %, 811 con 65 %, sección 4bis punto 1).
3. Las violaciones de capacitancia que quedan son del árbol de reloj y el resizer no las toca:
   `repair_design` no trabaja sobre nets de reloj. Dependen de la topología de TritonCTS y bajar de
   1 pin exige pagar buffers de reloj (sc_fulls6_t100: 1 pin con +11,01 % de área). Ninguna de las
   24 corridas del frente llegó a 0 pines de capacitancia.

Las dos configuraciones, como lista de VAR=VAL para `asic/encolar.sh` (o claves del YAML):

### (a) La mejor dentro del límite de 1 % de área

Hay que elegir entre bajar el conteo a 100 ns y conservar el período mínimo: ninguna variante de
este frente hace las dos cosas dentro del 1 %.

**(a1) Para la corrida del enunciado, a 100 ns y 40 % (la recomendada si lo que importa es el
conteo que se informa):**

```
DESIGN_REPAIR_MAX_SLEW_PCT=30
DESIGN_REPAIR_MAX_CAP_PCT=30
```

- Costo en área: 166.423 µm² contra 165.358 de la base, +1.065 µm² (+0,64 %), dentro del 1 %
  (límite 167.012 µm²). Fuente: `asic/rom/resultados/sc_g30_t100/metrics.json`.
- Costo en slew y capacitancia: mejora, 214 pines de slew contra 327 (-34,6 %) y 1 de capacidad
  (la raíz del árbol de reloj) contra 1. `asic/rom/resultados/sc_g30_t100/pines.md`.
- Costo en período mínimo: **no sirve al período**. sc_g30_t24 no cierra (-2,500 ns en la peor
  ruta a flip-flop contra +0,434 ns de fb_t24) y agregar `RUN_POST_GRT_RESIZER_TIMING=true` tampoco
  la salva (sc2_g30p_t24: no cierra, -2,411 ns, 169.935 µm², 191 slew / 1 cap;
  `asic/rom/resultados/sc2_g30p_t24/cierre.md`). O sea: estas dos variables van en la corrida de
  100 ns, no en el barrido de período.
- Cierre: sc_g30_t100 cierra completo (DRC 0, LVS 0, antenas 0, setup y hold en las 9 esquinas,
  `asic/rom/resultados/sc_g30_t100/cierre.md`).

**(a2) Si se quiere una sola configuración para 100 ns y para el barrido de período:**

```
RUN_POST_GRT_DESIGN_REPAIR=true
GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30
GRT_DESIGN_REPAIR_MAX_CAP_PCT=30
```

- Costo en área: 165.494 µm² a 100 ns, +136 µm² (+0,08 %). `asic/rom/resultados/sc_c30_t100/metrics.json`.
- Costo en slew y capacitancia: 323 / 1 contra 327 / 1, o sea casi nada (-1,2 %).
- Costo en período mínimo: ninguno, y de hecho da un poco más de margen que la base: cierra a 24 ns
  (+0,588 ns contra +0,434 de fb_t24) y a 23,5 ns (+0,243 contra +0,053). No se midió a 23 ns, así
  que su período mínimo es "23,5 ns o mejor" y no está acotado por la regla de 0,5 ns.
- Es la honesta si el grupo no quiere dos configuraciones: el beneficio es despreciable, pero no
  cuesta nada.
### (b) La mejor sin límite de área: la recomendada si el grupo quiere cero violaciones

`LAYERS_RC` es un diccionario y no se puede pasar como VAR=VAL al encolar: va en el YAML. Las
otras tres sí son VAR=VAL. La configuración completa es `asic/rom/config_rc.yaml` (igual a
`asic/rom/config.yaml` más el bloque `LAYERS_RC`, con la justificación de los valores en el propio
archivo) más:

```
RUN_POST_GRT_DESIGN_REPAIR=true
GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30
GRT_DESIGN_REPAIR_MAX_CAP_PCT=30
RUN_POST_GRT_RESIZER_TIMING=true
```

- Costo en slew y capacitancia: **0 pines de slew en las 9 esquinas** a 100 ns y a 22,5 ns
  (sc2_rccp_t100 y sc2_rccp_t22p5) y 3 pines, marginales, a 24 ns (sc_rccp_t24: slack -0,012 ns, un
  `aoi221_1` de la ALU con 25,1 fF de pines). Queda **1 pin de capacitancia** en las tres: la raíz
  del árbol de reloj `clknet_0_clk_regs` (0,337 pF contra el límite de 0,2 de la SDC; el liberty
  permite 3,93 pF en el `clkbuf_16` que la maneja). Fanout: 10 buffers de hoja con 11 o 12 sumideros.
  Fuente: `asic/rom/resultados/{sc2_rccp_t100,sc2_rccp_t22p5,sc_rccp_t24}/pines.md`.
- Costo en área: a 100 ns 178.834 µm² contra 165.358 de la base, +13.476 µm² (**+8,15 %**); a 22,5 ns
  186.599 µm² contra 172.185 de fb_t23p5 (+8,37 %). Rompe el límite de 1 % que se fijó este frente,
  pero no el límite de la sesión: la regla de selección permite hasta 105 % del área de main a 100 ns,
  o sea 191.378 µm², y main mide 182.265 µm². Esta configuración queda 1,9 % por debajo de main y
  6,6 % por debajo del límite de la sesión, porque B2 y B5 ya habían bajado el área un 9,3 %.
  Fuente: `metrics.json` de cada corrida y la regla de selección de la sesión.
- Costo en período mínimo: **ninguno, lo mejora**. Cierra a 22,5 ns con +1,580 ns en la peor ruta a
  flip-flop, contra 23,5 ns de la base (44,4 MHz contra 42,6 MHz, +4,4 %). El período mínimo real
  está por debajo de 22,5 ns y no quedó acotado por la regla de 0,5 ns (sección 8).
- Reparo: la corrida a 100 ns dejó 1 net con violación de antena (relación 1,18) y por eso no cierra;
  la de 22,5 ns cierra completo. Hay que repetir la corrida de 100 ns antes de usarla para entregar
  (sección 4ter, punto 5).
- Variante descartada: agregar `CTS_DISTANCE_BETWEEN_BUFFERS=100` (sc_fullp_t24) cambia el pin de
  capacitancia de la raíz (0,335 pF) a un net de nivel 3 (0,220 pF) pero sube el skew de setup de
  2,485 a 2,880 ns y baja el margen de 1,773 a 1,249 ns a 24 ns. Mismo conteo, peor timing: no la
  recomiendo salvo que lo que se quiera mostrar sea el valor de la capacidad, no la cuenta.
- Cero de verdad (0 slew y 0 cap) no se logró en ninguna de las 24 corridas. La única que bajó a 1
  pin de capacidad por topología del reloj fue sc_fulls6_t100 (`CTS_SINK_CLUSTERING_SIZE=6`), con
  +11,01 % de área, y esta configuración llega al mismo 1 pin sin ese costo.
### Qué de esto depende del RTL de B5 y qué no (para el frente E)

La rama candidata es A+B2 y no lleva B5, así que vale la pena separar las dos cosas:

- **No depende del RTL**: el bloque `LAYERS_RC` de `asic/rom/config_rc.yaml`. Son los valores del
  tech LEF de gf180mcuD escalados por esquina para que el promedio que usa `set_wire_rc` coincida
  con la pendiente de la extracción de OpenRCX (factores cap 2,93 / 2,59 / 2,30 y R 2,18 / 1,99 /
  1,81 para max / nom / min). La pendiente se ajustó por regresión sobre los 2.399 nets de más de
  20 µm de una corrida de este RTL, pero lo que corrige es una propiedad del stack de capas y de la
  mezcla de capas que usa el ruteo, no del RTL; el mismo bloque sirve en la candidata. Si se quiere
  verificar, `asic/signoff_pines.py <run>` imprime la regresión de la propia corrida y el bloque
  `LAYERS_RC` equivalente. Tampoco dependen del RTL las perillas del repair ni las del CTS.
- **Sí depende del RTL el punto de partida**: B5 elimina los 480 `mux2_2` de retención del banco de
  registros y con eso el conteo de slew baja de 546 / 36 (main) a 312 / 2 (B5 solo) y a 327 / 1 en
  la base de este frente. En la candidata sin B5 el punto de partida estará más cerca de los 546 /
  36 de main, así que los conteos absolutos y los porcentajes de área de las tablas de este
  documento no se trasladan: hay que volver a medir la base y las dos variantes en la candidata.
  Lo que sí se traslada es el mecanismo y el orden de magnitud del costo (la corrección del modelo
  de cable cuesta del 4 al 8 % de área de celdas estándar).
- **A favor de la candidata**: el tope de iteraciones del `repair_timing` post-CTS (RSZ-0062, 1200
  iteraciones con el peor endpoint siempre en un latch del banco, sección 4bis punto 2 y sección 4)
  es un efecto de los 480 latches de B5. Sin B5 ese tope no debería aparecer, así que la pérdida de
  período que mostró sc_g30_t24 (-2,500 ns) es, en parte, propia de B5 y puede no repetirse.

## 7. Comandos

Desde la raíz del repo principal, por la cola (`asic/encolar.sh`, `asic/esperar.sh`). Tanda 1:

```
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_base_t100 100
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_g30_t100 100 DESIGN_REPAIR_MAX_SLEW_PCT=30 DESIGN_REPAIR_MAX_CAP_PCT=30
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_c30_t100 100 RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_j30_t100 100 DESIGN_REPAIR_MAX_SLEW_PCT=30 DESIGN_REPAIR_MAX_CAP_PCT=30 RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_rc_t100 100
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_sdc2.yaml sc_sdc2_t100 100
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_rcc_t100 100 RUN_POST_GRT_DESIGN_REPAIR=true
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_rccs_t100 100 CTS_SINK_CLUSTERING_SIZE=20 CTS_SINK_CLUSTERING_MAX_DIAMETER=100
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_rccd_t100 100 CTS_DISTANCE_BETWEEN_BUFFERS=100
```

Tanda 2 (R = RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 CTS_DISTANCE_BETWEEN_BUFFERS=100):

```
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_full_t100 100 $R
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_full_t24 24 $R
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_fulls6_t100 100 $R CTS_SINK_CLUSTERING_SIZE=6
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_full0_t100 100 $R DESIGN_REPAIR_MAX_SLEW_PCT=0 DESIGN_REPAIR_MAX_CAP_PCT=0
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_g30_t24 24 DESIGN_REPAIR_MAX_SLEW_PCT=30 DESIGN_REPAIR_MAX_CAP_PCT=30
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_full_t23 23 $R
```

Post-proceso de cada tanda, desde el worktree (`bash asic/sc_post.sh "<título>" "<nota>" <tags>`):
`asic/recolectar.py` (tabla en `asic/barrido_exp.md`), `asic/verificar_cierre.py`
(`resultados/<tag>/cierre.md`) y `asic/signoff_pines.py` (`resultados/<tag>/pines.md`:
violaciones por celda que maneja y por pin de carga, nets con peor slew con largo, capacidad de
cable extraída, capacidad de pines y resistencia, nets con violación de capacitancia, y
regresión RC contra largo con el bloque `LAYERS_RC` equivalente).

Tanda 3 (C = RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30):

```
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_c30_t24 24 $C
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_c30_t23p5 23.5 $C
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_fullp_t24 24 $C CTS_DISTANCE_BETWEEN_BUFFERS=100 RUN_POST_GRT_RESIZER_TIMING=true
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc_rccp_t24 24 $C RUN_POST_GRT_RESIZER_TIMING=true
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_c50_t100 100 RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=50 GRT_DESIGN_REPAIR_MAX_CAP_PCT=50
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc_c65_t100 100 RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=65 GRT_DESIGN_REPAIR_MAX_CAP_PCT=65
```

Tanda 4 (sc2_*):

```
bash asic/encolar.sh build/exp_signoff0 asic/rom/config.yaml sc2_g30p_t24 24 DESIGN_REPAIR_MAX_SLEW_PCT=30 DESIGN_REPAIR_MAX_CAP_PCT=30 RUN_POST_GRT_RESIZER_TIMING=true
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc2_rccp_t100 100 $C RUN_POST_GRT_RESIZER_TIMING=true
bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc2_rccp_t22p5 22.5 $C RUN_POST_GRT_RESIZER_TIMING=true
```

Ruta crítica con nombres de bloque: `bash asic/layout/anotar.sh asic/rom/runs/<tag>` (KLayout en Docker) deja
`asic/rom/resultados/<tag>/layout/ruta_critica.txt`, `bloques.txt` y las figuras; hecho para sc_full_t24.
Peor ruta a flip-flop (los latches reportan 0,000): `python3 asic/ruta_ff.py asic/rom/runs/<tag>`.

## 7bis. Simulación post-PnR del netlist de la configuración recomendada

El frente no cambió el RTL, pero sí el netlist (otras celdas y otros buffers), así que conviene
dejar la comprobación hecha. Con el netlist de sc2_rccp_t22p5 (la configuración recomendada, en su
período mínimo medido) y con el de sc_full_t100:

```
export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH
make post-synth-final NETLIST_FINAL=asic/rom/runs/sc2_rccp_t22p5/final/nl/asic_top.nl.v
```

PASS en los dos casos: 320.000 ciclos, trazas del RTL y del netlist idénticas (3 cambios de salida)
y 0 valores desconocidos. Resultados en `asic/rom/resultados/sc2_rccp_t22p5/post_synth_final.md` y
`asic/rom/resultados/sc_full_t100/post_synth_final.md`.

## 8. Qué queda pendiente

1. **El período mínimo de la configuración recomendada no está acotado.** sc2_rccp_t22p5 cierra con
   +1,580 ns en la peor ruta a flip-flop, así que el mínimo está por debajo de 22,5 ns. Faltan dos
   corridas para cumplir la regla de 0,5 ns (este frente ya usó el cupo de corridas que le autorizó
   el coordinador):

   ```
   bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc3_rccp_t21p5 21.5 RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 RUN_POST_GRT_RESIZER_TIMING=true
   bash asic/encolar.sh build/exp_signoff0 asic/rom/config_rc.yaml sc3_rccp_t21   21   RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 RUN_POST_GRT_RESIZER_TIMING=true
   ```

   Esto le toca al frente B o a quien mida f_max, porque cambia la métrica de selección
   (MIPS = f_max / CPI): con 22,5 ns ya son 44,4 MHz contra los 42,6 MHz de la base.
2. **Repetir sc2_rccp_t100.** Esa corrida dejó 1 net con violación de antena (relación 1,18) y por
   eso no cierra, aunque la misma configuración a 22,5 ns cierre con 0 (sección 4ter, punto 5).
3. **Verificación funcional de la rama.** Este frente solo cambió configuración del flujo, no el
   RTL: el RTL es el de exp/rf-latch (B2+B5) en el commit 210b6a7, que verifica el frente B. Lo que
   sí se verificó aquí es el netlist que sale de la configuración recomendada: `make post-synth-final`
   PASS con trazas idénticas al RTL y 0 valores desconocidos (sección 7bis). Faltan `make check`,
   `make equiv` y `make post-synth` de la rama, que son del RTL y los corre el frente B; si el
   coordinador quiere esta rama como candidata, hay que correrlos igual.
4. **Las 10 violaciones de fanout** (buffers de hoja del reloj con 11 o 12 sumideros cuando la SDC
   pide 10) quedan en todas las variantes con `LAYERS_RC`, y 35 en las que no lo llevan. No son
   criterio de cierre y no se trabajaron; vienen del post-proceso del CTS, que agrega sumideros
   aislados a clusters ya completos.
5. **`asic/rom/config.yaml` de la rama quedó sin cambiar a propósito**, para que la base de
   comparación de las 24 corridas siga siendo la misma. La configuración recomendada está en
   `asic/rom/config_rc.yaml` más las tres variables de la sección 6(b).
