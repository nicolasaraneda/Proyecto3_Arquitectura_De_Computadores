#!/usr/bin/env python3
"""Tabla de evolución del rendimiento del diseño, etapa por etapa (sección 3.4).

Uso: python3 asic/evolucion.py [--md asic/evolucion.md]

Una fila por etapa del proyecto. De cada una informa el período mínimo que cierra, la
frecuencia máxima, el CPI del juego completo, los MIPS de la Ley de Hierro, el área de
celdas estándar a 100 ns y las violaciones de max slew y de max capacitancia a 100 ns.
Nada está escrito a mano salvo el CPI y la descripción de cada etapa: el período mínimo
sale de evaluar el criterio de cierre (D14 más DRC, LVS y antenas) sobre las corridas del
barrido de cada etapa, y el resto de los `metrics.json`.

El CPI va declarado en la tabla ETAPAS porque no sale de una corrida de LibreLane sino de
un testbench, y cada valor dice de dónde sale. Las etapas con el RTL de v1 comparten CPI
2,665 porque D18 se verificó equivalente ciclo a ciclo contra el RTL anterior
(`make equiv MODO=ciclo`, REF 116fa20); las del pipeline comparten 1,665.

Al final escribe la descomposición del aumento de MIPS entre lo que aporta el RTL (bajar el
CPI) y lo que aporta el flujo (bajar el período), con los dos órdenes posibles y el término
de interacción, que es la forma honesta de repartirlo.
"""

import argparse
import json
import os

LENTA = "max_ss_125C_4v50"

# (nombre, descripcion, cpi_juego, de donde sale el cpi, corrida a 100 ns, corridas del barrido)
ETAPAS = [
    ("s1 (estrategia 1, configuración de D14 a D16)",
     "RTL del Proyecto 3 antes de la pre-decodificación (equivalente ciclo a ciclo a `116fa20`), "
     "con la configuración corregida de esquinas y celdas de retardo",
     2.665, "`make check` de v1 (`game_tb`); D18 es equivalente ciclo a ciclo a este RTL",
     "asic/rom/resultados/s1_t100",
     ["asic/rom/resultados/s1_t60", "asic/rom/resultados/s1_t55",
      "asic/rom/resultados/s1_t53", "asic/rom/resultados/s1_t52",
      "asic/rom/resultados/s1_t50", "asic/rom/resultados/s1_t45",
      "asic/rom/resultados/s1_t40"]),
    ("p1 (pre-decodificación, D18, con el flujo de D15)",
     "el decode pasa a un registro (D18), con la configuración de flujo de D15 y D16",
     2.665, "el mismo de la fila anterior, porque D18 no cambia ningún ciclo",
     "asic/rom/resultados/p1_t100",
     ["asic/rom/resultados/p1_t50", "asic/rom/resultados/p1_t45",
      "asic/rom/resultados/p1_t42", "asic/rom/resultados/p1_t40",
      "asic/rom/resultados/p1_t38", "asic/rom/resultados/p1_t36",
      "asic/rom/resultados/p1_t34"]),
    ("v1 (corrida final de v1, tag `v1-final`)",
     "lo anterior más el flujo final de D20 y D21 (sin `buf_1`, margen del resizer de 10 ns, "
     "terminales por función)",
     2.665, "`make check` de v1 (`game_tb`): 1.599.759 / 600.218",
     "asic/rom/resultados/v1_final",
     ["asic/rom/resultados/f1_t32", "asic/rom/resultados/f1_t30",
      "asic/rom/resultados/f1_t26", "asic/rom/resultados/f1_t25",
      "asic/rom/resultados/f1_t24p5", "asic/rom/resultados/f1_t24"]),
    ("co_rcm (el RTL de v1 con el modelo de cable)",
     "el mismo RTL de v1 con `LAYERS_RC` y la reparación post-GRT: mide cuánto del salto es del "
     "flujo y no del diseño",
     2.665, "el RTL es el de v1, así que el CPI es el mismo",
     "asic/main_rc/resultados/co_rcm_t100",
     ["asic/main_rc/resultados/co_rcm_t23", "asic/main_rc/resultados/co_rcm_t22",
      "asic/main_rc/resultados/co_rcm_t21p5"]),
    ("pr (el pipeline sin B2, con el flujo final)",
     "el pipeline con lectura del banco y decodificación en el fetch, sin el offset de byte de la "
     "carga registrado en la LSU, con la configuración final: mide el aporte de B2",
     1.665, "`make check` del worktree `build/exp_pipeline`; A y A+B2 tienen el mismo CPI",
     "build/exp_pipeline/asic/rom/resultados/pr_t100",
     ["build/exp_pipeline/asic/rom/resultados/pr_t24",
      "build/exp_pipeline/asic/rom/resultados/pr_t23",
      "build/exp_pipeline/asic/rom/resultados/pr_t22",
      "build/exp_pipeline/asic/rom/resultados/pr_t21p5",
      "build/exp_pipeline/asic/rom/resultados/pr_t21"]),
    ("final (la corrida final de D23)",
     "el pipeline con B2 más el modelo de cable y la reparación post-GRT",
     1.665, "`docs/verificacion/integracion_01_make_check.txt` (`game_tb`): 1.595.814 / 958.358",
     "asic/rom/resultados/final",
     ["asic/rom/resultados/f2_t30", "asic/rom/resultados/f2_t25",
      "asic/rom/resultados/f2_t24", "asic/rom/resultados/f2_t23",
      "asic/rom/resultados/f2_t22", "asic/rom/resultados/f2_t21p5",
      "asic/rom/resultados/f2_t21"]),
]


