#!/usr/bin/env python3
"""Cuenta, directamente en un VCD, las transiciones y el tiempo en alto de
algunas senales escalares del DUT, para contrastar con la actividad que
OpenSTA anota desde el mismo VCD (get_property <pin> activity en
asic/potencia/potencia.tcl, seccion "sonda"). Frente D3.

  python3 asic/potencia/contar_vcd.py <archivo.vcd> [<periodo_ns>] [senal ...]

Las senales son nombres de net del nivel dut del VCD (escapados como en el
netlist, p. ej. '\\u_soc.u_periph.cycles_q[0]'); por defecto las de la sonda.
Imprime la duracion del VCD, y por senal: transiciones, actividad por ciclo
(transiciones / ciclos de <periodo_ns>), densidad en 1/s y duty (fraccion
del tiempo en 1). La densidad y el duty son los que calcula OpenSTA:
density = transiciones / (t_max - t_min), duty = tiempo_en_alto / (t_max - t_min)
(power/VcdReader.cc, ReadVcdActivities::setActivities).
"""
import sys

SONDA = ["clk", "btn[0]", "rst_n",
         "\\u_soc.u_periph.cycles_q[0]", "\\u_soc.u_periph.cycles_q[2]",
         "\\u_soc.u_core.pc_id[2]", "\\u_soc.u_core.pc_id[3]",
         "\\u_soc.g_mem_rom.u_mem.a_rdata_o[0]",
         "\\u_soc.u_core.u_rf/regs[9][0]",
         "\\u_soc.u_periph.u_debounce.u_tick.cnt[0]",
         "\\u_soc.u_core.u_id.operand_a[0]"]


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    vcd = sys.argv[1]
    periodo_ps = 100000.0
    args = sys.argv[2:]
    if args and args[0].replace(".", "", 1).isdigit():
        periodo_ps = float(args[0]) * 1000.0
        args = args[1:]
    nombres = args if args else SONDA
    codigos = {}
    escala_ps = 1.0
    with open(vcd) as f:
        scope = []
        en_timescale = False
        for linea in f:
            if en_timescale:
                p = linea.split()
                if p and p[0] != "$end":
                    unidad = p[0].lstrip("0123456789")
                    n = int(p[0][: len(p[0]) - len(unidad)] or "1")
                    escala_ps = n * {"fs": 1e-3, "ps": 1.0, "ns": 1e3, "us": 1e6}[unidad]
                    en_timescale = False
            elif linea.startswith("$timescale"):
                en_timescale = True
            elif linea.startswith("$scope"):
                scope.append(linea.split()[2])
            elif linea.startswith("$upscope"):
                scope.pop()
            elif linea.startswith("$var"):
                p = linea.split()
                code, nombre = p[3], p[4]
                # Vectores: '$var wire 4 ! btn [3:0]'; solo se cuentan escalares,
                # pero btn[k] se toma como bit de un vector si hace falta.
                if len(scope) == 2:
                    for n in nombres:
                        if nombre == n:
                            codigos.setdefault(code, []).append((n, None))
                        elif n.startswith(nombre + "[") and len(p) > 5 and p[5].startswith("["):
                            alto, bajo = [int(x) for x in p[5].strip("[]").split(":")]
                            bit = int(n[len(nombre) + 1:-1])
                            codigos.setdefault(code, []).append((n, (alto, bajo, bit)))
            elif linea.startswith("$enddefinitions"):
                break
        t = None
        t0 = None
        estado = {c: {} for c in codigos}
        for linea in f:
            if linea.startswith("#"):
                t = int(linea[1:])
                if t0 is None:
                    t0 = t
            elif linea[0] in "01xz":
                c = linea[1:].strip()
                if c in codigos:
                    for n, sel in codigos[c]:
                        registrar(estado[c], n, linea[0], t)
            elif linea[0] == "b":
                valor, c = linea[1:].split()
                if c in codigos:
                    for n, sel in codigos[c]:
                        if sel is None:
                            continue
                        alto, bajo, bit = sel
                        valor_ext = valor.rjust(alto - bajo + 1, "0")
                        registrar(estado[c], n, valor_ext[alto - bit], t)
        for c in codigos:
            for n in estado[c]:
                cerrar(estado[c][n], t)
    dur = t - t0
    ciclos = dur * escala_ps / periodo_ps
    print("vcd: %s" % vcd)
    print("t_min = %d, t_max = %d (unidades de %g ps), duracion = %.1f ciclos de %.0f ns" % (t0, t, escala_ps, ciclos, periodo_ps / 1000))
    print("%-48s %12s %12s %14s %8s" % ("senal", "transiciones", "act/ciclo", "densidad(1/s)", "duty"))
    for n in nombres:
        e = None
        for c in codigos:
            if n in estado[c]:
                e = estado[c][n]
        if e is None:
            print("%-48s no esta en el VCD" % n)
            continue
        print("%-48s %12d %12.6f %14.6e %8.6f" % (n, e["trans"], e["trans"] / ciclos, e["trans"] / (dur * escala_ps * 1e-12), e["alto"] / dur))


def registrar(estado, n, v, t):
    e = estado.setdefault(n, {"val": None, "t": None, "trans": 0, "alto": 0})
    if e["val"] is not None and v != e["val"]:
        e["trans"] += 1
    if e["val"] == "1":
        e["alto"] += t - e["t"]
    e["val"] = v
    e["t"] = t


def cerrar(e, t):
    if e["val"] == "1":
        e["alto"] += t - e["t"]
        e["t"] = t


if __name__ == "__main__":
    main()
