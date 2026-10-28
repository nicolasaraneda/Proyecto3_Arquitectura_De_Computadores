#!/usr/bin/env python3
"""Tabla de la sesión de optimización (27 y 28-10-2026) a partir de los metrics.json.

Uso: python3 asic/tabla_sesion.py asic/ramas_sesion.json [--md asic/exploraciones_tabla.md]

A diferencia de asic/exploraciones_tabla.py, que descubre las corridas de cada rama por el
prefijo del tag, acá cada fila declara EXPLÍCITAMENTE sus corridas, porque en esta sesión una
misma rama tiene corridas con configuraciones distintas (perillas del flujo) y el período
mínimo es el de una configuración concreta, no el mejor de la rama.

Formato del JSON: una lista de objetos con estas claves (las de "corridas" son rutas de
carpeta de corrida, relativas a la raíz del repositorio):

    {
      "nombre": "exp/pipeline (A)",
      "rama": "exp/pipeline",
      "cambio": "lectura del banco y decode en el fetch",
      "verificacion": "check PASS, equiv funcional, hazard_test, 0 X, post-synth PASS",
      "cpi_isa": 1.969,
      "cpi_juego": 1.665,
      "corrida_100": "build/exp_pipeline/asic/rom/runs/pa_t100",
      "corridas_periodo": ["build/exp_pipeline/asic/rom/runs/pa_t26", "..."],
      "potencia_mw": null,
      "nota": "texto opcional"
    }

Período mínimo: el menor CLOCK_PERIOD de "corridas_periodo" que cumple el criterio de cierre
(D14 más DRC, LVS y antenas). Se informa además el primer período que NO cierra, para que se
vea la resolución del barrido (regla de 0,5 ns de la sesión). f máx = 1 / T mínimo y
MIPS = f máx / CPI del juego (Ley de Hierro). Área, slew y capacitancia son los de la corrida
a 100 ns. Una corrida sin final/metrics.json se informa como incompleta.
"""

import argparse
import json
import os
import subprocess
import sys

LENTA = "max_ss_125C_4v50"


def metrics(run):
    p = os.path.join(run, "final", "metrics.json")
    if not os.path.exists(p):
        return None
    return json.load(open(p))


def periodo(run):
    p = os.path.join(run, "resolved.json")
    return float(json.load(open(p))["CLOCK_PERIOD"]) if os.path.exists(p) else None


def cierra(m):
    g = m.get
    return (g("timing__setup__ws", -1) >= 0 and g("timing__setup__tns", -1) == 0
            and g("timing__hold__ws", -1) >= 0 and g("timing__hold__tns", -1) == 0
            and g("antenna__violating__nets", 1) == 0
            and g("magic__drc_error__count", 1) == 0 and g("design__lvs_error__count", 1) == 0)


def commit_de(rama):
    try:
        return subprocess.check_output(["git", "rev-parse", "--short", rama], text=True).strip()
    except Exception:
        return "?"


def num(x, dec=0):
    return "n/d" if x is None else f"{x:,.{dec}f}".replace(",", ".")


def fila(r):
    tmin, tno, det = None, None, []
    for run in r.get("corridas_periodo", []):
        m, T = metrics(run), periodo(run)
        tag = os.path.basename(run)
        if m is None:
            det.append(f"{tag}: {'no corrida' if not os.path.isdir(run) else 'incompleta'}")
            continue
        ok = cierra(m)
        det.append(f"{T:g}: {m[f'timing__setup__ws__corner:{LENTA}']:.3f}{'' if ok else ' (no cierra)'}")
        if ok and (tmin is None or T < tmin):
            tmin = T
        if not ok and (tno is None or T > tno):
            tno = T
    f = 1000.0 / tmin if tmin else None
    mips = f / r["cpi_juego"] if f else None
    m100 = metrics(r["corrida_100"]) if r.get("corrida_100") else None
    area = m100 and m100["design__instance__area__stdcell"]
    die = m100 and m100["design__die__area"]
    sc = f"{m100['design__max_slew_violation__count']:.0f} / {m100['design__max_cap_violation__count']:.0f}" if m100 else "n/d"
    pot = r.get("potencia_mw")
    return "| " + " | ".join([
        r["nombre"], commit_de(r["rama"]), r["cambio"], r["verificacion"],
        ", ".join(det) if det else "sin barrido",
        f"{tmin:g}" if tmin else "ninguna cierra",
        f"(no cierra a {tno:g})" if tno else "sin cota",
        num(f, 1), f"{r['cpi_isa']:.3f}", f"{r['cpi_juego']:.3f}", num(mips, 1),
        num(area), num(die), sc,
        "n/d" if pot is None else f"{pot:.2f}",
        r.get("nota", ""),
    ]) + " |"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("json")
    ap.add_argument("--md", help="archivo al que se escribe la tabla (si no, solo la imprime)")
    a = ap.parse_args()
    enc = ["rama o variante", "commit", "cambio", "verificación", "barrido (T: WNS max_ss)",
           "T mínimo (ns)", "cota inferior", "f máx (MHz)", "CPI isa_test", "CPI juego",
           "MIPS", "área stdcell a 100 ns (µm²)", "área die a 100 ns (µm²)",
           "slew / cap a 100 ns", "potencia con actividad (mW)", "nota"]
    L = ["| " + " | ".join(enc) + " |", "|" + "---|" * len(enc)]
    for r in json.load(open(a.json)):
        L.append(fila(r))
    texto = "\n".join(L) + "\n"
    sys.stdout.write(texto)
    if a.md:
        open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
