#!/usr/bin/env python3
"""Compara dos trazas de tb/core_trace_tb.v (make equiv).

Uso: python3 tb/comparar_trazas.py --modo ciclo|funcional traza_ref.txt traza_act.txt

- ciclo: las trazas deben ser idénticas línea a línea, con el número de ciclo.
- funcional: se comparan las tres secuencias de eventos por separado y sin el
  número de ciclo: escrituras al banco de registros (sin las escrituras a x0,
  que no cambian nada), accesos al bus de datos y cambios de las salidas. Sirve
  para variantes que cambian los ciclos por instrucción (experimento B4): el
  programa hace lo mismo, en otros ciclos. Como el programa termina en un lazo
  infinito, se compara hasta donde llega la más corta de las dos secuencias de
  cada tipo y se exige que la otra no tenga eventos distintos antes de ese punto.
Código de salida 0 si son equivalentes, 1 si no (muestra la primera diferencia).
"""
import argparse
import sys


def leer(path):
    out = []
    for linea in open(path):
        partes = linea.split(maxsplit=1)
        if len(partes) == 2:
            out.append((int(partes[0]), partes[1].strip()))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--modo", choices=["ciclo", "funcional"], default="ciclo")
    ap.add_argument("ref")
    ap.add_argument("act")
    a = ap.parse_args()
    r, t = leer(a.ref), leer(a.act)
    if a.modo == "ciclo":
        if r == t:
            print(f"trazas identicas ciclo a ciclo ({len(r)} eventos)")
            sys.exit(0)
        for i, (x, y) in enumerate(zip(r, t)):
            if x != y:
                print(f"DIFIEREN en el evento {i + 1}: ref={x} act={y}")
                break
        else:
            print(f"DIFIEREN en el largo: ref {len(r)} eventos, act {len(t)} eventos")
        sys.exit(1)
    ok = True
    for tipo in ("rf", "bus", "io"):
        sr = [e for c, e in r if e.startswith(tipo + " ") and not e.startswith("rf x0 ")]
        st = [e for c, e in t if e.startswith(tipo + " ") and not e.startswith("rf x0 ")]
        n = min(len(sr), len(st))
        if sr[:n] != st[:n]:
            i = next(k for k in range(n) if sr[k] != st[k])
            print(f"DIFIEREN ({tipo}) en el evento {i + 1}: ref='{sr[i]}' act='{st[i]}'")
            ok = False
        else:
            print(f"{tipo}: {n} eventos iguales (ref {len(sr)}, act {len(st)})")
    print("secuencias de eventos equivalentes (sin ciclos)" if ok else "secuencias DISTINTAS")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
