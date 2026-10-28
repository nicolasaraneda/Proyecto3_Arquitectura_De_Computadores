#!/usr/bin/env python3
"""Deja un solo nombre público por red, común a gold y gate (frente D2).

Uso: canonizar.py <gold.json> <gate.json> <directorio de salida> [--solo-ff]

Con --solo-ff solo quedan con nombre común los puertos y las salidas de flip-flop
(los demás nombres comunes se ocultan en los dos lados), de modo que eqy corta
únicamente en registros y cada partición es el cono combinacional entre registros.

eqy empareja señales por nombre y usa las señales emparejadas como puntos de
corte de las particiones. Si una misma red tiene dos nombres emparejados (en el
RTL aplanado, u_soc.u_core.lsu_addr[2] y u_soc.u_core.u_id.u_alu.result_o[2]
son la misma red, y en el netlist también), las dos entran a la partición como
entradas libres independientes y el solver encuentra contraejemplos falsos
(en build/eqy/sint de la primera corrida, led.0: lsu_addr[2] = 0 y
result_o[2] = 1 en el mismo paso).

Este script lee los JSON que escribe `write_json` de los dos diseños, ya
aplanados y con `splitnets -ports` (todos los wires de 1 bit). En el JSON, dos
nombres son alias de la misma red cuando tienen el mismo número de bit. Por
cada red elige un nombre que exista en los dos lados (primero los puertos,
después los que son salida de flip-flop en los dos lados, después el más corto
y, a igual largo, el menor alfabéticamente; función `elegir`) y escribe un
script de Yosys por lado que renombra a nombres privados ($alias_N, que eqy no
empareja) los demás nombres públicos de esa red. Si una red del gold contiene
dos nombres que en el gate son redes distintas, deja uno y oculta el otro en
los dos lados. Lo que no tiene nombre común en los dos lados queda como está.

Salida (en el directorio dado):
  gold_renombrar.ys, gate_renombrar.ys   "cd asic_top" + un rename por alias
  resumen.txt                            conteos
  comunes.txt                            nombres canónicos comunes (uno por red)
  ff_gold_sin_par.txt                    bits Q de flip-flops del gold sin nombre común
  ff_gate_sin_par.txt                    ídem del gate
"""
import json
import os
import sys

TIPOS_FF = ('$dff', '$adff', '$sdff', '$aldff', '$dffsr', '$dffe', '$adffe', '$sdffe',
            '$sdffce', '$aldffe', '$dffsre', '$_DFF', '$_SDFF', '$_ALDFF', '$_DFFSR',
            '$_DLATCH', '$dlatch', '$ff', '$_FF_')


def leer(ruta, top):
    d = json.load(open(ruta))
    if top not in d['modules']:
        sys.exit('%s: no tiene el módulo %s (tiene %s)' % (ruta, top, ', '.join(d['modules'])))
    m = d['modules'][top]
    puertos = set()
    for nombre, p in m['ports'].items():
        if len(p['bits']) == 1:
            puertos.add(nombre)
        else:
            for i in range(len(p['bits'])):
                puertos.add('%s[%d]' % (nombre, i))
    nombre_de_bit = {}   # bit -> [nombres públicos]
    bit_de_nombre = {}
    multibit = 0
    for nombre, nn in m['netnames'].items():
        if nn.get('hide_name', 0):
            continue
        bits = nn['bits']
        if len(bits) == 1:
            pares = [(nombre, bits[0])]
        else:
            multibit += 1
            desplazamiento = nn.get('offset', 0)
            pares = [('%s[%d]' % (nombre, i + desplazamiento), b) for i, b in enumerate(bits)]
        for n, b in pares:
            if not isinstance(b, int):
                continue   # bit constante
            nombre_de_bit.setdefault(b, []).append(n)
            bit_de_nombre[n] = b
    q_bits = set()
    n_ff = 0
    for c in m['cells'].values():
        if c['type'].startswith(TIPOS_FF):
            n_ff += 1
            for b in c['connections'].get('Q', []):
                if isinstance(b, int):
                    q_bits.add(b)
    return dict(puertos=puertos, nombre_de_bit=nombre_de_bit, bit_de_nombre=bit_de_nombre,
                q_bits=q_bits, n_ff=n_ff, multibit=multibit)


