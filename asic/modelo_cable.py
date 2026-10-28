#!/usr/bin/env python3
"""Deriva el bloque LAYERS_RC de la configuración final desde la extracción de una corrida.

Qué hace, en una línea: compara la capacidad y la resistencia de cable que OpenRCX
extrae del ruteo detallado con las que el resizer de OpenROAD usa para estimar, y
escala los valores por capa del tech LEF por el factor que falta, esquina por esquina.

Uso:
    python3 asic/modelo_cable.py <corrida> [--md salida.md] [--comparar asic/rom/config.yaml]

Ejemplo (el comando que produjo los valores de asic/rom/config.yaml):
    python3 asic/modelo_cable.py build/exp_rf_latch/asic/rom/runs/b5_t100 \
        --md asic/modelo_cable.md --comparar asic/rom/config.yaml

Lee de la corrida (ninguno de estos archivos se escribe a mano):
  - <run>/final/spef/{max,nom,min}/asic_top.{max,nom,min}.spef: la extracción de
    OpenRCX. De cada net toma la capacidad total de cable (el número que va en la
    línea *D_NET; el SPEF no incluye las capacidades de pin, dice "PIN_CAP NONE") y
    la resistencia total (la suma de la sección *RES).
  - <run>/*-odb-reportwirelength/wire_lengths.csv: el largo ruteado de cada net.
  - <run>/*-openroad-dumprcvalues/resizer_values_after.rpt: el par de valores
    (ohm/µm, F/µm) con que el resizer estima los parásitos, fila "Signal Avg".
  - <run>/*-openroad-dumprcvalues/tlef_values.rpt: los valores por capa del tech
    LEF del PDK, que son los que LAYERS_RC reemplaza.

Cómo calcula:
  1. Para cada extracción (max, nom, min) hace una regresión lineal de la capacidad
     de cable extraída contra el largo ruteado, sobre los nets de más de 20 µm (los
     cortos están dominados por la ordenada, que es la capacidad de las vías y de
     los extremos). La pendiente es la capacidad por unidad de largo que el ruteo
     real tiene, en aF/µm. Lo mismo con la resistencia total, en ohm/µm.
  2. Divide esa pendiente por el valor que usa el resizer: eso da el factor que le
     falta a la estimación (factor > 1 quiere decir que el resizer estima de menos).
  3. Multiplica cada valor por capa del tech LEF por el factor de su esquina y lo
     escribe como bloque LAYERS_RC, con los patrones "max_*", "nom_*" y "min_*" que
     LibreLane expande a las 9 esquinas (3 extracciones por 3 esquinas de liberty).

Con --comparar <config.yaml> compara los valores derivados con los que están escritos
en esa configuración y termina con código 1 si alguno no coincide, para que la
configuración no pueda quedar con números que la corrida ya no respalda.

Por qué el factor no es 1 y por qué importa: el resizer decide dónde poner buffers con
los parásitos que estima, y los estima con un solo par de valores promedio del tech LEF
(docs/modelo_cable.md). Si ese par estima de menos, el resizer cree que ya cumplió y
deja de reparar antes de tiempo; las violaciones aparecen recién en el STA final, que sí
usa la extracción. Corregirlo con LAYERS_RC cuesta área de celdas (más buffers) y gana
período.
"""

import argparse
import csv
import glob
import os
import re
import sys

CAPAS_ORDEN = ("Metal1", "Metal2", "Metal3", "Metal4", "Metal5")
EXTRACCIONES = ("max", "nom", "min")
LARGO_MINIMO = 20.0  # µm: nets más cortos que esto están dominados por la ordenada


def paso(run, nombre):
    """El directorio del paso <nombre> de la corrida, sin depender de su número.

    El número cambia con la configuración: la final de D23 agrega
    RepairDesignPostGRT y ResizerTimingPostGRT, así que todos los pasos
    posteriores se corren dos lugares.
    """
    c = sorted(glob.glob(os.path.join(run, f"*-{nombre}")))
    return c[-1] if c else None


def leer_spef(path):
    """{net: (capacidad de cable en pF, resistencia total en ohm)} del SPEF."""
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
                nets[cur] = [float(p[2]), 0.0]
                sec = "net"
                continue
            if cur and linea.startswith(("*RES", "*CAP", "*CONN")):
                sec = linea.split()[0][1:].lower()
                continue
            if cur and linea.startswith("*END"):
                cur = sec = None
                continue
            if cur and sec == "res":
                p = linea.split()
                if len(p) >= 4:
                    nets[cur][1] += float(p[3])
    return {k: tuple(v) for k, v in nets.items()}


def leer_largos(path):
    """{net: largo ruteado en µm} de wire_lengths.csv."""
    out = {}
    if not path or not os.path.exists(path):
        return out
    for fila in csv.DictReader(open(path, encoding="utf-8")):
        v = fila["length_um"].strip()
        net = fila["net"].replace("\\", "")
        if v.endswith("mm"):
            out[net] = float(v[:-2]) * 1000
        elif v.endswith(("µm", "um")):
            out[net] = float(v[:-2])
        else:
            out[net] = float(v)
    return out


