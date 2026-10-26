# Progreso del cierre del Proyecto 3

Lista de tareas del bloque final, con su estado y el comando para retomar cada una.
Se actualiza al cerrar cada tarea para que otra sesión pueda continuar.

Convenciones: las corridas de LibreLane se lanzan desde la raíz con el entorno
activado (`source ~/herramientas/librelane/bin/activate`); máximo 3 a la vez
(`PAR=3 bash asic/barrido.sh < lista.txt`) y con `bash asic/vigilar.sh &` corriendo
(detiene las que pasen de 40 min o si la memoria usada pasa de 26000 MB). No lanzar
corridas nuevas si `free -m` muestra más de 20000 MB usados.

| Tarea | Estado | Cómo retomar / verificar |
|---|---|---|
| A0 metrics.json versionados | hecha | `git check-ignore -v asic/rom/resultados/p1_t100/metrics.json` debe devolver la regla `!asic/**/resultados/**/metrics.json` |
| A1 D20 y D21 en la configuración | hecha | `asic/rom/config.yaml`, `asic/rom/pines.cfg`, `docs/decisiones.md` (D20, D21). Prueba: `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag prueba_pines --to Odb.CustomIOPlacement` |
| A2 `make final` | pendiente | |
| A3 barrido de período con la configuración final | pendiente | |
| A4 barrido de FP_CORE_UTIL, pines automáticos, costo | pendiente | |
| A5 síntesis jerárquica y `asic/sintesis.md` | pendiente | |
| A6a figuras del layout (`asic/layout/anotar.py`) | pendiente | |
| A6b antena de la estrategia 2 | pendiente | |
| A6c DRC de KLayout con el deck del PDK | pendiente | |
| A6d avisos de la corrida final | pendiente | |
| A6e `docs/layout.md` | pendiente | |
| A7 simulación post-síntesis (`make post-synth`) | pendiente | |
| A8 README final | pendiente | |
| A9 `docs/datos_informe.md` y `docs/defensa.md` | pendiente | |
| B1 exp/signoff | pendiente | |
| B2 exp/lsu-offset | pendiente | |
| B3 exp/branch-cmp | pendiente | |
| B4 exp/cpi | pendiente | |
| B5 exp/rf-latch (opcional) | pendiente | |
| C1 GIF del chip construyéndose (opcional) | pendiente | |
