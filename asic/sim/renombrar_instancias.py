#!/usr/bin/env python3
"""Renombra las instancias de nombre jerárquico del netlist post-PnR y de sus SDF
para que Icarus Verilog pueda anotarlos.

Problema: el netlist que escribe OpenROAD es plano, pero las celdas de los módulos
cuya jerarquía se conservó en síntesis (SYNTH_KEEP_HIERARCHY_MODULES) se llaman
`\\u_soc.u_core.u_rf/_2913_ ` (identificador escapado con puntos y barra), y el SDF
de OpenSTA las escribe como `u_soc\\.u_core\\.u_rf\\/_2913_`. El lexer de SDF de
Icarus (vpi/sdf_lexor.lex) quita las barras de escape y después sdf_select_instance
y get_port_handle (vpi/sys_sdf.c) parten el nombre por los puntos como si fuera una
ruta jerárquica u_soc > u_core > u_rf/_2913_, que no existe en un netlist plano:
  - cada CELL con ese nombre da "SDF ERROR: Cannot find u_soc in scope ..." y, como
    sdf_cur_cell no se limpia al fallar, sus IOPATH se aplican a la celda anterior;
  - el primer INTERCONNECT que llega a una de esas instancias termina en
    vpi_scan(NULL) y vvp aborta ("Assertion `0' failed", código 139), en Icarus
    13.0 y 14.0-devel.
Solución: un nombre simple y único por instancia, el mismo en el netlist y en los
SDF: `u_soc.u_core.u_rf/_2913_` pasa a `u_soc__u_core__u_rf___2913_` (cada '.'
y '/' se cambia por '__'). Solo se renombran instancias; los nets escapados del
netlist quedan igual (el SDF no los nombra). El script comprueba que los nombres
nuevos no choquen con ningún identificador existente.

Uso: python3 asic/sim/renombrar_instancias.py --netlist <asic_top.nl.v> --salida <dir> <sdf> [<sdf> ...]
Escribe <dir>/asic_top.nl.v, <dir>/<nombre de cada sdf> y <dir>/instancias_renombradas.txt.
"""
import argparse
import os
import re
import sys

# instancia de celda estándar con nombre escapado: "  gf180mcu_..._x \\nombre (" o
# "  gf180mcu_..._x nombre ("
RE_INST = re.compile(r"^\s*(gf180mcu_fd_sc_mcu7t5v0__\w+)\s+(\\\S+|\S+)\s*\(", re.M)
# identificador del SDF con al menos un carácter escapado (\. o \/ o \[ ...)
RE_SDF_ESC = re.compile(r"[A-Za-z0-9_$\[\]]*(?:\\[^\sA-Za-z0-9_$(),:]+[A-Za-z0-9_$\[\]]*)+")


def nombre_simple(n):
    return n.replace(".", "__").replace("/", "__")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--netlist", required=True)
    ap.add_argument("--salida", required=True)
    ap.add_argument("sdf", nargs="*")
    a = ap.parse_args()
    nl = open(a.netlist, encoding="utf-8").read()
    instancias = {}
    for m in RE_INST.finditer(nl):
        nombre = m.group(2)
        if nombre.startswith("\\"):
            instancias[nombre[1:]] = True
    mapa = {n: nombre_simple(n) for n in instancias if "." in n or "/" in n}
    # choques: ningún nombre nuevo puede existir ya como identificador del netlist
    ids = set(re.findall(r"(?<![\\\w])[A-Za-z_][A-Za-z0-9_$]*", nl))
    choques = [v for v in mapa.values() if v in ids]
    if choques or len(set(mapa.values())) != len(mapa):
        sys.exit(f"nombres nuevos que chocan con identificadores existentes: {choques[:5]}")
    # netlist: "\\nombre " (escapado con espacio final) -> nombre simple
    def rn(m):
        n = m.group(1)
        return mapa[n] if n in mapa else m.group(0)
    nl2 = re.sub(r"\\(\S+) ", rn, nl)
    os.makedirs(a.salida, exist_ok=True)
    with open(os.path.join(a.salida, os.path.basename(a.netlist)), "w", encoding="utf-8") as f:
        f.write(nl2)
    with open(os.path.join(a.salida, "instancias_renombradas.txt"), "w", encoding="utf-8") as f:
        for k, v in sorted(mapa.items()):
            f.write(f"{k} {v}\n")
    print(f"netlist: {len(instancias)} instancias con nombre escapado, {len(mapa)} renombradas -> {a.salida}/{os.path.basename(a.netlist)}")
    for s in a.sdf:
        txt = open(s, encoding="utf-8").read()
        cont = {"ok": 0, "sin": set()}
        def rs(m):
            plano = re.sub(r"\\(.)", r"\1", m.group(0))
            if plano in mapa:
                cont["ok"] += 1
                return mapa[plano]
            cont["sin"].add(plano)
            return m.group(0)
        txt2 = RE_SDF_ESC.sub(rs, txt)
        dst = os.path.join(a.salida, os.path.basename(s))
        with open(dst, "w", encoding="utf-8") as f:
            f.write(txt2)
        print(f"sdf {os.path.basename(s)}: {cont['ok']} referencias renombradas, {len(cont['sin'])} nombres escapados sin mapa -> {dst}")
        if cont["sin"]:
            print("  sin mapa (primeros 5):", sorted(cont["sin"])[:5])


if __name__ == "__main__":
    main()
