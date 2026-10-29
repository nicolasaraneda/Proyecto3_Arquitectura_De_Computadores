# Potencia con actividad real de la corrida final (D23)

Potencia del macro de la corrida final (`asic/rom/runs/final`, T = 100 ns, FP_CORE_UTIL = 40 %, RTL
del pipeline más el modelo de cable del resizer) calculada por OpenSTA con la actividad de
conmutación de una simulación del netlist post-PnR ejecutando el juego real, en vez de la actividad
por defecto que usó el flujo (los 9,620 mW de
`57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`).

Todo lo de este documento es un cálculo de OpenSTA sobre el netlist, los parásitos y el liberty, con
actividad tomada de una simulación funcional sin retardos; no es una medición sobre silicio. Cada
número tiene su archivo de origen en `asic/potencia/resultados/`. El documento de v1 se conserva en
`asic/potencia/resultado_v1.md` y sus reportes en `asic/potencia/resultados_v1/`.

Se corrió con `bash asic/potencia/correr.sh todo`. Las dos ventanas que dependen del instante en que
el display pasa a 01 se corrieron 22 ciclos respecto de v1, porque con el core nuevo ese evento está
en el ciclo 262.172 y no en el 262.194 (`build/post_synth/traza_netlist_final.txt`, de
`make post-synth-final`); las otras dos son lazos en régimen y quedaron en los mismos ciclos, para
que la comparación con v1 sea de la misma fase del juego.

## 1. Resumen

| Esquina | Flujo (sin actividad) | Solo reloj | Pantalla de inicio (polling) | Espera de 3 s de la ronda | Alrededor del 01 en el display | Ráfaga round_begin |
|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 9,620 mW | 9,734 mW | 13,936 mW (+44,9 %) | **16,615 mW (+72,7 %)** | 15,906 mW (+65,3 %) | 15,912 mW (+65,4 %) |
| `max_ss_125C_4v50` | 7,919 mW | 8,013 mW | 11,508 mW (+45,3 %) | 13,717 mW (+73,2 %) | 13,133 mW (+65,8 %) | 13,137 mW (+65,9 %) |
| `min_ff_n40C_5v50` | 11,814 mW | 11,930 mW | 17,025 mW (+44,1 %) | 20,287 mW (+71,7 %) | 19,423 mW (+64,4 %) | 19,429 mW (+64,5 %) |

Origen: `resultados/{defecto,cero,polling,espera,display,rafaga}_<esquina>.rpt`, fila `Total` de
`report_power`. Las 9 esquinas están en `resultados/tablas.md` (83 reportes). La esquina de mayor
potencia es `max_ff_n40C_5v50` con 21,279 mW en la ventana de espera.

## 2. Comparación con v1 y con la candidata sin modelo de cable

Las tres son el mismo programa, el mismo testbench y la misma ventana; cambia el diseño.

| Diseño | Sin actividad (nom_tt) | Polling (nom_tt) | Polling (max_ss) | Polling (min_ff) | Origen |
|---|---|---|---|---|---|
| v1 (`main` antes de integrar) | 8,971 mW | 11,504 mW | 9,514 mW | 14,040 mW | `asic/potencia/resultados_v1/` |
| `exp/candidata` (el RTL nuevo con el flujo de v1) | 8,597 mW | 12,392 mW | 10,260 mW | 15,096 mW | `build/exp_candidata/asic/potencia/resultado.md` |
| **corrida final de D23** (el RTL nuevo con el modelo de cable) | **9,620 mW** | **13,936 mW** | **11,508 mW** | **17,025 mW** | `asic/potencia/resultados/` |

Lectura, en orden:

1. **El RTL nuevo solo, sin el modelo de cable, baja la potencia sin actividad** (8,597 contra
   8,971 mW) porque tiene 26 flip-flops menos (964 contra 990) y la potencia sin actividad es casi
   toda del reloj y de los pines CLK. Pero **la sube con actividad real** (12,392 contra 11,504 mW en
   polling), porque ejecuta 1,6 veces más instrucciones por ciclo: la lógica combinacional trabaja
   más.
2. **El modelo de cable la sube otra vez** (de 12,392 a 13,936 mW en polling), y eso es el precio
   directo de lo que compró: el resizer inserta 1.335 buffers de reparación de timing contra 636 en
   v1, y el CTS pone 172 buffers de reloj contra 110
   (`design__instance__count__class:timing_repair_buffer` y `clock_buffer` de cada `metrics.json`).
   Esos 62 buffers de reloj de más son los que llevan la potencia del reloj de 3,709 a 4,592 mW, un
   24 por ciento más, y esa parte se paga en todos los ciclos, haya o no actividad.
