#!/usr/bin/env python3
"""Emit the generated line-numbered view of this repository's cited declarations.

WHY THIS EXISTS.  A consuming repository's adequacy argument tabulates paper obligations against
the Lean declarations that discharge them, and it cited each one by `file.lean:NNN`.  Nothing in
either repository read those numbers, so four of them drifted by exactly +38 lines -- a docstring
edit above the citation targets -- and landed inside a different theorem with every gate in both
repositories green.  C20 already encodes the right convention (tier 2: publication-facing surfaces
cite declaration NAMES; the declaration-span assertion fails a named `file.lean:NNN` citation that
does not land inside the named declaration), but C20's live scope is this repository's own files.

The fix is to stop maintaining the line-numbered view by hand.  This script takes a reviewable
plain-text list of fully qualified declaration names and emits their current file, keyword line and
span as JSON.  The consuming document then cites names and includes the manifest, exactly as
`docs/reference/paper-definitions-of-record.md` cites `\\label{}` keys and re-derives every hash
from the live paper.

WHERE THE SPANS COME FROM.  `scripts/lib/lean_citations.py`'s `decl_spans` and `candidates` -- the
same reader C20's declaration-span assertion uses, imported rather than reimplemented, so the
exporter and that gate can never disagree about where a declaration lives.  A declaration's span
runs from the opening line of its own leading `/--` doc comment (walking back past `@[...]`
attribute lines) through the line before the next declaration's span begins; see that module's
header for why the span is not the keyword line.

FULLY QUALIFIED NAMES.  `decl_spans` reports a declaration's name as *written*, which is the local
name inside whatever `namespace` block encloses it.  This script tracks the `namespace` / `end`
stack of each file to recover the fully qualified name, then matches a seeded name against that.
`candidates` is consulted only as a fallback, and only to report an ambiguity precisely rather than
to guess.

FIELDS ARE NOT DECLARATIONS.  Some rows of a transcription audit are about a *field* of a structure
(`FrameOver.worldNonempty`, `TaskModel.valuation`), and a field opens no declaration span -- C20's
own output counts such citations as "not checkable, not failed".  A seed line therefore writes
`Parent.Name#field`: the parent is resolved as a declaration and the field is carried through as
metadata, so every seeded name resolves to exactly one declaration and the manifest still records
exactly what the consuming side should cite.

DETERMINISM IS LOAD BEARING.  The output carries no timestamp, no absolute path and no dictionary
whose order depends on a filesystem walk: entries appear in seed-file order.  Re-running the
exporter on an unchanged tree must produce a byte-identical file, or the freshness gate that reads
it (C35 in `scripts/check-module-invariants.sh`) is unusable.

EXIT STATUS.  0 when every seeded name resolved to exactly one declaration; 1 when any did not,
with a per-entry diagnostic on stderr and an explicit error entry in the manifest.  A name that
resolves nowhere is either a rename this repository made and never propagated, or a typo in the
seed list; either way it is a finding, never a silently omitted row.  2 on a usage or I/O error.

USAGE.

    python3 scripts/export-lean-citations.py                 # write the manifest
    python3 scripts/export-lean-citations.py --check         # compare, write nothing
    python3 scripts/export-lean-citations.py --stdout        # print, write nothing
"""

import argparse
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "lib"))

from lean_citations import candidates, decl_spans  # noqa: E402
from live_walk import live_files  # noqa: E402

REPO = os.path.dirname(HERE)
SEEDS = os.path.join(HERE, "lean-citation-seeds.txt")
MANIFEST = os.path.join(HERE, "lean-citation-manifest.json")

# The library roots a cited declaration can live in.  `Tests/` is deliberately absent: an audit
# cites the library, never its test suite.
SCAN_ROOTS = ("FormalSystem", "BimodalTools")

_NS = re.compile(r"^\s*namespace\s+([A-Za-z_][A-Za-z0-9_.'!?]*)\s*$")
_END = re.compile(r"^\s*end\s+([A-Za-z_][A-Za-z0-9_.'!?]*)\s*$")
_SECTION = re.compile(r"^\s*section\b")
_END_BARE = re.compile(r"^\s*end\s*$")


def qualified_names(lines):
    """Map each declaration of one file to its fully qualified name.

    Returns a list of `(fully_qualified_name, Decl)` pairs, in file order.  The namespace stack is
    read from the same comment-masked view `decl_spans` uses, so a `namespace` quoted inside a
    docstring's ```lean fence never enters it.
    """
    depth, code = 0, []
    for l in lines:
        code.append(depth == 0)
        depth += l.count("/-") - l.count("-/")
        if depth < 0:
            depth = 0

    # prefix_at[k] is the dotted namespace prefix in force on line k (0-indexed).
    prefix_at, stack = [], []
    for k, l in enumerate(lines):
        prefix_at.append(".".join(p for p in stack if p is not None))
        if not code[k]:
            continue
        m = _NS.match(l)
        if m:
            stack.append(m.group(1))
            continue
        if _SECTION.match(l):
            stack.append(None)
            continue
        m = _END.match(l)
        if m:
            # `end Foo` closes the innermost matching `namespace Foo`, discarding any anonymous
            # `section` frames opened inside it.
            for i in range(len(stack) - 1, -1, -1):
                if stack[i] == m.group(1):
                    del stack[i:]
                    break
            else:
                if stack:
                    stack.pop()
            continue
        if _END_BARE.match(l):
            if stack:
                stack.pop()
            continue
        # A `section Foo` line opens a named section, not a namespace; the `section` branch above
        # only matches the keyword, so a named section is already handled there.

    out = []
    for d in decl_spans(lines):
        prefix = prefix_at[d.line - 1]
        out.append((prefix + "." + d.name if prefix else d.name, d))
    return out


