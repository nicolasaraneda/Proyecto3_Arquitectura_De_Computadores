#!/usr/bin/env python3
"""Parte la ruta crítica de un report_checks en tramos y arma el cálculo del tiempo requerido.

Uso:
    python3 asic/ruta_tramos.py <ruta_critica.rpt> [--md salida.md] [--titulo "..."]

Entrada: la salida de `report_checks -path_delay max` de OpenSTA tal como la copia
`asic/recolectar.py` a `asic/<config>/resultados/<tag>/<esquina>_ruta_critica.rpt`.

Qué hace, y por qué: el reporte trae una línea por pin y es difícil de leer en un informe.
Este script lo resume en dos tablas que son las que pide la sección 3.4:

  1. **Tramos de la ruta de datos.** El camino de llegada se parte en:
     - el árbol de reloj hasta el pin CLK del flip-flop de inicio (latencia de lanzamiento);
     - el arco reloj a Q del flip-flop de inicio;
     - un tramo por cada bloque de la jerarquía por el que pasa el camino, con sus celdas y
       su retardo. El bloque de una celda es el prefijo jerárquico de su instancia
       (`u_soc.u_core.u_id.u_alu/...`); las celdas que la síntesis aplanó no tienen prefijo y
       se agrupan como "lógica aplanada", y para saber de qué se trata el script informa los
       nets por los que pasa el tramo, que sí conservan el nombre del RTL;
     - el pin D del flip-flop de llegada.
  2. **Tiempo requerido.** La latencia del reloj de captura, la incertidumbre
     (`clock uncertainty`), el pesimismo de reconvergencia (`clock reconvergence pessimism`,
     CRPR) y el setup de la biblioteca (`library setup time`), con el período y el slack.

No interpreta nada: todos los números salen del reporte, y la función de cada tramo
(fetch, decode, ejecución, acceso a memoria o write-back) la decide quien escribe el
informe mirando los nets que este script lista.
"""

import argparse
import os
import re
import sys

# Las columnas del reporte (Fanout, Cap, Slew, Delay, Time) no siempre están todas:
# una línea de pin de entrada trae Slew, Delay y Time, y una de salida trae las cinco.
# Los dos últimos números son siempre Delay y Time, así que se leen por el final.
CELDA = re.compile(r"^\s*((?:-?[0-9.]+\s+)*)\s*([\^v])\s+(\S+)\s+\((\S+)\)\s*$")
NET = re.compile(r"^\s+(\S+) \(net\)\s*$")
SOLO = re.compile(r"^\s*((?:-?[0-9.]+\s+)+)([A-Za-z].*?)\s*$")
CORTO = re.compile(r"^gf180mcu_fd_sc_mcu7t5v0__")


def corto(celda):
    return CORTO.sub("", celda)


def modulo(pin):
    """El bloque jerarquico del pin: lo que va antes del nombre de la instancia.

    `u_soc.u_core.u_id.u_alu/_0712_/ZN` -> `u_soc.u_core.u_id.u_alu`.
    `fanout630/Z` -> "" (celda que la sintesis aplano, sin nombre jerarquico).
    """
    inst = pin.rsplit("/", 1)[0] if "/" in pin else pin
    return inst.rsplit("/", 1)[0] if "/" in inst else ""


