#!/usr/bin/env python3
"""Tablas de la potencia con actividad real (frente D3).

Lee asic/potencia/resultados/*.rpt (salida de asic/potencia/potencia.tcl),
resultados/ventanas.txt (ciclos, tamano y variables de cada VCD) y
resultados/pc_<ventana>.txt (histograma del PC del RTL) y escribe
resultados/tablas.md y resultados/ventanas_pc.md. Sin raya larga.
"""
import glob
import os
import re
import sys

R = "asic/potencia/resultados"
ESQUINAS = ["nom_tt_025C_5v00", "nom_ss_125C_4v50", "nom_ff_n40C_5v50",
            "min_tt_025C_5v00", "min_ss_125C_4v50", "min_ff_n40C_5v50",
            "max_tt_025C_5v00", "max_ss_125C_4v50", "max_ff_n40C_5v50"]
VENTANAS = ["polling", "espera", "display", "rafaga"]
MODOS = ["defecto", "cero"] + VENTANAS
GRUPOS = ["Sequential", "Combinational", "Clock", "Total"]
DESCR = {
    "defecto": "sin actividad (lo que hizo el flujo)",
    "cero": "actividad global 0 (solo el reloj)",
    "polling": "polling de botones, pantalla de inicio",
    "espera": "espera de 3 s de la ronda (wt_wait_loop)",
    "display": "2000 ciclos alrededor del 01 en el display",
    "rafaga": "solo la rafaga round_begin + show_bcd + wait_tenths",
    "polling_prof1": "calibracion: polling con $dumpvars(1, dut), solo puertos",
}


def leer_rpt(ruta):
    """Devuelve {grupo: (interna, conmutacion, fuga, total)} en W, mas anotados."""
    datos = {"anotados": None, "no_anotados": None}
    with open(ruta) as f:
        texto = f.read()
    m = re.search(r"^Annotated (\d+) pin activities", texto, re.M)
    if m:
        datos["anotados"] = int(m.group(1))
    m = re.search(r"^unannotated\s+(\d+)", texto, re.M)
    if m:
        datos["no_anotados"] = int(m.group(1))
    bloque = texto.split("=== report_power -corner")[1].split("=== report_power -highest")[0]
    for linea in bloque.splitlines():
        partes = linea.split()
        if len(partes) >= 5 and partes[0] in GRUPOS:
            try:
                datos[partes[0]] = tuple(float(x) for x in partes[1:5])
            except ValueError:
                pass
    if "Total" not in datos:
        raise RuntimeError("sin tabla de report_power en " + ruta)
    # Sonda: "sonda puerto clk: 2.00000e+07 0.500 clock" / "sonda pin X/Q: ..."
    datos["sonda"] = {}
    for m in re.finditer(r"^sonda (?:puerto|pin) (\S+): (\S+) (\S+) (\S+)$", texto, re.M):
        datos["sonda"][m.group(1)] = (float(m.group(2)), float(m.group(3)), m.group(4))
    datos["instancias"] = {}
    if "=== sonda: report_power -instances" in texto:
        bloque = texto.split("=== sonda: report_power -instances")[1].split("=== design_power")[0]
        for linea in bloque.splitlines():
            partes = linea.split()
            if len(partes) == 5:
                try:
                    datos["instancias"][partes[4]] = tuple(float(x) for x in partes[0:4])
                except ValueError:
                    pass
    return datos


# Senal del VCD (como la cuenta contar_vcd.py) -> pin de la sonda de potencia.tcl.
MAPA_SONDA = [
    ("clk", "clk", "reloj (puerto)"),
    ("btn[0]", "btn[0]", "boton 0 (puerto)"),
    ("rst_n", "rst_n", "reset (puerto)"),
    ("\\u_soc.u_periph.cycles_q[0]", "u_soc.u_periph.u_cycles/_164_/Q", "cycles_q[0]"),
    ("\\u_soc.u_periph.cycles_q[2]", "u_soc.u_periph.u_cycles/_166_/Q", "cycles_q[2]"),
    ("\\u_soc.u_core.pc_id[2]", "_4418_/Q", "pc_id[2]"),
    ("\\u_soc.g_mem_rom.u_mem.a_rdata_o[0]", "_4186_/Q", "ROM a_rdata_o[0]"),
    ("\\u_soc.u_core.u_rf/regs[9][0]", "u_soc.u_core.u_rf/_3050_/Q", "regs[9][0] (x9 bit 0)"),
    ("\\u_soc.u_periph.u_debounce.u_tick.cnt[0]", "_4551_/Q", "debounce tick cnt[0]"),
    ("\\u_soc.u_core.u_id.operand_a[0]", "OPERAND_A_PIN", "ALU operand_a[0]"),
]
PERIODO_S = 100e-9
# Pin de salida de la celda que maneja operand_a[0] (se reemplaza al generar; ver potencia.tcl).
OPERAND_A_PIN = "_2617_/ZN"


