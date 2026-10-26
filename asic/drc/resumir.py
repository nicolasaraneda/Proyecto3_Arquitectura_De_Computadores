#!/usr/bin/env python3
"""Resume una base de marcadores de DRC de KLayout (.lyrdb) por regla.

Uso: python3 asic/drc/resumir.py <drc.lyrdb> [--md resumen.md] [--gds <gds>]
Imprime cuántas violaciones hay por categoría (regla) y la descripción de la
regla que trae el deck, y escribe la tabla en Markdown. Código de salida 0.
"""
import argparse
import xml.etree.ElementTree as ET
from collections import Counter


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("lyrdb")
    ap.add_argument("--md")
    ap.add_argument("--gds", default="")
    a = ap.parse_args()
    raiz = ET.parse(a.lyrdb).getroot()
    desc = {}
    for cat in raiz.iter("category"):
        n = cat.findtext("name")
        if n is not None:
            desc[n.strip("'")] = (cat.findtext("description") or "").strip()
    cuenta = Counter()
    ejemplo = {}
    for it in raiz.iter("item"):
        c = (it.findtext("category") or "").strip("'")
        cuenta[c] += 1
        if c not in ejemplo:
            v = it.find("values/value")
            ejemplo[c] = (v.text or "").strip() if v is not None else ""
    total = sum(cuenta.values())
    L = [f"# DRC de KLayout: {a.gds or a.lyrdb}", "",
         f"{total} marcadores en {len(cuenta)} reglas (de {len(desc)} reglas evaluadas por el deck). Generado por `asic/drc/resumir.py`.", ""]
    if cuenta:
        L += ["| regla | marcadores | descripción del deck | ejemplo (coordenadas en µm) |", "|---|---|---|---|"]
        for c, n in cuenta.most_common():
            L.append(f"| {c} | {n} | {desc.get(c, '')} | {ejemplo.get(c, '')} |")
    else:
        L.append("Sin violaciones: el deck no marcó ninguna regla.")
    texto = "\n".join(L) + "\n"
    print(texto)
    if a.md:
        open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
