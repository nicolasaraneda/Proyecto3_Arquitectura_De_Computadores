# Rutas criticas por tramos (seccion 3.4)

Generado por `bash asic/rutas.sh`, que llama a `asic/ruta_tramos.py` sobre el `report_checks`
de cada corrida (`asic/<config>/resultados/<tag>/max_ss_125C_4v50_ruta_critica.rpt`). Todas las
rutas son de setup, grupo `clk`, en la esquina mas lenta `max_ss_125C_4v50`, que es la que decide
el cierre (D14).

Como leer la tabla de tramos: el camino de llegada se parte en el arbol de reloj hasta el pin CLK
del flip-flop de inicio, el arco reloj a Q de ese flip-flop, un tramo por cada bloque de la
jerarquia por el que pasa el camino, y el pin D del flip-flop de llegada. Las celdas que la
sintesis aplano no tienen nombre jerarquico y se agrupan como "logica aplanada"; para saber de que
se trata, la ultima columna lista los nets, que si conservan el nombre del RTL.

La funcion de cada tramo (fetch, decode, ejecucion, acceso a memoria o write-back) esta
interpretada en `docs/datos_informe.md`, seccion 3.4.

Los nombres de inicio y de llegada que el reporte da aplanados (`_4136_`, `_4440_`) se resuelven
en el netlist de la corrida, que si guarda el nombre del RTL en el net de salida. Por ejemplo,
para la corrida del periodo minimo:

    grep -A3 "dffrnq_1 _4440_" asic/rom/runs/f2_t21p5/final/nl/asic_top.nl.v

devuelve `.Q(\u_soc.u_periph.digit_q[4] )`, es decir que el flip-flop de llegada es el bit 4 del
registro del display del periferico. Lo mismo con el de inicio: el net de la primera fila de la
tabla de tramos ya lo nombra (`u_soc.u_core.u_id.alu_op_a_sel[2]`).

### Corrida final nueva a 100 ns (tag final)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4287_`, endpoint `u_soc.u_core.u_rf/_4123_`. Generado por `python3 asic/ruta_tramos.py asic/rom/resultados/final/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.647 | `_4287_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.877 | `_4287_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 13 | 12.355 | `_2258_/ZN` | `u_soc.g_mem_rom.u_mem.a_addr_i[2]`, `net928`, `net927`, `net926`, `net925`, `_0393_`, `net815`, `net814`, `_0575_`, `net754`, `_0583_`, `_0584_`, `_0593_` |
| u_soc.u_core.u_rf | 19 | 19.154 | `u_soc.u_core.u_rf/_2889_/ZN` | `u_soc.g_mem_rom.u_mem.a_next_o[17]`, `u_soc.u_core.u_rf/net1142`, `u_soc.u_core.u_rf/net471`, `u_soc.u_core.u_rf/net470`, `u_soc.u_core.u_rf/net467`, `u_soc.u_core.u_rf/net1088`, `u_soc.u_core.u_rf/_0550_`, `u_soc.u_core.u_rf/net344`, `... |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_4123_/D` | `u_soc.u_core.u_rf/_0505_` |
| **total** | | **36.033** | | |

El total es la llegada del dato: 36.033 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 100.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.412 | `u_soc.u_core.u_rf/_4123_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.115 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.519 | `library setup time` |
| **tiempo requerido** | **101.758** | `data required time` |
| llegada del dato | -36.033 | `data arrival time` |

### Corrida final nueva al periodo minimo (f2_t21p5, 21,5 ns)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4136_`, endpoint `_4440_`. Generado por `python3 asic/ruta_tramos.py asic/rom/resultados/f2_t21p5/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.673 | `_4136_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.830 | `_4136_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 9 | 4.267 | `_2844_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net935`, `_1023_`, `net1430`, `net768`, `net767`, `net1103`, `net997`, `_1050_` |
| u_soc.u_core.u_id.u_alu | 18 | 9.048 | `u_soc.u_core.u_id.u_alu/_1126_/ZN` | `u_soc.u_core.u_id.operand_a[26]`, `u_soc.u_core.u_id.u_alu/_0006_`, `u_soc.u_core.u_id.u_alu/_0059_`, `u_soc.u_core.u_id.u_alu/_0060_`, `u_soc.u_core.u_id.u_alu/_0514_`, `u_soc.u_core.u_id.u_alu/_0515_`, `u_soc.u_core.u_id.u_alu/net1294... |
| lógica aplanada (sin nombre jerárquico) | 10 | 4.417 | `_4094_/ZN` | `u_soc.u_core.lsu_addr[31]`, `net117`, `_0384_`, `_1838_`, `_1980_`, `_1982_`, `net938`, `net24`, `net1126`, `_1986_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `_4440_/D` | `_0357_` |
| **total** | | **22.235** | | |

El total es la llegada del dato: 22.235 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 21.500 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.385 | `_4440_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.116 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.640 | `library setup time` |
| **tiempo requerido** | **23.111** | `data required time` |
| llegada del dato | -22.235 | `data arrival time` |