def leer_conteo(ruta):
    """Devuelve {senal: (transiciones, act_por_ciclo, densidad, duty)} de conteo_<ventana>.txt."""
    res = {}
    for linea in open(ruta):
        p = linea.split()
        if len(p) == 5 and (p[0].startswith("\\") or p[0] in ("clk", "rst_n") or p[0].startswith("btn")):
            try:
                res[p[0]] = (int(p[1]), float(p[2]), float(p[3]), float(p[4]))
            except ValueError:
                pass
    return res


def mw(x):
    return "%.3f" % (x * 1e3)


def pct(a, b):
    return "%.1f" % (100.0 * a / b) if b else "-"


def main():
    res = {}
    for ruta in sorted(glob.glob(os.path.join(R, "*.rpt"))):
        nombre = os.path.basename(ruta)[:-4]
        for e in ESQUINAS:
            if nombre.endswith("_" + e):
                modo = nombre[: -len(e) - 1]
                try:
                    res[(modo, e)] = leer_rpt(ruta)
                except Exception as ex:  # noqa: BLE001
                    print("aviso: %s: %s" % (ruta, ex), file=sys.stderr)
                break

    ventanas = {}
    rv = os.path.join(R, "ventanas.txt")
    if os.path.exists(rv):
        for linea in open(rv):
            p = linea.split()
            if len(p) >= 10:
                ventanas[p[0]] = dict(ini=int(p[1]), fin=int(p[2]), ciclos=int(p[3]), bytes=int(p[4]),
                                      vars=int(p[5]), codigos=int(p[6]), t0=int(p[7]), t1=int(p[8]), tiempo=p[9])

    out = []
    out.append("# Tablas de potencia con actividad real (generadas por asic/potencia/tabla.py)\n")
    out.append("Fuente de cada numero: `asic/potencia/resultados/<modo o ventana>_<esquina>.rpt`, tabla de "
               "`report_power -corner <esquina>` (OpenSTA 2.7.0 de la imagen de LibreLane 3.0.16, "
               "`asic/potencia/potencia.tcl`). Potencias en mW; los porcentajes de reloj, secuencial y "
               "combinacional son la fila de cada grupo sobre la fila Total del mismo reporte.\n")

    if ventanas:
        out.append("## Ventanas simuladas (netlist post-PnR de la corrida final, resultados/ventanas.txt)\n")
        out.append("| Ventana | Que cubre | Ciclos [ini, fin) | Ciclos | VCD (MB) | Variables del VCD | Codigos distintos | Duracion del VCD (ns) | Tiempo de simulacion |")
        out.append("|---|---|---|---|---|---|---|---|---|")
        for v in VENTANAS + ["polling_prof1"] + [w + s for s in ("_init0", "_init1") for w in VENTANAS]:
            if v in ventanas:
                d = ventanas[v]
                descr = DESCR.get(v, "%s con los flip-flops sin reset en %s (dffq_func_init.v)" % (v[:-6], v[-1]))
                out.append("| %s | %s | [%d, %d) | %d | %.1f | %d | %d | %d | %s |" % (
                    v, descr, d["ini"], d["fin"], d["ciclos"], d["bytes"] / 1e6, d["vars"], d["codigos"],
                    (d["t1"] - d["t0"]) // 1000, d["tiempo"]))
        out.append("")

    out.append("## Total por modo y esquina (mW) y diferencia contra el modo defecto\n")
    out.append("| Esquina | " + " | ".join(MODOS) + " | pines anotados (VCD) |")
    out.append("|---|" + "---|" * (len(MODOS) + 1))
    for e in ESQUINAS:
        fila = ["`%s`" % e]
        base = res.get(("defecto", e), {}).get("Total", (0, 0, 0, 0))[3]
        for m in MODOS:
            d = res.get((m, e))
            if d is None:
                fila.append("-")
            else:
                t = d["Total"][3]
                if m == "defecto":
                    fila.append(mw(t))
                else:
                    fila.append("%s (%+.1f %%)" % (mw(t), 100.0 * (t - base) / base if base else 0))
        anot = sorted({res[(m, e)]["anotados"] for m in VENTANAS if (m, e) in res and res[(m, e)]["anotados"] is not None})
        fila.append("/".join(str(a) for a in anot) if anot else "-")
        out.append("| " + " | ".join(fila) + " |")
    out.append("")

    for m in MODOS:
        out.append("## %s: %s\n" % (m, DESCR[m]))
        out.append("| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |")
        out.append("|---|---|---|---|---|---|---|---|---|---|")
        for e in ESQUINAS:
            d = res.get((m, e))
            if d is None:
                continue
            tot = d["Total"]
            out.append("| `%s` | %s | %s | %s | %s | %s | %s | %s | %s %% | %s %% |" % (
                e, mw(tot[3]), mw(tot[0]), mw(tot[1]), "%.4f" % (tot[2] * 1e3),
                pct(d["Clock"][3], tot[3]), pct(d["Sequential"][3], tot[3]), pct(d["Combinational"][3], tot[3]),
                pct(tot[0], tot[3]), pct(tot[1], tot[3])))
        out.append("")

    out.append("## Desglose por grupo en la esquina tipica nom_tt_025C_5v00 (mW)\n")
    cols = [m for m in MODOS if (m, "nom_tt_025C_5v00") in res]
    extra = [m for m in ["entrada", "entrada05", "cero_duty0", "polling_prof1"] if (m, "nom_tt_025C_5v00") in res]
    out.append("| Grupo / componente | " + " | ".join(cols + extra) + " |")
    out.append("|---|" + "---|" * (len(cols) + len(extra)))
    for g in GRUPOS:
        for k, nombre in enumerate(["interna", "conmutacion", "fuga", "total"]):
            fila = ["%s %s" % (g, nombre)]
            for m in cols + extra:
                fila.append(mw(res[(m, "nom_tt_025C_5v00")][g][k]))
            out.append("| " + " | ".join(fila) + " |")
    out.append("")
    out.append("Columnas extra de calibracion (solo nom_tt): `entrada` = `set_power_activity -input -activity 0.1 "
               "-duty 0.5`, `entrada05` = lo mismo con actividad 0.5, `cero_duty0` = `set_power_activity -global "
               "-activity 0 -duty 0`, `polling_prof1` = VCD de la ventana polling con `$dumpvars(1, dut)` "
               "(solo los puertos del macro).\n")

    # Sonda: actividad por pin y modo en nom_tt, y contraste con el conteo del VCD.
    e0 = "nom_tt_025C_5v00"
    modos_sonda = [m for m in cols + extra if res[(m, e0)].get("sonda")]
    if modos_sonda:
        out.append("## Sonda: actividad anotada en pines con nombre, esquina nom_tt_025C_5v00\n")
        out.append("Transiciones por ciclo de 100 ns (densidad de `get_property <pin> activity` por 100 ns) y, entre "
                   "parentesis, duty y origen de la actividad segun OpenSTA (`vcd`, `clock`, `input`, `propagated`, "
                   "`global`, `unknown`). Fuente: lineas `sonda` de cada `.rpt`.\n")
        out.append("| Pin | Que es | " + " | ".join(modos_sonda) + " |")
        out.append("|---|---|" + "---|" * len(modos_sonda))
        for senal, pin, que in MAPA_SONDA:
            pin_real = pin if pin != "OPERAND_A_PIN" else OPERAND_A_PIN
            fila = ["`%s`" % pin_real, que]
            for m in modos_sonda:
                d = res[(m, e0)]["sonda"].get(pin_real)
                fila.append("%.4f (%.3f, %s)" % (d[0] * PERIODO_S, d[1], d[2]) if d else "-")
            out.append("| " + " | ".join(fila) + " |")
        out.append("")

        conteos = {}
        for v in VENTANAS:
            rc = os.path.join(R, "conteo_%s.txt" % v)
            if os.path.exists(rc):
                conteos[v] = leer_conteo(rc)
        if conteos:
            out.append("## Contraste: transiciones contadas en el VCD contra la actividad que anota OpenSTA\n")
            out.append("Por ventana: transiciones por ciclo contadas directamente en el VCD por "
                       "`asic/potencia/contar_vcd.py` (`resultados/conteo_<ventana>.txt`) y las que anota OpenSTA "
                       "en el pin correspondiente (`resultados/<ventana>_nom_tt_025C_5v00.rpt`, lineas `sonda`). "
                       "Deben coincidir; el reloj lo fija la SDC (origen `clock`, 2 por ciclo), no el VCD.\n")
            vs = [v for v in VENTANAS if v in conteos and (v, e0) in res]
            out.append("| Senal del VCD | Pin de OpenSTA | " + " | ".join("%s: VCD / OpenSTA" % v for v in vs) + " |")
            out.append("|---|---|" + "---|" * len(vs))
            for senal, pin, que in MAPA_SONDA:
                pin_real = pin if pin != "OPERAND_A_PIN" else OPERAND_A_PIN
                fila = ["`%s`" % senal.replace("\\", ""), "`%s`" % pin_real]
                for v in vs:
                    c = conteos[v].get(senal)
                    d = res[(v, e0)]["sonda"].get(pin_real)
                    fila.append("%s / %s" % ("%.4f" % c[1] if c else "-", "%.4f" % (d[0] * PERIODO_S) if d else "-"))
                out.append("| " + " | ".join(fila) + " |")
            out.append("")

        inst_modos = [m for m in cols + extra if res[(m, e0)].get("instancias")]
        if inst_modos:
            out.append("## Sonda: potencia total de algunas instancias (uW), esquina nom_tt_025C_5v00\n")
            out.append("`report_power -instances` de `asic/potencia/potencia.tcl`; total (interna + conmutacion + fuga) "
                       "en microvatios.\n")
            out.append("| Instancia | Que es | " + " | ".join(inst_modos) + " |")
            out.append("|---|---|" + "---|" * len(inst_modos))
            for senal, pin, que in MAPA_SONDA:
                if pin in ("clk", "btn[0]", "rst_n"):
                    continue
                pin_real = pin if pin != "OPERAND_A_PIN" else OPERAND_A_PIN
                inst = pin_real.rsplit("/", 1)[0]
                fila = ["`%s`" % inst, que]
                for m in inst_modos:
                    d = res[(m, e0)]["instancias"].get(inst)
                    fila.append("%.3f" % (d[3] * 1e6) if d else "-")
                out.append("| " + " | ".join(fila) + " |")
            out.append("")

    # Experimento de sensibilidad: flip-flops sin reset inicializados a 0 y a 1
    # (correr.sh xinit, asic/potencia/dffq_func_init.v) contra la simulacion base
    # (estado inicial x, transiciones a/desde x que OpenSTA no cuenta).
    esq_x = [e for e in ESQUINAS if any((v + "_init0", e) in res for v in VENTANAS)]
    if esq_x:
        out.append("## Sensibilidad a los flip-flops sin reset: estado inicial x (base), 0 y 1 (mW)\n")
        out.append("La simulacion base deja en x los 804 `dffq_1` sin reset (banco de registros, D4; RAM de datos; "
                   "registros de la segmentacion) hasta que el programa los escribe; los nodos de los muxes de "
                   "lectura conmutan a x y OpenSTA no cuenta esas transiciones (`resultados/conteo_x_<ventana>.txt`: "
                   "lineas de valor 0/1 y x del VCD fuera del volcado inicial). Con `asic/potencia/dffq_func_init.v` "
                   "los mismos flip-flops arrancan en 0 o en 1 (`resultados/<ventana>_init<0|1>_<esquina>.rpt`); "
                   "los VCD de esas simulaciones no tienen ninguna linea x "
                   "(`resultados/conteo_x_<ventana>_init<0|1>.txt`), asi que toda la conmutacion que la base "
                   "escondia en x queda contada. La columna Lineas 0/1 init 0 / init 1 muestra cuanta "
                   "conmutacion 0/1 aparece de mas o de menos respecto de la base.\n")
        out.append("| Ventana | Lineas 0/1 del VCD | Lineas x | x / 0/1 | Senales con x | Lineas 0/1 init 0 | Lineas 0/1 init 1 | Esquina | base (x) | init 0 | init 1 | Comb. base / 0 / 1 |")
        out.append("|---|---|---|---|---|---|---|---|---|---|---|---|")

        def leer_cx(nombre):
            d = {}
            rc = os.path.join(R, "conteo_x_%s.txt" % nombre)
            if os.path.exists(rc):
                for linea in open(rc):
                    p = linea.split()
                    if len(p) == 2:
                        d[p[0]] = p[1]
            return d

        for v in VENTANAS:
            cx = leer_cx(v)
            cx0 = leer_cx(v + "_init0")
            cx1 = leer_cx(v + "_init1")
            for e in esq_x:
                b = res.get((v, e)); i0 = res.get((v + "_init0", e)); i1 = res.get((v + "_init1", e))
                if b is None or i0 is None:
                    continue
                tb = b["Total"][3]
                col = lambda d: ("%s (%+.1f %%)" % (mw(d["Total"][3]), 100.0 * (d["Total"][3] - tb) / tb)) if d else "-"
                comb = " / ".join(mw(d["Combinational"][3]) if d else "-" for d in (b, i0, i1))
                out.append("| %s | %s | %s | %s %% | %s | %s | %s | `%s` | %s | %s | %s | %s |" % (
                    v, cx.get("lineas_01", "-"), cx.get("lineas_x", "-"), cx.get("porcentaje_x", "-"),
                    cx.get("senales_con_x", "-"), cx0.get("lineas_01", "-"), cx1.get("lineas_01", "-"),
                    e, mw(tb), col(i0), col(i1), comb))
        out.append("")

    with open(os.path.join(R, "tablas.md"), "w") as f:
        f.write("\n".join(out))
    print("escrito %s/tablas.md (%d reportes)" % (R, len(res)))

    # Histogramas del PC.
    desc = {}
    rom = "rtl/gen/pochoco_rom.v"
    if os.path.exists(rom):
        for linea in open(rom):
            m = re.search(r"//\s*0x([0-9a-f]{4}):\s*(.*)$", linea)
            if m:
                desc[int(m.group(1), 16)] = m.group(2).strip()
    out = ["# Histograma del PC por ventana (RTL, asic/potencia/potencia_tb.v con -DRTL)\n",
           "Ciclos en los que `u_soc.u_core.u_if.pc_q` (la direccion que busca la etapa IF) vale cada "
           "direccion, dentro de la ventana [ini, fin). Las instrucciones son las de `rtl/gen/pochoco_rom.v` "
           "(sw/game.s ensamblado). Una direccion que aparece pocas veces justo despues de un salto es la "
           "busqueda especulativa de PC+4 que el salto descarta. Fuente: `resultados/pc_<ventana>.txt`.\n"]
    for v in VENTANAS:
        ruta = os.path.join(R, "pc_%s.txt" % v)
        if not os.path.exists(ruta):
            continue
        filas = []
        total = 0
        for linea in open(ruta):
            p = linea.split()
            if len(p) == 2 and p[0].startswith("0x"):
                filas.append((int(p[0], 16), int(p[1])))
                total += int(p[1])
            elif len(p) == 2 and p[0] == "fuera":
                filas.append((-1, int(p[1])))
                total += int(p[1])
        d = ventanas.get(v)
        rango = "[%d, %d)" % (d["ini"], d["fin"]) if d else ""
        out.append("## %s %s: %s (%d ciclos)\n" % (v, rango, DESCR[v], total))
        out.append("| PC | Instruccion | Ciclos | % |")
        out.append("|---|---|---|---|")
        for pc, n in filas:
            if pc < 0:
                out.append("| fuera de la ROM | | %d | %s |" % (n, pct(n, total)))
            else:
                out.append("| 0x%04x | `%s` | %d | %s |" % (pc, desc.get(pc, "?"), n, pct(n, total)))
        out.append("")
    with open(os.path.join(R, "ventanas_pc.md"), "w") as f:
        f.write("\n".join(out))
    print("escrito %s/ventanas_pc.md" % R)


if __name__ == "__main__":
    main()
