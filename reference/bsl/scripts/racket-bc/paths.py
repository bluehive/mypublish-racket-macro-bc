"""Shared paths for racket-bc build scripts."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOOK_SLUG = "racket-bc"
BOOK_MD = ROOT / "manuscript/racket-bc/book.md"
OUT_DIR = ROOT / "output/racket-bc"
ASSETS = ROOT / "assets/epub"
COVER = ROOT / "images/cover.jpg"

TITLE = "Racket でつくる bc"
SUBTITLE = "BSL で学ぶ dc 流スタック電卓"
AUTHOR = "bluehive / Grok / Codex"
EPUB_BASENAME = "Racket でつくる bc"

APPENDIX_C_MARKER = "rackunit"

DEFAULT_OUTPUT = {
    "epub-horizontal": OUT_DIR / f"{EPUB_BASENAME}-横書き.epub",
    "epub-vertical": OUT_DIR / f"{EPUB_BASENAME}-縦書き.epub",
    "docx": OUT_DIR / f"{EPUB_BASENAME}.docx",
}
