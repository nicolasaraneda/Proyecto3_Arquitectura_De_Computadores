#!/usr/bin/env python3
"""Arma el GIF del chip construyéndose con los cuadros de asic/layout/animacion.py.

Uso: python3 asic/layout/gif.py asic/rom/resultados/final/animacion docs/figuras/construccion.gif
Necesita Pillow (instalado en el entorno de LibreLane: source ~/herramientas/librelane/bin/activate).
Cada cuadro dura 1,2 s y el último 3 s; el GIF se repite.
"""
import os
import sys

from PIL import Image

carpeta, salida = sys.argv[1], sys.argv[2]
cuadros = sorted(f for f in os.listdir(carpeta) if f.endswith(".png"))
imgs = [Image.open(os.path.join(carpeta, f)).convert("P", palette=Image.ADAPTIVE, colors=128) for f in cuadros]
dur = [1200] * (len(imgs) - 1) + [3000]
os.makedirs(os.path.dirname(salida) or ".", exist_ok=True)
imgs[0].save(salida, save_all=True, append_images=imgs[1:], duration=dur, loop=0, optimize=True)
print(f"escrito {salida} con {len(imgs)} cuadros ({os.path.getsize(salida) // 1024} KB)")
