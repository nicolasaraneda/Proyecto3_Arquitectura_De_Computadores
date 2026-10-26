#!/usr/bin/env python3
"""Figuras anotadas del layout de una corrida de LibreLane, con KLayout en modo batch.

Corre dentro de la imagen de Docker de LibreLane (tiene klayout 0.30.7 y su
módulo de Python), desde la raíz del repositorio:

    docker run --rm -v $HOME:$HOME -w $(pwd) \\
        -e PDK_ROOT=$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee \\
        ghcr.io/librelane/librelane:3.0.16 \\
        klayout -b -r asic/layout/anotar.py -rd run=asic/rom/runs/final [-rd out=...] \\
            [-rd corner=max_ss_125C_4v50] [-rd figuras=bloques,ruta,slew] [-rd net=net3342 -rd nombre=antena_antes]

(o `make layout RUN=asic/rom/runs/final`, que arma ese comando). Toma el DEF
final de la corrida con los LEF del PDK, y escribe en <out> (por defecto
asic/<config>/resultados/<tag>/layout/):

  bloques.png       celdas en gris tenue; el register file (u_soc.u_core.u_rf),
                    la ALU (u_soc.u_core.u_id.u_alu) y el contador de ciclos
                    (u_soc.u_periph.u_cycles) en colores con su rectángulo
                    envolvente, leyenda con área y porcentaje de cada bloque,
                    barra de escala y los terminales con su nombre.
  bloques.lyrdb     la misma información como base de marcadores de KLayout,
                    para repetir las marcas en la interfaz (docs/layout.md).
  ruta_critica.png  celdas de la ruta crítica de setup de la esquina `corner`
                    (primera ruta de <run>/*-openroad-stapostpnr/<corner>/max.rpt),
                    numeradas en orden y unidas con flechas, coloreadas por
                    módulo según el nombre jerárquico de su net de salida.
  ruta_critica.txt  la lista de celdas de la ruta con su módulo.
  slew.png          pines con violación de max slew en la esquina `corner`
                    (checks.rpt) como mapa de calor por severidad.
  <nombre>.png y <nombre>_zoom.png   con -rd net=<nombre de net>: la ruta
                    completa de ese net resaltada sobre el layout, y un
                    acercamiento (para la violación de antena de la estrategia 2).

Las coordenadas son las del DEF (micrómetros); los nombres de instancia los
conserva el lector de LEF/DEF de KLayout como propiedad de cada instancia. Los
textos de las figuras se dibujan como polígonos con la fuente de KLayout
(TextGenerator), que solo tiene mayúsculas sin acentos.
"""

import os
import re
import sys

import pya

# ---------------------------------------------------------------------------
# Parámetros: -rd nombre=valor (klayout -b) o --nombre valor (python3).
# ---------------------------------------------------------------------------
def _param(nombre, defecto=None):
    v = globals().get(nombre)
    if v is not None:
        return v
    args = sys.argv[1:]
    for i, a in enumerate(args):
        if a == "--" + nombre and i + 1 < len(args):
            return args[i + 1]
    return defecto

RUN = _param("run")
if not RUN:
    print("falta -rd run=asic/<config>/runs/<tag>")
    sys.exit(1)
RUN = RUN.rstrip("/")
TAG = os.path.basename(RUN)
CFG_DIR = os.path.dirname(os.path.dirname(RUN))
OUT = _param("out", os.path.join(CFG_DIR, "resultados", TAG, "layout"))
CORNER = _param("corner", "max_ss_125C_4v50")
FIGURAS = _param("figuras", "bloques,ruta,slew").split(",")
NET = _param("net")
NOMBRE_NET = _param("nombre", "net")
PDK_ROOT = os.environ.get("PDK_ROOT", os.path.expanduser("~/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee"))
PDK = os.environ.get("PDK", "gf180mcuD")
SCL = "gf180mcu_fd_sc_mcu7t5v0"
ANCHO_PX = int(_param("ancho", "2400"))

os.makedirs(OUT, exist_ok=True)

