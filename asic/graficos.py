#!/usr/bin/env python3
"""Gráficos de los barridos (secciones 3.4 y 3.5) a partir de los metrics.json.

Uso:
    python3 asic/graficos.py --util asic/rom/runs/final asic/rom/runs/u1_u50 ... --salida-util docs/figuras/utilizacion.png
    python3 asic/graficos.py --periodo asic/rom/runs/final asic/rom/runs/f1_t32 ... --salida-periodo docs/figuras/periodo.png

Lee final/metrics.json y resolved.json de cada corrida. Necesita matplotlib
(instalado en el entorno de LibreLane: source ~/herramientas/librelane/bin/activate).
"""
import argparse
import json
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

LENTA = "max_ss_125C_4v50"
TIPICA = "nom_tt_025C_5v00"


def cargar(run):
    m = json.load(open(os.path.join(run, "final", "metrics.json")))
    r = json.load(open(os.path.join(run, "resolved.json")))
    g = m.get
    iters = sorted((int(k.split(":")[1]), v) for k, v in m.items() if k.startswith("route__drc_errors__iter:"))
    cierra = g("timing__setup__ws", -1) >= 0 and g("timing__setup__tns", -1) == 0 and g("timing__hold__ws", -1) >= 0 and g("timing__hold__tns", -1) == 0 \
        and g("antenna__violating__nets", 1) == 0 and g("magic__drc_error__count", 1) == 0 and g("design__lvs_error__count", 1) == 0
    return {
        "tag": os.path.basename(run.rstrip("/")),
        "T": r["CLOCK_PERIOD"], "util_cfg": r["FP_CORE_UTIL"],
        "util": g("design__instance__utilization"),
        "die": g("design__die__area"), "core": g("design__core__area"),
        "stdcell": g("design__instance__area__stdcell"),
        "drc_iter": iters, "drc_iter0": iters[0][1] if iters else None, "drc_final": g("route__drc_errors"),
        "grt_wl": g("global_route__wirelength"), "wl": g("route__wirelength"), "wl_max": g("route__wirelength__max"),
        "slew": g("design__max_slew_violation__count"), "cap": g("design__max_cap_violation__count"),
        "antena": g("antenna__violating__nets"), "drc_magic": g("magic__drc_error__count"),
        "ws_ss": g(f"timing__setup__ws__corner:{LENTA}"), "ws_tt": g(f"timing__setup__ws__corner:{TIPICA}"),
        "tns_ss": g(f"timing__setup__tns__corner:{LENTA}"), "hold_ss": g(f"timing__hold__ws__corner:{LENTA}"),
        "ws": g("timing__setup__ws"), "cierra": cierra, "completa": True,
    }