3. **En MIPS por mW el diseño nuevo gana igual.** En la ventana de polling en nom_tt: v1 rinde
   15,3 MIPS con 11,504 mW, es decir 1,33 MIPS/mW; la corrida final rinde 27,9 MIPS con 13,936 mW,
   es decir 2,00 MIPS/mW, un 50 por ciento mejor. (El MIPS es el de la frecuencia máxima y la
   potencia es a 10 MHz, así que esta razón es una comparación relativa entre los dos diseños y no
   una métrica física; la potencia a la frecuencia máxima no se midió.)

## 3. Desglose por grupo en la esquina típica

Fila por grupo de `report_power` en `nom_tt_025C_5v00`, con el valor de v1 entre paréntesis
(`resultados_v1/` del mismo modo).

| grupo | sin actividad | polling | espera de 3 s | ráfaga |
|---|---|---|---|---|
| secuencial | 5,024 mW, 52,2 % (5,259 mW, 58,6 %) | 5,253 mW, 37,7 % (5,470) | 5,310 mW, 32,0 % (5,509) | 5,290 mW, 33,2 % (5,463) |
| combinacional | 0,0036 mW, 0,0 % (0,0031) | 4,091 mW, 29,4 % (2,325) | **6,713 mW, 40,4 %** (3,537) | 6,030 mW, 37,9 % (2,999) |
| reloj | 4,592 mW, 47,7 % (3,709 mW, 41,3 %) | 4,592 mW, 33,0 % (3,709) | 4,592 mW, 27,6 % (3,709) | 4,592 mW, 28,9 % (3,709) |
| **total** | **9,620 mW** (8,971) | **13,936 mW** (11,504) | **16,615 mW** (12,755) | **15,912 mW** (12,172) |

Qué dice el desglose:

- **La estimación del flujo sigue siendo la misma trampa que en v1**: con la actividad por defecto de
  OpenSTA (0,1 transiciones por ciclo en las entradas, duty 0,5, propagada) la lógica combinacional
  queda en 0,0 por ciento, porque la actividad se extingue en los registros. Con la actividad real
  pasa a 29 a 40 por ciento del total. Por eso el número que informa el flujo subestima entre un 45 y
  un 73 por ciento según la fase del juego.
- **El reloj y los registros pesan menos que antes, aunque siguen siendo la mayor parte.** El árbol
  de reloj más la energía interna de los pines CLK de los flip-flops (las filas "reloj" y
  "secuencial" del reporte) son, en la corrida final, el **70,6 por ciento** del total en la ventana
  de polling, el **59,6** en la de espera y el **62,1** en las de display y ráfaga; en v1 eran
  79,8, 72,3, 74,1 y 75,4 por ciento. O sea que el diseño nuevo gasta proporcionalmente más en
  lógica combinacional, porque hace más trabajo por ciclo, y la fase que más lo muestra es la espera
  de tres segundos, que es un lazo de tres instrucciones con una lectura al bus en cada vuelta.
- **El árbol de reloj es el único término que no depende de la actividad**: 4,592 mW exactos en las
  cuatro ventanas, porque el reloj conmuta siempre.
- OpenSTA anotó **23.591 actividades de pin y 0 pines sin anotar**
  (`report_activity_annotation -report_unannotated` en `resultados/polling_nom_tt_025C_5v00.rpt`).

## 4. Ventanas simuladas y por qué estas

Las justifica el histograma del PC (`resultados/ventanas_pc.md`): cada ventana cae dentro de un lazo
distinto del programa. Tamaños y tiempos en `resultados/ventanas.txt`.

| Ventana | Qué cubre | Ciclos | VCD (MB) | Tiempo de simulación |
|---|---|---|---|---|
| `polling` | pantalla de inicio: lazo `ss_wait_press` (lw BTN / beq) | [500, 20500) | 130,4 | 0 min 30 s |
| `espera` | los 3 s de la ronda 1: lazo `wt_wait_loop` (lw CYCLES / sub / bltu) | [265000, 285000) | 163,4 | 5 min 46 s |
| `display` | 2.000 ciclos centrados en el cambio del display al 01 (ciclo 262.172) | [261172, 263172) | 18,1 | 4 min 32 s |
| `rafaga` | la ráfaga `round_begin` más `show_bcd` (división) y la multiplicación de `wait_tenths` | [262151, 262491) | 4,6 | 4 min 25 s |

La ventana de mayor consumo es `espera`, que es un lazo de tres instrucciones con una lectura al bus
en cada vuelta: es el caso en que el camino de datos trabaja sin parar. La de menor es `polling`, que
tiene el mismo tipo de lazo pero más corto.

## 5. Lo que no se midió

- La potencia a la frecuencia máxima (21,5 ns). Todo este documento es a 100 ns, que es el período de
  la corrida final del enunciado. A 21,5 ns la potencia dinámica subiría aproximadamente con la
  frecuencia, pero no está medida y no se informa.
- El experimento de sensibilidad al estado inicial de los flip-flops sin reset (`correr.sh xinit`),
  que v1 sí tiene en `resultado_v1.md`. No se repitió por tiempo.
- La potencia de la estrategia 2.