BLOQUES = [
    # (clave, prefijo de instancia, etiqueta, color)
    ("rf", "u_soc.u_core.u_rf/", "register file (u_soc.u_core.u_rf)", 0x1f77b4),
    ("alu", "u_soc.u_core.u_id.u_alu/", "ALU (u_soc.u_core.u_id.u_alu)", 0xd62728),
    ("cycles", "u_soc.u_periph.u_cycles/", "contador de ciclos (u_soc.u_periph.u_cycles)", 0x2ca02c),
]
GRIS_CELDA = 0xc8c8c8
GRIS_FILL = 0xeeeeee
GRIS_TEXTO = 0x303030

# ---------------------------------------------------------------------------
# Carga del DEF con los LEF del PDK.
# ---------------------------------------------------------------------------
def cargar_def(run):
    base = os.path.join(PDK_ROOT, PDK)
    lyt = os.path.join(base, "libs.tech/klayout/tech/gf180mcu.lyt")
    lym = os.path.join(base, "libs.tech/klayout/tech/gf180mcu.map")
    tlef = os.path.join(base, f"libs.ref/{SCL}/techlef/{SCL}__nom.tlef")
    lef = os.path.join(base, f"libs.ref/{SCL}/lef/{SCL}.lef")
    deff = os.path.join(run, "final", "def", next(f for f in os.listdir(os.path.join(run, "final", "def")) if f.endswith(".def")))
    tech = pya.Technology()
    tech.load(lyt)
    lo = tech.load_layout_options
    cfg = lo.lefdef_config
    cfg.map_file = lym
    cfg.macro_resolution_mode = 1
    cfg.read_lef_with_def = False
    cfg.lef_files = [tlef, lef]
    # unidades del DEF
    with open(deff) as f:
        for linea in f:
            m = re.match(r"\s*UNITS DISTANCE MICRONS (\d+)", linea)
            if m:
                cfg.dbu = 1.0 / int(m.group(1))
                break
    layout = pya.Layout()
    layout.read(deff, lo)
    return layout, deff


def leer_def_texto(deff):
    """DIEAREA y pines (nombre, capa, rectángulo en µm) del DEF."""
    texto = open(deff).read()
    m = re.search(r"DIEAREA \( (-?\d+) (-?\d+) \) \( (-?\d+) (-?\d+) \)", texto)
    u = int(re.search(r"UNITS DISTANCE MICRONS (\d+)", texto).group(1))
    die = pya.DBox(int(m.group(1)) / u, int(m.group(2)) / u, int(m.group(3)) / u, int(m.group(4)) / u)
    pines = []
    bloque = re.search(r"\nPINS \d+ ;\n(.*?)\nEND PINS", texto, re.S)
    if bloque:
        for pin in re.split(r"\n\s*- ", bloque.group(1))[1:]:
            nombre = pin.split()[0]
            if "+ USE POWER" in pin or "+ USE GROUND" in pin:
                continue
            capa = re.search(r"LAYER (\S+) \( (-?\d+) (-?\d+) \) \( (-?\d+) (-?\d+) \)", pin)
            pos = re.search(r"PLACED \( (-?\d+) (-?\d+) \) (\S+)", pin)
            if capa and pos:
                x, y = int(pos.group(1)) / u, int(pos.group(2)) / u
                r = pya.DBox(int(capa.group(2)) / u, int(capa.group(3)) / u, int(capa.group(4)) / u, int(capa.group(5)) / u)
                pines.append((nombre, capa.group(1), r.moved(x, y)))
    return die, pines


def instancias(layout):
    """[(nombre, celda, DBox)] de las instancias con nombre del top."""
    top = layout.top_cell()
    out = []
    for inst in top.each_inst():
        if inst.prop_id == 0:
            continue
        props = layout.properties(inst.prop_id)
        nombre = None
        for k, v in props:
            if str(k) == "1" or k == 1:
                nombre = v
        if nombre is None:
            continue
        out.append((nombre, inst.cell.name, inst.dbbox()))
    return out


def es_fill(celda):
    return any(s in celda for s in ("__fill", "__filltie", "__endcap", "__fillcap"))