def parsear(texto):
    """Devuelve (encabezado, llegada, requerido, resumen)."""
    enc, llegada, requerido, resumen = {}, [], [], {}
    seccion = "enc"
    net_pendiente = None
    for linea in texto.splitlines():
        m = re.match(r"^(Startpoint|Endpoint|Path Group|Path Type):\s*(.+)$", linea)
        if m:
            enc[m.group(1)] = m.group(2).strip()
            continue
        m = re.match(r"^=+ (\S+) Corner =+", linea)
        if m:
            enc["Corner"] = m.group(1)
            continue
        mn = NET.match(linea)
        if mn:
            net_pendiente = mn.group(1)
            continue
        mc = CELDA.match(linea)
        if mc:
            nums = [float(x) for x in mc.group(1).split()]
            if len(nums) < 2:
                continue
            retardo, tiempo = nums[-2], nums[-1]
            pin, celda = mc.group(3), mc.group(4)
            (llegada if seccion == "llegada" else requerido).append(
                {"pin": pin, "celda": celda, "retardo": retardo, "tiempo": tiempo,
                 "net": net_pendiente})
            net_pendiente = None
            continue
        ms = SOLO.match(linea)
        if ms:
            nums = [float(x) for x in ms.group(1).split()]
            etq = ms.group(2).strip()
            val, t = (nums[-2], nums[-1]) if len(nums) >= 2 else (nums[-1], nums[-1])
            if etq.startswith("clock clk (rise edge)"):
                seccion = "llegada" if not llegada and not requerido else "requerido"
                if seccion == "requerido":
                    resumen["periodo"] = t
                continue
            if etq == "data arrival time":
                if "llegada" not in resumen:
                    resumen["llegada"] = t
                seccion = "requerido"
                continue
            if etq == "data required time":
                resumen["requerido"] = t
                continue
            for clave, nombre in (("clock uncertainty", "incertidumbre"),
                                  ("clock reconvergence pessimism", "crpr"),
                                  ("library setup time", "setup")):
                if etq == clave:
                    resumen[nombre] = (val, t)
            continue
        if "slack (" in linea:
            m = re.search(r"(-?[0-9.]+)\s+slack \((MET|VIOLATED)\)", linea)
            if m:
                resumen["slack"] = float(m.group(1))
                resumen["cumple"] = m.group(2)
    return enc, llegada, requerido, resumen


