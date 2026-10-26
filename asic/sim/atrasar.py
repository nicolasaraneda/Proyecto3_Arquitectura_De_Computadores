#!/usr/bin/env python3
"""Copia un archivo de estímulos (asic/sim/estimulos.txt) atrasando una pulsación.

Uso: python3 asic/sim/atrasar.py <entrada> <salida> --pulsacion N --ciclos K
Cada pulsación son dos líneas "<ciclo> <máscara>": la que aprieta (máscara
distinta de 0000) y la que suelta (0000). La pulsación N (contando desde 1; la
1 es la de inicio, la 2 es la de la primera ronda) se corre K ciclos, con su
línea de soltar. Los comentarios y las demás líneas quedan iguales.
Es el control negativo de make post-synth-control.
"""
import argparse


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("entrada")
    ap.add_argument("salida")
    ap.add_argument("--pulsacion", type=int, required=True)
    ap.add_argument("--ciclos", type=int, required=True)
    a = ap.parse_args()
    out = []
    n = 0
    apretado = False
    for linea in open(a.entrada):
        partes = linea.split()
        if len(partes) == 2 and partes[0].isdigit():
            ciclo, mascara = int(partes[0]), partes[1]
            if mascara != "0000" and not apretado:
                n += 1
                apretado = True
            elif mascara == "0000":
                apretado = False
            if n == a.pulsacion:
                ciclo += a.ciclos
            linea = f"{ciclo} {mascara}\n"
        out.append(linea)
    if n < a.pulsacion:
        raise SystemExit(f"{a.entrada} tiene {n} pulsaciones, no hay pulsacion {a.pulsacion}")
    open(a.salida, "w").write("".join(out))


if __name__ == "__main__":
    main()