# ---------------------------------------------------------------------------
# Lienzo: un layout nuevo con capas de dibujo, y un LayoutView para la imagen.
# ---------------------------------------------------------------------------
class Lienzo:
    def __init__(self, dbu):
        self.layout = pya.Layout()
        self.layout.dbu = dbu
        self.top = self.layout.create_cell("figura")
        self.capas = []  # (índice, color, orden)
        self.tg = pya.TextGenerator.default_generator()

    def capa(self, color):
        idx = self.layout.layer(len(self.capas) + 1, 0)
        self.capas.append((idx, color))
        return idx

    def caja(self, capa, dbox):
        self.top.shapes(capa).insert(pya.DBox(dbox))

    def anillo(self, capa, dbox, grosor):
        ext = pya.Region(pya.DBox(dbox).enlarged(grosor, grosor).to_itype(self.layout.dbu))
        inte = pya.Region(pya.DBox(dbox).to_itype(self.layout.dbu))
        self.top.shapes(capa).insert(ext - inte)

    def texto(self, capa, s, x, y, alto):
        """Texto con esquina inferior izquierda en (x, y), alto en µm."""
        reg = self.tg.text(s, self.layout.dbu, alto / 0.7)
        reg.move(int(x / self.layout.dbu), int(y / self.layout.dbu))
        self.top.shapes(capa).insert(reg)
        return reg.bbox().to_dtype(self.layout.dbu)

    def ancho_texto(self, s, alto):
        return self.tg.text(s, self.layout.dbu, alto / 0.7).bbox().to_dtype(self.layout.dbu).width()

    def linea(self, capa, p1, p2, ancho):
        self.top.shapes(capa).insert(pya.DPath([pya.DPoint(*p1), pya.DPoint(*p2)], ancho))

    def flecha(self, capa, p1, p2, ancho):
        import math
        x1, y1 = p1
        x2, y2 = p2
        L = math.hypot(x2 - x1, y2 - y1)
        if L < 1e-6:
            return
        ux, uy = (x2 - x1) / L, (y2 - y1) / L
        cab = max(4 * ancho, 3.0)
        bx, by = x2 - ux * cab, y2 - uy * cab
        self.linea(capa, p1, (bx, by), ancho)
        px, py = -uy, ux
        tri = pya.DPolygon([pya.DPoint(x2, y2), pya.DPoint(bx + px * cab * 0.5, by + py * cab * 0.5),
                            pya.DPoint(bx - px * cab * 0.5, by - py * cab * 0.5)])
        self.top.shapes(capa).insert(tri)

    def guardar(self, path, caja, ancho_px):
        lv = pya.LayoutView()
        lv.set_config("background-color", "#ffffff")
        lv.set_config("grid-visible", "false")
        lv.set_config("text-visible", "false")
        lv.show_layout(self.layout, False)
        lv.clear_layers()
        for idx, color in self.capas:
            lp = pya.LayerPropertiesNode()
            info = self.layout.get_info(idx)
            lp.source = f"{info.layer}/{info.datatype}@1"
            lp.fill_color = color
            lp.frame_color = color
            lp.dither_pattern = 0
            lp.width = 1
            lp.transparent = False
            lv.insert_layer(lv.end_layers(), lp)
        lv.max_hier()
        alto_px = int(ancho_px * caja.height() / caja.width())
        lv.zoom_box(caja)
        lv.save_image_with_options(path, ancho_px, alto_px, 0, 1, 0, caja, False)
        print(f"escrito {path} ({ancho_px}x{alto_px})")


def color_mas_claro(color, factor):
    r, g, b = (color >> 16) & 255, (color >> 8) & 255, color & 255
    r = int(r + (255 - r) * factor)
    g = int(g + (255 - g) * factor)
    b = int(b + (255 - b) * factor)
    return (r << 16) | (g << 8) | b


def paleta_calor(n):
    """n colores de amarillo a rojo oscuro."""
    out = []
    for i in range(n):
        t = i / max(n - 1, 1)
        r = 255 - int(80 * t)
        g = int(230 * (1 - t))
        b = 0
        out.append((r << 16) | (g << 8) | b)
    return out


# ---------------------------------------------------------------------------
# Figuras
# ---------------------------------------------------------------------------
def base_con_celdas(lz, insts, die, gris=True):
    c_fill = lz.capa(GRIS_FILL)
    c_cel = lz.capa(GRIS_CELDA)
    for nombre, celda, box in insts:
        lz.caja(c_fill if es_fill(celda) else c_cel, box)
    c_die = lz.capa(GRIS_TEXTO)
    lz.anillo(c_die, die, 1.0)
    return c_cel