def grafico_util(runs, salida):
    datos = []
    for r in runs:
        try:
            datos.append(cargar(r))
        except FileNotFoundError:
            datos.append({"tag": os.path.basename(r.rstrip("/")), "util_cfg": int(os.path.basename(r.rstrip("/")).split("_u")[-1]) if "_u" in r else None, "completa": False})
    datos.sort(key=lambda d: d["util_cfg"] or 0)
    ok = [d for d in datos if d["completa"]]
    x = [d["util_cfg"] for d in ok]
    fig, ejes = plt.subplots(2, 2, figsize=(11, 7.5))
    fig.suptitle("Barrido de FP_CORE_UTIL a T = 100 ns (configuración final)")
    a = ejes[0][0]
    a.plot(x, [d["drc_iter0"] for d in ok], "o-", label="DRC de ruteo, iteración 0")
    a.plot(x, [d["drc_final"] for d in ok], "s-", label="DRC de ruteo, última iteración")
    a.set_ylabel("violaciones de DRC del ruteo detallado")
    a.set_yscale("symlog")
    a.legend()
    a.grid(alpha=0.3)
    a = ejes[0][1]
    a.plot(x, [d["grt_wl"] / 1000 for d in ok], "o-", label="ruteo global")
    a.plot(x, [d["wl"] / 1000 for d in ok], "s-", label="ruteo detallado")
    a.set_ylabel("largo total de cables (mm)")
    a.legend()
    a.grid(alpha=0.3)
    a = ejes[1][0]
    a.plot(x, [d["slew"] for d in ok], "o-", label="max slew (pines, peor esquina)")
    a.plot(x, [d["cap"] for d in ok], "s-", label="max capacitancia (pines)")
    a.plot(x, [d["antena"] for d in ok], "^-", label="antena (nets)")
    a.set_ylabel("violaciones")
    a.set_xlabel("FP_CORE_UTIL (%)")
    a.legend()
    a.grid(alpha=0.3)
    a = ejes[1][1]
    a.plot(x, [d["die"] / 1e6 for d in ok], "o-", label="área del die (mm²)")
    a.set_ylabel("área del die (mm²)")
    a.set_xlabel("FP_CORE_UTIL (%)")
    a2 = a.twinx()
    a2.plot(x, [d["ws_ss"] for d in ok], "s--", color="tab:red", label="WNS setup esquina lenta (ns)")
    a2.set_ylabel("WNS de setup, max_ss (ns)")
    a2.axhline(0, color="tab:red", lw=0.5)
    for d in ok:
        if not d["cierra"]:
            a.annotate("no cierra", (d["util_cfg"], d["die"] / 1e6), textcoords="offset points", xytext=(0, 8), ha="center", fontsize=8, color="tab:red")
    h1, l1 = a.get_legend_handles_labels()
    h2, l2 = a2.get_legend_handles_labels()
    a.legend(h1 + h2, l1 + l2, loc="center right", fontsize=8)
    a.grid(alpha=0.3)
    fallan = [d["util_cfg"] for d in datos if not d["completa"]]
    for u in fallan:
        for eje in (ejes[0][0], ejes[0][1], ejes[1][0], ejes[1][1]):
            eje.axvline(u, color="tab:red", ls=":", lw=1)
    if fallan:
        # una sola etiqueta, junto a la primera utilizacion que no completa el flujo
        ejes[0][0].annotate("el flujo falla", (min(fallan), 1), textcoords="offset points", xytext=(4, 10),
                            ha="left", fontsize=8, color="tab:red", rotation=90)
    fig.tight_layout()
    os.makedirs(os.path.dirname(salida) or ".", exist_ok=True)
    fig.savefig(salida, dpi=150)
    print(f"escrito {salida}")
    return datos


def grafico_periodo(runs, salida):
    datos = sorted((cargar(r) for r in runs), key=lambda d: d["T"])
    x = [d["T"] for d in datos]
    fig, ejes = plt.subplots(1, 2, figsize=(11, 4.2))
    fig.suptitle("Barrido de CLOCK_PERIOD (configuración final)")
    a = ejes[0]
    a.plot(x, [d["ws_ss"] for d in datos], "o-", label="WNS setup, max_ss_125C_4v50")
    a.plot(x, [d["ws_tt"] for d in datos], "s-", label="WNS setup, nom_tt_025C_5v00")
    a.axhline(0, color="k", lw=0.8)
    a.set_xlabel("CLOCK_PERIOD (ns)")
    a.set_ylabel("WNS de setup (ns)")
    a.legend()
    a.grid(alpha=0.3)
    for d in datos:
        if not d["cierra"]:
            a.annotate("no cierra", (d["T"], d["ws_ss"]), textcoords="offset points", xytext=(0, -14), ha="center", fontsize=8, color="tab:red")
    a = ejes[1]
    a.plot(x, [d["stdcell"] / 1000 for d in datos], "o-", label="área de celdas estándar (10³ µm²)")
    a.set_xlabel("CLOCK_PERIOD (ns)")
    a.set_ylabel("área de celdas estándar (10³ µm²)")
    a2 = a.twinx()
    a2.plot(x, [d["slew"] for d in datos], "s--", color="tab:orange", label="violaciones de max slew")
    a2.set_ylabel("violaciones de max slew (pines)")
    h1, l1 = a.get_legend_handles_labels()
    h2, l2 = a2.get_legend_handles_labels()
    a.legend(h1 + h2, l1 + l2, fontsize=8)
    a.grid(alpha=0.3)
    fig.tight_layout()
    os.makedirs(os.path.dirname(salida) or ".", exist_ok=True)
    fig.savefig(salida, dpi=150)
    print(f"escrito {salida}")
    return datos


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--util", nargs="*", default=[])
    ap.add_argument("--salida-util", default="docs/figuras/utilizacion.png")
    ap.add_argument("--periodo", nargs="*", default=[])
    ap.add_argument("--salida-periodo", default="docs/figuras/periodo.png")
    a = ap.parse_args()
    if a.util:
        grafico_util(a.util, a.salida_util)
    if a.periodo:
        grafico_periodo(a.periodo, a.salida_periodo)


if __name__ == "__main__":
    main()
