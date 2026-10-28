#!/usr/bin/env python3
"""Genera asic/sim/config.yaml (y, con --pnr, asic/sim/config_pnr.yaml) a partir de asic/rom/config.yaml.

La configuración de simulación post-síntesis (sección 3.7) es la misma que la
de la corrida final salvo dos cosas:
  - la ROM es la del programa de simulación, asic/sim/gen/pochoco_rom.v
    (game.s ensamblado con -D CYCLES_PER_TENTH=1), en vez de rtl/gen/;
  - SYNTH_PARAMETERS agrega DebounceDivBits=<DIV_BITS> para que el debounce
    acepte un botón en pocos ciclos (el RTL se simula con el mismo valor).
Se genera en vez de copiarse a mano para que no se desincronice de la
configuración final: `make post-synth` lo regenera y git diff muestra si
cambió. Uso: python3 asic/sim/generar_config.py [--div-bits 2] [--pnr]

Sin --pnr escribe asic/sim/config.yaml, que solo se corre hasta Yosys.Synthesis
y por eso omite IO_PIN_ORDER_CFG (no llega al floorplan). Con --pnr escribe
asic/sim/config_pnr.yaml: la configuración final COMPLETA (incluido
IO_PIN_ORDER_CFG apuntando a asic/rom/pines.cfg) con esa ROM y ese parámetro,
para correr el flujo entero y obtener el netlist post-PnR y los SDF de las
esquinas con los que se hace la simulación con retardos (make post-pnr-sdf).
"""
import argparse
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--div-bits", type=int, default=2)
    ap.add_argument("--pnr", action="store_true",
                    help="configuración completa (con IO_PIN_ORDER_CFG) en asic/sim/config_pnr.yaml")
    a = ap.parse_args()
    src = open(os.path.join(RAIZ, "asic/rom/config.yaml"), encoding="utf-8").read()
    out = []
    out.append("# GENERADO por asic/sim/generar_config.py a partir de asic/rom/config.yaml: no editar a mano.")
    if a.pnr:
        out.append("# Configuración COMPLETA del flujo (hasta el signoff) para la simulación post-PnR con SDF")
        out.append("# (sección 3.7, make post-pnr-sdf): igual a la corrida final, con la ROM del programa de")
        out.append(f"# simulación (CYCLES_PER_TENTH=1) y DebounceDivBits={a.div_bits}. Generada con --pnr.")
    else:
        out.append("# Configuración de la síntesis para la simulación post-síntesis (sección 3.7): igual a la")
        out.append("# corrida final, con la ROM del programa de simulación (CYCLES_PER_TENTH=1) y")
        out.append(f"# DebounceDivBits={a.div_bits}. Se corre solo hasta Yosys.Synthesis.")
    for linea in src.splitlines():
        if linea.startswith("#"):
            continue  # los comentarios de la configuración final se omiten
        if linea.strip() == "- dir::../../rtl/gen/*.v":
            out.append("  - dir::gen/pochoco_rom.v")
            continue
        if linea.strip() == "- dir::../../rtl/gen":
            out.append("  - dir::gen")
            continue
        if linea.strip() == "- DataWords=4":
            out.append(linea)
            out.append(f"  - DebounceDivBits={a.div_bits}")
            continue
        if linea.startswith("IO_PIN_ORDER_CFG"):
            if a.pnr:
                # el mismo archivo de pines de la corrida final, visto desde asic/sim/
                out.append("IO_PIN_ORDER_CFG: dir::../rom/pines.cfg")
            continue  # sin --pnr no llega al floorplan
        out.append(linea)
    dst = os.path.join(RAIZ, "asic/sim/config_pnr.yaml" if a.pnr else "asic/sim/config.yaml")
    with open(dst, "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")
    print(f"escrito {dst}")


if __name__ == "__main__":
    main()