def dibujar_pines(lz, pines, die, capa_texto, alto=8.0):
    c_pin = lz.capa(0x000000)
    for nombre, capa, r in pines:
        lz.caja(c_pin, r.enlarged(1.5, 1.5))
        cx, cy = r.center().x, r.center().y
        w = lz.ancho_texto(nombre, alto)
        if abs(cx - die.left) < 2:        # oeste: texto afuera a la izquierda
            lz.texto(capa_texto, nombre, die.left - w - 4, cy - alto / 2, alto)
        elif abs(cx - die.right) < 2:     # este
            lz.texto(capa_texto, nombre, die.right + 4, cy - alto / 2, alto)
        elif abs(cy - die.top) < 2:       # norte
            lz.texto(capa_texto, nombre, cx - w / 2, die.top + 4, alto)
        else:                             # sur
            lz.texto(capa_texto, nombre, cx - w / 2, die.bottom - alto - 4, alto)


def barra_escala(lz, capa, die, x0, y, largo=100.0, alto_texto=9.0):
    lz.caja(capa, pya.DBox(x0, y, x0 + largo, y + 3))
    lz.caja(capa, pya.DBox(x0, y - 3, x0 + 1.5, y + 6))
    lz.caja(capa, pya.DBox(x0 + largo - 1.5, y - 3, x0 + largo, y + 6))
    lz.texto(capa, f"{largo:.0f} um", x0 + largo / 2 - lz.ancho_texto(f"{largo:.0f} um", alto_texto) / 2, y + 8, alto_texto)


def figura_bloques(layout, deff):
    die, pines = leer_def_texto(deff)
    insts = instancias(layout)
    lz = Lienzo(layout.dbu)
    base_con_celdas(lz, insts, die)
    c_txt = lz.capa(GRIS_TEXTO)
    area_total = sum(b.area() for n, c, b in insts if not es_fill(c))
    rdb = pya.ReportDatabase("bloques del Pochoco SoC")
    rdb.description = f"Register file, ALU y contador de ciclos de {RUN} (asic/layout/anotar.py)"
    rdb_cell = rdb.create_cell(layout.top_cell().name)
    resumen = []
    for clave, prefijo, etiqueta, color in BLOQUES:
        c_b = lz.capa(color)
        c_env = lz.capa(color_mas_claro(color, 0.0))
        cat = rdb.create_category(clave)
        cat.description = etiqueta
        env = None
        area = 0.0
        n = 0
        for nombre, celda, box in insts:
            if nombre.startswith(prefijo):
                lz.caja(c_b, box)
                area += box.area()
                n += 1
                env = box if env is None else env + box
                it = rdb.create_item(rdb_cell.rdb_id(), cat.rdb_id())
                it.add_value(box)
        if env is not None:
            lz.anillo(c_env, env.enlarged(1.0, 1.0), 1.2)
            cat_env = rdb.create_category(clave + "_envolvente")
            cat_env.description = "rectángulo envolvente de " + etiqueta
            it = rdb.create_item(rdb_cell.rdb_id(), cat_env.rdb_id())
            it.add_value(env)
        resumen.append((etiqueta, n, area, 100 * area / area_total if area_total else 0, color, env))
    # leyenda a la derecha del die
    alto = 9.0
    x_leg = die.right + 60
    y = die.top - 20
    lz.texto(c_txt, f"{TAG}: bloques del layout", x_leg, y, alto + 2)
    y -= 2.2 * alto
    for etiqueta, n, area, pct, color, env in resumen:
        c_l = lz.capa(color)
        lz.caja(c_l, pya.DBox(x_leg, y, x_leg + 14, y + alto))
        lz.texto(c_txt, etiqueta, x_leg + 20, y, alto)
        y -= 1.5 * alto
        lz.texto(c_txt, f"{n} celdas, {area:,.0f} um2, {pct:.1f} % de las celdas".replace(",", "."), x_leg + 20, y, alto * 0.9)
        y -= 2.0 * alto
    c_g = lz.capa(GRIS_CELDA)
    lz.caja(c_g, pya.DBox(x_leg, y, x_leg + 14, y + alto))
    lz.texto(c_txt, f"otras celdas estandar (resto del diseno, aplanado)", x_leg + 20, y, alto)
    y -= 1.5 * alto
    lz.texto(c_txt, f"area de celdas estandar: {area_total:,.0f} um2; die {die.width():.1f} x {die.height():.1f} um = {die.area() / 1e6:.4f} mm2".replace(",", "."), x_leg + 20, y, alto * 0.9)
    y -= 2.0 * alto
    lz.texto(c_txt, "terminales (negro) con su nombre; sin pads de I/O: es un macro", x_leg, y, alto * 0.9)
    y -= 3 * alto
    barra_escala(lz, c_txt, die, x_leg, y)
    dibujar_pines(lz, pines, die, c_txt)
    caja = pya.DBox(die.left - 60, die.bottom - 30, x_leg + 520, die.top + 30)
    lz.guardar(os.path.join(OUT, "bloques.png"), caja, ANCHO_PX)
    rdb.save(os.path.join(OUT, "bloques.lyrdb"))
    with open(os.path.join(OUT, "bloques.txt"), "w") as f:
        f.write(f"corrida {RUN}; die {die.width():.2f} x {die.height():.2f} um ({die.area() / 1e6:.4f} mm2); area de celdas estandar (sin fill) {area_total:.1f} um2\n")
        for etiqueta, n, area, pct, color, env in resumen:
            f.write(f"{etiqueta}: {n} celdas, {area:.1f} um2, {pct:.2f} %, envolvente {env}\n")
        f.write("terminales:\n")
        for nombre, capa, r in pines:
            f.write(f"  {nombre} {capa} centro ({r.center().x:.2f}, {r.center().y:.2f})\n")
    print("\n".join(f"{e}: {n} celdas, {a:.0f} um2, {p:.1f} %" for e, n, a, p, c, env in resumen))


