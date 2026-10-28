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
`pines.md`, reportes). Tags `sc_*`.

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

Las dos capacitancias del árbol de reloj no las mueve el resizer (los nets de reloj no se tocan en
`repair_design`): dependen de la topología que construye TritonCTS. Con el árbol por defecto viola
la raíz (0,33 pF); con `CTS_DISTANCE_BETWEEN_BUFFERS=100` la raíz baja pero violan dos nets de nivel
3 (0,20 a 0,23 pF); con clusters de 6 sumideros queda uno (0,202). `CTS_MAX_CAP` no cambia el árbol
(B1) y `CTS_SINK_CLUSTERING_SIZE=20` con diámetro 100 µm lo empeora (sc_rccs: 4 nets). Dejar el
árbol en cero exige pagar área de buffers de reloj (sc_fulls6, +11 %) o aceptar 1 o 2 pines a 0,2 a
0,23 pF contra un límite de la SDC de 0,2 pF (el liberty permite 1,83 pF en clkbuf_8 y 3,93 en clkbuf_16).

## 6. Configuración recomendada

(pendiente: tanda 2)

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

Ruta crítica con nombres de bloque: `bash asic/layout/anotar.sh asic/rom/runs/<tag>` (KLayout en Docker) deja
`asic/rom/resultados/<tag>/layout/ruta_critica.txt`, `bloques.txt` y las figuras; hecho para sc_full_t24.
Peor ruta a flip-flop (los latches reportan 0,000): `python3 asic/ruta_ff.py asic/rom/runs/<tag>`.
