#!/usr/bin/env python3
"""Junta los resultados de corridas de LibreLane y los resume en Markdown.

Uso:
    python3 asic/recolectar.py --md asic/barrido.md --titulo "Título" \\
        asic/rom/runs/p1_t100 asic/rom/runs/p1_t50 ...

Para cada corrida (carpeta asic/<config>/runs/<tag>):
  1. Copia a asic/<config>/resultados/<tag>/ los archivos que usa el
     informe: metrics.json, el reporte de síntesis (sintesis_stat.rpt), el
     resumen de timing (sta_summary.rpt), el resumen de antenas del último
     chequeo y la primera ruta de max.rpt de la esquina típica y de la más
     lenta (<esquina>_ruta_critica.rpt).
  2. Agrega al final de --md una sección con dos tablas: timing, área y
     signoff tras PnR, y síntesis (área, flip-flops y área de los módulos
     con jerarquía conservada).

Criterio de cierre (docs/decisiones.md, D14): una corrida cierra timing si
en la peor de las 9 esquinas el WNS de setup y de hold es >= 0 y el TNS es 0.
Cierra todo si además no tiene violaciones de antena, DRC ni LVS.

Una corrida sin final/metrics.json se informa como incompleta y no se copia.
No interpreta nada: solo reúne y formatea datos.
"""

import argparse
import glob
import json
import os
import re
import shutil
import sys

TIPICA = "nom_tt_025C_5v00"
LENTA = "max_ss_125C_4v50"
MODULOS = ["espino_register_file", "espino_alu", "pochoco_cycle_counter"]


def paso(run, nombre):
    """Carpeta del paso con ese nombre; si hay varias, la de número más alto."""
    cands = glob.glob(os.path.join(run, f"*-{nombre}")) + glob.glob(os.path.join(run, f"*-{nombre}-*"))
    cands = [c for c in cands if os.path.isdir(c)]
    if not cands:
        return None
    return max(cands, key=lambda c: int(os.path.basename(c).split("-", 1)[0]))


def primera_ruta(path):
    lineas = []
    with open(path, encoding="utf-8", errors="replace") as f:
        for linea in f:
            lineas.append(linea)
            if "slack (" in linea:
                break
    return "".join(lineas)


def stat_sintesis(path):
    """Área total, área secuencial, flip-flops y área de cada módulo."""
    out = {"area": None, "area_seq": None, "ff": 0, "modulos": {}}
    if not path or not os.path.exists(path):
        return out
    texto = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r"Chip area for top module '\\\\?(\S+)':\s*([0-9.]+)\s*\n\s*of which used for sequential elements:\s*([0-9.]+)", texto)
    if m:
        out["area"], out["area_seq"] = float(m.group(2)), float(m.group(3))
    for mod, area in re.findall(r"Chip area for module '\\\\?(\S+)':\s*([0-9.]+)", texto):
        out["modulos"][mod] = float(area)
    # flip-flops: suma por módulo (cada módulo se instancia una vez en este diseño)
    for bloque in re.split(r"\n=== ", texto):
        if bloque.startswith("design hierarchy"):
            continue
        for cnt, celda in re.findall(r"^\s+(\d+)\s+[0-9.E+-]+\s+(\S+)\s*$", bloque, re.M):
            if "dff" in celda or "latch" in celda:
                out["ff"] += int(cnt)
    if out["area"] is None and out["modulos"]:
        out["area"] = max(out["modulos"].values())
    return out


def contar_dly(run):
    nl = glob.glob(os.path.join(run, "final", "nl", "*.nl.v"))
    if not nl:
        return None
    n = 0
    with open(nl[0], encoding="utf-8", errors="replace") as f:
        for linea in f:
            if re.match(r"\s*gf180mcu_fd_sc_mcu7t5v0__dly", linea):
                n += 1
    return n


def f3(x):
    if x is None:
        return "n/d"
    if isinstance(x, bool):
        return "sí" if x else "no"
    if isinstance(x, (int,)) and not isinstance(x, bool):
        return str(x)
    return f"{x:.3f}"


