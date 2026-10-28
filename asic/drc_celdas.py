#!/usr/bin/env python3
"""A qué instancia del DEF pertenece cada error de DRC de Magic.

Lee el reporte de Magic de una corrida (<run>/*-magic-drc/reports/drc.magic.rpt),
toma la esquina inferior izquierda de cada rectángulo de error y busca la
instancia colocada del DEF final cuyo rectángulo (origen del DEF más el SIZE
del LEF de la biblioteca) lo contiene. Sirve para distinguir un error del
diseño (enrutado, celdas de relleno, pozos) de un error dentro de una celda de
la biblioteca, que no se puede arreglar desde el flujo.

Uso:
    python3 asic/drc_celdas.py asic/rom/runs/<tag> [--md salida.md]
"""

import argparse
import glob
import os
import re
import sys
from collections import Counter


def tamanos_lef(run):
    """SIZE de cada macro de los LEF de celdas que usó la corrida."""
    out = {}
    lefs = []
    res = os.path.join(run, "resolved.json")
    if os.path.exists(res):
        txt = open(res, encoding="utf-8", errors="replace").read()
        lefs = [p for p in re.findall(r'"([^"]+\.lef)"', txt) if os.path.exists(p)]
    if not lefs:
        pdk = os.environ.get("PDK_ROOT", "")
        lefs = glob.glob(os.path.join(pdk, "*", "libs.ref", "*", "lef", "*.lef"))
    for l in lefs:
        t = open(l, encoding="utf-8", errors="replace").read()
        for m in re.finditer(r"MACRO (\S+)(.*?)END \1", t, re.S):
            s = re.search(r"SIZE\s+([\d.]+)\s+BY\s+([\d.]+)", m.group(2))
            if s:
                out[m.group(1)] = (float(s.group(1)), float(s.group(2)))
    return out


def instancias(deff, tam):
    txt = open(deff, encoding="utf-8", errors="replace").read()
    u = re.search(r"UNITS DISTANCE MICRONS (\d+)", txt)
    k = int(u.group(1)) if u else 1000
    out = []
    pat = re.compile(
        r"-\s+(\S+)\s+(\S+)\s*\+\s*(?:SOURCE \S+\s*\+\s*)?(?:FIXED|PLACED)"
        r"\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)")
    for m in pat.finditer(txt):
        nombre, celda, x, y = m.group(1), m.group(2), int(m.group(3)) / k, int(m.group(4)) / k
        w, h = tam.get(celda, (0.0, 0.0))
        out.append((x, y, x + w, y + h, celda, nombre.replace("\\", "")))
    return out


def errores(rpt):
    """[(regla, x, y)] del reporte de Magic (coordenadas en µm)."""
    out = []
    regla = None
    for linea in open(rpt, encoding="utf-8", errors="replace"):
        s = linea.strip()
        if not s or s.startswith("---") or s.startswith("[INFO"):
            continue
        m = re.match(r"^([\d.]+)um\s+([\d.]+)um\s+([\d.]+)um\s+([\d.]+)um$", s)
        if m and regla:
            out.append((regla, float(m.group(1)), float(m.group(2))))
        elif not m:
            regla = s
    return out


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("run")
    p.add_argument("--md")
    a = p.parse_args()
    rpts = glob.glob(os.path.join(a.run, "*magic-drc", "reports", "drc.magic.rpt"))
    deffs = glob.glob(os.path.join(a.run, "final", "def", "*.def"))
    if not rpts or not deffs:
        sys.exit(f"no encuentro drc.magic.rpt o el DEF final en {a.run}")
    errs = errores(rpts[0])
    insts = instancias(deffs[0], tamanos_lef(a.run))
    lineas = [f"Errores de DRC de Magic de `{rpts[0]}` ubicados en el DEF "
              f"`{deffs[0]}` ({len(errs)} errores, {len(insts)} instancias colocadas)\n"]
    por_celda = Counter()
    por_regla = Counter()
    vistos = {}
    for regla, x, y in errs:
        por_regla[regla] += 1
        dentro = [i for i in insts
                  if i[0] - 0.01 <= x <= i[2] + 0.01 and i[1] - 0.01 <= y <= i[3] + 0.01]
        clave = (regla, x, y)
        if dentro:
            for i in dentro:
                por_celda[i[4]] += 1
            vistos.setdefault(clave, [f"{i[4]} ({i[5]})" for i in dentro])
        else:
            por_celda["(sin instancia: enrutado o pozos)"] += 1
            vistos.setdefault(clave, ["(sin instancia)"])
    lineas.append("| regla | errores |\n|---|---|")
    for r, n in por_regla.most_common():
        lineas.append(f"| {r} | {n} |")
    lineas.append("\n| celda que contiene el error | errores |\n|---|---|")
    for c, n in por_celda.most_common():
        lineas.append(f"| `{c}` | {n} |")
    lineas.append("\n| regla | x (µm) | y (µm) | instancia |\n|---|---|---|---|")
    for (regla, x, y), quien in sorted(vistos.items(), key=lambda t: (t[0][2], t[0][1])):
        lineas.append(f"| {regla} | {x:.3f} | {y:.3f} | `{'`, `'.join(quien)}` |")
    texto = "\n".join(lineas) + "\n"
    print(texto)
    if a.md:
        os.makedirs(os.path.dirname(a.md) or ".", exist_ok=True)
        open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
