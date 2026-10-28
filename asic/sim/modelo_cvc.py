#!/usr/bin/env python3
"""Copia del modelo Verilog de las celdas del PDK para Open Verilog CVC.

Los bloques specify de gf180mcu_fd_sc_mcu7t5v0.v declaran algunos arcos con
flanco bajo `ifnone` (p. ej. `ifnone (posedge S => (Z:S)) = (1.0,1.0);` en
mux2, y todos los arcos de xor2, xnor2, xor3 y de los sumadores addf/addh).
La norma 1364 no admite `ifnone` en arcos con flanco: Icarus los descarta con
el aviso "ifnone with an edge-sensitive path is not supported" (y entonces los
IOPATH del SDF de esos arcos no casan con nada) y CVC los rechaza como error
"[1012] ifnone path illegal - has edge or is state dependent" y no simula.

Este script quita solo la palabra `ifnone` de los arcos con flanco: el arco
queda incondicional, que es lo que el SDF describe (OpenSTA escribe esos
IOPATH sin COND). En mux2, xor2 y xnor2 no hay arcos condicionales para esos
pines, así que el modelo es equivalente; en addf/addh conviven con arcos
condicionales del mismo par de pines y el simulador toma el retardo del arco
que corresponde. Todo lo demás del modelo (funciones, timing checks,
`ifndef FUNCTIONAL) queda igual.

Uso: python3 asic/sim/modelo_cvc.py <modelo.v> <salida.v>
"""
import sys


def main():
    src, dst = sys.argv[1], sys.argv[2]
    lineas = open(src, encoding="utf-8").read().split("\n")
    out, quitados = [], 0
    for k, linea in enumerate(lineas):
        if linea.strip() == "ifnone":
            j = k + 1
            while j < len(lineas) and (not lineas[j].strip() or lineas[j].strip().startswith("//")):
                j += 1
            sig = lineas[j] if j < len(lineas) else ""
            if "=>" in sig and ("posedge" in sig or "negedge" in sig):
                out.append(linea.replace("ifnone", "// ifnone (quitado por asic/sim/modelo_cvc.py: arco con flanco)"))
                quitados += 1
                continue
        out.append(linea)
    open(dst, "w", encoding="utf-8").write("\n".join(out))
    print(f"{dst}: {quitados} 'ifnone' de arcos con flanco quitados de {src}")


if __name__ == "__main__":
    main()
