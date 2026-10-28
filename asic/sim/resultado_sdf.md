# Simulación post-PnR con retardos (SDF) de la candidata, sección 3.7

Rama `exp/candidata` (frente E). Mismo método y mismos scripts que dejó el frente D1 en `main`
(`asic/sim/post_pnr_sdf.sh`, `asic/sim/renombrar_instancias.py`, `tb/post_synth_tb.v`,
objetivo `post-pnr-sdf` del Makefile; ver `asic/sim/README.md` y el `asic/sim/resultado_sdf.md`
de `main` para el detalle del método, los experimentos de calibración y la parte de CVC), pero
sobre el netlist y los SDF de la corrida `e1_pnr` de ESTA rama.

Resultado: el netlist post-PnR con los retardos anotados de las tres esquinas principales se
comporta igual que el RTL, con la misma traza de salidas y sin valores X.

## 1. Corrida e1_pnr (flujo completo con la configuración de simulación)

`asic/sim/config_pnr.yaml` de la rama, generada por `make asic/sim/config_pnr.yaml`
(`asic/sim/generar_config.py --div-bits 2 --pnr`): es `asic/rom/config.yaml` de la candidata
(D15, D20, D21 y `EarlyRead=1`) con la ROM del programa de simulación
(`asic/sim/gen/pochoco_rom.v`, `CYCLES_PER_TENTH=1`), `DebounceDivBits=2` y el orden de
terminales de D21 (`IO_PIN_ORDER_CFG: dir::../rom/pines.cfg`). Encolada con la cola de la sesión:

```
bash asic/encolar.sh build/exp_candidata asic/sim/config_pnr.yaml e1_pnr 100
```

Cierra: DRC de Magic 0, LVS 0, antenas 0, setup y hold con WNS >= 0 y TNS = 0 en las 9 esquinas
(`asic/sim/resultados/e1_pnr/cierre.md`). Área de celdas estándar 184.300 µm², 9.097 celdas,
die 414.282 µm², WNS de setup 58,590 ns y hold 0,153 ns en la peor esquina
(`asic/sim/runs/e1_pnr/final/metrics.json`). Es una corrida distinta de `pa_b2_t100` porque el
programa (ROM) y `DebounceDivBits` son los de la simulación.

## 2. Resultado por esquina

`make post-pnr-sdf ESQUINA=<esquina>` (tres ejecuciones de `vvp` del mismo binario, con el Icarus
Verilog 13.0 de la imagen `ghcr.io/librelane/librelane:3.0.16`, estímulos a +50 ns y muestreo a
+50 ns del flanco). Salidas completas en `build/post_pnr/e1_pnr/<esquina>/` (no versionadas):
`resumen.md`, `iverilog.log`, `vvp_<n>.log`, `traza_<n>.txt`, `tiempo_<n>.txt` y
`mensajes_sdf.txt`.

| esquina | ciclos | cambios de salida | con X | igual al RTL | 3 md5 iguales | tiempo real de vvp (s) | IOPATH anotados | INTERCONNECT anotados | timing checks |
|---|---|---|---|---|---|---|---|---|---|
| nom_tt_025C_5v00 | 4500 | 16 | 0 | sí (3 de 3) | sí | 82,2 / 82,8 / 75,6 | 33.247 de 35.715 | 15.543 de 15.544 | no evaluados (951 bloques ignorados) |
| max_ss_125C_4v50 | 4500 | 16 | 0 | sí (3 de 3) | sí | 61,7 / 55,4 / 59,5 | 33.247 de 35.715 | 15.543 de 15.544 | no evaluados (951 bloques ignorados) |
| min_ff_n40C_5v50 | 4500 | 16 | 0 | sí (3 de 3) | sí | 64,2 / 56,4 / 55,3 | 33.247 de 35.715 | 15.543 de 15.544 | no evaluados (951 bloques ignorados) |

El md5 de las nueve trazas del netlist y el de la traza del RTL son el mismo
(`5b6cebfb898a90a258b592fb29e64651`): las tres esquinas y las tres repeticiones dan exactamente
la misma traza de salidas que el RTL (17 líneas: ronda 01 con el display en 51, ronda 02 en 51,
pulsación incorrecta en el ciclo 1405 con EE y vuelta a la ronda 02 en el ciclo 1507).

## 3. Qué se anotó

Cada SDF de la corrida tiene 35.715 entradas IOPATH, 15.544 INTERCONNECT y 951 bloques
TIMINGCHECK con 7.173 checks (SETUP 1.902, HOLD 1.902, WIDTH 2.074, RECOVERY 172, REMOVAL 172,
PERIOD 951). Antes de simular, `asic/sim/renombrar_instancias.py` renombra las 3.404 instancias
con nombre escapado del netlist y las 19.792 referencias del SDF (0 nombres escapados sin mapa),
porque Icarus no resuelve esos nombres jerárquicos al anotar.

Mensajes de `$sdf_annotate` (`mensajes_sdf.txt`): 0 celdas no encontradas, 2.468 IOPATH sin
ModPath que case (quedan 33.247 anotados), 1 INTERCONNECT no creado (quedan 15.543) y 951 avisos
`TIMINGCHECK not supported`.

## 4. Los timing checks no se evalúan en este simulador

Icarus imprime 1.926 avisos `Timing checks are not supported` al compilar y 951
`TIMINGCHECK not supported` al anotar: los 7.173 checks de setup, hold, width, recovery, removal
y period del SDF NO se verifican en esta simulación, así que este resultado no dice nada sobre
violaciones de setup o de hold. Eso lo da el STA de las 9 esquinas del flujo
(`asic/verificar_cierre.py` sobre la corrida; para la candidata, `cierre.md` de `pa_b2_t100` y de
`pa_b2_t25p5`). El frente D1 dejó en `main` el camino con Open Verilog CVC, que sí los evalúa;
no se repitió acá por tiempo (ver la lista de lo que no se completó en el informe del frente).