def leer_ruta(run, corner):
    """Celdas de la primera ruta de max.rpt: [(instancia, celda, pin_salida, net)]."""
    sta = sorted(d for d in os.listdir(run) if d.endswith("openroad-stapostpnr"))
    if not sta:
        raise SystemExit("no hay paso openroad-stapostpnr en la corrida")
    path = os.path.join(run, sta[-1], corner, "max.rpt")
    celdas = []
    en_ruta = False
    ultimo = None
    with open(path) as f:
        for linea in f:
            if linea.startswith("Startpoint:"):
                if celdas:
                    break
                en_ruta = True
            if not en_ruta:
                continue
            if "data arrival time" in linea:
                break
            m = re.search(r"[\^v] (\S+)/(\S+) \((\S+)\)", linea)
            if m:
                inst, pin, celda = m.group(1), m.group(2), m.group(3)
                ultimo = (inst, celda, pin)
                if not celdas or celdas[-1][0] != inst:
                    celdas.append([inst, celda, pin, None])
                else:
                    celdas[-1][2] = pin
                continue
            m = re.search(r"^\s+(\S+) \(net\)", linea)
            if m and celdas:
                celdas[-1][3] = m.group(1)
    return celdas, path


def modulo_de(inst, net):
    """Módulo al que pertenece una celda de la ruta, por su nombre o el de su net de salida."""
    cand = inst if "/" in inst else (net or "")
    for clave, prefijo, etiqueta, color in BLOQUES:
        if cand.startswith(prefijo) or (net or "").startswith(prefijo):
            return clave
    s = net or ""
    if s.startswith("u_soc.u_core.u_id."):
        return "id"
    if s.startswith("u_soc.u_core.u_lsu.") or s.startswith("u_soc.u_core.lsu_") or s.startswith("u_soc.u_core.data_") or s.startswith("u_soc.data_") or s.startswith("u_soc.ram_") or s.startswith("u_soc.per_"):
        return "lsu"
    if s.startswith("u_soc.u_core.u_if.") or s.startswith("u_soc.u_core.pc_") or s.startswith("u_soc.instr_") or s.startswith("u_soc.u_core.instr_"):
        return "if"
    if s.startswith("u_soc.u_core.rf_") or s.startswith("u_soc.u_core.u_rf"):
        return "rf"
    if s.startswith("u_soc.u_periph") or s.startswith("u_soc.g_mem_rom"):
        return "soc"
    if s.startswith("clk") or inst.startswith("clkbuf"):
        return "clk"
    return "otro"


