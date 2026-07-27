#!/usr/bin/env python3
"""Guarded, suffix-anchored, `.ilean`-driven declaration renamer.

Mechanism (settled by the research experiment; see the plan's "Design decisions are SETTLED"):

  * Every edit position comes from a resolved reference recorded in an `.ilean` artifact, so a
    span is only ever touched when the elaborator agreed it denotes the target declaration.
    This is what makes the 47.2% prefix-collision hazard structurally impossible -- there is no
    substring matching anywhere in this tool.
  * A recorded span may be written bare (`truth_at`, 83.46%), qualified
    (`Bimodal.Semantics.truth_at`, 16.01%), or dot-notation (0.53%).  The **guard** is that the
    span's source text must END with the declaration's old final component, and only that
    trailing sub-span is rewritten.  Everything else is REJECTED and reported.
  * A rejection is a correct outcome, not a bug (postmortem constraint 8).  Wildcard `_` holes
    and keyword/anonymous-declaration sites are exactly the ranges a naive rewriter corrupts
    into syntactically valid nonsense.
  * All edits are computed from ONE `.ilean` snapshot and applied in ONE pass, per file, per
    line, RIGHT-TO-LEFT (postmortem constraint 4) -- rewriting left-to-right shifts the columns
    of every other target on the same line.

Usage:
  rename.py --self-test [--out report.json]
        Round-trip every recorded range for a project declaration and report the exact-suffix
        match rate plus the mismatch taxonomy.  Acceptance bar: >= 99.7%, no unknown bucket.

  rename.py --map target-names.tsv --plan edits.json
        Compute (but do not apply) the edit set.

  rename.py --map target-names.tsv --apply [--rejections guard-rejections.md]
        Compute and apply the edit set.

The map is a TSV of `old_fully_qualified_name <TAB> new_final_component` (extra columns
ignored, `#` comments and a header row starting with `old` are skipped).
"""
import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ilean import REPO, iter_ileans, parse_key, u16_to_py  # noqa: E402

PROJECT_ROOTS = ("Bimodal", "BimodalTest", "FormalSystem")

IDENT_CHAR = re.compile(r"[A-Za-z0-9_'!?À-￿]")
KEYWORDS = {
    "by", "where", "def", "theorem", "lemma", "instance", "example", "abbrev", "deriving",
    "fun", "do", "match", "with", "let", "have", "show", "from", "calc", "this", "at",
    "structure", "inductive", "class", "macro", "syntax", "notation", "attribute", "open",
    "namespace", "end", "section", "variable", "universe", "mutual", "partial", "unsafe",
    "noncomputable", "private", "protected", "if", "then", "else", "rfl", "‹›", "_",
}


class Corpus:
    """All recorded ranges for project declarations, from one `.ilean` snapshot."""

    def __init__(self):
        self.sources = {}          # Path -> list[str] (lines, no trailing newline)
        # (src_path, line) -> list of (start_py, end_py, fqn)
        self.ranges = defaultdict(set)
        self.n_ilean = 0
        self.load()

    def lines(self, path):
        if path not in self.sources:
            self.sources[path] = path.read_text(encoding="utf-8").split("\n")
        return self.sources[path]

    def load(self):
        for _p, data, src in iter_ileans():
            self.n_ilean += 1
            for key, val in data["references"].items():
                _mod, fqn = parse_key(key)
                if not fqn or fqn.split(".")[0] not in PROJECT_ROOTS:
                    continue
                spans = []
                d = val.get("definition")
                if d:
                    spans.append(d)
                spans.extend(val.get("usages") or [])
                for sp in spans:
                    if len(sp) < 4:
                        continue
                    sl, sc, el, ec = sp[0], sp[1], sp[2], sp[3]
                    if sl != el:
                        continue  # multi-line spans are never a bare identifier
                    self.ranges[(src, sl)].add((sc, ec, fqn))

    def extract(self, src, line_no, sc, ec):
        ls = self.lines(src)
        if line_no >= len(ls):
            return None, None
        line = ls[line_no]
        a, b = u16_to_py(line, sc), u16_to_py(line, ec)
        return line, line[a:b]


