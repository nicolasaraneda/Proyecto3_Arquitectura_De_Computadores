#!/usr/bin/env python3
"""Tabla resumen de las ramas exp/* (bloque B) a partir de los metrics.json de sus corridas.

Uso: python3 asic/exploraciones_tabla.py [--md asic/exploraciones_tabla.md]
Para cada rama busca sus corridas en build/exp_<nombre>/asic/rom/runs/<prefijo>_t<T>
(o en asic/rom/runs para main) y calcula: período mínimo que cierra (criterio D14 más
DRC, LVS y antenas), frecuencia máxima, área de celdas estándar a 100 ns y violaciones
de slew y capacitancia a 100 ns. El CPI se toma de los valores medidos con
core_trace_tb y game_tb (constantes abajo). MIPS = f máx / CPI del juego.
"""
import argparse
import glob
import json
import os
import re
import subprocess

RAMAS = [
    # (nombre, rama git, carpeta de corridas, prefijo de tag, cambio, verificación, CPI isa, CPI juego)
    ("main (referencia)", "main", "asic/rom/runs", "f1", "configuración final D20 y D21", "check PASS, equiv ciclo a ciclo", 2.953, 2.665),
    ("exp/lsu-offset (B2)", "exp/lsu-offset", "build/exp_lsu_offset/asic/rom/runs", "b2", "offset de byte de la carga registrado en la LSU", "check PASS, equiv ciclo a ciclo", 2.953, 2.665),
    ("exp/branch-cmp (B3)", "exp/branch-cmp", "build/exp_branch_cmp/asic/rom/runs", "b3", "comparador de saltos desde el banco de registros", "check PASS, equiv ciclo a ciclo", 2.953, 2.665),
    ("exp/lsu-branch (B2+B3)", "exp/lsu-branch", "build/exp_lsu_branch/asic/rom/runs", "b23", "B2 y B3 juntos", "check PASS, equiv ciclo a ciclo", 2.953, 2.665),
    ("exp/cpi (B4)", "exp/cpi", "build/exp_cpi/asic/rom/runs", "b4", "ROM y banco combinacionales, decode en el fetch, 1 instrucción por ciclo", "check PASS, equiv funcional", 1.004, 1.312),
    ("exp/rf-latch (B5)", "exp/rf-latch", "build/exp_rf_latch/asic/rom/runs", "b5", "banco de registros con latches y clock gating", "check PASS, equiv ciclo a ciclo", 2.953, 2.665),
    ("exp/signoff (B1), variante b1c", "exp/signoff", "build/exp_signoff/asic/rom/runs", "b1c", "reparación post-GRT con márgenes de 30 % (mejor variante dentro del 1 % de área)", "mismo RTL que main", 2.953, 2.665),
    ("exp/signoff (B1), variante b1g", "exp/signoff", "build/exp_signoff/asic/rom/runs", "b1g", "márgenes del repair de placement en 30 %", "mismo RTL que main", 2.953, 2.665),
]


def cierra(m):
    g = m.get
    return (g("timing__setup__ws", -1) >= 0 and g("timing__setup__tns", -1) == 0 and g("timing__hold__ws", -1) >= 0
            and g("timing__hold__tns", -1) == 0 and g("antenna__violating__nets", 1) == 0
            and g("magic__drc_error__count", 1) == 0 and g("design__lvs_error__count", 1) == 0)


def corridas(carpeta, prefijo):
    out = {}
    for run in glob.glob(os.path.join(carpeta, prefijo + "*")):
        tag = os.path.basename(run)
        mt = re.search(r"_t(\d+)$", tag)
        if not mt or not os.path.exists(os.path.join(run, "final", "metrics.json")):
            continue
        out[(tag, int(mt.group(1)))] = json.load(open(os.path.join(run, "final", "metrics.json")))
    if prefijo == "f1":
        p = "asic/rom/runs/final/final/metrics.json"
        if os.path.exists(p):
            out[("final", 100)] = json.load(open(p))
    return out


def commit_de(rama):
    try:
        return subprocess.check_output(["git", "rev-parse", "--short", rama], text=True).strip()
    except Exception:
        return "?"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", default="asic/exploraciones_tabla.md")
    a = ap.parse_args()
    L = ["| rama | commit | cambio | verificación | corridas (T: WNS max_ss) | T mínimo que cierra (ns) | f máx (MHz) | CPI isa_test | CPI juego | MIPS (f/CPI juego) | área stdcell a 100 ns (µm²) | slew / cap a 100 ns |",
         "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for nombre, rama, carpeta, prefijo, cambio, verif, cpi_isa, cpi_juego in RAMAS:
        runs = corridas(carpeta, prefijo)
        if not runs:
            L.append(f"| {nombre} | {commit_de(rama)} | {cambio} | {verif} | sin corridas | | | {cpi_isa:.3f} | {cpi_juego:.3f} | | | |")
            continue
        det = ", ".join(f"{T}: {m['timing__setup__ws__corner:max_ss_125C_4v50']:.2f}{'' if cierra(m) else ' (no cierra)'}" for (tag, T), m in sorted(runs.items(), key=lambda x: -x[0][1]))
        que_cierran = [T for (tag, T), m in runs.items() if cierra(m)]
        tmin = min(que_cierran) if que_cierran else None
        f = 1000 / tmin if tmin else None
        m100 = [m for (tag, T), m in runs.items() if T == 100]
        area = f"{m100[0]['design__instance__area__stdcell']:.0f}" if m100 else "sin corrida a 100"
        sc = f"{m100[0]['design__max_slew_violation__count']} / {m100[0]['design__max_cap_violation__count']}" if m100 else ""
        L.append(f"| {nombre} | {commit_de(rama)} | {cambio} | {verif} | {det} | {tmin if tmin else 'ninguna cierra'} | {f'{f:.1f}' if f else ''} | {cpi_isa:.3f} | {cpi_juego:.3f} | {f'{f / cpi_juego:.1f}' if f else ''} | {area} | {sc} |")
    texto = "\n".join(L) + "\n"
    print(texto)
    open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
