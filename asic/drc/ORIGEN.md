# Deck de DRC de KLayout para GF180MCU

`gf180mcu.drc` es el deck completo de reglas de diseño de GF180MCU para KLayout,
copiado sin cambios de `rules/klayout/drc/gf180mcu.drc` del repositorio
[google/globalfoundries-pdk-libs-gf180mcu_fd_pr](https://github.com/google/globalfoundries-pdk-libs-gf180mcu_fd_pr),
commit `b239189ef05aa6c83d241799163695b70f78d0d1` (21-08-2022, el último que toca esa
carpeta). Licencia Apache 2.0 (GlobalFoundries PDK Authors).

Por qué está acá: la copia del PDK que instala ciel para LibreLane 3.0.16
(`gf180mcuD/libs.tech/klayout/tech/drc/gf180mcu.drc`) es una plantilla que incluye
sus reglas con `# %include rule_decks/*.drc`, pero la carpeta `rule_decks/` no viene
en el PDK: el archivo no contiene ninguna regla (`grep -c ".output(" ` da 0). Por eso
LibreLane no define `KLAYOUT_DRC_RUNSET` para gf180mcuD y salta el paso `KLayout.DRC`.
El deck de este directorio es la versión monolítica anterior del mismo repositorio,
con 729 chequeos, que corre sola. Se usa con `asic/drc_klayout.sh`.

Único cambio respecto del archivo original: el formateador del log usaba el
comando externo `pmap` para imprimir la memoria usada, que no existe en la imagen
de Docker, y hacía fallar el deck en la primera línea de log; se reemplazó por
`RBA::Timer.memory_size`, como hace la plantilla nueva del PDK. No cambia ninguna regla.