def final(fqn):
    return fqn.split(".")[-1]


def trim_wrappers(text, b):
    """Some recorded spans enclose the identifier in parentheses (`(.bot)`,
    `(Axiom.serial_future)`).  Strip balanced trailing `)` so the suffix rule applies to the
    identifier itself, returning the adjusted end offset.  The plan requires parenthesized
    spans be handled via the suffix rule rather than rejected."""
    while text.endswith(")") and text.count("(") >= text.count(")"):
        text = text[:-1]
        b -= 1
    return text, b


def suffix_ok(text, old_final):
    """The guard: `text` ends with `old_final` at an identifier boundary."""
    if text is None or not text.endswith(old_final):
        return False
    head = text[: len(text) - len(old_final)]
    return head == "" or not IDENT_CHAR.match(head[-1])


def classify(text, old):
    """Bucket a guard rejection.  A new bucket blocks the phase (Phase 1 acceptance bar)."""
    if text is None:
        return "out-of-range"
    t = text.strip()
    if t == "_" or t == "":
        return "wildcard-_"
    if t in KEYWORDS:
        return "keyword/anon-decl"
    if t.endswith("»"):
        return "guillemet-escaped"
    if "_root_" in t:
        return "_root_-form"
    if old.startswith("_aux_") or "._aux_" in old or "_@_" in old:
        return "compiler-aux-decl"
    # `(name : Type)` type-ascription spans record the WHOLE parenthesised group, so the
    # identifier is span-INITIAL, not span-final.  Rewriting the trailing token here would
    # corrupt the ascribed type, so these must stay rejected; the build catches any that
    # matter.  Diagnosed at Syntax/SubformulaClosure/TemporalFormulas.lean:357.
    if t.startswith("(") and ":" in t and re.match(r"^\(\s*" + re.escape(old) + r"\s*:", t):
        return "binder-ascription-span"
    if old in t:
        return "embedded-not-suffix"
    return "UNKNOWN"


def self_test(corpus, out_path=None):
    total = ok = 0
    buckets = Counter()
    samples = defaultdict(list)
    for (src, line_no), items in corpus.ranges.items():
        for sc, ec, fqn in items:
            total += 1
            _line, text = corpus.extract(src, line_no, sc, ec)
            if text is not None:
                trimmed, _ = trim_wrappers(text, ec)
                if suffix_ok(trimmed, final(fqn)):
                    ok += 1
                    continue
            b = classify(text, final(fqn))
            buckets[b] += 1
            if len(samples[b]) < 8:
                samples[b].append(
                    {"file": str(src.relative_to(REPO)), "line": line_no + 1,
                     "text": text, "name": fqn}
                )
    rate = ok / total if total else 0.0
    print(f"ilean files:      {corpus.n_ilean}")
    print(f"recorded ranges:  {total}")
    print(f"exact suffix:     {ok}  ({rate:.4%})")
    print("mismatch taxonomy:")
    for b, n in buckets.most_common():
        print(f"  {n:6d}  {b}")
    unknown = buckets.get("UNKNOWN", 0)
    if out_path:
        Path(out_path).write_text(
            json.dumps({"total": total, "ok": ok, "rate": rate,
                        "buckets": dict(buckets), "samples": dict(samples)},
                       indent=1, ensure_ascii=False), encoding="utf-8")
    print()
    if rate < 0.997:
        print(f"FAIL: {rate:.4%} < 99.7% acceptance bar")
        return 1
    if unknown:
        print(f"FAIL: {unknown} ranges in an unknown mismatch bucket")
        for s in samples["UNKNOWN"] + samples["embedded-not-suffix"]:
            print("   ", s)
        return 1
    print("PASS: >= 99.7% exact suffix, mismatch taxonomy reproduces the known buckets only")
    return 0


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