def recolectar(run):
    run = os.path.normpath(run)
    tag = os.path.basename(run)
    cfg_dir = os.path.dirname(os.path.dirname(run))  # asic/<config>
    metrics_path = os.path.join(run, "final", "metrics.json")
    if not os.path.exists(metrics_path):
        return {"tag": tag, "cfg": cfg_dir, "incompleta": True}
    dest = os.path.join(cfg_dir, "resultados", tag)
    os.makedirs(dest, exist_ok=True)
    shutil.copy(metrics_path, os.path.join(dest, "metrics.json"))

    sint = paso(run, "yosys-synthesis")
    stat_path = os.path.join(sint, "reports", "stat.rpt") if sint else None
    if stat_path and os.path.exists(stat_path):
        shutil.copy(stat_path, os.path.join(dest, "sintesis_stat.rpt"))

    sta = paso(run, "openroad-stapostpnr")
    if sta:
        if os.path.exists(os.path.join(sta, "summary.rpt")):
            shutil.copy(os.path.join(sta, "summary.rpt"), os.path.join(dest, "sta_summary.rpt"))
        for esquina in (TIPICA, LENTA):
            mx = os.path.join(sta, esquina, "max.rpt")
            if os.path.exists(mx):
                with open(os.path.join(dest, f"{esquina}_ruta_critica.rpt"), "w", encoding="utf-8") as f:
                    f.write(primera_ruta(mx))

    ant = paso(run, "openroad-checkantennas")
    if ant and os.path.exists(os.path.join(ant, "reports", "antenna_summary.rpt")):
        shutil.copy(os.path.join(ant, "reports", "antenna_summary.rpt"), os.path.join(dest, "antenna_summary.rpt"))

    m = json.load(open(metrics_path))
    g = m.get
    cierra_t = (
        g("timing__setup__ws", -1) >= 0 and g("timing__setup__tns", -1) == 0
        and g("timing__hold__ws", -1) >= 0 and g("timing__hold__tns", -1) == 0
    )
    limpio = g("antenna__violating__nets", 1) == 0 and g("magic__drc_error__count", 1) == 0 and g("design__lvs_error__count", 1) == 0
    resolved = os.path.join(run, "resolved.json")
    periodo = None
    if os.path.exists(resolved):
        periodo = json.load(open(resolved)).get("CLOCK_PERIOD")
    st = stat_sintesis(stat_path)
    return {
        "tag": tag, "cfg": cfg_dir, "incompleta": False, "T": periodo,
        "m": m, "cierra_t": cierra_t, "cierra_todo": cierra_t and limpio,
        "dly": contar_dly(run), "sint": st,
    }


def tabla(filas):
    enc1 = [
        "corrida", "T (ns)",
        f"setup WS tt", "setup TNS tt", "setup WS ss", "setup TNS ss",
        "hold WS tt", "hold TNS tt", "hold WS ss", "hold TNS ss",
        "setup WS peor", "setup TNS peor", "hold WS peor", "hold TNS peor",
        "cierra timing",
        "área stdcell (µm²)", "utilización", "área die (µm²)",
        "antena (nets)", "DRC", "LVS", "cierra todo",
        "slew (peor)", "cap (peor)", "celdas dly",
    ]
    out = ["| " + " | ".join(enc1) + " |", "|" + "---|" * len(enc1)]
    for r in filas:
        if r["incompleta"]:
            out.append(f"| {r['tag']} | " + " | ".join(["incompleta"] + [""] * (len(enc1) - 2)) + " |")
            continue
        g = r["m"].get
        c = lambda k, e: g(f"{k}__corner:{e}")
        celdas = [
            r["tag"], f3(r["T"]),
            f3(c("timing__setup__ws", TIPICA)), f3(c("timing__setup__tns", TIPICA)),
            f3(c("timing__setup__ws", LENTA)), f3(c("timing__setup__tns", LENTA)),
            f3(c("timing__hold__ws", TIPICA)), f3(c("timing__hold__tns", TIPICA)),
            f3(c("timing__hold__ws", LENTA)), f3(c("timing__hold__tns", LENTA)),
            f3(g("timing__setup__ws")), f3(g("timing__setup__tns")),
            f3(g("timing__hold__ws")), f3(g("timing__hold__tns")),
            f3(r["cierra_t"]),
            f3(g("design__instance__area__stdcell")), f3(g("design__instance__utilization")),
            f3(g("design__die__area")),
            f3(g("antenna__violating__nets")), f3(g("magic__drc_error__count")),
            f3(g("design__lvs_error__count")), f3(r["cierra_todo"]),
            f3(g("design__max_slew_violation__count")), f3(g("design__max_cap_violation__count")),
            f3(r["dly"]),
        ]
        out.append("| " + " | ".join(celdas) + " |")
    out.append("")
    enc2 = ["corrida", "área de celdas de síntesis (µm²)", "área secuencial (µm²)", "flip-flops"] + [f"área {m} (µm²)" for m in MODULOS]
    out += ["| " + " | ".join(enc2) + " |", "|" + "---|" * len(enc2)]
    for r in filas:
        if r["incompleta"]:
            continue
        s = r["sint"]
        out.append("| " + " | ".join(
            [r["tag"], f3(s["area"]), f3(s["area_seq"]), f3(s["ff"])] + [f3(s["modulos"].get(m)) for m in MODULOS]
        ) + " |")
    return "\n".join(out) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--md", required=True, help="archivo Markdown al que se agrega la sección")
    ap.add_argument("--titulo", required=True, help="título de la sección")
    ap.add_argument("--nota", default="", help="párrafo opcional bajo el título")
    ap.add_argument("runs", nargs="+", help="carpetas de corridas (asic/<config>/runs/<tag>)")
    a = ap.parse_args()
    filas = [recolectar(r) for r in a.runs]
    seccion = f"\n## {a.titulo}\n\n"
    if a.nota:
        seccion += a.nota.strip() + "\n\n"
    seccion += (
        f"Esquina típica: `{TIPICA}`; esquina más lenta: `{LENTA}`; \"peor\" es la peor de las 9 esquinas. "
        "Generado por `asic/recolectar.py`.\n\n"
    )
    seccion += tabla(filas)
    with open(a.md, "a", encoding="utf-8") as f:
        f.write(seccion)
    sys.stdout.write(seccion)
    inc = [r["tag"] for r in filas if r["incompleta"]]
    if inc:
        print(f"\nCorridas incompletas (sin final/metrics.json): {', '.join(inc)}", file=sys.stderr)


if __name__ == "__main__":
    main()