### Corrida final nueva a 22 ns (f2_t22)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4136_`, endpoint `_4403_`. Generado por `python3 asic/ruta_tramos.py asic/rom/resultados/f2_t22/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.643 | `_4136_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.843 | `_4136_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 10 | 4.361 | `_2844_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net935`, `_1023_`, `net770`, `net1359`, `net768`, `net1347`, `net767`, `net997`, `_1050_` |
| u_soc.u_core.u_id.u_alu | 19 | 9.590 | `u_soc.u_core.u_id.u_alu/_1126_/ZN` | `u_soc.u_core.u_id.operand_a[26]`, `u_soc.u_core.u_id.u_alu/_0006_`, `u_soc.u_core.u_id.u_alu/_0059_`, `u_soc.u_core.u_id.u_alu/_0060_`, `u_soc.u_core.u_id.u_alu/_0514_`, `u_soc.u_core.u_id.u_alu/_0515_`, `u_soc.u_core.u_id.u_alu/net1219... |
| lógica aplanada (sin nombre jerárquico) | 9 | 4.811 | `_3994_/ZN` | `u_soc.u_core.lsu_addr[31]`, `net117`, `_0384_`, `_1838_`, `net1413`, `_1840_`, `net61`, `net58`, `_1922_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `_4403_/D` | `_0320_` |
| **total** | | **23.248** | | |

El total es la llegada del dato: 23.248 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 22.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.388 | `_4403_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.115 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.349 | `library setup time` |
| **tiempo requerido** | **23.904** | `data required time` |
| llegada del dato | -23.248 | `data arrival time` |

### exp/pipeline sin B2 con el flujo final (pr_t100)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4267_`, endpoint `u_soc.u_core.u_rf/_4131_`. Generado por `python3 asic/ruta_tramos.py build/exp_pipeline/asic/rom/resultados/pr_t100/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.730 | `_4267_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 2.630 | `_4267_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 13 | 11.383 | `wire1195/Z` | `u_soc.g_mem_rom.u_mem.a_addr_i[6]`, `net918`, `net917`, `_0389_`, `net827`, `net824`, `_0487_`, `net1237`, `net772`, `_0677_`, `net645`, `u_soc.g_mem_rom.u_mem.a_next_o[22]`, `net1196` |
| u_soc.u_core.u_rf | 20 | 19.343 | `u_soc.u_core.u_rf/_3047_/ZN` | `net1195`, `u_soc.u_core.u_rf/net1194`, `u_soc.u_core.u_rf/net357`, `u_soc.u_core.u_rf/net1171`, `u_soc.u_core.u_rf/net354`, `u_soc.u_core.u_rf/net352`, `u_soc.u_core.u_rf/_0553_`, `u_soc.u_core.u_rf/net299`, `u_soc.u_core.u_rf/net297`, ... |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_4131_/D` | `u_soc.u_core.u_rf/_0513_` |
| **total** | | **36.085** | | |

