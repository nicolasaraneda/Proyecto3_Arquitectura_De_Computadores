#!/usr/bin/env python3
"""Agrupa las violaciones de max slew y max capacitancia de una corrida de LibreLane.

Uso:
    python3 asic/signoff_pines.py asic/rom/runs/<tag> [--esquina max_ss_125C_4v50] [--top 25] [--md salida.md]

Lee:
  - <run>/55-openroad-stapostpnr/<esquina>/checks.rpt (report_check_types -violators):
    secciones "max slew", "max fanout" y "max capacitance", con pin, límite, valor y slack;
  - <run>/final/nl/asic_top.nl.v: netlist final, para saber la celda de cada instancia,
    el net de cada pin y la celda que maneja cada net;
  - el liberty de la esquina (dirección de cada pin de cada celda);
  - <run>/final/spef/<rc>/asic_top.<rc>.spef: capacidad de cable extraída de cada net
    (el SPEF no incluye las capacidades de pin: "PIN_CAP NONE");
  - <run>/50-odb-reportwirelength/wire_lengths.csv: largo ruteado de cada net.

Imprime (y opcionalmente escribe en Markdown):
  1. resumen: pines con violación de slew y de capacitancia, nets distintos;
  2. violaciones de slew agrupadas por celda que maneja el net (y por pin de salida);
  3. violaciones de slew agrupadas por tipo de pin de carga (celda/pin);
  4. los nets con peor slew: driver, fanout, largo, capacidad de cable extraída,
     capacidad de pines (del liberty) y slew;
  5. lo mismo para capacitancia;
  6. regresión capacidad de cable extraída contra largo ruteado (aF/µm) y resistencia
     total contra largo (ohm/µm) sobre todos los nets, para compararla con los valores
     por unidad de largo que usa el resizer (14-openroad-dumprcvalues/resizer_values_after.rpt).
No interpreta: solo reúne y formatea datos de la corrida.
"""

import argparse
import csv
import glob
import json
import os
import re
import sys
from collections import Counter, defaultdict

PDK_ROOT = os.environ.get(
    "PDK_ROOT",
    os.path.expanduser("~/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee"),
)
LIB_DIR = os.path.join(PDK_ROOT, "gf180mcuD", "libs.ref", "gf180mcu_fd_sc_mcu7t5v0", "lib")


def liberty_pines(esquina):
    """{celda: {pin: (direccion, capacitancia)}} del liberty de esa esquina."""
    pvt = esquina.split("_", 1)[1]  # max_ss_125C_4v50 -> ss_125C_4v50
    path = os.path.join(LIB_DIR, f"gf180mcu_fd_sc_mcu7t5v0__{pvt}.lib")
    celdas = {}
    celda = pin = None
    with open(path, encoding="utf-8", errors="replace") as f:
        for linea in f:
            m = re.match(r'\s*cell\s*\(\s*"?([\w]+)"?\s*\)', linea)
            if m:
                celda = m.group(1)
                celdas[celda] = {}
                pin = None
                continue
            m = re.match(r'\s*pin\s*\(\s*"?([\w\[\]]+)"?\s*\)', linea)
            if m and celda:
                pin = m.group(1)
                celdas[celda][pin] = ["", None]
                continue
            if pin and celda:
                m = re.match(r"\s*direction\s*:\s*(\w+)", linea)
                if m:
                    celdas[celda][pin][0] = m.group(1)
                    continue
                m = re.match(r"\s*capacitance\s*:\s*([0-9.eE+-]+)", linea)
                if m and celdas[celda][pin][1] is None:
                    celdas[celda][pin][1] = float(m.group(1))
    return celdas


def leer_netlist(path):
    """instancias {inst: celda}, pin2net {(inst, pin): net}, drivers {net: (inst, pin)}."""
    texto = open(path, encoding="utf-8", errors="replace").read()
    # quitar declaraciones y quedarse con instancias: "celda inst (.p(n), ...);"
    inst = {}
    pin2net = {}
    cargas = defaultdict(list)
    patron = re.compile(r"^\s*(gf180mcu_fd_sc_mcu7t5v0__\w+)\s+(\\\S+ |\S+)\s*\((.*?)\);", re.S | re.M)
    for m in patron.finditer(texto):
        celda, nombre, cuerpo = m.group(1), m.group(2).strip(), m.group(3)
        nombre = nombre.replace("\\", "")
        inst[nombre] = celda
        for pm in re.finditer(r"\.(\w+)\(\s*(\\\S+ |[^,()]+?)\s*\)", cuerpo):
            pin, net = pm.group(1), pm.group(2).strip()
            net = net.replace("\\", "")
            pin2net[(nombre, pin)] = net
            cargas[net].append((nombre, pin))
    return inst, pin2net, cargas


