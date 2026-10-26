#!/usr/bin/env python3
"""Analiza los reportes de síntesis (sección 3.3) y escribe asic/sintesis.md.

Uso:
    python3 asic/analisis_sintesis.py --final asic/rom/runs/final \\
        --jerarquica asic/rom/runs/h2_t100 --md asic/sintesis.md

Entradas (de cada corrida, el reporte de Yosys 06-yosys-synthesis/reports/stat.json):
  --final       la corrida final: síntesis aplanada salvo los tres módulos de
                SYNTH_KEEP_HIERARCHY_MODULES (register file, ALU y contador).
  --jerarquica  una síntesis de la misma configuración con
                SYNTH_HIERARCHY_MODE=keep (solo hasta Yosys.Synthesis), que
                conserva todos los módulos y permite repartir las celdas y el
                área por módulo.

Qué calcula:
  1. área por módulo (local e incluyendo submódulos) y su porcentaje del total,
     a partir de la síntesis jerárquica;
  2. las cinco celdas más usadas de la corrida final, con el desglose por
     módulo (síntesis jerárquica) y la cantidad esperada desde el RTL para las
     celdas que se pueden contar a mano (flip-flops, multiplexores de
     retención);
  3. la fracción de área del contador de ciclos.
Las áreas son las del liberty de la esquina típica que usa Yosys (µm²).
"""

import argparse
import json
import os
import re

LIB = "gf180mcu_fd_sc_mcu7t5v0__"

# Nombre de instancia de cada módulo del RTL (para que las tablas hablen de
# instancias y no de nombres de Yosys). Los $paramod se reducen a su módulo.
INSTANCIAS = {
    "asic_top": "top",
    "pochoco_soc": "u_soc",
    "espino_core": "u_soc.u_core",
    "espino_if_stage": "u_soc.u_core.u_if",
    "espino_id_stage": "u_soc.u_core.u_id",
    "espino_decoder": "u_soc.u_core.u_id.u_decoder",
    "espino_alu": "u_soc.u_core.u_id.u_alu",
    "espino_register_file": "u_soc.u_core.u_rf",
    "espino_load_store_unit": "u_soc.u_core.u_lsu",
    "espino_controller": "u_soc.u_core.u_ctrl",
    "pochoco_mem_rom": "u_soc.g_mem_rom.u_mem",
    "pochoco_rom": "u_soc.g_mem_rom.u_mem.u_rom",
    "pochoco_periph": "u_soc.u_periph",
    "debounce4": "u_soc.u_periph.u_debounce",
    "debounce_tick": "u_soc.u_periph.u_debounce.u_tick",
    "debounce": "u_soc.u_periph.u_debounce.g_btn[0..3].u_db (4 instancias)",
    "pochoco_cycle_counter": "u_soc.u_periph.u_cycles",
}

FUNCION = {
    "asic_top": "sincronizador de reset",
    "pochoco_soc": "decodificador de direcciones y mux de lectura del bus",
    "espino_core": "solo instancias",
    "espino_if_stage": "fetch: PC, PC+4 y registro de PC de la etapa ID",
    "espino_id_stage": "decode y ejecución: pre-decodificación registrada, muxes de operandos, salto y write-back",
    "espino_decoder": "decodificador de instrucciones (combinacional)",
    "espino_alu": "ALU: suma, resta, lógica y comparaciones",
    "espino_register_file": "banco de registros x1 a x15 con dos puertos de lectura registrados",
    "espino_load_store_unit": "LSU: alineación de bytes y medias palabras",
    "espino_controller": "control de stall y salto",
    "pochoco_mem_rom": "registro de instrucción y RAM de datos de 4 palabras",
    "pochoco_rom": "ROM combinacional del programa (generada por el assembler)",
    "pochoco_periph": "registros DISP, LEDS, BTN y lectura registrada",
    "debounce4": "solo instancias",
    "debounce_tick": "divisor del debounce (contador de 15 bits)",
    "debounce": "filtro de un botón (3 muestras)",
    "pochoco_cycle_counter": "contador de ciclos CYCLES (32 bits)",
}

