# Potencia de la candidata con actividad real (versión reducida del método del frente D3)

Rama `exp/candidata` (frente E). Se reusaron los scripts que el frente D3 dejó en `main`
(`asic/potencia/correr.sh`, `potencia.tcl`, `potencia_tb.v`, `contar_vcd.py`, `tabla.py`),
copiados a la rama con dos cambios de parametrización, documentados acá:

1. `potencia.tcl`: la corrida ya no está clavada; `set corrida` toma la variable de entorno
   `CORRIDA` y por defecto usa `asic/rom/runs/pa_b2_t100/final` (la corrida base de la candidata).
2. `correr.sh`: `NL`, `CORRIDA` y `ESQUINAS` son variables de entorno, y con `SOLO_POLLING=1`
   corre una sola ventana. Por defecto `ESQUINAS` son las tres principales.

Qué se corrió (por tiempo, es una versión reducida del documento de `main`, que tiene 4 ventanas,
9 esquinas y el experimento de sensibilidad a los flip-flops sin reset):

```
SOLO_POLLING=1 bash asic/potencia/correr.sh sim     # netlist de pa_b2_t100, ventana polling
SOLO_POLLING=1 bash asic/potencia/correr.sh sta     # OpenSTA en 3 esquinas
```

Todo lo de acá es un cálculo de OpenSTA sobre el netlist post-PnR, los parásitos extraídos y el
liberty, con la actividad de conmutación de una simulación funcional sin retardos; no es una
medición sobre silicio. Reportes en `asic/potencia/resultados/<modo o ventana>_<esquina>.rpt`.

## 1. Resultado

Ventana `polling` (ciclos 500 a 20.500: la pantalla de inicio, lazo `ss_wait_press` de lectura de
BTN), netlist de `pa_b2_t100` (constantes reales del juego, `DebounceDivBits=15`).

| esquina | flujo (sin actividad) | actividad real, polling | subida | main (polling, frente D3) |
|---|---|---|---|---|
| `nom_tt_025C_5v00` | 8,597 mW | 12,392 mW | +44,1 % | 11,504 mW |
| `max_ss_125C_4v50` | 7,098 mW | 10,260 mW | +44,5 % | 9,514 mW |
| `min_ff_n40C_5v50` | 10,529 mW | 15,096 mW | +43,4 % | 14,040 mW |

Origen: `resultados/{defecto,polling}_<esquina>.rpt`, fila `Total` de `report_power`.

Desglose en `nom_tt_025C_5v00` (`resultados/polling_nom_tt_025C_5v00.rpt` contra
`defecto_nom_tt_025C_5v00.rpt`):

| grupo | sin actividad | con actividad (polling) |
|---|---|---|
| secuencial | 5,125 mW (59,6 %) | 5,403 mW (43,6 %) |
| combinacional | 0,000 mW (0,0 %) | 3,520 mW (28,4 %) |
| reloj | 3,469 mW (40,3 %) | 3,469 mW (28,0 %) |
| total | 8,597 mW | 12,392 mW |

OpenSTA anotó 22.130 actividades de pin y 0 pines sin anotar
(`report_activity_annotation -report_unannotated` en el mismo reporte).

## 2. Lectura

- La estimación del flujo (8,597 mW) no tiene actividad combinacional: la actividad por defecto de
  OpenSTA se extingue en los registros. Con la actividad real del programa la lógica
  combinacional aporta 3,52 mW (28,4 %) y el total sube 44 % en las tres esquinas.
- Contra `main` en la misma ventana y la misma esquina (11,504 mW, `asic/potencia/resultado.md` del
  frente D3 en el repo principal): la candidata consume 12,392 mW, un 7,7 % más. Es consistente con
  lo que hace: en esos mismos ciclos ejecuta alrededor de 1,6 veces más instrucciones (CPI 1,665
  contra 2,665), así que hay más conmutación combinacional por ciclo. Por instrucción retirada la
  candidata gasta bastante menos: 12,392 mW / (1/1,665 instr. por ciclo) contra
  11,504 mW / (1/2,665), es decir 0,38 contra 0,52 nJ por instrucción a 100 ns de período
  (cálculo derivado de las dos cifras anteriores, no una medición aparte).
- Sin actividad la candidata consume 4 % MENOS que `main` en las tres esquinas (tiene 26
  flip-flops menos y el reloj domina ese modo).

## 3. Lo que no se hizo

Las ventanas `espera`, `display` y `rafaga`, las 9 esquinas, el conteo de transiciones del VCD
(`contar_vcd.py`), el histograma del PC y el experimento de sensibilidad de los flip-flops sin
reset (`xinit`), que en `main` acotan el error en -1,2 % a +1,8 %. Los ciclos de las ventanas
`display` y `rafaga` de `main` no sirven tal cual para la candidata: el juego llega a esos
eventos en otro ciclo porque ejecuta más instrucciones por ciclo, así que habría que recalcularlos
con la fase `pc` antes de usarlos.