El total es la llegada del dato: 36.085 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 100.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.449 | `u_soc.u_core.u_rf/_4131_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.116 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.520 | `library setup time` |
| **tiempo requerido** | **101.796** | `data required time` |
| llegada del dato | -36.085 | `data arrival time` |

### exp/pipeline sin B2 con el flujo final (pr_t22)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4112_`, endpoint `u_soc.u_core.u_rf/_4143_`. Generado por `python3 asic/ruta_tramos.py build/exp_pipeline/asic/rom/resultados/pr_t22/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.736 | `_4112_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.757 | `_4112_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 6 | 2.990 | `_2788_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net942`, `_1025_`, `net1496`, `net1507`, `_1028_` |
| u_soc.u_core.u_id.u_alu | 13 | 8.395 | `u_soc.u_core.u_id.u_alu/_0818_/ZN` | `u_soc.u_core.u_id.operand_a[2]`, `u_soc.u_core.u_id.u_alu/_0172_`, `u_soc.u_core.u_id.u_alu/net627`, `u_soc.u_core.u_id.u_alu/_0173_`, `u_soc.u_core.u_id.u_alu/_0175_`, `u_soc.u_core.u_id.u_alu/_0178_`, `u_soc.u_core.u_id.u_alu/_0187_`,... |
| lógica aplanada (sin nombre jerárquico) | 9 | 5.444 | `_2686_/ZN` | `u_soc.u_core.lsu_addr[0]`, `net176`, `_0385_`, `_0899_`, `_0907_`, `_0913_`, `net157`, `_0945_`, `_0947_` |
| u_soc.u_core.u_rf | 4 | 3.043 | `u_soc.u_core.u_rf/_3275_/ZN` | `u_soc.u_core.rf_wdata[13]`, `u_soc.u_core.u_rf/net67`, `u_soc.u_core.u_rf/net65`, `u_soc.u_core.u_rf/_1484_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_4143_/D` | `u_soc.u_core.u_rf/_0525_` |
| **total** | | **24.366** | | |

El total es la llegada del dato: 24.366 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 22.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.417 | `u_soc.u_core.u_rf/_4143_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.116 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.515 | `library setup time` |
| **tiempo requerido** | **23.769** | `data required time` |
| llegada del dato | -24.366 | `data arrival time` |

### exp/pipeline sin B2 con el flujo final (pr_t21p5)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4112_`, endpoint `u_soc.u_core.u_rf/_4127_`. Generado por `python3 asic/ruta_tramos.py build/exp_pipeline/asic/rom/resultados/pr_t21p5/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.735 | `_4112_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.876 | `_4112_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 7 | 3.811 | `_2828_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net942`, `_1025_`, `net1541`, `net777`, `net1482`, `_1048_` |
| u_soc.u_core.u_id.u_alu | 12 | 7.865 | `u_soc.u_core.u_id.u_alu/_0818_/ZN` | `u_soc.u_core.u_id.operand_a[22]`, `u_soc.u_core.u_id.u_alu/_0078_`, `u_soc.u_core.u_id.u_alu/net637`, `u_soc.u_core.u_id.u_alu/_0080_`, `u_soc.u_core.u_id.u_alu/_0089_`, `u_soc.u_core.u_id.u_alu/_0214_`, `u_soc.u_core.u_id.u_alu/_0215_`... |
| lógica aplanada (sin nombre jerárquico) | 11 | 5.813 | `_2772_/ZN` | `u_soc.u_core.lsu_addr[0]`, `net176`, `_0385_`, `_0899_`, `_0907_`, `_0913_`, `_0961_`, `net94`, `net1543`, `_1017_`, `net84` |
| u_soc.u_core.u_rf | 4 | 2.132 | `u_soc.u_core.u_rf/_2965_/ZN` | `u_soc.u_core.rf_wdata[29]`, `u_soc.u_core.u_rf/net30`, `u_soc.u_core.u_rf/net29`, `u_soc.u_core.u_rf/_1190_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_4127_/D` | `u_soc.u_core.u_rf/_0509_` |
| **total** | | **24.232** | | |