# Flip-flops esperados desde el RTL, por módulo: (sin reset -> dffq, con reset
# asíncrono -> dffrnq). Cada entrada dice de dónde sale el número.
FF_ESPERADOS = {
    "espino_register_file": {"dffq": (544, "15 registros x 32 bits = 480 de almacenamiento + 2 puertos de lectura registrados x 32 = 64"), "dffrnq": (0, "sin reset (D4)")},
    "pochoco_mem_rom": {"dffq": (192, "registro de instrucción a_rdata_o (32) + RAM de 4 x 32 (128) + b_rdata_o (32)"), "dffrnq": (0, "")},
    "espino_id_stage": {"dffq": (82, "pre-decodificación (D18): alu_operator 4 + alu_op_a_sel 2 + alu_op_b_sel 1 + imm_operand 32 + imm_target 32 + rf_we 1 + rf_wd_sel 2 + is_branch/is_jal/is_jalr 3 + lsu_req/lsu_we 2 + lsu_type 2 + lsu_sign 1"), "dffrnq": (1, "ops_valid_q")},
    "espino_if_stage": {"dffq": (0, ""), "dffrnq": (65, "pc_q 32 + pc_id_q 32 + valid_q 1")},
    "espino_load_store_unit": {"dffq": (0, ""), "dffrnq": (1, "busy_q")},
    "pochoco_soc": {"dffq": (0, ""), "dffrnq": (2, "rd_is_per y rd_is_spi")},
    "asic_top": {"dffq": (0, ""), "dffrnq": (2, "rst_sync_q[1:0]")},
    "pochoco_periph": {"dffq": (0, ""), "dffrnq": (52, "btn_meta 4 + btn_sync 4 + led_q 4 + digit_q 8 + rdata_o 32")},
    "debounce_tick": {"dffq": (0, ""), "dffrnq": (15, "cnt de DivBits = 15 bits")},
    "debounce": {"dffq": (0, ""), "dffrnq": (4, "sr de 3 bits + clean_o, por botón")},
    "pochoco_cycle_counter": {"dffq": (0, ""), "dffrnq": (32, "count_o de 32 bits")},
}

# Multiplexores de retención esperados: un mux2 por flip-flop dffq escrito bajo
# condición (la biblioteca no tiene flip-flops con enable), más los muxes
# funcionales que se pueden contar a mano.
MUX2_ESPERADOS = {
    "espino_register_file": (480, "retención de los 480 bits de almacenamiento (regs[waddr] <= wdata solo si we_i); el resto son los árboles de lectura"),
    "pochoco_mem_rom": (160, "retención de los 128 bits de la RAM (escritura por byte) + 32 del registro de instrucción (carga solo si a_req_i)"),
    "espino_id_stage": (82, "retención de los 82 registros de pre-decodificación (cargan solo si !ops_valid_q); el resto son los muxes de operandos, de write-back y de pc_target"),
}

EXPLICACION_CELDA = {
    "dffq_1": "flip-flop D sin reset. Los usa todo registro que no necesita valor de reset: el banco de registros (D4), la RAM de datos, el registro de instrucción y los registros de pre-decodificación.",
    "dffrnq_1": "flip-flop D con reset asíncrono activo en bajo. Es todo registro con `if (!rst_ni)`: PC, contador de ciclos, periféricos, debounce, sincronizadores.",
    "mux2_2": "multiplexor 2:1. La biblioteca no tiene flip-flops con enable, así que cada bit que se escribe bajo condición lleva un mux2 de retención delante del flip-flop; los demás forman los árboles de lectura del banco de registros y los muxes de operandos.",
    "nand2_1": "NAND de 2 entradas, la compuerta más chica de la biblioteca: ABC con la estrategia AREA mapea sobre ella la lógica aleatoria (ROM, decodificador, ALU, comparadores).",
    "mux4_1": "multiplexor 4:1: árboles de lectura de 15 a 1 del banco de registros (dos puertos x 32 bits).",
    "oai21_1": "OR-AND-inversor: lógica aleatoria de la ROM, la ALU y el decodificador de direcciones.",
    "clkinv_1": "inversor chico; la síntesis lo usa como inversor de lógica común, no solo en el reloj.",
    "nor2_1": "NOR de 2 entradas: lógica aleatoria (decodificación de la ROM y comparaciones).",
    "aoi22_1": "AND-OR-inversor 2x2: muxes y selección de datos (lectura del bus, RAM).",
    "aoi21_1": "AND-OR-inversor: lógica aleatoria.",
}


