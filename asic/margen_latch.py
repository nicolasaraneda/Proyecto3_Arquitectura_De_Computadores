#!/usr/bin/env python3
"""Margen real de setup en una corrida con latches (rama exp/fmax, frente B).

Con el banco de registros en latches (B5), OpenSTA reporta slack 0,000 en los
endpoints de latch mientras les quede préstamo de tiempo (time borrowing), así
que el WNS de setup de metrics.json queda en 0 por convención y no dice cuánto
margen tienen las rutas que terminan en flip-flops. Este script lee max.rpt de
una esquina (report_checks -path_delay max, una ruta por endpoint) y reporta:
  - la peor ruta cuyo endpoint NO es un latch (flip-flop o puerto): slack,
    inicio y fin;
  - el mayor préstamo real ("actual time borrow") entre los endpoints de latch,
    con su endpoint y el préstamo máximo disponible ("max time borrow").

Uso:
    python3 asic/margen_latch.py <run>/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt [--md salida.md]
"""

import argparse
import re
import sys


def rutas(path):
    texto = open(path, encoding="utf-8", errors="replace").read()
    bloques = re.split(r"\n(?=Startpoint: )", texto)
    out = []
    for b in bloques:
        if not b.startswith("Startpoint: "):
            continue
        m_ini = re.match(r"Startpoint: (\S+)\s*\(([^)]*)\)", b, re.S)
        m_fin = re.search(r"Endpoint: (\S+)\s*\(([^)]*)\)", b, re.S)
        m_slack = re.search(r"^\s*(-?[0-9.]+)\s+slack \((MET|VIOLATED)\)", b, re.M)
        if not (m_ini and m_fin and m_slack):
            continue
        r = {
            "inicio": m_ini.group(1), "tipo_inicio": m_ini.group(2),
            "fin": m_fin.group(1), "tipo_fin": m_fin.group(2),
            "slack": float(m_slack.group(1)),
            "latch": "latch" in m_fin.group(2),
        }
        m_b = re.search(r"actual time borrow\s+(-?[0-9.]+)", b)
        m_mb = re.search(r"max time borrow\s+(-?[0-9.]+)", b)
        m_tb = re.search(r"(-?[0-9.]+)\s+[0-9.]+\s+time borrowed from endpoint", b)
        r["prestamo"] = float(m_b.group(1)) if m_b else (float(m_tb.group(1)) if m_tb else None)
        r["prestamo_max"] = float(m_mb.group(1)) if m_mb else None
        r["texto"] = b
        out.append(r)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("max_rpt")
    ap.add_argument("--md")
    ap.add_argument("--ruta", help="escribe la peor ruta a flip-flop o puerto (bloque completo del reporte) en este archivo, para asic/layout/anotar.py -rd rpt=")
    a = ap.parse_args()
    rs = rutas(a.max_rpt)
    if not rs:
        print("no se encontraron rutas en", a.max_rpt)
        sys.exit(1)
    no_latch = [r for r in rs if not r["latch"]]
    latch = [r for r in rs if r["latch"]]
    lineas = [f"Margen real de setup en `{a.max_rpt}` ({len(rs)} rutas: {len(no_latch)} a flip-flop o puerto, {len(latch)} a latch)", ""]
    if no_latch:
        peor = min(no_latch, key=lambda r: r["slack"])
        lineas += [
            f"- Peor ruta a flip-flop o puerto: slack {peor['slack']:.3f} ns, de `{peor['inicio']}` ({peor['tipo_inicio']}) a `{peor['fin']}` ({peor['tipo_fin']}).",
        ]
    else:
        lineas += ["- No hay rutas a flip-flop o puerto en el reporte."]
    if latch:
        con_p = [r for r in latch if r["prestamo"] is not None]
        if con_p:
            pm = max(con_p, key=lambda r: r["prestamo"])
            lineas += [
                f"- Mayor préstamo de tiempo en latches: {pm['prestamo']:.3f} ns de {pm['prestamo_max']:.3f} ns disponibles, en `{pm['fin']}` (desde `{pm['inicio']}`); slack reportado {pm['slack']:.3f} ns.",
            ]
        peor_l = min(latch, key=lambda r: r["slack"])
        lineas += [f"- Peor slack entre endpoints de latch: {peor_l['slack']:.3f} ns (`{peor_l['fin']}`)."]
    if a.ruta and no_latch:
        peor = min(no_latch, key=lambda r: r["slack"])
        open(a.ruta, "w", encoding="utf-8").write(peor["texto"].rstrip("\n") + "\n")
        lineas.append(f"- Bloque de la peor ruta a flip-flop escrito en `{a.ruta}`.")
    texto = "\n".join(lineas) + "\n"
    print(texto)
    if a.md:
        open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