MODULOS_RUTA = {
    "rf": ("register file (u_soc.u_core.u_rf)", 0x1f77b4),
    "alu": ("ALU (u_soc.u_core.u_id.u_alu)", 0xd62728),
    "cycles": ("contador de ciclos", 0x2ca02c),
    "id": ("etapa ID aplanada (u_soc.u_core.u_id.*)", 0xff7f0e),
    "lsu": ("LSU / bus de datos (u_soc.u_core.lsu_*, data_*)", 0x9467bd),
    "if": ("etapa IF (u_soc.u_core.u_if.*)", 0x8c564b),
    "soc": ("perifericos y memoria (u_soc.*)", 0x17becf),
    "clk": ("arbol de reloj", 0x7f7f7f),
    "otro": ("logica aplanada sin nombre jerarquico (net _nnnn_)", 0xbcbd22),
}


def figura_ruta(layout, deff):
    die, pines = leer_def_texto(deff)
    insts = instancias(layout)
    pos = {n: b for n, c, b in insts}
    ruta, path = leer_ruta(RUN, CORNER)
    lz = Lienzo(layout.dbu)
    base_con_celdas(lz, insts, die)
    c_txt = lz.capa(GRIS_TEXTO)
    capas_mod = {k: lz.capa(v[1]) for k, v in MODULOS_RUTA.items()}
    c_flecha = lz.capa(0x000000)
    usados = {}
    puntos = []
    lineas_txt = []
    for i, (inst, celda, pin, net) in enumerate(ruta, 1):
        box = pos.get(inst)
        if box is None:
            print(f"aviso: {inst} no está en el DEF")
            continue
        mod = modulo_de(inst, net)
        usados[mod] = usados.get(mod, 0) + 1
        lz.caja(capas_mod[mod], box.enlarged(1.0, 1.0))
        puntos.append((box.center().x, box.center().y))
        lineas_txt.append(f"{i:2d} {inst} ({celda.replace(SCL + '__', '')}) -> {net}  [{MODULOS_RUTA[mod][0]}]")
    for a, b in zip(puntos, puntos[1:]):
        lz.flecha(c_flecha, a, b, 0.8)
    for i, (x, y) in enumerate(puntos, 1):
        lz.texto(c_txt, str(i), x + 3, y + 3, 7.0)
    alto = 9.0
    x_leg = die.right + 60
    y = die.top - 20
    lz.texto(c_txt, f"{TAG}: ruta critica de setup, esquina {CORNER}", x_leg, y, alto + 1)
    y -= 1.6 * alto
    lz.texto(c_txt, f"{ruta[0][0]} ({ruta[0][1].replace(SCL + '__', '')}) -> {ruta[-1][0]} ({ruta[-1][1].replace(SCL + '__', '')}), {len(ruta)} celdas", x_leg, y, alto * 0.85)
    y -= 2.2 * alto
    for k, (etiqueta, color) in MODULOS_RUTA.items():
        if k not in usados:
            continue
        lz.caja(capas_mod[k], pya.DBox(x_leg, y, x_leg + 14, y + alto))
        lz.texto(c_txt, f"{etiqueta}: {usados[k]} celdas", x_leg + 20, y, alto)
        y -= 1.7 * alto
    y -= alto
    lz.texto(c_txt, "las flechas siguen el orden de la ruta; el numero es la posicion de la celda", x_leg, y, alto * 0.85)
    y -= 3 * alto
    barra_escala(lz, c_txt, die, x_leg, y)
    dibujar_pines(lz, pines, die, c_txt)
    caja = pya.DBox(die.left - 60, die.bottom - 30, x_leg + 620, die.top + 30)
    lz.guardar(os.path.join(OUT, "ruta_critica.png"), caja, ANCHO_PX)
    with open(os.path.join(OUT, "ruta_critica.txt"), "w") as f:
        f.write(f"ruta critica de {path}\n")
        f.write("\n".join(lineas_txt) + "\n")
    print("\n".join(lineas_txt))


