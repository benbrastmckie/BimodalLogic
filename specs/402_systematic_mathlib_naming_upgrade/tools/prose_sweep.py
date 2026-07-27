#!/usr/bin/env python3
"""Phase 7 silent-staleness sweep: rewrite old declaration names where the build cannot see them.

Two territories, selected by `--mode`:

  --mode lean   Inside built Lean sources (`FormalSystem/` excluding `Boneyard/`, and `Tests/`),
                rewrite ONLY the non-code regions -- comments, docstrings, and string literals --
                using `leanmask.code_mask` inverted.  Elaborated code was already rewritten in
                Phase 6 from resolved references; touching it here would be a textual pass over
                the 47.2% prefix-collision hazard.

  --mode docs   Inside `docs/`, `typst/`, `latex/`, `README.md`, rewrite everywhere (there is no
                code to protect).

Both modes are driven from the rename map, never from free-text search (plan, Phase 7.1 task 5).
Ambiguous final components -- one old name mapping to two different targets -- are reported and
skipped, never guessed.
"""
import argparse
import re
import subprocess
from collections import Counter, defaultdict
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from leanmask import code_mask  # noqa: E402

REPO = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                           text=True, check=True).stdout.strip())
IDENT = r"[A-Za-z0-9_'!?]"


def load_map(path):
    m = {}
    for raw in Path(path).read_text(encoding="utf-8").split("\n"):
        if not raw.strip() or raw.startswith("#"):
            continue
        parts = raw.split("\t")
        if len(parts) < 2 or parts[0] in ("old", "old_name", "current"):
            continue
        m[parts[0].strip()] = parts[1].strip()
    return m


def final_map(name_map, keep_ambiguous=False):
    """old final component -> new final component, dropping ambiguous finals."""
    d = defaultdict(set)
    for fqn, new in name_map.items():
        d[fqn.split(".")[-1]].add(new)
    out, ambiguous = {}, {}
    for old, news in d.items():
        if len(news) == 1:
            out[old] = next(iter(news))
        else:
            ambiguous[old] = sorted(news)
    return out, ambiguous


def build_pattern(fm):
    # longest-first so `temp_linearity_past` wins over `temp_linearity`
    alt = "|".join(re.escape(k) for k in sorted(fm, key=len, reverse=True))
    return re.compile(r"(?<!" + IDENT + r")(" + alt + r")(?!" + IDENT + r")")


def targets(mode):
    if mode == "lean":
        for root in ("FormalSystem", "Tests"):
            for p in (REPO / root).rglob("*.lean"):
                if "Boneyard" in p.parts:
                    continue
                yield p
    else:
        for root in ("docs", "typst", "latex"):
            d = REPO / root
            if not d.is_dir():
                continue
            for p in d.rglob("*"):
                if p.is_file() and p.suffix in (".md", ".typ", ".tex", ".txt"):
                    yield p
        rm = REPO / "README.md"
        if rm.exists():
            yield rm


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", required=True)
    ap.add_argument("--mode", choices=["lean", "docs"], required=True)
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--report")
    args = ap.parse_args()

    name_map = load_map(args.map)
    fm, ambiguous = final_map(name_map)
    pat = build_pattern(fm)

    per_file = Counter()
    per_name = Counter()
    total = 0
    for p in sorted(targets(args.mode)):
        text = p.read_text(encoding="utf-8")
        if args.mode == "lean":
            mask = code_mask(text)
            allow = lambda m: not any(mask[k] for k in range(m.start(), m.end()))  # noqa: E731
        else:
            allow = lambda m: True  # noqa: E731
        hits = [m for m in pat.finditer(text) if allow(m)]
        if not hits:
            continue
        for m in hits:
            per_name[m.group(1)] += 1
        per_file[str(p.relative_to(REPO))] = len(hits)
        total += len(hits)
        if args.apply:
            out = text
            for m in reversed(hits):
                out = out[: m.start()] + fm[m.group(1)] + out[m.end():]
            p.write_text(out, encoding="utf-8")

    print(f"mode:              {args.mode}")
    print(f"map entries:       {len(name_map)}  (unambiguous finals: {len(fm)})")
    print(f"ambiguous finals:  {len(ambiguous)}  {sorted(ambiguous)[:10]}")
    print(f"files with hits:   {len(per_file)}")
    print(f"total occurrences: {total}")
    for f, n in per_file.most_common(20):
        print(f"  {n:5d}  {f}")

    if args.report:
        lines = [f"# Phase 7 sweep report ({args.mode})", "",
                 f"- map entries: {len(name_map)}",
                 f"- unambiguous final components: {len(fm)}",
                 f"- ambiguous finals skipped: {len(ambiguous)}", "",
                 f"**Total occurrences rewritten: {total}** across {len(per_file)} files.", ""]
        if ambiguous:
            lines += ["## Ambiguous final components (skipped, never guessed)", "",
                      "| old final | candidate targets |", "|---|---|"]
            lines += [f"| `{k}` | {', '.join('`' + x + '`' for x in v)} |"
                      for k, v in sorted(ambiguous.items())]
            lines.append("")
        lines += ["## Per-file", "", "| file | occurrences |", "|---|---|"]
        lines += [f"| `{f}` | {n} |" for f, n in per_file.most_common()]
        lines += ["", "## Per-name (top 40)", "", "| old final | occurrences |", "|---|---|"]
        lines += [f"| `{k}` | {n} |" for k, n in per_name.most_common(40)]
        Path(args.report).write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