def tramos(llegada, inicio):
    """Agrupa el camino de llegada en tramos: reloj de lanzamiento, clk->Q, bloques, pin D."""
    out = []
    # 1. arbol de reloj hasta el pin CLK del flip-flop de inicio
    i_clk = next((i for i, e in enumerate(llegada)
                  if e["pin"].endswith("/CLK") and e["pin"].split("/")[0].split(".")[-1] == inicio.split("/")[-1]), None)
    if i_clk is None:
        i_clk = next((i for i, e in enumerate(llegada) if e["pin"].endswith("/CLK")), None)
    if i_clk is None:
        return out
    celdas_clk = [e for e in llegada[:i_clk + 1] if e["celda"]]
    out.append({"tramo": "árbol de reloj (latencia de lanzamiento)",
                "celdas": len([e for e in celdas_clk if "/Z" in e["pin"] or "/ZN" in e["pin"]]),
                "retardo": llegada[i_clk]["tiempo"],
                "desde": "clk (in)", "hasta": llegada[i_clk]["pin"],
                "nets": ""})
    # 2. reloj a Q del flip-flop de inicio
    i_q = next((i for i in range(i_clk + 1, len(llegada))
                if llegada[i]["pin"].endswith(("/Q", "/QN"))), None)
    if i_q is None:
        return out
    out.append({"tramo": "reloj a Q del flip-flop de inicio",
                "celdas": 1, "retardo": llegada[i_q]["retardo"],
                "desde": llegada[i_clk]["pin"], "hasta": llegada[i_q]["pin"],
                "nets": llegada[i_q]["net"] or ""})
    # 3. el resto, agrupado por bloque de la jerarquia
    resto = llegada[i_q + 1:]
    grupo = None
    for e in resto:
        esD = e["pin"].rsplit("/", 1)[-1] in ("D", "DATA") and "dff" in e["celda"]
        mod = modulo(e["pin"])
        if esD:
            if grupo:
                out.append(grupo)
                grupo = None
            out.append({"tramo": "entrada al flip-flop de llegada (pin D)",
                        "celdas": 0, "retardo": e["retardo"],
                        "desde": "", "hasta": e["pin"],
                        "nets": f"`{e['net']}`" if e["net"] else ""})
            continue
        if grupo is None or grupo["_mod"] != mod:
            if grupo:
                out.append(grupo)
            grupo = {"_mod": mod, "tramo": mod if mod else "lógica aplanada (sin nombre jerárquico)",
                     "celdas": 0, "retardo": 0.0, "desde": e["pin"], "hasta": e["pin"],
                     "_nets": []}
        grupo["retardo"] += e["retardo"]
        grupo["hasta"] = e["pin"]
        if e["pin"].rsplit("/", 1)[-1] in ("Z", "ZN", "Q", "QN"):
            grupo["celdas"] += 1
        if e["net"]:
            grupo["_nets"].append(e["net"])
    if grupo:
        out.append(grupo)
    for g in out:
        if "_nets" in g:
            g["nets"] = ", ".join(f"`{n}`" for n in g.pop("_nets"))
            g.pop("_mod", None)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("rpt")
    ap.add_argument("--md")
    ap.add_argument("--titulo")
    a = ap.parse_args()
    if not os.path.exists(a.rpt):
        sys.exit(f"{a.rpt}: no existe")
    enc, llegada, requerido, res = parsear(open(a.rpt, encoding="utf-8", errors="replace").read())
    if not llegada:
        sys.exit(f"{a.rpt}: no se pudo leer el camino de llegada")
    ini = enc.get("Startpoint", "").split()[0]
    fin = enc.get("Endpoint", "").split()[0]
    tr = tramos(llegada, ini)

    L = []
    L.append(f"### {a.titulo or f'Ruta crítica de `{a.rpt}`'}")
    L.append("")
    L.append(f"Esquina `{enc.get('Corner','?')}`, grupo `{enc.get('Path Group','?')}`, "
             f"tipo `{enc.get('Path Type','?')}`. Startpoint `{ini}`, endpoint `{fin}`. "
             f"Generado por `python3 asic/ruta_tramos.py {a.rpt}`.")
    L.append("")
    L.append("| tramo | celdas | retardo (ns) | hasta | nets del RTL por los que pasa |")
    L.append("|---|---|---|---|---|")
    total = 0.0
    for g in tr:
        total += g["retardo"]
        nets = g.get("nets", "")
        if len(nets) > 240:
            nets = nets[:237] + "..."
        L.append(f"| {g['tramo']} | {g['celdas']} | {g['retardo']:.3f} | `{g['hasta']}` | {nets} |")
    L.append(f"| **total** | | **{total:.3f}** | | |")
    L.append("")
    L.append(f"El total es la llegada del dato: {res.get('llegada', float('nan')):.3f} ns "
             "(línea `data arrival time` del reporte).")
    L.append("")
    L.append("#### Cálculo del tiempo requerido")
    L.append("")
    L.append("| término | valor (ns) | de dónde sale |")
    L.append("|---|---|---|")
    per = res.get("periodo")
    if per is not None:
        L.append(f"| período del reloj (flanco de captura) | {per:.3f} | `clock clk (rise edge)` del segundo bloque |")
    if requerido:
        clk_cap = next((e["tiempo"] for e in requerido if e["pin"].endswith("/CLK")), None)
        if clk_cap is not None and per is not None:
            L.append(f"| latencia del árbol de reloj hasta el flip-flop de llegada | +{clk_cap - per:.3f} "
                     f"| `{fin}/CLK` del segundo bloque menos el período |")
    for clave, nombre, de in (("incertidumbre", "incertidumbre del reloj", "`clock uncertainty`"),
                              ("crpr", "pesimismo de reconvergencia (CRPR)", "`clock reconvergence pessimism`"),
                              ("setup", "setup de la biblioteca", "`library setup time`")):
        if clave in res:
            v = res[clave][0]
            L.append(f"| {nombre} | {v:+.3f} | {de} |")
    if "requerido" in res:
        L.append(f"| **tiempo requerido** | **{res['requerido']:.3f}** | `data required time` |")
    if "llegada" in res:
        L.append(f"| llegada del dato | -{res['llegada']:.3f} | `data arrival time` |")
    if "slack" in res:
        L.append(f"| **slack** | **{res['slack']:+.3f}** | `slack ({res.get('cumple','?')})` |")
    L.append("")
    texto = "\n".join(L) + "\n"
    print(texto)
    if a.md:
        os.makedirs(os.path.dirname(os.path.abspath(a.md)) or ".", exist_ok=True)
        with open(a.md, "a", encoding="utf-8") as f:
            f.write(texto)


if __name__ == "__main__":
    main()
