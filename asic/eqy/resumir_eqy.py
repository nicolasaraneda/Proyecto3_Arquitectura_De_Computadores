#!/usr/bin/env python3
"""Resume el logfile.txt de una corrida de eqy (frente D2).

Uso: resumir_eqy.py <directorio de trabajo de eqy> [--md | --particiones]

Cuenta las particiones, cuántas probó cada estrategia, cuáles no se pudieron probar
y con qué motivo por estrategia ("partitions not equivalent" es un contraejemplo del
miter de la partición; "equivalence unknown" es que la inducción no cerró en la
profundidad dada), el resultado final (PASS/FAIL) y los tiempos que informa eqy.
"""
import os
import re
import sys


def main():
    d = sys.argv[1]
    md = '--md' in sys.argv
    log = open(os.path.join(d, 'logfile.txt')).read().splitlines()
    particiones = set()
    for linea in open(os.path.join(d, 'partition.list')):
        partes = linea.split()
        if len(partes) >= 2:
            particiones.add(partes[1])
    probadas = {}      # partición -> estrategia
    motivos = {}       # partición -> [(estrategia, motivo)]
    falladas = []
    reloj = cpu = resultado = None
    for l in log:
        m = re.search(r"Proved equivalence of partition '([^']+)' using strategy '([^']+)'", l)
        if m:
            probadas[m.group(1)] = m.group(2)
            continue
        m = re.search(r"Could not prove equivalence of partition '([^']+)' using strategy '([^']+)': (.*)$", l)
        if m:
            motivos.setdefault(m.group(1), []).append((m.group(2), m.group(3)))
            continue
        m = re.search(r"Failed to prove equivalence of partition (\S+)", l)
        if m:
            falladas.append(m.group(1))
            continue
        m = re.search(r"Elapsed clock time .*\((\d+)\)", l)
        if m:
            reloj = int(m.group(1))
        m = re.search(r"Elapsed process time .*\((\d+)\)", l)
        if m:
            cpu = int(m.group(1))
        m = re.search(r"DONE \((PASS|FAIL)", l)
        if m:
            resultado = m.group(1)
    por_estrategia = {}
    for e in probadas.values():
        por_estrategia[e] = por_estrategia.get(e, 0) + 1
    motivos_cuenta = {}
    for p in falladas:
        for e, mo in motivos.get(p, []):
            k = '%s: %s' % (e, mo)
            motivos_cuenta[k] = motivos_cuenta.get(k, 0) + 1
    grupos = {}
    for p in falladas:
        base = re.sub(r'\.\d+$', '', p)
        grupos.setdefault(base, []).append(p)
    if md:
        print('| particiones | probadas | por estrategia | no probadas | resultado | tiempo de reloj (s) | tiempo de CPU (s) |')
        print('|---|---|---|---|---|---|---|')
        print('| %d | %d | %s | %d | %s | %s | %s |' % (
            len(particiones), len(probadas),
            ', '.join('%s %d' % kv for kv in sorted(por_estrategia.items())) or '-',
            len(falladas), resultado or 'sin terminar', reloj if reloj is not None else '-', cpu if cpu is not None else '-'))
        if falladas:
            print()
            print('Motivos por estrategia en las no probadas: ' + '; '.join('%s (%d)' % kv for kv in sorted(motivos_cuenta.items())))
            print()
            print('| grupo de particiones no probadas | cuántas | ejemplos |')
            print('|---|---|---|')
            for base, lista in sorted(grupos.items()):
                print('| %s | %d | %s |' % (base, len(lista), ', '.join(sorted(lista)[:4])))
    else:
        print('particiones: %d; probadas: %d (%s); no probadas: %d; resultado: %s; reloj %s s, CPU %s s' % (
            len(particiones), len(probadas), ', '.join('%s %d' % kv for kv in sorted(por_estrategia.items())),
            len(falladas), resultado, reloj, cpu))
        for k, v in sorted(motivos_cuenta.items()):
            print('  %s: %d' % (k, v))
        for base, lista in sorted(grupos.items()):
            print('  no probadas %s: %d' % (base, len(lista)))


if __name__ == '__main__' and '--particiones' not in sys.argv:
    main()


def tabla_particiones(d):
    """Tabla Markdown con una fila por partición: salidas comparadas, estrategia que la
    probó (o el motivo de cada estrategia si no se probó) y tiempo de CPU de la
    estrategia que la probó (sat: "time:" al final de run.log; sby: "Elapsed process
    time" de su logfile.txt)."""
    salidas = {}
    for linea in open(os.path.join(d, 'partition.list')):
        partes = linea.split()
        if len(partes) >= 2:
            salidas[partes[1]] = len(partes) - 4
    log = open(os.path.join(d, 'logfile.txt')).read().splitlines()
    estado = {}
    for l in log:
        m = re.search(r"Proved equivalence of partition '([^']+)' using strategy '([^']+)'", l)
        if m:
            estado[m.group(1)] = ('probada', m.group(2))
        m = re.search(r"Could not prove equivalence of partition '([^']+)' using strategy '([^']+)': (.*)$", l)
        if m and m.group(1) not in estado:
            estado.setdefault(m.group(1) + '\0', []).append('%s: %s' % (m.group(2), m.group(3)))
    filas = []
    for p in sorted(salidas, key=lambda x: (-salidas[x], x)):
        if p in estado:
            e = estado[p][1]
            t = '-'
            if e == 'sat':
                for l in open(os.path.join(d, 'strategies', p, 'sat', 'run.log'), errors='ignore'):
                    m = re.search(r'time: ([0-9.]+)s, user: ([0-9.]+)s', l)
                    if m:
                        t = '%.1f' % (float(m.group(2)))
            else:
                try:
                    for l in open(os.path.join(d, 'strategies', p, e, p, 'logfile.txt'), errors='ignore'):
                        m = re.search(r'Elapsed process time .*\((\d+)\)', l)
                        if m:
                            t = m.group(1)
                except OSError:
                    pass
            filas.append((p, salidas[p], 'probada', e, t))
        else:
            filas.append((p, salidas[p], 'no probada', '; '.join(estado.get(p + '\0', [])), '-'))
    print('| partición | salidas comparadas | resultado | estrategia (o motivos) | CPU (s) |')
    print('|---|---|---|---|---|')
    for f in filas:
        print('| %s | %d | %s | %s | %s |' % f)


if __name__ == '__main__' and '--particiones' in sys.argv:
    tabla_particiones(sys.argv[1])
