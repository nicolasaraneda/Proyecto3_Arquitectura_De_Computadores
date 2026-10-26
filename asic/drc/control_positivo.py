#!/usr/bin/env python3
"""Control positivo del DRC de KLayout (asic/drc/control_positivo.sh).

Dos modos:

  klayout -b -r asic/drc/control_positivo.py -rd modo=insertar -rd entrada=<gds> -rd salida=<gds>
      Copia el GDS y agrega en Metal1 (capa 34/0), en una zona vacía del die,
      dos violaciones conocidas del deck asic/drc/gf180mcu.drc:
        M1.1   un rectángulo de 0,20 µm de ancho (mínimo 0,23 µm);
        M1.2a  dos rectángulos separados 0,15 µm (mínimo 0,23 µm).
      Corre con el Python de KLayout dentro de la imagen de Docker de LibreLane.
      Imprime las coordenadas (en µm) de la zona y de cada rectángulo.

  python3 asic/drc/control_positivo.py verificar <drc.lyrdb> <control_positivo.md> <gds>
      Lee la base de marcadores que dejó el deck sobre la copia y comprueba
      que las reglas marcadas son exactamente M1.1 y M1.2a y que cada marcador
      está dentro de la figura que lo provoca. Escribe el informe en Markdown.
      Código de salida 0 solo si el control pasa.

Las figuras se definen una sola vez (FIGURAS) para que los dos modos usen las
mismas coordenadas; la zona se elige entre las esquinas del die, la primera
cuya caja (con 2 µm de margen) no tenga ninguna forma en ninguna capa salvo la
del contorno del die (0/0).
"""
import re
import sys

LADO = 4.0      # lado de la zona, µm
MARGEN = 2.0    # margen vacío alrededor de la zona, µm
CAPA_M1 = (34, 0)
CAPAS_IGNORADAS = {(0, 0)}   # contorno del die (prBoundary)

# Figuras relativas a la esquina inferior izquierda de la zona: (regla, nombre, x0, y0, x1, y1).
# Todas las coordenadas son múltiplos de 0,005 µm (grilla del deck) y cada
# rectángulo tiene área 0,4 µm² o más (regla M1.3, mínimo 0,1444 µm²).
FIGURAS = [
    ("M1.1", "rectangulo angosto (ancho 0,20 um)", 1.000, 0.500, 1.200, 2.500),
    ("M1.2a", "rectangulo A (ancho 0,50 um)", 2.500, 0.500, 3.000, 2.500),
    ("M1.2a", "rectangulo B, a 0,15 um de A", 3.150, 0.500, 3.650, 2.500),
]
# Dónde debe caer el marcador de cada regla, relativo a la zona.
ESPERADO = {
    "M1.1": ("dentro del rectangulo angosto", 1.000, 0.500, 1.200, 2.500),
    "M1.2a": ("en el hueco entre A y B", 3.000, 0.500, 3.150, 2.500),
}
TOL = 0.01  # µm


def _param(nombre, defecto=None):
    v = globals().get(nombre)
    if v is not None:
        return v
    args = sys.argv[1:]
    for i, a in enumerate(args):
        if a == "--" + nombre and i + 1 < len(args):
            return args[i + 1]
    return defecto


def elegir_zona(ly, top):
    import pya
    dbu = ly.dbu
    die = top.dbbox()
    d = MARGEN + 0.5
    candidatos = [
        ("suroeste", die.left + d, die.bottom + d),
        ("sureste", die.right - d - LADO, die.bottom + d),
        ("noroeste", die.left + d, die.top - d - LADO),
        ("noreste", die.right - d - LADO, die.top - d - LADO),
    ]
    for nombre, x0, y0 in candidatos:
        zona = pya.DBox(x0, y0, x0 + LADO, y0 + LADO)
        caja = zona.enlarged(MARGEN, MARGEN)
        ib = pya.Box(int(round(caja.left / dbu)), int(round(caja.bottom / dbu)),
                     int(round(caja.right / dbu)), int(round(caja.top / dbu)))
        ocupadas = []
        for li in ly.layer_indexes():
            info = ly.get_info(li)
            if (info.layer, info.datatype) in CAPAS_IGNORADAS:
                continue
            if not pya.Region(top.begin_shapes_rec_touching(li, ib)).is_empty():
                ocupadas.append(f"{info.layer}/{info.datatype}")
        if not ocupadas:
            return nombre, zona, caja
        print(f"esquina {nombre}: caja {caja} ocupada en capas {ocupadas}")
    raise SystemExit("no hay una esquina vacía del die para el control positivo")