def leer_checks(path):
    """{'slew': [(pin, limite, valor, slack)], 'fanout': [...], 'cap': [...]}"""
    out = {"slew": [], "fanout": [], "cap": []}
    sec = None
    for linea in open(path, encoding="utf-8", errors="replace"):
        if re.match(r"^Pin\s+Limit\s+Slew", linea):
            sec = "slew"
            continue
        if re.match(r"^Pin\s+Limit\s+Fanout", linea):
            sec = "fanout"
            continue
        if re.match(r"^Pin\s+Limit\s+Cap", linea):
            sec = "cap"
            continue
        if sec and linea.startswith("---"):
            continue
        if sec:
            p = linea.split()
            if len(p) >= 4 and re.match(r"^-?[0-9.]+$", p[1]):
                out[sec].append((p[0], float(p[1]), float(p[2]), float(p[3])))
            elif not linea.strip():
                sec = None
    return out


def leer_spef(path):
    """{net: (cap_cable_pF, R_total_ohm, n_conexiones)}"""
    nombres, nets = {}, {}
    cur = sec = None
    with open(path, encoding="utf-8", errors="replace") as f:
        for linea in f:
            if linea.startswith("*NAME_MAP"):
                sec = "map"
                continue
            if linea.startswith("*PORTS"):
                sec = "ports"
                continue
            if sec == "map" and linea.startswith("*"):
                p = linea.split()
                if len(p) == 2 and p[0][1:].isdigit():
                    nombres[p[0]] = p[1].replace("\\", "")
                continue
            if linea.startswith("*D_NET"):
                p = linea.split()
                cur = nombres.get(p[1], p[1])
                nets[cur] = [float(p[2]), 0.0, 0]
                sec = "net"
                continue
            if cur and linea.startswith("*RES"):
                sec = "res"
                continue
            if cur and linea.startswith("*CAP"):
                sec = "cap"
                continue
            if cur and linea.startswith("*CONN"):
                sec = "conn"
                continue
            if cur and linea.startswith("*END"):
                cur = sec = None
                continue
            if cur and sec == "res":
                p = linea.split()
                if len(p) >= 4:
                    nets[cur][1] += float(p[3])
            if cur and sec == "conn" and linea.startswith("*"):
                nets[cur][2] += 1
    return {k: tuple(v) for k, v in nets.items()}


def leer_largos(path):
    out = {}
    if not os.path.exists(path):
        return out
    for fila in csv.DictReader(open(path, encoding="utf-8")):
        v = fila["length_um"].strip()
        net = fila["net"].replace("\\", "")
        if v.endswith("mm"):
            out[net] = float(v[:-2]) * 1000
        elif v.endswith("µm") or v.endswith("um"):
            out[net] = float(v[:-2])
        else:
            out[net] = float(v)
    return out


def regresion(xs, ys):
    n = len(xs)
    if n < 2:
        return None
    mx, my = sum(xs) / n, sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    if sxx == 0:
        return None
    b = sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / sxx
    a = my - b * mx
    return a, b


