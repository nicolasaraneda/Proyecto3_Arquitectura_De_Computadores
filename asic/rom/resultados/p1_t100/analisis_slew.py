#!/usr/bin/env python3
"""Violaciones de max slew de checks.rpt agrupadas por celda, dirección y net."""
import re, sys, collections

LIB = sys.argv[1]; CHK = sys.argv[2]; NL = sys.argv[3]

# --- direcciones de pines por celda (liberty) ---
dirs = {}
cell = None
for line in open(LIB, encoding="utf-8", errors="replace"):
    m = re.match(r"\s*cell\((\S+)\)", line)
    if m: cell = m.group(1); continue
    m = re.match(r"\s*pin\((\S+)\)", line)
    if m: pin = m.group(1); continue
    m = re.match(r"\s*direction\s*:\s*(\w+)", line)
    if m and cell: dirs[(cell, pin)] = m.group(1)

# --- netlist plano ---
txt = open(NL, encoding="utf-8", errors="replace").read()
def norm(s):
    s = s.strip()
    return s[1:].strip() if s.startswith("\\") else s
inst_cell = {}            # instancia -> celda
pin_net = {}              # (instancia, pin) -> net
net_pins = collections.defaultdict(list)  # net -> [(instancia, pin, dir)]
for m in re.finditer(r"^\s*(gf180mcu_fd_sc_mcu7t5v0__\w+)\s+(\\?\S+)\s*\((.*?)\);", txt, re.M | re.S):
    c, inst, conns = m.group(1), norm(m.group(2)), m.group(3)
    inst_cell[inst] = c
    for pm in re.finditer(r"\.(\w+)\(([^()]*)\)", conns):
        p, net = pm.group(1), norm(pm.group(2))
        if not net or "'" in net: continue
        pin_net[(inst, p)] = net
        net_pins[net].append((inst, p, dirs.get((c, p), "?")))
# puertos del top
ports = {}
hdr = re.search(r"module\s+asic_top\s*\((.*?)\);", txt, re.S).group(1)
for d in ("input", "output"):
    for pm in re.finditer(rf"^\s*{d}\s+(?:\[[^\]]+\]\s*)?(\\?\S+?)\s*;", txt, re.M):
        ports[norm(pm.group(1))] = d
for pm in re.finditer(r"^\s*(input|output)\s+\[(\d+):(\d+)\]\s*(\\?\S+?)\s*;", txt, re.M):
    d, a, b, name = pm.groups()
    for i in range(min(int(a), int(b)), max(int(a), int(b)) + 1):
        ports[f"{norm(name)}[{i}]"] = d

def driver(net):
    for inst, p, d in net_pins[net]:
        if d == "output": return inst, inst_cell[inst], p
    if ports.get(net) == "input": return net, "puerto de entrada", ""
    return None, "?", ""
def fanout(net):
    n = sum(1 for _, _, d in net_pins[net] if d == "input")
    if ports.get(net) == "output": n += 1
    return n

# --- sección max slew de checks.rpt ---
viol = []
on = False
for line in open(CHK, encoding="utf-8", errors="replace"):
    if line.startswith("max slew"): on = True; continue
    if on and (line.startswith("max fanout") or line.startswith("max capacitance") or line.startswith("====")): break
    m = re.match(r"(\S+)\s+([\d.]+)\s+([\d.]+)\s+(-?[\d.]+)\s+\(VIOLATED\)", line)
    if on and m: viol.append((m.group(1), float(m.group(2)), float(m.group(3)), float(m.group(4))))
print(f"Violaciones de max slew en checks.rpt: {len(viol)}")
limites = collections.Counter(v[1] for v in viol)
print(f"Límite reportado por pin: {dict(limites)}")
print(f"Slew máximo: {max(v[2] for v in viol):.3f} ns; mínimo entre violaciones: {min(v[2] for v in viol):.3f} ns")

por_celda = collections.Counter(); por_dir = collections.Counter(); por_celda_dir = collections.Counter()
nets = collections.Counter(); sin_mapa = []
clk = 0; rst_pins = 0
# nets derivados de rst_sync_q: BFS por buffers/inversores/retardos
rst_nets = set(n for n in net_pins if n.startswith("rst_sync_q"))
cola = list(rst_nets)
while cola:
    n = cola.pop()
    for inst, p, d in net_pins[n]:
        c = inst_cell[inst]
        if d == "input" and re.search(r"__(buf|clkbuf|inv|clkinv|dly)\w*_\d+$", c):
            for (i2, p2), n2 in pin_net.items():
                if i2 == inst and dirs.get((c, p2)) == "output" and n2 not in rst_nets:
                    rst_nets.add(n2); cola.append(n2)