def insertar(entrada, salida):
    import pya
    ly = pya.Layout()
    ly.read(entrada)
    top = ly.top_cell()
    nombre, zona, caja = elegir_zona(ly, top)
    print(f"die {top.dbbox()} um; zona vacia elegida: esquina {nombre}, {zona} (comprobada con margen: {caja})")
    m1 = ly.layer(*CAPA_M1)
    for regla, desc, x0, y0, x1, y1 in FIGURAS:
        r = pya.DBox(zona.left + x0, zona.bottom + y0, zona.left + x1, zona.bottom + y1)
        top.shapes(m1).insert(pya.DPolygon(r))
        print(f"{regla} {desc}: metal1 {r}")
    ly.write(salida)
    print(f"escrito {salida}")
    with open(salida + ".zona.txt", "w") as f:
        f.write(f"{nombre} {zona.left:.3f} {zona.bottom:.3f} {zona.right:.3f} {zona.top:.3f}\n")


def leer_lyrdb(path):
    import xml.etree.ElementTree as ET
    raiz = ET.parse(path).getroot()
    desc = {}
    for cat in raiz.iter("category"):
        n = cat.findtext("name")
        if n is not None:
            desc[n.strip("'")] = (cat.findtext("description") or "").strip()
    items = []
    for it in raiz.iter("item"):
        c = (it.findtext("category") or "").strip("'")
        v = it.find("values/value")
        texto = (v.text or "").strip() if v is not None else ""
        nums = [(float(x), float(y)) for x, y in re.findall(r"(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)", texto)]
        bbox = None
        if nums:
            bbox = (min(p[0] for p in nums), min(p[1] for p in nums), max(p[0] for p in nums), max(p[1] for p in nums))
        items.append((c, texto, bbox))
    return desc, items


def verificar(lyrdb, md, gds):
    nombre, x0, y0, x1, y1 = open(gds + ".zona.txt").read().split()
    zx, zy = float(x0), float(y0)
    desc, items = leer_lyrdb(lyrdb)
    L = ["# Control positivo del DRC de KLayout", "",
         f"Deck `asic/drc/gf180mcu.drc` sobre `{gds}`: el GDS de la corrida final con dos "
         "violaciones conocidas de Metal1 agregadas por `asic/drc/control_positivo.sh` "
         f"en una zona vacía del die (esquina {nombre}, de ({zx:.3f}, {zy:.3f}) a ({float(x1):.3f}, {float(y1):.3f}) µm, "
         f"sin ninguna forma en {MARGEN:.0f} µm a la redonda). El GDS modificado no se versiona (está en `build/`).", "",
         "## Figuras agregadas (Metal1, capa 34/0, coordenadas en µm)", "",
         "| regla que debe marcar | figura | x0 | y0 | x1 | y1 |", "|---|---|---|---|---|---|"]
    for regla, d, fx0, fy0, fx1, fy1 in FIGURAS:
        L.append(f"| {regla} | {d} | {zx + fx0:.3f} | {zy + fy0:.3f} | {zx + fx1:.3f} | {zy + fy1:.3f} |")
    L += ["", "## Marcadores que dejó el deck", "",
          f"{len(items)} marcadores en {len(set(c for c, _, _ in items))} reglas (de {len(desc)} reglas evaluadas; el GDS original tiene 0 marcadores).", "",
          "| regla | descripción del deck | marcador (coordenadas en µm) | dónde debía caer | cae ahí |", "|---|---|---|---|---|"]
    ok = True
    vistas = set()
    for c, texto, bbox in items:
        vistas.add(c)
        esp = ESPERADO.get(c)
        if esp is None or bbox is None:
            cae = "NO (regla no esperada)"
            ok = False
        else:
            e = (zx + esp[1] - TOL, zy + esp[2] - TOL, zx + esp[3] + TOL, zy + esp[4] + TOL)
            dentro = bbox[0] >= e[0] and bbox[1] >= e[1] and bbox[2] <= e[2] and bbox[3] <= e[3]
            cae = "sí" if dentro else "NO"
            ok = ok and dentro
        donde = f"{esp[0]}, ({zx + esp[1]:.3f}, {zy + esp[2]:.3f}) a ({zx + esp[3]:.3f}, {zy + esp[4]:.3f})" if esp else ""
        L.append(f"| {c} | {desc.get(c, '')} | {texto} | {donde} | {cae} |")
    faltan = set(ESPERADO) - vistas
    if faltan:
        ok = False
        L += ["", f"Reglas esperadas sin marcador: {', '.join(sorted(faltan))}."]
    L += ["", "## Resultado", "",
          f"Reglas marcadas: {', '.join(sorted(vistas)) or 'ninguna'}; esperadas: {', '.join(sorted(ESPERADO))}. "
          f"Marcadores dentro de su figura: {'todos' if ok and not faltan else 'NO'}.", "",
          f"**{'PASA' if ok else 'FALLA'}**: el deck {'detecta' if ok else 'no detecta'} las dos violaciones y no marca nada más."]
    texto = "\n".join(L) + "\n"
    print(texto)
    open(md, "w", encoding="utf-8").write(texto)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "verificar":
        verificar(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        modo = _param("modo")
        if modo != "insertar":
            raise SystemExit(__doc__)
        insertar(_param("entrada"), _param("salida"))
