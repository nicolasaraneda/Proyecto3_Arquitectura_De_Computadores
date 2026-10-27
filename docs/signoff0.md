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

## 4. Corridas al período mínimo

(pendiente: tanda 2)

## 5. Pines que quedan y su causa

Esquina `max_ss_125C_4v50` en todos los casos (`<run>/5x-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`; agrupación en `pines.md`).

- sc_base: 327 pines en 83 nets. Celdas que manejan: nor2_1 (14 nets, los enables de clock gate `g_reg[n].en` hacia `icgtp_1/E`, 280 a 390 µm de cable,
  60 a 80 fF de cable contra 3,4 fF de pin), aoi22_1, oai211_1, aoi221_1, nor3_1 (`rf_we`, `g_reg[4].en`), oai21_1; cargas: nand2_1/A2, buf_2/I, dffq_1/D, aoi22_1/A1.
  Cap: `clknet_0_clk_regs` (raíz del H-tree de los 544 flip-flops: clkbuf_16 con ocho clkbuf_16, 181,7 fF de pines más 150 fF de 1.093 µm de cable, 0,332 pF).
  Fanout: 35 buffers de hoja del reloj con 11 o 12 sumideros (el CTS agrupa hasta 10 y la post-proceso agrega sumideros aislados).
- sc_rc: 47 pines en 19 nets: 14 enables de clock gate (nor2_1, 3,4 a 4,5 ns), `g_reg[4].en` (nor3_1, 6,05 ns), 2 aoi22_1, nand4_1, nor4_1.
  Cap: la raíz (0,332) y `clknet_3_3__leaf_clk_regs` (clkbuf_16 con 8 buffers de hoja, 580 µm, 0,204 pF).
- sc_rcc: 2 pines (un net): `g_reg[4].en`, nor3_1 -> buf_4 (buffer `wire1198` que insertó el repair), 3,498 ns. Cap: la raíz, 0,332 pF.
  El repair post-GRT con margen 10 % no lo toma; en la tanda 2 se sube a 30 %.
- sc_rccd: cap en `clknet_3_3_0_clk_regs` (0,209) y `clknet_3_6_0_clk_regs` (0,205): clkbuf_8 de nivel 3 con 8 clkbuf_8 de hoja (90 fF de pines) y
  590 a 641 µm de cable (114 a 118 fF); y `g_reg[4].en` (0,081 pF contra 0,0799 del pin del nor3_1, no del límite de 0,2 de la SDC).

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