viol_nets = {}
for pinpath, lim, slew, slack in viol:
    if "/" in pinpath:
        inst, p = pinpath.rsplit("/", 1)
        c = inst_cell.get(inst)
        if c is None: sin_mapa.append(pinpath); continue
        d = dirs.get((c, p), "?")
        net = pin_net.get((inst, p))
    else:
        c = "puerto " + ports.get(pinpath, "?"); d = "output" if ports.get(pinpath) == "output" else "input"
        net = pinpath
    por_celda[c] += 1; por_dir[d] += 1; por_celda_dir[(c, d)] += 1
    if net:
        nets[net] += 1
        if "clk" in net: clk += 1
        if net in rst_nets: rst_pins += 1
print(f"Pines sin mapear en el netlist: {len(sin_mapa)} {sin_mapa[:5]}")
print(f"\nPor dirección del pin: entrada {por_dir['input']}, salida {por_dir['output']}, otra {por_dir['?']}")
print("\nPor tipo de celda (total / pines de entrada / pines de salida):")
for c, n in por_celda.most_common():
    print(f"  {c:45s} {n:5d}  ent {por_celda_dir[(c,'input')]:5d}  sal {por_celda_dir[(c,'output')]:5d}")
print(f"\nNets distintos con pines en violación: {len(nets)}")
print("\n15 nets con más pines en violación (pines en violación / driver: instancia, celda, pin / fanout del net):")
for net, n in nets.most_common(15):
    inst, c, p = driver(net)
    print(f"  {net:40s} {n:4d}  {inst}/{p} ({c})  fanout {fanout(net)}")
print(f"\nViolaciones en nets de reloj (nombre con 'clk'): {clk}")
print(f"Nets derivados de rst_sync_q (buffers/inversores): {len(rst_nets)} -> {sorted(rst_nets)}")
print(f"Violaciones en la red de reset: {rst_pins}")

# --- complemento: nets en violación agrupados por la celda que los maneja y por fanout ---
drv = collections.Counter(); fo = collections.Counter(); fo_buf1 = collections.Counter()
for net in nets:
    inst, c, p = driver(net)
    drv[c] += 1; fo[fanout(net)] += 1
    if c.endswith("__buf_1"): fo_buf1[fanout(net)] += 1
print("\nNets en violación según la celda que los maneja:")
for c, n in drv.most_common():
    print(f"  {c:45s} {n:4d}")
print("\nNets en violación según su fanout (fanout: cantidad de nets):")
print("  " + ", ".join(f"{k}: {v}" for k, v in sorted(fo.items())))
print("Solo los manejados por buf_1 (fanout: cantidad de nets):")
print("  " + ", ".join(f"{k}: {v}" for k, v in sorted(fo_buf1.items())))
# instancias buf_1 en el netlist y cuántas vienen del resizer (fanout*/max_cap*/hold*/input*/output*)
buf1 = [i for i, c in inst_cell.items() if c.endswith("__buf_1")]
pref = collections.Counter(re.sub(r"\d+$", "", i.rsplit("/", 1)[-1]) for i in buf1)
print(f"\nInstancias buf_1 en el netlist: {len(buf1)}; por prefijo de nombre: {dict(pref.most_common())}")

# --- complemento 2: distribución de pines en violación por net y detalle de la red de reset ---
dist = collections.Counter(nets.values())
print("\nNets según cantidad de pines en violación (pines: nets):")
print("  " + ", ".join(f"{k}: {v}" for k, v in sorted(dist.items(), reverse=True)))
print("\nRed de reset: nets derivados de rst_sync_q con pines en violación (net / pines en violación / driver / fanout):")
for net in sorted(rst_nets):
    if nets.get(net):
        inst, c, p = driver(net)
        print(f"  {net:16s} {nets[net]:3d}  {inst}/{p} ({c})  fanout {fanout(net)}")
print("Red de reset: nets derivados de rst_sync_q sin violaciones: " + ", ".join(n for n in sorted(rst_nets) if not nets.get(n)))
# celdas de los pines en violación de la red de reset
rc = collections.Counter()
for pinpath, lim, slew, slack in viol:
    if "/" in pinpath:
        inst, p = pinpath.rsplit("/", 1)
        net = pin_net.get((inst, p))
        if net in rst_nets: rc[(inst_cell[inst], dirs.get((inst_cell[inst], p), "?"))] += 1
print("Red de reset: pines en violación por celda y dirección: " + ", ".join(f"{c} {d}: {n}" for (c, d), n in rc.most_common()))