El total es la llegada del dato: 24.232 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 21.500 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.444 | `u_soc.u_core.u_rf/_4127_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.116 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.516 | `library setup time` |
| **tiempo requerido** | **23.294** | `data required time` |
| llegada del dato | -24.232 | `data arrival time` |

### exp/pipeline sin B2 con el flujo final (pr_t21)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4112_`, endpoint `u_soc.u_core.u_rf/_3952_`. Generado por `python3 asic/ruta_tramos.py build/exp_pipeline/asic/rom/resultados/pr_t21/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.748 | `_4112_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.906 | `_4112_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 7 | 3.960 | `_2828_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net942`, `_1025_`, `net1539`, `net777`, `net1480`, `_1048_` |
| u_soc.u_core.u_id.u_alu | 12 | 7.824 | `u_soc.u_core.u_id.u_alu/_0818_/ZN` | `u_soc.u_core.u_id.operand_a[22]`, `u_soc.u_core.u_id.u_alu/_0078_`, `u_soc.u_core.u_id.u_alu/net637`, `u_soc.u_core.u_id.u_alu/_0080_`, `u_soc.u_core.u_id.u_alu/_0089_`, `u_soc.u_core.u_id.u_alu/_0214_`, `u_soc.u_core.u_id.u_alu/_0215_`... |
| lógica aplanada (sin nombre jerárquico) | 8 | 5.282 | `_2693_/ZN` | `u_soc.u_core.lsu_addr[0]`, `net176`, `_0906_`, `_0907_`, `_0913_`, `net157`, `_0951_`, `_0953_` |
| u_soc.u_core.u_rf | 3 | 2.793 | `u_soc.u_core.u_rf/_2238_/Z` | `u_soc.u_core.rf_wdata[14]`, `u_soc.u_core.u_rf/net64`, `u_soc.u_core.u_rf/net63` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_3952_/D` | `u_soc.u_core.u_rf/_0334_` |
| **total** | | **24.513** | | |

El total es la llegada del dato: 24.513 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 21.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.455 | `u_soc.u_core.u_rf/_3952_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.117 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.442 | `library setup time` |
| **tiempo requerido** | **22.880** | `data required time` |
| llegada del dato | -24.513 | `data arrival time` |

### exp/pipeline sin B2 con el flujo final (pr_t23)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4112_`, endpoint `u_soc.u_core.u_rf/_4143_`. Generado por `python3 asic/ruta_tramos.py build/exp_pipeline/asic/rom/resultados/pr_t23/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.733 | `_4112_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.768 | `_4112_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 6 | 2.976 | `_2786_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net942`, `_1025_`, `net1381`, `net779`, `_1027_` |
| u_soc.u_core.u_id.u_alu | 13 | 8.618 | `u_soc.u_core.u_id.u_alu/_0818_/ZN` | `u_soc.u_core.u_id.operand_a[1]`, `u_soc.u_core.u_id.u_alu/_0165_`, `u_soc.u_core.u_id.u_alu/net628`, `u_soc.u_core.u_id.u_alu/_0166_`, `u_soc.u_core.u_id.u_alu/_0175_`, `u_soc.u_core.u_id.u_alu/_0178_`, `u_soc.u_core.u_id.u_alu/_0187_`,... |
| lógica aplanada (sin nombre jerárquico) | 9 | 5.277 | `_2686_/ZN` | `u_soc.u_core.lsu_addr[0]`, `net176`, `_0385_`, `_0899_`, `_0907_`, `_0913_`, `net157`, `_0945_`, `_0947_` |
| u_soc.u_core.u_rf | 4 | 2.955 | `u_soc.u_core.u_rf/_3275_/ZN` | `u_soc.u_core.rf_wdata[13]`, `u_soc.u_core.u_rf/net67`, `u_soc.u_core.u_rf/net65`, `u_soc.u_core.u_rf/_1484_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_4143_/D` | `u_soc.u_core.u_rf/_0525_` |
| **total** | | **24.327** | | |

El total es la llegada del dato: 24.327 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 23.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.435 | `u_soc.u_core.u_rf/_4143_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.117 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.512 | `library setup time` |
| **tiempo requerido** | **24.790** | `data required time` |
| llegada del dato | -24.327 | `data arrival time` |

