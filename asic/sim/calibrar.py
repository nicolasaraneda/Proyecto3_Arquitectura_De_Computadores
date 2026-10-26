#!/usr/bin/env python3
"""Construye asic/sim/estimulos.txt corriendo el RTL (sección 3.7).

El escenario es: pulsación de inicio (siembra el LFSR), una ronda correcta con
una reacción conocida, una pulsación incorrecta en la ronda siguiente y el
reintento correcto de esa misma ronda. Qué LED se enciende en cada ronda lo
decide el LFSR del programa, así que el botón correcto no se conoce de
antemano: este script corre el RTL por etapas, lee en la traza el ciclo en que
se encendió el LED objetivo y qué LED fue, y agrega la pulsación siguiente en
ciclos absolutos. El archivo resultante queda fijo y versionado; después
`make post-synth` lo aplica igual al RTL y al netlist.

Uso: python3 asic/sim/calibrar.py [--salida asic/sim/estimulos.txt]
Necesita iverilog y vvp (oss-cad-suite) y asic/sim/gen/pochoco_rom.v
(`make asic/sim/gen/pochoco_rom.v`).
"""
import argparse
import os
import subprocess

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INICIO = 300        # ciclo de la pulsación de inicio
RETARDO = 20        # ciclos entre el encendido del LED objetivo y la pulsación
PULSO = 60          # ciclos que se mantiene apretado el botón (> 3 ticks del debounce)
CICLOS = 6000


def simular(eventos, traza):
    est = os.path.join(RAIZ, "build/post_synth/estimulos_calibracion.txt")
    os.makedirs(os.path.dirname(est), exist_ok=True)
    with open(est, "w") as f:
        for c, m, _ in eventos:
            f.write(f"{c} {m:04b}\n")
    exe = os.path.join(RAIZ, "build/post_synth/tb_rtl_cal")
    cmd = ["iverilog", "-g2012", "-I", "asic/sim/gen", f'-DESTIMULOS="{est}"', f'-DTRAZA="{traza}"',
           f"-DCICLOS={CICLOS}", "-o", exe, "tb/post_synth_tb.v"]
    cmd += sorted(os.path.join("rtl", f) for f in os.listdir(os.path.join(RAIZ, "rtl")) if f.endswith(".v"))
    cmd += sorted(os.path.join("rtl/espino_core", f) for f in os.listdir(os.path.join(RAIZ, "rtl/espino_core")) if f.endswith(".v"))
    cmd += ["asic/sim/gen/pochoco_rom.v"]
    subprocess.run(cmd, cwd=RAIZ, check=True)
    subprocess.run(["vvp", exe], cwd=RAIZ, check=True, stdout=subprocess.DEVNULL)
    out = []
    for linea in open(os.path.join(RAIZ, traza)):
        c, led, disp = linea.split()
        out.append((int(c), led.split("=")[1], disp.split("=")[1]))
    return out


def primer_led_unico(traza, desde):
    """Primer cambio de los LEDs después de `desde` que deja encendido exactamente
    un LED (el paso de los cuatro LEDs al objetivo). Se exige que los LEDs
    cambien, porque el display también genera líneas en la traza."""
    prev = None
    for c, led, disp in traza:
        if prev is not None and c > desde and led != prev and led.count("1") == 1:
            return c, int(led, 2)
        prev = led
    raise SystemExit(f"no se encendió un LED único después del ciclo {desde}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--salida", default="asic/sim/estimulos.txt")
    a = ap.parse_args()
    traza = "build/post_synth/traza_calibracion.txt"
    eventos = [(INICIO, 1, "pulsacion de inicio: siembra el LFSR con CYCLES"),
               (INICIO + PULSO, 0, "se suelta")]

    # Ronda 1: pulsación correcta.
    t = simular(eventos, traza)
    c1, led1 = primer_led_unico(t, INICIO + PULSO)
    eventos += [(c1 + RETARDO, led1, f"ronda 1: LED objetivo {led1:04b} encendido en el ciclo {c1}; boton correcto {RETARDO} ciclos despues"),
                (c1 + RETARDO + PULSO, 0, "se suelta")]

    # Ronda 2: pulsación incorrecta.
    t = simular(eventos, traza)
    c2, led2 = primer_led_unico(t, c1 + RETARDO + PULSO)
    mal = 1 if led2 != 1 else 2
    eventos += [(c2 + RETARDO, mal, f"ronda 2: LED objetivo {led2:04b} encendido en el ciclo {c2}; boton INCORRECTO {mal:04b}"),
                (c2 + RETARDO + PULSO, 0, "se suelta")]

    # Reintento de la ronda 2: pulsación correcta.
    t = simular(eventos, traza)
    c3, led3 = primer_led_unico(t, c2 + RETARDO + PULSO)
    eventos += [(c3 + RETARDO, led3, f"reintento de la ronda 2: LED objetivo {led3:04b} encendido en el ciclo {c3}; boton correcto"),
                (c3 + RETARDO + PULSO, 0, "se suelta")]

    t = simular(eventos, traza)
    with open(os.path.join(RAIZ, a.salida), "w") as f:
        f.write("# Estimulos de la simulacion post-sintesis (seccion 3.7): <ciclo> <mascara btn[3:0]>.\n")
        f.write("# Ciclos absolutos desde que se suelta rst_n. Generado por asic/sim/calibrar.py\n")
        f.write(f"# corriendo el RTL por etapas (inicio en {INICIO}, pulsacion {RETARDO} ciclos despues de cada LED, {PULSO} ciclos apretado).\n")
        for c, m, com in eventos:
            f.write(f"# {com}\n{c} {m:04b}\n")
    print(f"escrito {a.salida} con {len(eventos)} eventos")
    print("traza del RTL con estos estimulos:")
    for c, led, disp in t:
        print(f"  {c:5d} led={led} disp={disp}")


if __name__ == "__main__":
    main()
