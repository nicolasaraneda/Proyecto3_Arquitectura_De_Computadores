#!/usr/bin/env python3
"""Verifica los criterios de cierre de la sección 2 sobre una corrida de LibreLane.

Uso:
    python3 asic/verificar_cierre.py asic/rom/runs/final [--md salida.md]

Criterios (enunciado, sección 2, y docs/decisiones.md, D14):
  - el flujo llegó al final (existe final/metrics.json);
  - DRC de Magic limpio (magic__drc_error__count == 0);
  - LVS limpio (design__lvs_error__count == 0);
  - sin violaciones de antena (antenna__violating__nets == 0 y
    route__antenna_violation__count == 0; una violación justificada se puede
    aceptar con --antena-justificada);
  - setup y hold: WNS >= 0 y TNS == 0 en las 9 esquinas de STA_CORNERS
    (timing__setup__ws, timing__setup__tns, timing__hold__ws y
    timing__hold__tns globales son el peor valor de todas las esquinas, y se
    revisan además esquina por esquina).
Imprime una tabla con cada criterio y termina con código 0 si todos se
cumplen y 1 si alguno falla. Las violaciones de max slew y max capacitancia
no son criterio de cierre del enunciado; se informan aparte.
"""

import argparse
import json
import os
import sys

TIPICA = "nom_tt_025C_5v00"
LENTA = "max_ss_125C_4v50"


def cargar(run):
    p = os.path.join(run, "final", "metrics.json")
    if not os.path.exists(p):
        return None
    return json.load(open(p))


def esquinas(m):
    out = set()
    for k in m:
        if "__corner:" in k and k.startswith("timing__setup__ws"):
            out.add(k.split("__corner:")[1])
    return sorted(out)


def verificar(run, antena_justificada=False):
    m = cargar(run)
    filas = []
    if m is None:
        return [("flujo completo (final/metrics.json)", "no existe", False)], False
    g = m.get
    filas.append(("flujo completo (final/metrics.json)", "sí", True))
    filas.append(("DRC Magic (magic__drc_error__count)", str(g("magic__drc_error__count")), g("magic__drc_error__count") == 0))
    kl = g("klayout__drc_error__count")
    filas.append(("DRC KLayout (klayout__drc_error__count)", "no corrido en el flujo" if kl is None else str(kl), True if kl is None else kl == 0))
    filas.append(("LVS (design__lvs_error__count)", str(g("design__lvs_error__count")), g("design__lvs_error__count") == 0))
    ant_ok = g("antenna__violating__nets") == 0 and g("route__antenna_violation__count", 0) == 0
    filas.append(("antena (antenna__violating__nets)", str(g("antenna__violating__nets")), ant_ok or antena_justificada))
    for tipo in ("setup", "hold"):
        ws = g(f"timing__{tipo}__ws")
        tns = g(f"timing__{tipo}__tns")
        filas.append((f"{tipo} WNS peor esquina (ns)", f"{ws:.3f}", ws is not None and ws >= 0))
        filas.append((f"{tipo} TNS peor esquina (ns)", f"{tns:.3f}", tns == 0))
        for e in esquinas(m):
            w = g(f"timing__{tipo}__ws__corner:{e}")
            t = g(f"timing__{tipo}__tns__corner:{e}")
            filas.append((f"  {tipo} {e}: WNS / TNS", f"{w:.3f} / {t:.3f}", w >= 0 and t == 0))
    ok = all(f[2] for f in filas)
    informativas = [
        ("max slew (design__max_slew_violation__count, peor esquina)", str(g("design__max_slew_violation__count"))),
        ("max capacitancia (design__max_cap_violation__count, peor esquina)", str(g("design__max_cap_violation__count"))),
        ("área del die (µm²)", str(g("design__die__area"))),
        ("utilización", f"{g('design__instance__utilization'):.3f}"),
    ]
    return filas, ok, informativas


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("run")
    ap.add_argument("--md", help="además, escribe la tabla en este archivo Markdown")
    ap.add_argument("--antena-justificada", action="store_true", help="aceptar violaciones de antena justificadas en el informe")
    a = ap.parse_args()
    res = verificar(a.run, a.antena_justificada)
    filas, ok = res[0], res[1]
    informativas = res[2] if len(res) > 2 else []
    lineas = [f"Criterios de cierre de `{a.run}`", "", "| criterio | valor | cumple |", "|---|---|---|"]
    for nombre, valor, cumple in filas:
        lineas.append(f"| {nombre} | {valor} | {'sí' if cumple else 'NO'} |")
    if informativas:
        lineas += ["", "| dato informativo | valor |", "|---|---|"]
        for nombre, valor in informativas:
            lineas.append(f"| {nombre} | {valor} |")
    lineas += ["", f"**Resultado: {'CIERRA' if ok else 'NO CIERRA'}**"]
    texto = "\n".join(lineas) + "\n"
    print(texto)
    if a.md:
        os.makedirs(os.path.dirname(os.path.abspath(a.md)), exist_ok=True)
        with open(a.md, "w", encoding="utf-8") as f:
            f.write(texto)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
