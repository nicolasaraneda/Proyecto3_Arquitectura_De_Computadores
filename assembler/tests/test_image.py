"""Tests de las salidas Verilog del assembler (Proyecto 3).

--vh escribe la imagen que la estrategia 2 usa como valor de reset de la
memoria en flip-flops, y --rom escribe el módulo pochoco_rom, la ROM
combinacional de la estrategia 1. Las dos tienen que contener exactamente las
mismas palabras que el .hex, en el mismo orden.
"""

import re
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from core import assemble_text, format_hex, format_verilog_image, format_verilog_rom  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
CASE_RE = re.compile(r"^\s*(\d+): game_word = 32'h([0-9a-f]{8});")
ROM_RE = re.compile(r"^\s*\d+'d(\d+)\s*: data_o = 32'h([0-9a-f]{8});")


def image_words(text):
    return {int(m.group(1)): int(m.group(2), 16)
            for m in map(CASE_RE.match, text.splitlines()) if m}


def rom_words(text):
    return {int(m.group(1)): int(m.group(2), 16)
            for m in map(ROM_RE.match, text.splitlines()) if m}


class ImageTests(unittest.TestCase):
    def test_small_program(self):
        words = assemble_text("addi x1, x0, 5\nadd x2, x1, x1\n")
        vh = format_verilog_image(words, "t.s")
        self.assertIn("localparam integer GAME_WORDS = 2;", vh)
        self.assertEqual(image_words(vh), {0: words[0], 1: words[1]})
        self.assertIn("default: game_word = 32'h00000000;", vh)

    def test_comment_is_disassembly(self):
        vh = format_verilog_image(assemble_text("addi x1, x0, 5\n"), "t.s")
        self.assertRegex(vh, r"// 0x0000: addi x1, x0, 5")

    def test_game_image_matches_hex(self):
        text = (ROOT / "sw" / "game.s").read_text(encoding="utf-8")
        words = assemble_text(text)
        vh = format_verilog_image(words, "sw/game.s")
        self.assertIn(f"localparam integer GAME_WORDS = {len(words)};", vh)
        self.assertEqual(image_words(vh), dict(enumerate(words)))
        hex_words = [int(l, 16) for l in format_hex(words).split()]
        self.assertEqual(hex_words, words)

    def test_versioned_image_is_up_to_date(self):
        """rtl/gen/game_image.vh tiene que corresponder al sw/game.s actual."""
        text = (ROOT / "sw" / "game.s").read_text(encoding="utf-8")
        words = assemble_text(text)
        versioned = (ROOT / "rtl" / "gen" / "game_image.vh").read_text(encoding="utf-8")
        self.assertEqual(image_words(versioned), dict(enumerate(words)),
                         "rtl/gen/game_image.vh está desactualizada: correr `make image`")


class RomTests(unittest.TestCase):
    def test_small_program(self):
        words = assemble_text("addi x1, x0, 5\nadd x2, x1, x1\nnop\n")
        rom = format_verilog_rom(words, "t.s")
        self.assertIn("module pochoco_rom (", rom)
        self.assertIn("wire [1:0] word = addr_i[3:2];", rom)  # 3 palabras: 2 bits
        self.assertEqual(rom_words(rom), dict(enumerate(words)))
        self.assertIn("default: data_o = 32'h00000000;", rom)

    def test_game_rom_matches_hex(self):
        text = (ROOT / "sw" / "game.s").read_text(encoding="utf-8")
        words = assemble_text(text)
        rom = format_verilog_rom(words, "sw/game.s")
        self.assertIn("wire [6:0] word = addr_i[8:2];", rom)  # 115 palabras: 7 bits
        self.assertEqual(rom_words(rom), dict(enumerate(words)))

    def test_versioned_rom_is_up_to_date(self):
        """rtl/gen/pochoco_rom.v tiene que corresponder al sw/game.s actual."""
        text = (ROOT / "sw" / "game.s").read_text(encoding="utf-8")
        words = assemble_text(text)
        versioned = (ROOT / "rtl" / "gen" / "pochoco_rom.v").read_text(encoding="utf-8")
        self.assertEqual(rom_words(versioned), dict(enumerate(words)),
                         "rtl/gen/pochoco_rom.v está desactualizada: correr `make image`")


if __name__ == "__main__":
    unittest.main()