def corto(celda):
    return celda.replace("gf180mcu_fd_sc_mcu7t5v0__", "")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("run")
    ap.add_argument("--esquina", default="max_ss_125C_4v50")
    ap.add_argument("--top", type=int, default=25)
    ap.add_argument("--md")
    a = ap.parse_args()
    run = a.run.rstrip("/")
    tag = os.path.basename(run)
    rc = a.esquina.split("_")[0]
    sta = max(glob.glob(os.path.join(run, "*-openroad-stapostpnr")), default=None)
    if not sta:
        sys.exit(f"{run}: no hay paso openroad-stapostpnr")
    checks = leer_checks(os.path.join(sta, a.esquina, "checks.rpt"))
    inst, pin2net, cargas = leer_netlist(os.path.join(run, "final", "nl", "asic_top.nl.v"))
    lib = liberty_pines(a.esquina)
    spef = leer_spef(os.path.join(run, "final", "spef", rc, f"asic_top.{rc}.spef"))
    largos = leer_largos(os.path.join(run, "50-odb-reportwirelength", "wire_lengths.csv"))

    def direccion(instancia, pin):
        c = inst.get(instancia)
        if c is None:
            return "puerto"
        return lib.get(c, {}).get(pin, ["?", None])[0]

    def driver(net):
        for i, p in cargas.get(net, []):
            if direccion(i, p) == "output":
                return i, p
        return None, None

    def cap_pines(net):
        tot = 0.0
        for i, p in cargas.get(net, []):
            if direccion(i, p) == "input":
                c = lib.get(inst[i], {}).get(p, [None, None])[1]
                tot += c or 0.0
        return tot

    def net_de(pin_str):
        if "/" in pin_str:
            i, p = pin_str.rsplit("/", 1)
            return pin2net.get((i, p)), i, p
        return pin_str, None, pin_str  # puerto

    L = []
    L.append(f"# Violaciones de slew y capacitancia de `{tag}`, esquina `{a.esquina}`\n")
    L.append(f"Fuente: `{os.path.relpath(os.path.join(sta, a.esquina, 'checks.rpt'))}`, netlist `final/nl/asic_top.nl.v`, "
             f"SPEF `final/spef/{rc}/asic_top.{rc}.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, "
             f"liberty `{a.esquina.split('_', 1)[1]}` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.\n")

    # 1. resumen
    por_net = defaultdict(list)
    for pin, lim, val, sl in checks["slew"]:
        net, i, p = net_de(pin)
        por_net[net].append((pin, lim, val, sl))
    nets_cap = defaultdict(list)
    for pin, lim, val, sl in checks["cap"]:
        net, i, p = net_de(pin)
        nets_cap[net].append((pin, lim, val, sl))
    L.append(f"Pines con violación de max slew: {len(checks['slew'])} en {len(por_net)} nets "
             f"(límite {checks['slew'][0][1] if checks['slew'] else 'n/d'} ns); de max capacitancia: {len(checks['cap'])} "
             f"(límite {checks['cap'][0][1] if checks['cap'] else 'n/d'} pF); de max fanout: {len(checks['fanout'])}.\n")

    # 2. por celda que maneja
    por_driver = Counter()
    por_driver_nets = Counter()
    for net, lista in por_net.items():
        d, dp = driver(net)
        c = corto(inst[d]) + "/" + dp if d else "puerto de entrada"
        por_driver[c] += len(lista)
        por_driver_nets[c] += 1
    L.append("## Violaciones de slew por celda que maneja el net\n")
    L.append("| celda/pin que maneja | nets | pines con violación |")
    L.append("|---|---|---|")
    for c, n in por_driver.most_common():
        L.append(f"| {c} | {por_driver_nets[c]} | {n} |")
    L.append("")

    # 3. por tipo de pin de carga
    por_carga = Counter()
    for pin, lim, val, sl in checks["slew"]:
        net, i, p = net_de(pin)
        if i is None:
            por_carga["puerto " + p] += 1
        else:
            d = direccion(i, p)
            por_carga[f"{corto(inst[i])}/{p} ({'salida' if d == 'output' else 'entrada'})"] += 1
    L.append("## Pines con violación de slew por tipo de pin\n")
    L.append("| celda/pin | tipo | pines |")
    L.append("|---|---|---|")
    for c, n in por_carga.most_common():
        nombre, tipo = c.rsplit(" (", 1) if " (" in c else (c, "")
        L.append(f"| {nombre} | {tipo.rstrip(')')} | {n} |")
    L.append("")

    # 4. peores nets
    def fila_net(net, peor, lim, unidad):
        d, dp = driver(net)
        s = spef.get(net, (None, None, None))
        largo = largos.get(net)
        fan = sum(1 for i, p in cargas.get(net, []) if direccion(i, p) == "input")
        cp = cap_pines(net)
        return (f"| {net} | {corto(inst[d]) + '/' + dp if d else 'puerto'} | {fan} | "
                f"{'n/d' if largo is None else f'{largo:.0f}'} | "
                f"{'n/d' if s[0] is None else f'{s[0]*1000:.1f}'} | {cp*1000:.1f} | "
                f"{'n/d' if s[1] is None else f'{s[1]:.0f}'} | {peor:.3f} {unidad} | {lim} |")

    L.append(f"## Los {a.top} nets con peor slew\n")
    L.append("| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |")
    L.append("|---|---|---|---|---|---|---|---|---|")
    orden = sorted(por_net.items(), key=lambda kv: max(v[2] for v in kv[1]), reverse=True)
    for net, lista in orden[: a.top]:
        peor = max(v[2] for v in lista)
        L.append(fila_net(net, peor, lista[0][1], "ns"))
    L.append("")

    L.append("## Nets con violación de capacitancia\n")
    L.append("| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |")
    L.append("|---|---|---|---|---|---|---|---|---|")
    for net, lista in sorted(nets_cap.items(), key=lambda kv: max(v[2] for v in kv[1]), reverse=True):
        L.append(fila_net(net, max(v[2] for v in lista), lista[0][1], "pF"))
    L.append("")

    # 6. regresión por extracción (max, nom, min) y bloque LAYERS_RC
    L.append("## Capacidad y resistencia de cable extraídas contra largo ruteado\n")
    rv = os.path.join(run, "14-openroad-dumprcvalues", "resizer_values_after.rpt")
    est = None
    if os.path.exists(rv):
        t = open(rv, encoding="utf-8", errors="replace").read()
        m = re.search(r"Signal\s+Avg\s+([0-9.e+-]+)\s+([0-9.e+-]+)", t)
        if m:
            est = (float(m.group(1)), float(m.group(2)))
            L.append(f"Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, "
                     f"Signal Avg, promedio del tech LEF de las capas de ruteo): {est[0]:.4f} ohm/µm y {est[1]*1e6:.1f} aF/µm.\n")
    tl = os.path.join(run, "14-openroad-dumprcvalues", "tlef_values.rpt")
    capas = []
    if os.path.exists(tl):
        for m in re.finditer(r"^(Metal\d)\s+\w+\s+([0-9.e+-]+)\s+([0-9.e+-]+)", open(tl, encoding="utf-8").read(), re.M):
            capas.append((m.group(1), float(m.group(2)), float(m.group(3))))
    L.append("| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |")
    L.append("|---|---|---|---|---|---|---|---|---|---|")
    factores = {}
    for rcn in ("max", "nom", "min"):
        sp = os.path.join(run, "final", "spef", rcn, f"asic_top.{rcn}.spef")
        if not os.path.exists(sp):
            continue
        sn = spef if rcn == rc else leer_spef(sp)
        xs, ys, rs = [], [], []
        for net, (c, r, n) in sn.items():
            l = largos.get(net)
            if l and l > 20:
                xs.append(l)
                ys.append(c * 1e6)
                rs.append(r)
        reg_c, reg_r = regresion(xs, ys), regresion(xs, rs)
        if not reg_c:
            continue
        medc = sorted(y / x for x, y in zip(xs, ys))[len(xs) // 2]
        medr = sorted(r / x for x, r in zip(xs, rs))[len(xs) // 2]
        fc = reg_c[1] / (est[1] * 1e6) if est else float("nan")
        fr = reg_r[1] / est[0] if est else float("nan")
        factores[rcn] = (fr, fc)
        L.append(f"| {rcn} | {len(xs)} | {reg_c[1]:.1f} | {reg_c[0]:.0f} | {medc:.1f} | {reg_r[1]:.3f} | {reg_r[0]:.1f} | {medr:.3f} | {fc:.2f} | {fr:.2f} |")
    L.append("")
    if capas and factores:
        L.append("Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, "
                 "de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):\n")
        L.append("```yaml")
        L.append("LAYERS_RC:")
        for rcn, (fr, fc) in factores.items():
            L.append(f'  "{rcn}_*":')
            for nombre, r0, c0 in capas:
                L.append(f"    {nombre}: {{res: {r0*fr:.5f}, cap: {c0*fc:.4e}}}")
        L.append("```")
    L.append("")
    texto = "\n".join(L) + "\n"
    print(texto)
    if a.md:
        os.makedirs(os.path.dirname(a.md) or ".", exist_ok=True)
        open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
