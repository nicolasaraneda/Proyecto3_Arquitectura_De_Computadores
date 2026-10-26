#!/usr/bin/env python3
"""Compara las trazas del RTL y del netlist de la simulación post-síntesis.

Uso: python3 asic/sim/comparar.py build/post_synth/traza_rtl.txt build/post_synth/traza_netlist.txt [--md salida.md]

Las dos trazas vienen de tb/post_synth_tb.v con el mismo archivo de estímulos.
Imprime, para cada traza, los eventos que responden a la sección 3.7:
  - el valor que muestra el display tras la ronda correcta (ciclos medidos,
    porque el programa se ensambló con CYCLES_PER_TENTH=1) y el ciclo;
  - la aparición de EE tras la pulsación incorrecta y el número de ronda que
    se muestra después (tiene que ser el mismo que antes del error);
  - la cantidad de líneas con valores X.
Termina con PASS si las trazas son idénticas línea a línea y FAIL si no,
mostrando la primera diferencia. Código de salida 0 solo con PASS.
"""
import argparse
import sys


def leer(path):
    out = []
    for linea in open(path):
        partes = linea.split()
        if len(partes) == 3:
            out.append((int(partes[0]), partes[1][4:], partes[2][5:]))
    return out


def resumen(t):
    """Eventos clave: display después de cada acierto, EE y la ronda tras el error."""
    r = {"x": sum(1 for _, led, disp in t if "X" in disp or "x" in led), "rondas": [], "ee": None, "ronda_tras_ee": None, "valores": []}
    ronda_actual = None
    for c, led, disp in t:
        if disp.isdigit() and int(disp) <= 10 and led == "1111":
            ronda_actual = disp
            r["rondas"].append((c, disp))
            if r["ee"] is not None and r["ronda_tras_ee"] is None:
                r["ronda_tras_ee"] = (c, disp)
        elif disp == "EE" and r["ee"] is None:
            r["ee"] = (c, ronda_actual)
        elif disp.isdigit() and ronda_actual is not None and disp != ronda_actual and led.count("1") == 1:
            r["valores"].append((c, ronda_actual, disp))
    return r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rtl")
    ap.add_argument("netlist")
    ap.add_argument("--md")
    a = ap.parse_args()
    tr, tn = leer(a.rtl), leer(a.netlist)
    L = []
    for nombre, t in (("RTL", tr), ("netlist", tn)):
        s = resumen(t)
        L.append(f"{nombre}: {len(t)} cambios de salida, {s['x']} con valores X")
        for c, ronda, disp in s["valores"]:
            L.append(f"  ronda {ronda}: acierto, el display muestra {disp} (ciclos medidos) en el ciclo {c}")
        if s["ee"]:
            L.append(f"  pulsacion incorrecta en la ronda {s['ee'][1]}: EE en el ciclo {s['ee'][0]}")
        if s["ronda_tras_ee"]:
            L.append(f"  tras EE vuelve a la ronda {s['ronda_tras_ee'][1]} en el ciclo {s['ronda_tras_ee'][0]} ({'la ronda NO avanzo' if s['ee'] and s['ronda_tras_ee'][1] == s['ee'][1] else 'LA RONDA AVANZO'})")
    iguales = tr == tn
    if not iguales:
        for i in range(max(len(tr), len(tn))):
            a_ = tr[i] if i < len(tr) else None
            b_ = tn[i] if i < len(tn) else None
            if a_ != b_:
                L.append(f"primera diferencia en la linea {i + 1}: RTL={a_} netlist={b_}")
                break
    L.append(f"trazas {'identicas' if iguales else 'DISTINTAS'} ({len(tr)} lineas RTL, {len(tn)} lineas netlist)")
    L.append("PASS" if iguales else "FAIL")
    print("\n".join(L))
    if a.md:
        with open(a.md, "w", encoding="utf-8") as f:
            f.write("```\n" + "\n".join(L) + "\n```\n")
    sys.exit(0 if iguales else 1)


if __name__ == "__main__":
    main()
