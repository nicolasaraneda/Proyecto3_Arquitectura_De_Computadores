# Cómo abrir el layout final y repetir las marcas (sección 3.6)

El layout final está en `asic/rom/runs/final/final/` (no versionado; se regenera con
`make final`). Las figuras anotadas versionadas (`asic/rom/resultados/final/layout/`)
las genera `asic/layout/anotar.py` con KLayout en modo batch dentro de la imagen de
Docker de LibreLane (`make layout RUN=asic/rom/runs/final`). Esta guía es para abrir
el mismo layout en una interfaz gráfica, en Windows o en el Mac, y repetir las marcas
en vivo durante la defensa.

Hace falta tener en el computador: el PDK (`~/.ciel/ciel/gf180mcu/versions/5443...`,
unos 2 GB; en Windows está dentro de WSL en `\\wsl$\Ubuntu\home\<usuario>\.ciel\...`)
y la carpeta de la corrida (`asic/rom/runs/final`). Las rutas de abajo son relativas
a la raíz del repositorio.

## Archivos que describen el layout

| Archivo | Qué es |
|---|---|
| `asic/rom/runs/final/final/def/asic_top.def` | el layout con los nombres de instancia (`u_soc.u_core.u_rf/_2773_`), de nets y de terminales; es el que hay que abrir para buscar celdas por nombre |
| `asic/rom/runs/final/final/gds/asic_top.gds` | el GDS final (el que va a fabricación y el que se chequea con DRC y LVS); no tiene nombres de instancia, solo polígonos |
| `asic/rom/runs/final/final/odb/asic_top.odb` | la base de datos de OpenROAD, para la interfaz de OpenROAD |
| `asic/rom/resultados/final/layout/bloques.lyrdb` | base de marcadores de KLayout con los tres bloques y sus rectángulos envolventes, generada por `anotar.py` |
| PDK: `libs.tech/klayout/tech/gf180mcu.lyt`, `gf180mcu.lyp`, `gf180mcu.map` | tecnología, colores de capas y mapa de capas LEF/DEF para KLayout |
| PDK: `libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef` y `lef/gf180mcu_fd_sc_mcu7t5v0.lef` | LEF de la tecnología y de las celdas, necesarios para leer el DEF |

## Opción 1: KLayout (Windows o Mac, instalación nativa)

1. Instalar KLayout desde [klayout.de](https://www.klayout.de/build.html) (0.28 o más nuevo; la imagen de LibreLane usa 0.30.7).
2. Registrar la tecnología del PDK: `Tools > Manage Technologies > Import Technology`, elegir `gf180mcu.lyt` del PDK. Queda la tecnología `gf180mcu` con sus colores de capas.
3. Abrir el DEF con los LEF: `File > Import > LEF/DEF`. En el diálogo: archivo `asic_top.def`, tecnología `gf180mcu`, y en `LEF files` agregar el tech LEF y el LEF de celdas de la tabla. Marcar `Produce instance names` (está marcado por defecto) y `Read LEF with DEF` desactivado si se listaron los LEF a mano. El DEF se lee en segundos.
4. Marcar los bloques con la base de marcadores: `Tools > Marker Browser`, `File > Open` y elegir `bloques.lyrdb`. Aparecen las categorías `rf`, `alu`, `cycles` (una entrada por celda, con su rectángulo) y `rf_envolvente`, `alu_envolvente`, `cycles_envolvente`. Al seleccionar una categoría KLayout resalta todas sus celdas en el layout; con `Configure` se cambian el color y si se muestran todas a la vez.
5. Marcar a mano cualquier celda por su nombre jerárquico: `Edit > Select > Select by Properties` no existe para instancias, pero sí la búsqueda: `Edit > Search and Replace` (o Ctrl+F), pestaña `Find`, buscar `Instances` con la condición `name ~ "u_soc.u_core.u_rf/*"` (el nombre de instancia del DEF queda como propiedad `name`, clave 1). `Select All` resalta las 2103 celdas del register file; con `u_soc.u_core.u_id.u_alu/*` la ALU y con `u_soc.u_periph.u_cycles/*` el contador de ciclos. Con `Display > Show Properties` se ve el nombre de la instancia seleccionada.
6. Ver la ruta crítica: la lista de celdas está en `asic/rom/resultados/<tag>/layout/ruta_critica.txt` (la del período mínimo en `f1_t26`); se buscan una a una con la misma búsqueda de instancias, o se abre `ruta_critica.png`.
7. Los terminales son los textos de las capas `Metal2.PIN` (oeste y este) y `Metal3.PIN` (norte y sur): con `Display > Show Texts` se ven sus nombres sobre el borde del die.
8. Para ver el GDS en vez del DEF (`File > Open`, `asic_top.gds`, tecnología `gf180mcu`), las celdas aparecen con sus polígonos reales pero sin nombres de instancia; sirve para la DRC (`Tools > DRC`, con el deck `asic/drc/gf180mcu.drc`) y para la vista "de fabricación".

## Opción 2: OpenROAD GUI (Linux, WSL o Docker)

Dentro de la imagen de LibreLane, con una pantalla X (WSLg en Windows 11 la trae; en el Mac, XQuartz):

```bash
source ~/herramientas/librelane/bin/activate
librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --flow openinopenroad --run-tag final --last-run
```

(`--flow openinopenroad` abre el último estado de la corrida en la interfaz de
OpenROAD; `--flow openinklayout` hace lo mismo con KLayout.) En OpenROAD:

- `Find` (lupa de la barra, o `Ctrl+F`): tipo `Instance`, nombre `u_soc.u_core.u_rf/*`; `Highlight` pinta todas las instancias que coinciden. Repetir con `u_soc.u_core.u_id.u_alu/*` y `u_soc.u_periph.u_cycles/*`, eligiendo un color distinto cada vez.
- Ruta crítica: `Timing > Timing Report`, `Setup`, elegir la primera ruta: se dibuja sobre el layout con sus celdas y nets. Es la misma ruta de `ruta_critica.png` si se elige la esquina `max_ss_125C_4v50` (`Timing > Options`).
- En la consola Tcl: `report_checks -path_delay max -fields {slew cap input nets fanout}` da el mismo reporte que `max.rpt`.

## Qué se marca y dónde está

Datos de `asic/rom/resultados/final/layout/bloques.txt`:

- Register file `u_soc.u_core.u_rf`: 2103 celdas, 78.186 µm², 46 % de las celdas estándar; ocupa la mitad oeste del core (envolvente de x = 16 a 467 µm, y = 128 a 631 µm).
- ALU `u_soc.u_core.u_id.u_alu`: 615 celdas, 10.620 µm², 6,2 %; en el centro, entre el register file y los displays.
- Contador de ciclos `u_soc.u_periph.u_cycles`: 116 celdas, 3.978 µm², 2,3 %; una columna angosta junto al borde este, cerca de los periféricos.
- Terminales: oeste btn[3:0], clk (centro) y rst_n; este seg1[6:0] y seg2[6:0]; norte led[3:0]; sur spi_* (D21). Son rectángulos de metal en el borde del die, no pads: el macro se conectaría a pads de I/O de un chip completo.
