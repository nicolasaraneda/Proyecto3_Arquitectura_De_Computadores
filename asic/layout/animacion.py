#!/usr/bin/env python3
"""Cuadros del chip construyéndose (bloque C): un PNG por etapa de la corrida.

Corre con KLayout en modo batch dentro de la imagen de LibreLane (ver anotar.sh):
    klayout -b -r asic/layout/animacion.py -rd run=asic/rom/runs/final [-rd out=...]
Toma el DEF que deja cada paso de OpenROAD (floorplan, celdas de tap, red de
potencia, terminales, placement global y detallado, árbol de reloj, ruteo global
y detallado, relleno) y lo dibuja con los colores de capas del PDK y el nombre de
la etapa. Después asic/layout/gif.py arma el GIF con esos cuadros.
"""
import os
import re
import sys

import pya

RUN = (globals().get("run") or (sys.argv[sys.argv.index("--run") + 1] if "--run" in sys.argv else None)).rstrip("/")
TAG = os.path.basename(RUN)
CFG_DIR = os.path.dirname(os.path.dirname(RUN))
OUT = globals().get("out") or os.path.join(CFG_DIR, "resultados", TAG, "animacion")
PDK_ROOT = os.environ.get("PDK_ROOT", os.path.expanduser("~/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee"))
PDK = os.environ.get("PDK", "gf180mcuD")
SCL = "gf180mcu_fd_sc_mcu7t5v0"
ANCHO = int(globals().get("ancho") or 1000)
os.makedirs(OUT, exist_ok=True)

ETAPAS = [
    ("openroad-floorplan", "1. Floorplan: die y filas de celdas"),
    ("openroad-tapendcapinsertion", "2. Celdas de tap y endcap"),
    ("openroad-generatepdn", "3. Red de distribucion de potencia (VDD, VSS)"),
    ("odb-customioplacement", "4. Terminales (D21)"),
    ("openroad-globalplacement", "5. Placement global"),
    ("openroad-repairdesignpostgpl", "6. Reparacion de diseno: buffers de fanout"),
    ("openroad-detailedplacement", "7. Placement detallado"),
    ("openroad-cts", "8. Arbol de reloj"),
    ("openroad-resizertimingpostcts", "9. Resizer: setup y hold"),
    ("openroad-globalrouting", "10. Ruteo global"),
    # Los dos pasos que agrega la configuracion de D23 (modelo de cable mas
    # reparacion despues del ruteo global). Si la corrida no los tiene, se saltan.
    ("openroad-repairdesignpostgrt", "11. Reparacion de diseno tras el ruteo global (D23)"),
    ("openroad-resizertimingpostgrt", "12. Resizer de timing tras el ruteo global (D23)"),
    ("openroad-detailedrouting", "13. Ruteo detallado"),
    ("openroad-fillinsertion", "14. Relleno: layout final"),
]

base = os.path.join(PDK_ROOT, PDK)
lyt = os.path.join(base, "libs.tech/klayout/tech/gf180mcu.lyt")
lyp = os.path.join(base, "libs.tech/klayout/tech/gf180mcu.lyp")
lym = os.path.join(base, "libs.tech/klayout/tech/gf180mcu.map")
tlef = os.path.join(base, f"libs.ref/{SCL}/techlef/{SCL}__nom.tlef")
lef = os.path.join(base, f"libs.ref/{SCL}/lef/{SCL}.lef")
tech = pya.Technology()
tech.load(lyt)
lo = tech.load_layout_options
cfg = lo.lefdef_config
cfg.map_file = lym
cfg.macro_resolution_mode = 1
cfg.read_lef_with_def = False
cfg.lef_files = [tlef, lef]

pasos = sorted(d for d in os.listdir(RUN) if re.match(r"\d+-", d))
n = 0
for sufijo, titulo in ETAPAS:
    cand = [d for d in pasos if d.endswith(sufijo)]
    if not cand:
        continue
    d = cand[-1]
    defs = [f for f in os.listdir(os.path.join(RUN, d)) if f.endswith(".def")]
    if not defs:
        continue
    deff = os.path.join(RUN, d, defs[0])
    with open(deff) as f:
        for linea in f:
            m = re.match(r"\s*UNITS DISTANCE MICRONS (\d+)", linea)
            if m:
                cfg.dbu = 1.0 / int(m.group(1))
                break
    layout = pya.Layout()
    layout.read(deff, lo)
    top = layout.top_cell()
    die = top.dbbox()
    # título como polígonos en una capa propia
    li = layout.layer(250, 0)
    tg = pya.TextGenerator.default_generator()
    alto = die.width() / 45
    reg = tg.text(titulo, layout.dbu, alto / 0.7)
    reg.move(int(die.left / layout.dbu), int((die.top + alto * 0.8) / layout.dbu))
    top.shapes(li).insert(reg)
    reg2 = tg.text(f"{TAG}: paso {d}", layout.dbu, alto * 0.6 / 0.7)
    reg2.move(int(die.left / layout.dbu), int((die.bottom - alto * 1.6) / layout.dbu))
    top.shapes(li).insert(reg2)
    lv = pya.LayoutView()
    lv.set_config("background-color", "#000000")
    lv.set_config("grid-visible", "false")
    lv.set_config("text-visible", "false")
    lv.show_layout(layout, False)
    lv.load_layer_props(lyp)
    lp = pya.LayerPropertiesNode()
    lp.source = "250/0@1"
    lp.fill_color = 0xFFFFFF
    lp.frame_color = 0xFFFFFF
    lp.dither_pattern = 0
    lv.insert_layer(lv.begin_layers(), lp)
    lv.max_hier()
    caja = pya.DBox(die.left - 5, die.bottom - alto * 2.2, die.right + 5, die.top + alto * 2.2)
    lv.zoom_box(caja)
    altopx = int(ANCHO * caja.height() / caja.width())
    salida = os.path.join(OUT, f"{n:02d}_{sufijo}.png")
    lv.save_image_with_options(salida, ANCHO, altopx, 0, 1, 0, caja, False)
    print(f"escrito {salida}")
    n += 1
print(f"{n} cuadros en {OUT}")