def regresion(xs, ys):
    """Mínimos cuadrados: devuelve (ordenada, pendiente)."""
    n = len(xs)
    if n < 2:
        return None
    mx, my = sum(xs) / n, sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    if sxx == 0:
        return None
    b = sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / sxx
    return my - b * mx, b


def leer_estimacion(run):
    """(ohm/µm, F/µm) con que estima el resizer, de resizer_values_after.rpt."""
    d = paso(run, "openroad-dumprcvalues")
    if not d:
        return None
    p = os.path.join(d, "resizer_values_after.rpt")
    if not os.path.exists(p):
        return None
    m = re.search(r"Signal\s+Avg\s+([0-9.e+-]+)\s+([0-9.e+-]+)",
                  open(p, encoding="utf-8", errors="replace").read())
    return (float(m.group(1)), float(m.group(2))) if m else None


def leer_tlef(run):
    """[(capa, ohm/µm, pF/µm)] del tech LEF volcado por el flujo."""
    d = paso(run, "openroad-dumprcvalues")
    if not d:
        return []
    p = os.path.join(d, "tlef_values.rpt")
    if not os.path.exists(p):
        return []
    t = open(p, encoding="utf-8", errors="replace").read()
    capas = []
    for m in re.finditer(r"^(Metal\d)\s+\w+\s+([0-9.e+-]+)\s+([0-9.e+-]+)", t, re.M):
        capas.append((m.group(1), float(m.group(2)), float(m.group(3))))
    return [c for c in capas if c[0] in CAPAS_ORDEN]