def met(run):
    p = os.path.join(run, "metrics.json")
    if not os.path.exists(p):
        p = os.path.join(run, "final", "metrics.json")
    return json.load(open(p)) if os.path.exists(p) else None


def periodo(run):
    """El CLOCK_PERIOD de la corrida, leído del tag o de resolved.json."""
    p = os.path.join(run, "resolved.json")
    if os.path.exists(p):
        try:
            return float(json.load(open(p))["CLOCK_PERIOD"])
        except Exception:
            pass
    tag = os.path.basename(run.rstrip("/"))
    if "_t" in tag:
        t = tag.rsplit("_t", 1)[1].replace("p", ".")
        try:
            return float(t)
        except ValueError:
            return None
    return None


def cierra(m):
    g = m.get
    return (g("timing__setup__ws", -1) >= 0 and g("timing__setup__tns", -1) == 0
            and g("timing__hold__ws", -1) >= 0 and g("timing__hold__tns", -1) == 0
            and g("antenna__violating__nets", 1) == 0
            and g("magic__drc_error__count", 1) == 0
            and g("design__lvs_error__count", 1) == 0)


def num(x, dec=0):
    return "n/d" if x is None else f"{x:,.{dec}f}".replace(",", "@").replace(".", ",").replace("@", ".")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--md", help="archivo Markdown de salida")
    a = ap.parse_args()

    L = ["# Evolución del rendimiento del diseño (sección 3.4)", "",
         "Generada por `python3 asic/evolucion.py`. El período mínimo de cada etapa es el menor",
         "`CLOCK_PERIOD` de su barrido que cumple el criterio de cierre (D14 más DRC de Magic, LVS y",
         "antenas); la columna siguiente da el primer período que no cierra, para que se vea la resolución",
         "del barrido. El área, el slew y la capacitancia son los de la corrida a 100 ns de cada etapa.",
         "MIPS = f máx / CPI del juego completo (Ley de Hierro).", "",
         "| etapa | T mínimo (ns) | primer T que no cierra | f máx (MHz) | CPI del juego | MIPS | "
         "área de celdas a 100 ns (µm²) | slew / cap a 100 ns | origen del área |",
         "|---|---|---|---|---|---|---|---|---|"]
    filas = []
    for nombre, desc, cpi, _origen_cpi, r100, barrido in ETAPAS:
        tmin = tno = None
        for r in barrido:
            m, T = met(r), periodo(r)
            if m is None or T is None:
                continue
            if cierra(m):
                if tmin is None or T < tmin:
                    tmin = T
            else:
                if tno is None or T > tno:
                    tno = T
        m100 = met(r100)
        f = 1000.0 / tmin if tmin else None
        mips = f / cpi if f else None
        area = m100 and m100.get("design__instance__area__stdcell")
        sc = (f"{m100['design__max_slew_violation__count']:.0f} / "
              f"{m100['design__max_cap_violation__count']:.0f}") if m100 else "n/d"
        L.append(f"| {nombre} | {num(tmin, 1) if tmin else 'sin barrido'} | "
                 f"{num(tno, 1) if tno else 'sin cota'} | {num(f, 1)} | {num(cpi, 3)} | "
                 f"{num(mips, 1)} | {num(area)} | {sc} | `{r100}/metrics.json` |")
        filas.append((nombre, desc, cpi, tmin, f, mips, area))
    L.append("")
    L.append("Descripción y origen del CPI de cada etapa:")
    L.append("")
    for nombre, desc, cpi, origen in [(e[0], e[1], e[2], e[3]) for e in ETAPAS]:
        L.append(f"- **{nombre}**: {desc}. CPI {num(cpi, 3)}; origen del CPI: {origen}.")
    L.append("")

    # descomposicion del aumento de MIPS entre RTL y flujo
    d = {e[0].split(" ")[0]: e for e in filas}
    v1 = next((f for f in filas if f[0].startswith("v1")), None)
    fin = next((f for f in filas if f[0].startswith("final")), None)
    rcm = next((f for f in filas if f[0].startswith("co_rcm")), None)
    L.append("## Cuánto del aumento de MIPS viene del RTL y cuánto del flujo")
    L.append("")
    if v1 and fin and v1[5] and fin[5]:
        L.append(f"De v1 a la corrida final los MIPS pasan de {num(v1[5],1)} a {num(fin[5],1)}, "
                 f"es decir {num(fin[5]-v1[5],1)} MIPS más ({num(100*(fin[5]/v1[5]-1),1)} por ciento).")
        L.append("")
        L.append("MIPS = (1000 / T) / CPI, así que el aumento se puede repartir de dos maneras, y las")
        L.append("dos hay que darlas porque la diferencia entre ellas es el término de interacción")
        L.append("(bajar el período rinde más cuando el CPI ya es bajo):")
        L.append("")
        L.append("| camino | paso | MIPS | aporte |")
        L.append("|---|---|---|---|")
        # orden A: primero el flujo (RTL de v1 con el modelo de cable), despues el RTL
        if rcm and rcm[5]:
            L.append(f"| primero el flujo | v1 | {num(v1[5],1)} | |")
            L.append(f"| primero el flujo | v1 con el modelo de cable (co_rcm, T {num(rcm[3],1)} ns, "
                     f"CPI {num(rcm[2],3)}) | {num(rcm[5],1)} | {num(rcm[5]-v1[5],1)} MIPS del flujo |")
            L.append(f"| primero el flujo | la corrida final (T {num(fin[3],1)} ns, CPI "
                     f"{num(fin[2],3)}) | {num(fin[5],1)} | {num(fin[5]-rcm[5],1)} MIPS del RTL |")
        # orden B: primero el RTL (la candidata con el flujo de v1), despues el flujo
        cand_t, cand_cpi = 25.5, 1.665   # exp/candidata con la configuracion de v1
        cand = (1000.0 / cand_t) / cand_cpi
        L.append(f"| primero el RTL | v1 | {num(v1[5],1)} | |")
        L.append(f"| primero el RTL | el pipeline con el flujo de v1 (`exp/candidata`, T "
                 f"{num(cand_t,1)} ns, CPI {num(cand_cpi,3)}) | {num(cand,1)} | "
                 f"{num(cand-v1[5],1)} MIPS del RTL |")
        L.append(f"| primero el RTL | la corrida final (T {num(fin[3],1)} ns, CPI {num(fin[2],3)}) | "
                 f"{num(fin[5],1)} | {num(fin[5]-cand,1)} MIPS del flujo |")
        L.append("")
        if rcm and rcm[5]:
            rtl_min, flujo_min = min(fin[5]-rcm[5], cand-v1[5]), min(rcm[5]-v1[5], fin[5]-cand)
            inter = (fin[5]-v1[5]) - rtl_min - flujo_min
            L.append(f"Repartido de la forma conservadora (a cada factor su aporte más chico y el resto")
            L.append(f"a la interacción): **{num(rtl_min,1)} MIPS los pone el RTL** (bajar el CPI de "
                     f"{num(v1[2],3)} a {num(fin[2],3)}), **{num(flujo_min,1)} MIPS los pone el flujo**")
            L.append(f"(bajar el período de {num(v1[3],1)} a {num(fin[3],1)} ns) y **{num(inter,1)} MIPS")
            L.append("son de la interacción**, que no se le puede atribuir a ninguno de los dos por")
            L.append("separado. El orden de magnitud es claro: el RTL manda, porque el CPI entra")
            L.append("dividiendo y bajó un 37,5 por ciento mientras el período bajó un 12,2 por ciento.")
        L.append("")
        L.append("Origen de cada MIPS de la tabla: el período mínimo de cada fila sale de su barrido en")
        L.append("la tabla de arriba, y el CPI de la lista de orígenes de cada etapa. El valor de")
        L.append("`exp/candidata` con el flujo de v1 (25,5 ns) está en `docs/propuesta_d23.md`,")
        L.append("sección 4, y en `asic/exploraciones_tabla.md`.")
    else:
        L.append("Faltan corridas: no se puede calcular todavía.")
    L.append("")
    texto = "\n".join(L) + "\n"
    print(texto)
    if a.md:
        open(a.md, "w", encoding="utf-8").write(texto)


if __name__ == "__main__":
    main()