def elegir(candidatos, puertos, ff=frozenset()):
    """Puertos primero; después nombres que son salida de flip-flop (en los dos lados);
    después el más corto y, a igual largo, el menor alfabéticamente."""
    return min(candidatos, key=lambda n: (n not in puertos, n not in ff, len(n), n))


def main():
    solo_ff = '--solo-ff' in sys.argv
    args = [a for a in sys.argv[1:] if a != '--solo-ff']
    if len(args) != 3:
        sys.exit(__doc__)
    gold_json, gate_json, salida = args
    top = 'asic_top'
    os.makedirs(salida, exist_ok=True)
    g = leer(gold_json, top)
    t = leer(gate_json, top)
    nombres_gold = set(g['bit_de_nombre'])
    nombres_gate = set(t['bit_de_nombre'])
    comunes_antes = nombres_gold & nombres_gate
    # nombres que son salida de flip-flop en los dos lados (se prefieren como canónicos para
    # que los registros queden emparejados y sean puntos de corte de la inducción)
    ff_comunes = frozenset(n for n in comunes_antes
                           if g['bit_de_nombre'][n] in g['q_bits'] and t['bit_de_nombre'][n] in t['q_bits'])

    # 1. gate: por red, un nombre canónico que también exista en gold
    canon_gate = {}          # bit del gate -> nombre
    ocultar_gate = set()
    for b, nombres in t['nombre_de_bit'].items():
        cands = [n for n in nombres if n in nombres_gold]
        if not cands:
            continue
        c = elegir(cands, t['puertos'], ff_comunes)
        canon_gate[b] = c
        ocultar_gate |= {n for n in nombres if n != c and n not in t['puertos']}
    nombres_canon_gate = set(canon_gate.values())

    # 2. gold: por red, el nombre canónico del gate; si hay más de uno (gold une
    #    redes que el gate tiene separadas) se deja uno y el resto se oculta en
    #    los dos lados.
    canon_gold = {}
    ocultar_gold = set()
    unidas = []
    for b, nombres in g['nombre_de_bit'].items():
        cands = [n for n in nombres if n in nombres_canon_gate]
        if not cands:
            continue
        c = elegir(cands, g['puertos'], ff_comunes)
        canon_gold[b] = c
        ocultar_gold |= {n for n in nombres if n != c and n not in g['puertos']}
        sobran = [n for n in cands if n != c]
        if sobran:
            unidas.append((c, sobran))
            ocultar_gate |= {n for n in sobran if n not in t['puertos']}
    comunes = set(canon_gold.values()) & (nombres_canon_gate - ocultar_gate)

    # 3. --solo-ff: se ocultan además los nombres comunes que no son puertos ni salida de
    #    flip-flop en los dos lados. Así eqy solo empareja registros y puertos, y cada
    #    partición es el cono combinacional completo entre registros: las señales
    #    intermedias (stall, lsu_busy, rf_we, ...) dejan de ser entradas libres de la
    #    partición, lo que evitaba contraejemplos con combinaciones imposibles (por
    #    ejemplo stall = 0 con instr_valid_id = 1 y rf_ready = 0).
    solo_ff_ocultos = set()
    if solo_ff:
        for c in comunes:
            if c in g['puertos'] or c in t['puertos']:
                continue
            if g['bit_de_nombre'][c] in g['q_bits'] and t['bit_de_nombre'][c] in t['q_bits']:
                continue
            solo_ff_ocultos.add(c)
        ocultar_gold |= solo_ff_ocultos
        ocultar_gate |= solo_ff_ocultos
        comunes -= solo_ff_ocultos

    for lado, ocultar in (('gold', ocultar_gold), ('gate', ocultar_gate)):
        with open(os.path.join(salida, lado + '_renombrar.ys'), 'w') as f:
            f.write('cd %s\n' % top)
            for i, n in enumerate(sorted(ocultar)):
                f.write('rename \\%s $alias_%s_%d\n' % (n, lado, i))
            f.write('cd\n')
    with open(os.path.join(salida, 'comunes.txt'), 'w') as f:
        for n in sorted(comunes):
            f.write(n + '\n')

    # Flip-flops sin par: bits Q cuya red no tiene nombre común
    ff_gold_sin = sorted(elegir(g['nombre_de_bit'][b], g['puertos']) if b in g['nombre_de_bit'] else '(sin nombre público, bit %d)' % b
                         for b in g['q_bits'] if b not in canon_gold)
    ff_gate_sin = sorted(elegir(t['nombre_de_bit'][b], t['puertos']) if b in t['nombre_de_bit'] else '(sin nombre público, bit %d)' % b
                         for b in t['q_bits'] if b not in canon_gate or canon_gate[b] in ocultar_gate)
    with open(os.path.join(salida, 'ff_gold_sin_par.txt'), 'w') as f:
        f.write('\n'.join(ff_gold_sin) + ('\n' if ff_gold_sin else ''))
    with open(os.path.join(salida, 'ff_gate_sin_par.txt'), 'w') as f:
        f.write('\n'.join(ff_gate_sin) + ('\n' if ff_gate_sin else ''))

    lineas = [
        'gold: %d celdas de flip-flop, %d bits Q, %d redes con nombre público, %d nombres públicos, %d puertos, %d wires de más de un bit'
        % (g['n_ff'], len(g['q_bits']), len(g['nombre_de_bit']), len(nombres_gold), len(g['puertos']), g['multibit']),
        'gate: %d celdas de flip-flop, %d bits Q, %d redes con nombre público, %d nombres públicos, %d puertos, %d wires de más de un bit'
        % (t['n_ff'], len(t['q_bits']), len(t['nombre_de_bit']), len(nombres_gate), len(t['puertos']), t['multibit']),
        'redes del gold con más de un nombre: %d; del gate: %d'
        % (sum(1 for v in g['nombre_de_bit'].values() if len(v) > 1), sum(1 for v in t['nombre_de_bit'].values() if len(v) > 1)),
        'nombres comunes antes de canonizar: %d (%d son salida de flip-flop en los dos lados)' % (len(comunes_antes), len(ff_comunes)),
        'redes con nombre canónico común después: %d' % len(comunes),
        'nombres ocultados: %d en gold, %d en gate' % (len(ocultar_gold), len(ocultar_gate)),
        'redes del gold que el gate tiene separadas (se dejó un nombre): %d' % len(unidas),
        'bits Q de flip-flop con nombre común: gold %d de %d, gate %d de %d'
        % (len(g['q_bits']) - len(ff_gold_sin), len(g['q_bits']), len(t['q_bits']) - len(ff_gate_sin), len(t['q_bits'])),
        'bits Q sin par: gold %d (ff_gold_sin_par.txt), gate %d (ff_gate_sin_par.txt)' % (len(ff_gold_sin), len(ff_gate_sin)),
    ]
    if unidas:
        lineas.append('ejemplos de redes unidas en gold: ' + '; '.join('%s = %s' % (c, ' = '.join(s)) for c, s in unidas[:5]))
    if solo_ff:
        lineas.append('--solo-ff: %d nombres comunes que no son puerto ni flip-flop ocultados en los dos lados; quedan %d nombres comunes (puertos y salidas de flip-flop)'
                      % (len(solo_ff_ocultos), len(comunes)))
    with open(os.path.join(salida, 'resumen.txt'), 'w') as f:
        f.write('\n'.join(lineas) + '\n')
    print('\n'.join(lineas))


if __name__ == '__main__':
    main()