def derivar(run):
    """Devuelve (estimacion, capas, factores, filas) de la corrida."""
    est = leer_estimacion(run)
    capas = leer_tlef(run)
    largos = leer_largos(os.path.join(paso(run, "odb-reportwirelength") or "", "wire_lengths.csv"))
    factores, filas = {}, []
    for rcn in EXTRACCIONES:
        sp = os.path.join(run, "final", "spef", rcn, f"asic_top.{rcn}.spef")
        if not os.path.exists(sp):
            continue
        spef = leer_spef(sp)
        xs, ys, rs = [], [], []
        for net, (c, r) in spef.items():
            l = largos.get(net)
            if l and l > LARGO_MINIMO:
                xs.append(l)
                ys.append(c * 1e6)   # pF -> aF
                rs.append(r)
        reg_c, reg_r = regresion(xs, ys), regresion(xs, rs)
        if not reg_c or not reg_r or not est:
            continue
        medc = sorted(y / x for x, y in zip(xs, ys))[len(xs) // 2]
        medr = sorted(r / x for x, r in zip(xs, rs))[len(xs) // 2]
        fc = reg_c[1] / (est[1] * 1e6)
        fr = reg_r[1] / est[0]
        factores[rcn] = (fr, fc)
        filas.append((rcn, len(xs), reg_c[1], reg_c[0], medc, reg_r[1], reg_r[0], medr, fc, fr))
    return est, capas, factores, filas


def bloque_yaml(capas, factores):
    L = ["LAYERS_RC:"]
    for rcn in EXTRACCIONES:
        if rcn not in factores:
            continue
        fr, fc = factores[rcn]
        L.append(f'  "{rcn}_*":')
        for nombre, r0, c0 in capas:
            L.append(f"    {nombre}: {{res: {r0 * fr:.5f}, cap: {c0 * fc:.4e}}}")
    return "\n".join(L)


def leer_config(path):
    """{(patron, capa): (res, cap)} del bloque LAYERS_RC de un config.yaml."""
    out, patron = {}, None
    for linea in open(path, encoding="utf-8"):
        s = linea.strip()
        if s.startswith("#"):
            continue
        m = re.match(r'^"(\w+_\*)":$', s)
        if m:
            patron = m.group(1)
            continue
        m = re.match(r"^(Metal\d): \{res: ([0-9.e+-]+), cap: ([0-9.e+-]+)\}$", s)
        if m and patron:
            out[(patron, m.group(1))] = (float(m.group(2)), float(m.group(3)))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("run", help="corrida de LibreLane con final/spef (p. ej. asic/rom/runs/final)")
    ap.add_argument("--md", help="además, escribe el informe en este archivo Markdown")
    ap.add_argument("--comparar", help="config.yaml cuyo bloque LAYERS_RC hay que verificar")
    ap.add_argument("--tolerancia", type=float, default=1e-9,
                    help="diferencia relativa aceptada al comparar (por omisión 1e-9)")
    a = ap.parse_args()
    run = a.run.rstrip("/")
    if not os.path.isdir(run):
        sys.exit(f"{run}: no existe")
    est, capas, factores, filas = derivar(run)
    if not est:
        sys.exit(f"{run}: no se pudo leer resizer_values_after.rpt (paso openroad-dumprcvalues)")
    if not capas:
        sys.exit(f"{run}: no se pudo leer tlef_values.rpt (paso openroad-dumprcvalues)")
    if not filas:
        sys.exit(f"{run}: no hay SPEF en final/spef o no hay wire_lengths.csv")

    L = [f"# Modelo de cable del resizer derivado de `{run}`", "",
         f"Generado por `python3 asic/modelo_cable.py {run}`. Ningún valor de este archivo",
         "está escrito a mano: todos salen de la extracción y del tech LEF de esa corrida.", ""]
    L.append("## 1. Lo que estima el resizer")
    L.append("")
    L.append(f"`{os.path.basename(paso(run, 'openroad-dumprcvalues') or '')}/resizer_values_after.rpt`, fila "
             f"`Signal Avg`: **{est[0]:.4f} ohm/µm** y **{est[1] * 1e6:.1f} aF/µm**, el mismo par en las 9 "
             "esquinas. Es el promedio de las capas de ruteo del tech LEF, y es lo único con lo que "
             "`estimate_parasitics` alimenta a `repair_design`, `repair_timing` y al CTS.")
    L.append("")
    L.append("Valores por capa del tech LEF (`tlef_values.rpt`), que son los que LAYERS_RC reemplaza:")
    L.append("")
    L.append("| capa | res (ohm/µm) | cap (pF/µm) |")
    L.append("|---|---|---|")
    for nombre, r0, c0 in capas:
        L.append(f"| {nombre} | {r0:.5f} | {c0:.4e} |")
    L.append("")
    L.append("## 2. Lo que la extracción mide")
    L.append("")
    L.append(f"Regresión lineal sobre los nets de más de {LARGO_MINIMO:.0f} µm de la corrida: capacidad de "
             "cable del SPEF contra largo ruteado, y resistencia total del SPEF contra largo ruteado. El "
             "factor es la pendiente medida dividida por el valor que usa el resizer, y es lo que la "
             "estimación deja de ver.")
    L.append("")
    L.append("| extracción | nets | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) "
             "| R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |")
    L.append("|---|---|---|---|---|---|---|---|---|---|")
    for rcn, n, pc, oc, mc, pr, orr, mr, fc, fr in filas:
        L.append(f"| {rcn} | {n} | {pc:.1f} | {oc:.0f} | {mc:.1f} | {pr:.3f} | {orr:.1f} | {mr:.3f} "
                 f"| {fc:.2f} | {fr:.2f} |")
    L.append("")
    L.append("## 3. El bloque LAYERS_RC que sale de ahí")
    L.append("")
    L.append("Cada valor por capa del tech LEF multiplicado por el factor de su extracción, de modo que el "
             "promedio con que estima el resizer coincida con la pendiente medida. Los patrones los expande "
             "LibreLane a las 9 esquinas. Unidades: ohm/µm y pF/µm.")
    L.append("")
    L.append("```yaml")
    L.append(bloque_yaml(capas, factores))
    L.append("```")
    L.append("")

    salida_ok = True
    if a.comparar:
        esperado = leer_config(a.comparar)
        derivado = {}
        for rcn in EXTRACCIONES:
            if rcn not in factores:
                continue
            fr, fc = factores[rcn]
            for nombre, r0, c0 in capas:
                derivado[(f"{rcn}_*", nombre)] = (round(r0 * fr, 5), float(f"{c0 * fc:.4e}"))
        L.append(f"## 4. Comparación con `{a.comparar}`")
        L.append("")
        if not esperado:
            L.append(f"`{a.comparar}` no tiene bloque LAYERS_RC.")
            salida_ok = False
        else:
            malas = []
            for k, v in derivado.items():
                e = esperado.get(k)
                if e is None:
                    malas.append((k, "falta en la configuración", v))
                    continue
                for i, nom in ((0, "res"), (1, "cap")):
                    d = abs(e[i] - v[i]) / max(abs(v[i]), 1e-30)
                    if d > a.tolerancia:
                        malas.append((k, nom, f"configuración {e[i]:g} contra derivado {v[i]:g}"))
            sobran = sorted(set(esperado) - set(derivado))
            if malas or sobran:
                salida_ok = False
                L.append(f"**No coincide.** {len(malas)} valores distintos y {len(sobran)} de más:")
                L.append("")
                for k, nom, det in malas[:40]:
                    L.append(f"- `{k[0]}` `{k[1]}` {nom}: {det}")
                for k in sobran[:40]:
                    L.append(f"- `{k[0]}` `{k[1]}`: está en la configuración y no se deriva de esta corrida")
            else:
                L.append(f"**Coincide**: los {len(derivado)} pares (capa, extracción) del bloque LAYERS_RC de "
                         f"`{a.comparar}` son exactamente los que se derivan de `{run}`, a los decimales con "
                         "que se escriben (res con 5 decimales, cap con 4 cifras significativas).")
        L.append("")

    texto = "\n".join(L) + "\n"
    print(texto)
    if a.md:
        os.makedirs(os.path.dirname(os.path.abspath(a.md)), exist_ok=True)
        open(a.md, "w", encoding="utf-8").write(texto)
    sys.exit(0 if salida_ok else 1)


if __name__ == "__main__":
    main()