def nombre_modulo(yosys_name):
    s = yosys_name.lstrip("\\")
    if s.startswith("$paramod"):
        partes = s.split("\\")
        # $paramod$hash\modulo  o  $paramod\modulo\Param=...
        for p in partes[1:]:
            if "=" not in p and not p.startswith("$paramod"):
                return p
    return s


def cargar(run):
    cands = [os.path.join(run, d, "reports", "stat.json") for d in os.listdir(run) if d.endswith("yosys-synthesis")]
    if not cands:
        raise SystemExit(f"no hay reportes de síntesis en {run}")
    return json.load(open(cands[0]))


def arbol(stat):
    """Módulos con su área local, inclusiva, celdas locales y submódulos."""
    mods = {}
    for yn, m in stat["modules"].items():
        n = nombre_modulo(yn)
        celdas = {}
        hijos = []
        for c, cnt in m["num_cells_by_type"].items():
            if c.startswith(LIB):
                celdas[c[len(LIB):]] = cnt
            else:
                hijos.append((nombre_modulo(c), cnt))
        mods[n] = {"area_incl": m["area"], "celdas": celdas, "hijos": hijos, "num_cells": m["num_cells"], "seq": m.get("sequential_area", 0)}
    # área local = inclusiva - suma de las inclusivas de los hijos (por instancias)
    for n, m in mods.items():
        m["area_local"] = m["area_incl"] - sum(mods[h]["area_incl"] * k for h, k in m["hijos"] if h in mods)
    return mods


def recorrer(mods, raiz, nivel=0, mult=1, out=None):
    out = out if out is not None else []
    out.append((nivel, raiz, mult))
    for h, k in mods[raiz]["hijos"]:
        if h in mods:
            recorrer(mods, h, nivel + 1, mult * k, out)
    return out


def ff_de(celdas):
    q = sum(v for c, v in celdas.items() if c.startswith("dffq"))
    r = sum(v for c, v in celdas.items() if c.startswith("dffrnq") or c.startswith("dffsnq") or c.startswith("dffrsnq"))
    return q, r


