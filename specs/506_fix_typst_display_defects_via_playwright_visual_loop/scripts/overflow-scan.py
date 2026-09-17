#!/usr/bin/env python3
"""Task-scoped overflow scanner for task 506 (typst display defect fixes).

Scans a compiled PDF for text spans and vector drawings that exceed the
declared text block, using PyMuPDF. The text block is derived from the
documents' shared page geometry: A4 (595.276 x 841.890 pt) with
`margin: 1.75in` (126.0pt), giving:

    x in [126.0, 469.3]
    y in [126.0, 715.9]

Usage:
    python3 overflow-scan.py FILE.pdf [--threshold PT] [--all]

--threshold PT   Significance threshold in points (default: 8.0, matching the
                 research report's threshold for "above-threshold" findings).
--all            Also print the "noise band" (findings between 0pt and the
                 threshold) for manual review, not just above-threshold ones.

Output: one line per finding:
    page=<1-indexed> kind=<text|drawing> side=<left|right|top|bottom> \
        overflow=<pt> bbox=(x0,y0,x1,y1) text=<snippet>
"""
import sys
import argparse

try:
    import fitz  # PyMuPDF
except ImportError:
    print("ERROR: PyMuPDF (fitz) is not importable. pip install pymupdf", file=sys.stderr)
    sys.exit(2)

# Shared text-block bounds for both documents (A4, margin: 1.75in).
TEXT_X0 = 126.0
TEXT_X1 = 469.3
TEXT_Y0 = 126.0
TEXT_Y1 = 715.9

DEFAULT_THRESHOLD = 8.0

# Both documents use `#set page(numbering: "1", number-align: center, margin: 1.75in)`.
# Typst places the auto-numbering page number in the bottom margin band by design (that is
# what "margin" is for) -- it is expected to sit outside the declared text block on every
# single page and is not a layout defect. Filter it out by its signature: a purely numeric
# span whose bottom edge overflows by approximately the fixed footer offset. Confirmed via
# baseline scan: every page in both documents produces exactly this false positive
# (bbox y0=~752.3, y1=~763.3, overflow=47.4pt, text=page-number digits only).
FOOTER_OVERFLOW_PT = 47.4
FOOTER_TOLERANCE_PT = 2.0


def overflow_amounts(bbox):
    """Return dict of side -> overflow amount (positive = overflow) for a bbox."""
    x0, y0, x1, y1 = bbox
    return {
        "left": TEXT_X0 - x0,
        "right": x1 - TEXT_X1,
        "top": TEXT_Y0 - y0,
        "bottom": y1 - TEXT_Y1,
    }


def max_overflow(bbox):
    amounts = overflow_amounts(bbox)
    side, amt = max(amounts.items(), key=lambda kv: kv[1])
    return side, amt


def scan(pdf_path, threshold, show_all):
    doc = fitz.open(pdf_path)
    findings = []
    for pno in range(len(doc)):
        page = doc[pno]
        page_h = page.rect.height
        page_w = page.rect.width
        # Text spans
        d = page.get_text("dict")
        for block in d.get("blocks", []):
            if block.get("type") != 0:
                continue
            for line in block.get("lines", []):
                for span in line.get("spans", []):
                    bbox = span["bbox"]
                    text = span.get("text", "").strip()
                    side, amt = max_overflow(bbox)
                    if side == "bottom" and text.isdigit() and \
                            abs(amt - FOOTER_OVERFLOW_PT) <= FOOTER_TOLERANCE_PT:
                        continue  # auto-numbering page-number footer; expected, not a defect
                    if amt > 0:
                        findings.append({
                            "page": pno + 1,
                            "kind": "text",
                            "side": side,
                            "overflow": amt,
                            "bbox": bbox,
                            "text": span.get("text", "").strip()[:60],
                        })
        # Vector drawings (tables, rules, boxes)
        for draw in page.get_drawings():
            bbox = draw.get("rect")
            if bbox is None:
                continue
            bbox = (bbox.x0, bbox.y0, bbox.x1, bbox.y1)
            # Skip degenerate/whole-page background rects (common false positive:
            # a full-page fill or border drawn intentionally at the page edge).
            if bbox[0] <= 1 and bbox[1] <= 1 and bbox[2] >= page_w - 1 and bbox[3] >= page_h - 1:
                continue
            side, amt = max_overflow(bbox)
            if amt > 0:
                findings.append({
                    "page": pno + 1,
                    "kind": "drawing",
                    "side": side,
                    "overflow": amt,
                    "bbox": bbox,
                    "text": "",
                })
    doc.close()

    above = [f for f in findings if f["overflow"] > threshold]
    noise = [f for f in findings if f["overflow"] <= threshold]

    above.sort(key=lambda f: (f["page"], -f["overflow"]))
    noise.sort(key=lambda f: (f["page"], -f["overflow"]))

    print(f"=== {pdf_path}: {len(above)} above-threshold ({threshold}pt), "
          f"{len(noise)} below-threshold findings ===")
    for f in above:
        bbox_s = ",".join(f"{v:.1f}" for v in f["bbox"])
        print(f"page={f['page']} kind={f['kind']} side={f['side']} "
              f"overflow={f['overflow']:.1f}pt bbox=({bbox_s}) text={f['text']!r}")

    if show_all and noise:
        print(f"--- noise band (<= {threshold}pt), {len(noise)} findings ---")
        for f in noise:
            bbox_s = ",".join(f"{v:.1f}" for v in f["bbox"])
            print(f"page={f['page']} kind={f['kind']} side={f['side']} "
                  f"overflow={f['overflow']:.1f}pt bbox=({bbox_s}) text={f['text']!r}")

    return len(above)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("pdf", help="Path to compiled PDF")
    ap.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD,
                     help=f"Significance threshold in points (default: {DEFAULT_THRESHOLD})")
    ap.add_argument("--all", action="store_true", dest="show_all",
                     help="Also print below-threshold noise-band findings")
    args = ap.parse_args()

    n_above = scan(args.pdf, args.threshold, args.show_all)
    sys.exit(0 if n_above == 0 else 1)


if __name__ == "__main__":
    main()