def leer_slew(run, corner):
    sta = sorted(d for d in os.listdir(run) if d.endswith("openroad-stapostpnr"))
    path = os.path.join(run, sta[-1], corner, "checks.rpt")
    out = []
    en = False
    with open(path) as f:
        for linea in f:
            if linea.startswith("max slew"):
                en = True
                continue
            if en and (linea.startswith("max capacitance") or linea.startswith("max fanout")):
                break
            if en and "(VIOLATED)" in linea:
                p = linea.split()
                out.append((p[0], float(p[1]), float(p[2])))
    return out, path


def figura_slew(layout, deff):
    die, pines = leer_def_texto(deff)
    insts = instancias(layout)
    pos = {n: b for n, c, b in insts}
    viol, path = leer_slew(RUN, CORNER)
    lz = Lienzo(layout.dbu)
    base_con_celdas(lz, insts, die)
    c_txt = lz.capa(GRIS_TEXTO)
    limites = [3.0, 3.5, 4.0, 4.5, 5.0, 99.0]
    colores = paleta_calor(len(limites) - 1)
    capas = [lz.capa(c) for c in colores]
    cuentas = [0] * len(capas)
    peor = {}
    for pin, lim, slew in viol:
        inst = pin.rsplit("/", 1)[0]
        if inst not in pos:
            continue
        peor[inst] = max(peor.get(inst, 0), slew)
    for inst, slew in peor.items():
        k = next(i for i in range(len(limites) - 1) if slew < limites[i + 1])
        cuentas[k] += 1
    # dibujar de menor a mayor severidad para que lo peor quede arriba
    for k in range(len(capas)):
        for inst, slew in peor.items():
            kk = next(i for i in range(len(limites) - 1) if slew < limites[i + 1])
            if kk == k:
                lz.caja(capas[k], pos[inst].enlarged(1.5, 1.5))
    alto = 9.0
    x_leg = die.right + 60
    y = die.top - 20
    lz.texto(c_txt, f"{TAG}: violaciones de max slew, esquina {CORNER}", x_leg, y, alto + 1)
    y -= 1.6 * alto
    lz.texto(c_txt, f"{len(viol)} pines en {len(peor)} celdas; limite {viol[0][1] if viol else 3:.1f} ns (MAX_TRANSITION_CONSTRAINT); peor {max((s for _, _, s in viol), default=0):.2f} ns", x_leg, y, alto * 0.85)
    y -= 2.2 * alto
    for k in range(len(capas)):
        lz.caja(capas[k], pya.DBox(x_leg, y, x_leg + 14, y + alto))
        hi = f"{limites[k + 1]:.1f}" if limites[k + 1] < 99 else "mas"
        lz.texto(c_txt, f"slew de {limites[k]:.1f} a {hi} ns: {cuentas[k]} celdas", x_leg + 20, y, alto)
        y -= 1.7 * alto
    y -= alto
    lz.texto(c_txt, "cada celda toma el color de su peor pin", x_leg, y, alto * 0.85)
    y -= 3 * alto
    barra_escala(lz, c_txt, die, x_leg, y)
    dibujar_pines(lz, pines, die, c_txt)
    caja = pya.DBox(die.left - 60, die.bottom - 30, x_leg + 620, die.top + 30)
    lz.guardar(os.path.join(OUT, "slew.png"), caja, ANCHO_PX)
    with open(os.path.join(OUT, "slew.txt"), "w") as f:
        f.write(f"violaciones de max slew de {path}: {len(viol)} pines en {len(peor)} celdas\n")
        for k in range(len(capas)):
            f.write(f"  {limites[k]:.1f} a {limites[k + 1]:.1f} ns: {cuentas[k]} celdas\n")
        for inst, slew in sorted(peor.items(), key=lambda x: -x[1])[:30]:
            f.write(f"  {inst} {slew:.3f} ns\n")
    print(f"slew: {len(viol)} pines, {len(peor)} celdas, cuentas {cuentas}")