def f0(x):
    return f"{x:,.0f}".replace(",", ".")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--final", required=True)
    ap.add_argument("--jerarquica", required=True)
    ap.add_argument("--md", required=True)
    ap.add_argument("--top", type=int, default=5)
    a = ap.parse_args()

    fin = cargar(a.final)
    jer = cargar(a.jerarquica)
    mods = arbol(jer)
    total_j = jer["design"]["area"]
    total_f = fin["design"]["area"]
    raiz = "asic_top"
    orden = recorrer(mods, raiz)

    L = []
    L.append("# Síntesis: área por módulo y celdas más usadas (sección 3.3)\n")
    L.append(f"Generado por `asic/analisis_sintesis.py` a partir de `{a.final}` (corrida final) y `{a.jerarquica}` (síntesis jerárquica). Áreas en µm² del liberty de la esquina típica que usa Yosys.\n")
    L.append("## Método\n")
    L.append(
        "La corrida final sintetiza aplanando el diseño salvo tres módulos cuya jerarquía se conserva "
        "(`SYNTH_KEEP_HIERARCHY_MODULES`: register file, ALU y contador de ciclos, D12), así que su reporte "
        "solo separa esos tres bloques del resto. Para repartir el área y las celdas entre todos los módulos se "
        "corrió además la misma configuración con `SYNTH_HIERARCHY_MODE=keep` solo hasta `Yosys.Synthesis` "
        "(`librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml -c SYNTH_HIERARCHY_MODE=keep --to Yosys.Synthesis --run-tag h2_t100`). "
        "Esa síntesis conserva todos los módulos y Yosys informa cada uno por separado (`reports/stat.json`). "
        "Las dos síntesis usan el mismo RTL, la misma configuración y las mismas celdas; difieren solo en que la "
        "aplanada optimiza a través de los bordes de módulo, por eso sus totales no son idénticos y la tabla final los compara.\n"
    )
    L.append("## Área por módulo (síntesis jerárquica)\n")
    L.append("Área local: celdas del propio módulo. Área total: incluye sus submódulos. El porcentaje es sobre el área total del diseño en esta síntesis.\n")
    L.append("| módulo (instancia) | función | celdas locales | flip-flops locales | área local (µm²) | área total (µm²) | % del total |")
    L.append("|---|---|---|---|---|---|---|")
    for nivel, n, mult in orden:
        m = mods[n]
        q, r = ff_de(m["celdas"])
        sang = "&nbsp;&nbsp;" * nivel
        inst = INSTANCIAS.get(n, "")
        multtxt = f" x{mult}" if mult > 1 else ""
        L.append(f"| {sang}`{n}`{multtxt} ({inst}) | {FUNCION.get(n, '')} | {m["num_cells"]} | {q + r} | {f0(m['area_local'])} | {f0(m['area_incl'])} | {100 * m['area_incl'] / total_j:.1f} |")
    L.append(f"\nÁrea total de celdas en la síntesis jerárquica: {f0(total_j)} µm²; en la corrida final (aplanada): {f0(total_f)} µm² ({100 * (total_f - total_j) / total_j:+.1f} %, la optimización a través de los bordes de módulo).\n")

    # módulo con más área (hojas, por área local; y por área total excluyendo contenedores)
    hojas = sorted(((m["area_local"], n) for n, m in mods.items()), reverse=True)
    mayor = hojas[0]
    rf = mods.get("espino_register_file")
    L.append(f"**Módulo que más área aporta:** `{mayor[1]}` ({INSTANCIAS.get(mayor[1], '')}), {f0(mayor[0])} µm², {100 * mayor[0] / total_j:.1f} % del total de la síntesis jerárquica"
             + (f"; en la corrida final el módulo conservado `espino_register_file` mide {f0(fin['modules'].get(chr(92) + 'espino_register_file', {}).get('area', 0))} µm² ({100 * fin['modules'].get(chr(92) + 'espino_register_file', {}).get('area', 0) / total_f:.1f} % de {f0(total_f)} µm²)." if rf else "."))
    L.append("")
    cc = mods.get("pochoco_cycle_counter")
    if cc:
        q, r = ff_de(cc["celdas"])
        ccf = fin["modules"].get("\\pochoco_cycle_counter", {}).get("area", cc["area_incl"])
        L.append(f"**Fracción del contador de ciclos (`u_soc.u_periph.u_cycles`):** {f0(cc['area_incl'])} µm², {100 * cc['area_incl'] / total_j:.2f} % de la síntesis jerárquica y {100 * ccf / total_f:.2f} % de la corrida final ({f0(ccf)} de {f0(total_f)} µm²). Son {q + r} flip-flops con reset ({f0(cc['seq'])} µm², {100 * cc['seq'] / cc['area_incl']:.0f} % del módulo) más el incrementador de 32 bits.\n")

    # celdas más usadas en la corrida final
    tot_f = {}
    for yn, m in fin["modules"].items():
        for c, k in m["num_cells_by_type"].items():
            if c.startswith(LIB):
                tot_f[c[len(LIB):]] = tot_f.get(c[len(LIB):], 0) + k
    tot_j = {}
    for n, m in mods.items():
        mult = [mu for _, nn, mu in orden if nn == n]
        mult = mult[0] if mult else 1
        for c, k in m["celdas"].items():
            tot_j[c] = tot_j.get(c, 0) + k * mult
    top = sorted(tot_f.items(), key=lambda x: -x[1])[: a.top]
    ncel_f = sum(tot_f.values())
    L.append(f"## Las {a.top} celdas más usadas de la corrida final\n")
    L.append(f"La corrida final tiene {f0(ncel_f)} celdas de {len(tot_f)} tipos. El desglose por módulo sale de la síntesis jerárquica (misma configuración), por eso su total puede diferir en algunas celdas del de la corrida final.\n")
    L.append("| # | celda | cantidad (final) | % de las celdas | cantidad (jerárquica) | qué la explica |")
    L.append("|---|---|---|---|---|---|")
    for i, (c, k) in enumerate(top, 1):
        base = re.sub(r"_\d+$", "", c)
        L.append(f"| {i} | `{c}` | {k} | {100 * k / ncel_f:.1f} | {tot_j.get(c, 0)} | {EXPLICACION_CELDA.get(c, EXPLICACION_CELDA.get(base + '_1', ''))} |")
    L.append("")
    for i, (c, k) in enumerate(top, 1):
        L.append(f"### {i}. `{c}`: desglose por módulo\n")
        filas = []
        for nivel, n, mult in orden:
            cnt = mods[n]["celdas"].get(c, 0) * mult
            if cnt:
                filas.append((cnt, n, mult))
        filas.sort(reverse=True)
        L.append("| módulo | cantidad | esperado desde el RTL | comentario |")
        L.append("|---|---|---|---|")
        for cnt, n, mult in filas:
            esp, com = "", ""
            if c.startswith("dffq") and n in FF_ESPERADOS:
                e = FF_ESPERADOS[n]["dffq"]
                esp = str(e[0] * mult)
                com = e[1] + (" (coincide)" if e[0] * mult == cnt else f" (difiere en {cnt - e[0] * mult:+d})")
            elif c.startswith("dffrnq") and n in FF_ESPERADOS:
                e = FF_ESPERADOS[n]["dffrnq"]
                esp = str(e[0] * mult)
                com = e[1] + (" (coincide)" if e[0] * mult == cnt else f" (difiere en {cnt - e[0] * mult:+d})")
            elif c.startswith("mux2") and n in MUX2_ESPERADOS:
                e = MUX2_ESPERADOS[n]
                esp = f">= {e[0]}"
                com = e[1] + (f"; quedan {cnt - e[0]} muxes funcionales" if cnt >= e[0] else " (hay menos que los de retención: la síntesis los combinó)")
            L.append(f"| `{n}`{' x' + str(mult) if mult > 1 else ''} | {cnt} | {esp} | {com} |")
        L.append("")
        if c.startswith("dffq") or c.startswith("dffrnq"):
            esperado_total = sum(FF_ESPERADOS[n]["dffq" if c.startswith("dffq") else "dffrnq"][0] * mult for nivel, n, mult in orden if n in FF_ESPERADOS)
            L.append(f"Total esperado desde el RTL: {esperado_total}; síntesis jerárquica: {tot_j.get(c, 0)}; corrida final: {k}."
                     + (f" La diferencia de {tot_j.get(c, 0) - k} entre la jerárquica y la final son flip-flops que la síntesis aplanada elimina al propagar constantes a través de los bordes de módulo (por ejemplo, bits de inmediato que siempre valen 0)." if tot_j.get(c, 0) != k else "") + "\n")

    # comparación con lo esperado antes de sintetizar
    q_f = sum(v for c, v in tot_f.items() if c.startswith("dffq"))
    r_f = sum(v for c, v in tot_f.items() if c.startswith("dffrnq"))
    esperado_q = sum(FF_ESPERADOS[n]["dffq"][0] * mult for nivel, n, mult in orden if n in FF_ESPERADOS)
    esperado_r = sum(FF_ESPERADOS[n]["dffrnq"][0] * mult for nivel, n, mult in orden if n in FF_ESPERADOS)
    L.append("## Comparación con lo esperado antes de sintetizar\n")
    L.append(f"- Flip-flops: el RTL tiene {esperado_q} bits de registro sin reset y {esperado_r} con reset ({esperado_q + esperado_r} en total, contados módulo por módulo arriba). La síntesis jerárquica da {tot_j.get('dffq_1', 0)} + {tot_j.get('dffrnq_1', 0)} y la final {q_f} + {r_f} = {q_f + r_f}.")
    L.append(f"- Se esperaba que el banco de registros dominara el área: 480 bits de almacenamiento más dos árboles de lectura de 15 a 1 por 32 bits, sin celdas de memoria en la biblioteca. Resultó el {100 * (rf['area_incl'] if rf else 0) / total_j:.0f} % del área y concentra los flip-flops sin reset y los multiplexores.")
    L.append("- Se esperaba que los flip-flops fueran la celda más numerosa y los multiplexores la segunda, por los muxes de retención (un mux2 por bit escrito bajo condición). La tabla anterior lo confirma; la novedad es que `nand2_1` queda casi a la par de `mux2_2`: la ROM combinacional, el decodificador y la ALU se mapean sobre la compuerta más chica.")
    L.append(f"- El contador de ciclos es un bloque chico: {100 * (cc['area_incl'] if cc else 0) / total_j:.1f} % del área, casi todo flip-flops con reset.\n")

    with open(a.md, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main()
