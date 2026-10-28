#!/usr/bin/env python3
"""Peor ruta de setup que NO termina en un latch, a partir de max.rpt de una corrida.

Uso: python3 asic/ruta_ff.py <run> [--esquina max_ss_125C_4v50] [--top 3]

En la rama B5 el banco de registros usa latches con préstamo de tiempo: OpenSTA reporta
slack 0,000 en cada endpoint de latch mientras le quede préstamo, así que la primera ruta
de max.rpt y el WNS de metrics.json no dicen cuánto margen tienen las rutas a flip-flops.
Este script lee todas las rutas de <run>/*-openroad-stapostpnr/<esquina>/max.rpt, descarta
las que terminan en una instancia "*.u_lat" (latch) y muestra las de peor slack, con el
inicio, el fin, el slack, el tiempo de llegada y las celdas del camino (instancia y celda).
No interpreta: solo reordena lo que hay en max.rpt.
"""
import argparse, glob, os, re, sys

ap = argparse.ArgumentParser()
ap.add_argument("run")
ap.add_argument("--esquina", default="max_ss_125C_4v50")
ap.add_argument("--top", type=int, default=3)
a = ap.parse_args()
sta = max(glob.glob(os.path.join(a.run, "*-openroad-stapostpnr")), default=None)
if not sta:
    sys.exit("sin paso stapostpnr")
f = os.path.join(sta, a.esquina, "max.rpt")
rutas, cur = [], None
for linea in open(f, encoding="utf-8", errors="replace"):
    if linea.startswith("Startpoint:"):
        cur = {"inicio": linea.split(":", 1)[1].strip(), "celdas": [], "lineas": []}
    elif cur is None:
        continue
    elif linea.startswith("Endpoint:"):
        cur["fin"] = linea.split(":", 1)[1].strip()
    elif "data arrival time" in linea and "llegada" not in cur:
        cur["llegada"] = float(linea.split()[-4]) if len(linea.split()) >= 4 else None
    elif "time borrowed" in linea:
        cur["prestamo"] = float(linea.split()[0])
    elif "slack (" in linea:
        cur["slack"] = float(linea.split()[0])
        rutas.append(cur)
        cur = None
    else:
        m = re.search(r"[v^]\s+(\S+)\s+\((gf180mcu\S+)\)", linea)
        if m:
            cur["celdas"].append((m.group(1), m.group(2).replace("gf180mcu_fd_sc_mcu7t5v0__", "")))
ff = [r for r in rutas if not r.get("fin", "").endswith(".u_lat")]
print(f"{f}: {len(rutas)} rutas, {len(ff)} no terminan en latch")
for r in sorted(ff, key=lambda r: r["slack"])[: a.top]:
    print(f"slack {r['slack']:.3f} ns  llegada {r.get('llegada')}  {r['inicio']} -> {r['fin']}")
    print("   " + " -> ".join(f"{i} ({c})" for i, c in r["celdas"] if not i.endswith("/CLK") and not i.endswith("/CK")))