def build_index():
    """Every fully qualified declaration of the scanned roots -> list of (relpath, Decl)."""
    index, per_file = {}, {}
    for root in SCAN_ROOTS:
        base = os.path.join(REPO, root)
        paths = list(live_files(base, ".lean"))
        loose = os.path.join(REPO, root + ".lean")
        if os.path.isfile(loose):
            paths.append(loose)
        for path in sorted(paths):
            rel = os.path.relpath(path, REPO)
            with open(path, encoding="utf-8") as fh:
                lines = fh.read().split("\n")
            pairs = qualified_names(lines)
            per_file[rel] = (lines, [d for _, d in pairs])
            for qname, d in pairs:
                index.setdefault(qname, []).append((rel, d))
    return index, per_file


def parse_seeds(path):
    """Read the seed list: `## group` headers, one `Name[#field]` per line, `#` comments."""
    seeds, group = [], "ungrouped"
    with open(path, encoding="utf-8") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            stripped = line.strip()
            if not stripped:
                continue
            if stripped.startswith("##"):
                group = stripped[2:].strip()
                continue
            if stripped.startswith("#"):
                continue
            name, _, field = stripped.partition("#")
            seeds.append((group, name.strip(), field.strip() or None))
    return seeds


def resolve(seeds, index, per_file):
    """One manifest entry per seed, in seed order, plus the list of failures."""
    entries, failures = [], []
    for group, name, field in seeds:
        hits = index.get(name, [])
        if len(hits) == 1:
            rel, d = hits[0]
            entries.append({
                "group": group,
                "name": name,
                "field": field,
                "status": "resolved",
                "file": rel,
                "keyword_line": d.line,
                "span_start": d.start,
                "span_end": d.end,
            })
            continue
        if len(hits) > 1:
            where = sorted("%s:%d" % (rel, d.line) for rel, d in hits)
            status, detail = "ambiguous", "declared in %d places: %s" % (len(hits), ", ".join(where))
        else:
            near = sorted({
                rel for rel, (lines, decls) in per_file.items()
                if candidates(name, decls)
            })
            status = "unresolved"
            detail = ("no declaration with this fully qualified name"
                      + (" (last component declared in: %s)" % ", ".join(near) if near else ""))
        entries.append({
            "group": group,
            "name": name,
            "field": field,
            "status": status,
            "detail": detail,
        })
        failures.append((name, status, detail))
    return entries, failures


def render(entries):
    """The manifest text: deterministic, sorted keys, one trailing newline."""
    doc = {
        "schema": 1,
        "generated_by": "scripts/export-lean-citations.py",
        "seed_list": "scripts/lean-citation-seeds.txt",
        "note": ("Generated. Do not hand-edit: C35 in scripts/check-module-invariants.sh compares "
                 "this file against a fresh resolution and fails when they differ. Cite the `name` "
                 "field; the line numbers here are a derived view and are expected to move."),
        "resolved": sum(1 for e in entries if e["status"] == "resolved"),
        "total": len(entries),
        "entries": entries,
    }
    return json.dumps(doc, indent=2, sort_keys=True, ensure_ascii=False) + "\n"


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="compare the committed manifest against a fresh resolution; write nothing")
    ap.add_argument("--stdout", action="store_true", help="print the manifest; write nothing")
    ap.add_argument("--seeds", default=SEEDS, help="seed list path")
    ap.add_argument("--out", default=MANIFEST, help="manifest path")
    args = ap.parse_args(argv)

    if not os.path.isfile(args.seeds):
        print("export-lean-citations: no seed list at %s" % args.seeds, file=sys.stderr)
        return 2
    seeds = parse_seeds(args.seeds)
    if not seeds:
        print("export-lean-citations: seed list is empty -- nothing to resolve", file=sys.stderr)
        return 2

    index, per_file = build_index()
    if not index:
        print("export-lean-citations: zero declarations found under %s -- broken matcher"
              % ", ".join(SCAN_ROOTS), file=sys.stderr)
        return 2

    entries, failures = resolve(seeds, index, per_file)
    text = render(entries)

    if args.stdout:
        sys.stdout.write(text)
    elif args.check:
        if not os.path.isfile(args.out):
            print("export-lean-citations: --check but no manifest at %s" % args.out,
                  file=sys.stderr)
            return 1
        with open(args.out, encoding="utf-8") as fh:
            have = fh.read()
        if have != text:
            print("export-lean-citations: manifest is stale; re-run without --check",
                  file=sys.stderr)
            return 1
    else:
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(text)

    for name, status, detail in failures:
        print("export-lean-citations: %s: %s -- %s" % (status.upper(), name, detail),
              file=sys.stderr)
    if failures:
        print("export-lean-citations: %d of %d seeded name(s) did not resolve"
              % (len(failures), len(seeds)), file=sys.stderr)
        return 1
    print("export-lean-citations: %d seeded name(s) resolved" % len(seeds))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
