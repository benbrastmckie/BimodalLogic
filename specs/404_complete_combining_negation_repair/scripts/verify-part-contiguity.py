#!/usr/bin/env python3
"""verify-part-contiguity.py - Task 404 Phase 5 Task 1: verify contiguity across
every baier_katoen_2008 part-file boundary (tail of partNN vs. head of partNN+1)
before trusting a cumulative character-offset table built from
"\n".join(md_texts_raw) (the same join literature_combining_detect.py's
scan_directory() already performs for md_concat_raw).

Method: for each adjacent pair (partNN, partNN+1), take the last distinctive
run of >=6 ASCII letters near the tail of partNN's markdown and the first
distinctive run of >=6 ASCII letters near the head of partNN+1's markdown,
then locate BOTH runs inside the ground-truth PDF text (extracted the same
way scan_directory() does: PyMuPDF page.get_text("text"), concatenated across
all pages). If the tail landmark's LAST occurrence in the PDF is immediately
(within a small tolerance) followed by the head landmark's NEAREST occurrence
after it, the boundary is contiguous: no PDF content was duplicated across the
part split, and none was dropped between the two parts. A large positive gap
suggests dropped content; a large negative gap (head landmark found BEFORE the
tail landmark ends) suggests duplication or misordering.

This is a read-only, evidence-gathering check. It does not modify anything.

Usage:
    python3 verify-part-contiguity.py DIRPATH
"""
import glob
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", ".claude", "scripts"))
import fitz  # noqa: E402
from literature_combining_detect import find_md_paths, find_pdf_paths  # noqa: E402

WORD_RE = re.compile(r"[A-Za-z]{6,}")
TAIL_WINDOW = 600   # chars scanned at the tail of partNN
HEAD_WINDOW = 600   # chars scanned at the head of partNN+1
GAP_OK = 400         # chars of tolerance (running headers/page numbers/footnotes)


def last_word(text):
    window = text[-TAIL_WINDOW:]
    candidates = list(WORD_RE.finditer(window))
    if not candidates:
        return None
    m = candidates[-1]
    return m.group(0)


def first_word(text):
    window = text[:HEAD_WINDOW]
    candidates = list(WORD_RE.finditer(window))
    if not candidates:
        return None
    m = candidates[0]
    return m.group(0)


def main():
    dirpath = sys.argv[1]
    dirname = os.path.basename(os.path.normpath(dirpath))
    pdf_paths = find_pdf_paths(dirpath)
    md_paths = find_md_paths(dirpath)
    if len(pdf_paths) != 1:
        print(f"ERROR: expected exactly 1 PDF, found {len(pdf_paths)}", file=sys.stderr)
        sys.exit(1)

    doc = fitz.open(pdf_paths[0])
    pdf_text = "".join(page.get_text("text") for page in doc)
    print(f"[verify-part-contiguity] {dirname}: {len(md_paths)} md parts, "
          f"pdf_text len={len(pdf_text)}")

    md_texts = []
    for p in md_paths:
        with open(p, "r", encoding="utf-8", errors="replace") as f:
            md_texts.append((os.path.basename(p), f.read()))

    results = []
    for i in range(len(md_texts) - 1):
        name_a, text_a = md_texts[i]
        name_b, text_b = md_texts[i + 1]
        wl = last_word(text_a)
        wf = first_word(text_b)
        if wl is None or wf is None:
            results.append((name_a, name_b, None, None, None,
                             "SKIP: no >=6-letter word found near boundary"))
            continue

        # Last occurrence of wl in the PDF, first occurrence of wf strictly
        # after it whose gap is smallest (closest pairing).
        tail_positions = [m.end() for m in re.finditer(re.escape(wl), pdf_text)]
        head_positions = [m.start() for m in re.finditer(re.escape(wf), pdf_text)]
        if not tail_positions or not head_positions:
            results.append((name_a, name_b, wl, wf, None,
                             "SKIP: landmark word not found verbatim in PDF text "
                             "(likely a ligature/hyphenation artifact)"))
            continue

        best_gap = None
        for tp in tail_positions:
            candidates_after = [hp for hp in head_positions if hp >= tp]
            if not candidates_after:
                continue
            hp = min(candidates_after)
            gap = hp - tp
            if best_gap is None or abs(gap) < abs(best_gap):
                best_gap = gap

        if best_gap is None:
            # every head occurrence is before every tail occurrence in the PDF
            results.append((name_a, name_b, wl, wf, None,
                             "FLAG: head landmark never found after tail landmark in PDF"))
            continue

        verdict = "OK" if 0 <= best_gap <= GAP_OK else (
            "FLAG: large gap (possible dropped content)" if best_gap > GAP_OK else
            "FLAG: negative gap (possible duplication/misorder)"
        )
        results.append((name_a, name_b, wl, wf, best_gap, verdict))

    print()
    print(f"{'boundary':45s} {'tail_word':>15s} {'head_word':>15s} {'gap':>8s}  verdict")
    n_ok = 0
    n_flag = 0
    n_skip = 0
    for name_a, name_b, wl, wf, gap, verdict in results:
        gap_s = "" if gap is None else str(gap)
        print(f"{name_a + '/' + name_b:45s} {str(wl):>15s} {str(wf):>15s} {gap_s:>8s}  {verdict}")
        if verdict == "OK":
            n_ok += 1
        elif verdict.startswith("SKIP"):
            n_skip += 1
        else:
            n_flag += 1
    print()
    print(f"[verify-part-contiguity] {dirname}: {n_ok} OK, {n_flag} FLAGGED, {n_skip} SKIPPED "
          f"out of {len(results)} boundaries")


if __name__ == "__main__":
    main()