def figura_net(layout, deff, net, nombre):
    """Ruta completa de un net (cables y vías) resaltada, con un acercamiento."""
    die, pines = leer_def_texto(deff)
    insts = instancias(layout)
    top = layout.top_cell()
    lz = Lienzo(layout.dbu)
    base_con_celdas(lz, insts, die)
    c_txt = lz.capa(GRIS_TEXTO)
    c_net = lz.capa(0xd62728)
    c_pin = lz.capa(0x1f77b4)
    env = None
    n_shapes = 0
    for li in layout.layer_indexes():
        info = layout.get_info(li)
        if info.datatype != 0 or info.layer == 0:
            continue
        for sh in top.each_shape(li):
            if sh.prop_id == 0:
                continue
            ok = any((str(k) == "1" or k == 1) and v == net for k, v in layout.properties(sh.prop_id))
            if not ok:
                continue
            b = sh.dbbox()
            lz.caja(c_net, b.enlarged(0.6, 0.6))
            env = b if env is None else env + b
            n_shapes += 1
    # celdas conectadas: las que tocan el net (las que están dentro del envolvente y son del nombre fanout*)
    alto = 9.0
    x_leg = die.right + 60
    y = die.top - 20
    lz.texto(c_txt, f"{TAG}: net {net}", x_leg, y, alto + 2)
    y -= 1.6 * alto
    lz.texto(c_txt, f"{n_shapes} tramos de metal y vias en rojo; envolvente {env.width():.0f} x {env.height():.0f} um" if env else "net no encontrado", x_leg, y, alto * 0.85)
    y -= 3 * alto
    barra_escala(lz, c_txt, die, x_leg, y)
    dibujar_pines(lz, pines, die, c_txt)
    caja = pya.DBox(die.left - 60, die.bottom - 30, x_leg + 520, die.top + 30)
    lz.guardar(os.path.join(OUT, f"{nombre}.png"), caja, ANCHO_PX)
    if env:
        z = env.enlarged(15, 15)
        lz2 = Lienzo(layout.dbu)
        c_f = lz2.capa(GRIS_FILL)
        c_c = lz2.capa(GRIS_CELDA)
        c_t = lz2.capa(GRIS_TEXTO)
        for nm, celda, box in insts:
            if box.touches(z):
                lz2.caja(c_f if es_fill(celda) else c_c, box)
                if not es_fill(celda) and nm.startswith("fanout"):
                    pass
        c_n = lz2.capa(0xd62728)
        for li in layout.layer_indexes():
            info = layout.get_info(li)
            if info.datatype != 0 or info.layer == 0:
                continue
            for sh in top.each_shape(li):
                if sh.prop_id and any((str(k) == "1" or k == 1) and v == net for k, v in layout.properties(sh.prop_id)):
                    lz2.caja(c_n, sh.dbbox().enlarged(0.15, 0.15))
        # nombres de las celdas conectadas al net (según el reporte de antenas, pines fanout*): se marcan las celdas cuyo nombre aparece en antenna.rpt
        celdas_net = set()
        for d in sorted(x for x in os.listdir(RUN) if "checkantennas" in x):
            rp = os.path.join(RUN, d, "reports", "antenna.rpt")
            if os.path.exists(rp):
                en = False
                for linea in open(rp):
                    if linea.startswith("Net:"):
                        en = linea.split()[1] == net
                    elif en and linea.strip().startswith("Pin:"):
                        celdas_net.add(linea.split()[1].rsplit("/", 1)[0])
        c_cel = lz2.capa(0x1f77b4)
        for nm, celda, box in insts:
            if nm in celdas_net:
                lz2.caja(c_cel, box)
                lz2.texto(c_t, nm, box.left, box.top + 0.5, 1.6)
        lz2.texto(c_t, f"{TAG}: acercamiento al net {net} (rojo); celdas conectadas en azul", z.left, z.top + 3, 2.2)
        barra_escala(lz2, c_t, z, z.left, z.bottom - 8, largo=20.0, alto_texto=2.0)
        caja2 = pya.DBox(z.left - 2, z.bottom - 14, z.right + 2, z.top + 8)
        lz2.guardar(os.path.join(OUT, f"{nombre}_zoom.png"), caja2, ANCHO_PX)
    print(f"net {net}: {n_shapes} tramos")


def main():
    layout, deff = cargar_def(RUN)
    print(f"corrida {RUN}: {layout.top_cell().name}, {deff}")
    if NET:
        figura_net(layout, deff, NET, NOMBRE_NET)
        return
    if "bloques" in FIGURAS:
        figura_bloques(layout, deff)
    if "ruta" in FIGURAS:
        figura_ruta(layout, deff)
    if "slew" in FIGURAS:
        figura_slew(layout, deff)


main()