### exp/pipeline sin B2 con el flujo final (pr_t24)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4112_`, endpoint `u_soc.u_core.u_rf/_4143_`. Generado por `python3 asic/ruta_tramos.py build/exp_pipeline/asic/rom/resultados/pr_t24/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.707 | `_4112_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.894 | `_4112_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 6 | 2.803 | `_2812_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net942`, `_1025_`, `net781`, `net780`, `_1040_` |
| u_soc.u_core.u_id.u_alu | 14 | 8.670 | `u_soc.u_core.u_id.u_alu/_0818_/ZN` | `u_soc.u_core.u_id.operand_a[14]`, `u_soc.u_core.u_id.u_alu/_0112_`, `u_soc.u_core.u_id.u_alu/net635`, `u_soc.u_core.u_id.u_alu/_0117_`, `u_soc.u_core.u_id.u_alu/_0124_`, `u_soc.u_core.u_id.u_alu/_0140_`, `u_soc.u_core.u_id.u_alu/_0187_`... |
| lógica aplanada (sin nombre jerárquico) | 9 | 5.261 | `_2686_/ZN` | `u_soc.u_core.lsu_addr[0]`, `net176`, `_0385_`, `_0899_`, `_0907_`, `_0913_`, `net157`, `_0945_`, `_0947_` |
| u_soc.u_core.u_rf | 4 | 2.893 | `u_soc.u_core.u_rf/_3275_/ZN` | `u_soc.u_core.rf_wdata[13]`, `u_soc.u_core.u_rf/net67`, `u_soc.u_core.u_rf/net65`, `u_soc.u_core.u_rf/_1484_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_4143_/D` | `u_soc.u_core.u_rf/_0525_` |
| **total** | | **24.228** | | |

El total es la llegada del dato: 24.228 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 24.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.430 | `u_soc.u_core.u_rf/_4143_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.116 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.512 | `library setup time` |
| **tiempo requerido** | **25.785** | `data required time` |
| llegada del dato | -24.228 | `data arrival time` |

### Corrida final de v1 a 100 ns (historia)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4191_`, endpoint `_4309_`. Generado por `python3 asic/ruta_tramos.py asic/rom/resultados/v1_final/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.650 | `_4191_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 2.809 | `_4191_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 6 | 6.608 | `_2619_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net630`, `_0850_`, `net395`, `net391`, `_0852_` |
| u_soc.u_core.u_id.u_alu | 15 | 17.001 | `u_soc.u_core.u_id.u_alu/_1126_/ZN` | `u_soc.u_core.u_id.operand_a[1]`, `u_soc.u_core.u_id.u_alu/_0165_`, `u_soc.u_core.u_id.u_alu/_0284_`, `u_soc.u_core.u_id.u_alu/_0286_`, `u_soc.u_core.u_id.u_alu/_0297_`, `u_soc.u_core.u_id.u_alu/_0330_`, `u_soc.u_core.u_id.u_alu/_0408_`,... |
| lógica aplanada (sin nombre jerárquico) | 8 | 7.418 | `_2984_/ZN` | `u_soc.u_core.lsu_addr[31]`, `_0409_`, `_0963_`, `_1006_`, `_1055_`, `net105`, `net104`, `_1063_` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `_4309_/D` | `_0172_` |
| **total** | | **36.485** | | |

El total es la llegada del dato: 36.485 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 100.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.298 | `_4309_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.108 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.448 | `library setup time` |
| **tiempo requerido** | **101.709** | `data required time` |
| llegada del dato | -36.485 | `data arrival time` |

### Periodo minimo de v1 (f1_t24p5, 24,5 ns; historia)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4189_`, endpoint `u_soc.u_core.u_rf/_2933_`. Generado por `python3 asic/ruta_tramos.py asic/rom/resultados/f1_t24p5/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.658 | `_4189_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 2.337 | `_4189_/Q` |  |
| u_soc.u_core.u_id.u_alu | 9 | 9.500 | `u_soc.u_core.u_id.u_alu/_0829_/ZN` | `u_soc.u_core.u_id.alu_operator[1]`, `u_soc.u_core.u_id.u_alu/_0034_`, `u_soc.u_core.u_id.u_alu/_0239_`, `u_soc.u_core.u_id.u_alu/_0262_`, `u_soc.u_core.u_id.u_alu/net302`, `u_soc.u_core.u_id.u_alu/_0268_`, `u_soc.u_core.u_id.u_alu/net28... |
| lógica aplanada (sin nombre jerárquico) | 12 | 9.737 | `_2506_/ZN` | `u_soc.u_core.lsu_addr[1]`, `net186`, `_0412_`, `net182`, `_0720_`, `_0721_`, `_0729_`, `_0737_`, `net657`, `net125`, `_0760_`, `_0761_` |
| u_soc.u_core.u_rf | 2 | 1.552 | `u_soc.u_core.u_rf/_1724_/Z` | `u_soc.u_core.rf_wdata[11]`, `u_soc.u_core.u_rf/net65` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_2933_/D` | `u_soc.u_core.u_rf/_0331_` |
| **total** | | **25.784** | | |