def compute(corpus, name_map):
    """-> (edits, rejections).  edits: {src: {line: [(a, b, replacement)]}}"""
    edits = defaultdict(lambda: defaultdict(set))
    rejections = []
    for (src, line_no), items in corpus.ranges.items():
        for sc, ec, fqn in items:
            new_final = name_map.get(fqn)
            if new_final is None:
                continue
            old_final = final(fqn)
            line, text = corpus.extract(src, line_no, sc, ec)
            if text is None:
                rejections.append(
                    {"file": str(src.relative_to(REPO)), "line": line_no + 1,
                     "text": text, "name": fqn, "target": new_final,
                     "bucket": "out-of-range"})
                continue
            b_py = u16_to_py(line, ec)
            trimmed, b_py = trim_wrappers(text, b_py)
            if not suffix_ok(trimmed, old_final):
                rejections.append(
                    {"file": str(src.relative_to(REPO)), "line": line_no + 1,
                     "text": text, "name": fqn, "target": new_final,
                     "bucket": classify(text, old_final)})
                continue
            start = b_py - len(old_final)
            edits[src][line_no].add((start, b_py, new_final))
    return edits, rejections


def apply(edits, dry_run=False):
    n_files = n_edits = 0
    conflicts = []
    for src, per_line in sorted(edits.items()):
        lines = src.read_text(encoding="utf-8").split("\n")
        changed = False
        for line_no, spans in per_line.items():
            # right-to-left within the line (postmortem constraint 4)
            ordered = sorted(spans, key=lambda s: (-s[0], -s[1]))
            prev_start = None
            line = lines[line_no]
            for a, b, rep in ordered:
                if prev_start is not None and b > prev_start:
                    conflicts.append({"file": str(src), "line": line_no + 1,
                                      "span": [a, b], "repl": rep})
                    continue
                line = line[:a] + rep + line[b:]
                prev_start = a
                n_edits += 1
                changed = True
            lines[line_no] = line
        if changed:
            n_files += 1
            if not dry_run:
                src.write_text("\n".join(lines), encoding="utf-8")
    return n_files, n_edits, conflicts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--map")
    ap.add_argument("--plan")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--rejections")
    ap.add_argument("--out")
    args = ap.parse_args()

    corpus = Corpus()
    if args.self_test:
        sys.exit(self_test(corpus, args.out))

    if not args.map:
        sys.exit("need --map or --self-test")
    name_map = load_map(args.map)
    edits, rejections = compute(corpus, name_map)
    n_targets = len(name_map)
    n_spans = sum(len(s) for pl in edits.values() for s in pl.values())
    print(f"targets in map:   {n_targets}")
    print(f"files to edit:    {len(edits)}")
    print(f"spans to rewrite: {n_spans}")
    print(f"guard rejections: {len(rejections)}")
    for b, n in Counter(r["bucket"] for r in rejections).most_common():
        print(f"  {n:6d}  {b}")

    if args.plan:
        Path(args.plan).write_text(json.dumps(
            {str(k.relative_to(REPO)): {str(ln): sorted(v) for ln, v in pl.items()}
             for k, pl in edits.items()}, indent=1), encoding="utf-8")
    if args.rejections:
        write_rejections(args.rejections, rejections)
    if args.apply:
        nf, ne, conflicts = apply(edits)
        print(f"applied: {ne} edits across {nf} files; {len(conflicts)} overlap conflicts")
        if conflicts:
            print(json.dumps(conflicts[:20], indent=1))
            sys.exit(1)


def write_rejections(path, rejections):
    by = defaultdict(list)
    for r in rejections:
        by[r["bucket"]].append(r)
    out = ["# Guard rejections", "",
           "Every `.ilean` range whose extracted source text did not end with the expected old",
           "final component. A rejection is a correct outcome, not a bug: these are exactly the",
           "spans a naive textual rewriter corrupts into syntactically valid nonsense.", "",
           f"Total: {len(rejections)}", ""]
    for bucket, rows in sorted(by.items(), key=lambda kv: -len(kv[1])):
        out.append(f"## {bucket} ({len(rows)})")
        out.append("")
        out.append("| file | line | extracted text | declaration | intended target |")
        out.append("|---|---|---|---|---|")
        for r in rows:
            txt = (r["text"] or "").replace("|", "\\|")
            out.append(f"| `{r['file']}` | {r['line']} | `{txt}` | `{r['name']}` | `{r['target']}` |")
        out.append("")
    Path(path).write_text("\n".join(out), encoding="utf-8")


if __name__ == "__main__":
    main()