El total es la llegada del dato: 25.784 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 24.500 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.322 | `u_soc.u_core.u_rf/_2933_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.108 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.400 | `library setup time` |
| **tiempo requerido** | **26.280** | `data required time` |
| llegada del dato | -25.784 | `data arrival time` |

### RTL de v1 con el modelo de cable al periodo minimo (co_rcm_t22, 22 ns)

Esquina `max_ss_125C_4v50`, grupo `clk`, tipo `max`. Startpoint `_4191_`, endpoint `u_soc.u_core.u_rf/_2755_`. Generado por `python3 asic/ruta_tramos.py asic/main_rc/resultados/co_rcm_t22/max_ss_125C_4v50_ruta_critica.rpt`.

| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |
|---|---|---|---|---|
| árbol de reloj (latencia de lanzamiento) | 3 | 2.690 | `_4191_/CLK` |  |
| reloj a Q del flip-flop de inicio | 1 | 1.703 | `_4191_/Q` |  |
| lógica aplanada (sin nombre jerárquico) | 6 | 2.880 | `_2619_/ZN` | `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net891`, `_0850_`, `net1385`, `net609`, `_0852_` |
| u_soc.u_core.u_id.u_alu | 13 | 8.669 | `u_soc.u_core.u_id.u_alu/_0818_/ZN` | `u_soc.u_core.u_id.operand_a[1]`, `u_soc.u_core.u_id.u_alu/_0165_`, `u_soc.u_core.u_id.u_alu/net440`, `u_soc.u_core.u_id.u_alu/_0166_`, `u_soc.u_core.u_id.u_alu/_0175_`, `u_soc.u_core.u_id.u_alu/_0178_`, `u_soc.u_core.u_id.u_alu/_0187_`,... |
| lógica aplanada (sin nombre jerárquico) | 11 | 6.070 | `_2582_/Z` | `u_soc.u_core.lsu_addr[0]`, `_0413_`, `_0721_`, `_0729_`, `_0737_`, `_0783_`, `net110`, `net899`, `net896`, `_0822_`, `_0823_` |
| u_soc.u_core.u_rf | 3 | 1.629 | `u_soc.u_core.u_rf/_1537_/Z` | `u_soc.u_core.rf_wdata[25]`, `u_soc.u_core.u_rf/net923`, `u_soc.u_core.u_rf/net24` |
| entrada al flip-flop de llegada (pin D) | 0 | 0.000 | `u_soc.u_core.u_rf/_2755_/D` | `u_soc.u_core.u_rf/_0153_` |
| **total** | | **23.642** | | |

El total es la llegada del dato: 23.642 ns (línea `data arrival time` del reporte).

#### Cálculo del tiempo requerido

| término | valor (ns) | de dónde sale |
|---|---|---|
| período del reloj (flanco de captura) | 22.000 | `clock clk (rise edge)` del segundo bloque |
| latencia del árbol de reloj hasta el flip-flop de llegada | +2.438 | `u_soc.u_core.u_rf/_2755_/CLK` del segundo bloque menos el período |
| incertidumbre del reloj | -0.250 | `clock uncertainty` |
| pesimismo de reconvergencia (CRPR) | +0.115 | `clock reconvergence pessimism` |
| setup de la biblioteca | -0.446 | `library setup time` |
| **tiempo requerido** | **23.857** | `data required time` |
| llegada del dato | -23.642 | `data arrival time` |

