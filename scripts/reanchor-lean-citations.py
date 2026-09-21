#!/usr/bin/env python3
"""Re-anchor `file.lean:NNN` citations after a docstring edit shifts their targets.

WHAT THIS IS. A maintenance tool, not a gate. `scripts/check-module-invariants.sh`
check C20 tier 1 asserts that every `file.lean:NNN` citation in live scope lands on
a real, non-blank line. Editing a module's leading `/-! … -/` docstring moves every
line below it, so a docstring sweep silently invalidates every citation that points
into the edited file. This tool computes, per edited file, how far its body moved and
rewrites the citations accordingly.

THE MODEL. For an edited file F:

    Δ = new_line_count(F) - old_line_count(F)
    docstring_end = last line of F's leading /-! … -/ block, in the OLD content
    every citation "F:N" anywhere in scope with N > docstring_end  ->  N + Δ

This is a single integer per file, which is correct exactly when all of F's
line-count-changing edits are inside its leading docstring. That is the measured
shape of the sweep this tool was written for: 297 of the 298 `## References`
headings in the tree sit inside the leading module docstring. The tool VERIFIES the
assumption instead of trusting it -- it compares the old and new content below the
docstring and refuses the file if they differ (see `--exact` for the other case).

RUN IT EXACTLY ONCE PER BATCH, WITH AN EXPLICIT `--files`. The tool is NOT
idempotent. Δ is computed from `--base` (HEAD by default) to the working tree, so a
second run applies the same Δ a second time and every citation ends up shifted by
2Δ — and C20 will still PASS, because a double-shifted citation usually lands on
some other non-blank line. The default `--files` (every `.lean` changed vs `--base`)
makes this easy to trip: after the first run the rewritten CITERS are changed too,
so they join the target list. Always pass the batch's own edited files explicitly,
and run once. To recover from a double run, restore the citation-only-changed citer
files from `--base` and run again.

REFUSALS. The tool refuses rather than guesses, and reports what it refused:
  * a file whose leading `/-! … -/` block it cannot locate;
  * a file whose content below that block changed (the single-Δ model does not
    describe it) -- rerun that file under `--exact`;
  * under `--exact`, a citation whose target line was deleted outright.

It also reports, as `INSIDE`, a citation that points INTO an edited file's leading
docstring. The single-Δ model shifts only what lies BELOW that docstring, so such a
citation is left where it was -- which is wrong whenever the edit added or removed
lines above it inside the docstring. Check those by hand, or rerun that one target
under `--exact`.

C20's RESOLVER QUIRK. C20 matches an *unqualified* citation (`Foo.lean:12`) on
basename, and reports a citation whose basename is ambiguous, or names no live file,
as `unverifiable` rather than failed. `unverifiable` is not a pass. This tool
resolves citations exactly as C20 does, so a citation C20 cannot resolve is one this
tool will not rewrite either; after a run, assert the *resolvable* citation count is
unchanged, not merely that nothing FAILED.

USAGE
    # rewrite citations for every .lean file edited since HEAD
    python3 scripts/reanchor-lean-citations.py

    # limit to one phase's file set
    python3 scripts/reanchor-lean-citations.py --files FormalSystem/Semantics/*.lean

    # a file whose body also changed: exact per-line remap via difflib
    python3 scripts/reanchor-lean-citations.py --exact --files BimodalTools/TraceExporterMain.lean

    # show what would change, touch nothing
    python3 scripts/reanchor-lean-citations.py --dry-run

    # no-op validation: a Δ=0 run over the whole tree must change zero bytes
    python3 scripts/reanchor-lean-citations.py --selftest
"""

from __future__ import annotations

import argparse
import difflib
import os
import re
import subprocess
import sys
import tempfile

# Mirrors C20's own citation pattern, scan roots and extensions exactly. Keep in
# lockstep with scripts/check-module-invariants.sh; a divergence here means the tool
# rewrites a citation the gate does not read, or misses one it does.
CITE = re.compile(r"\b((?:[A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.lean):(\d+)\b")
SCAN_ROOTS = ["FormalSystem", "BimodalTools", "docs", "typst", "Tests", "scripts", "README.md"]
SCAN_EXTS = (".lean", ".md", ".typ", ".sh")
PRUNE_DIRS = ("Boneyard", ".lake", "__pycache__", ".git", "specs")
SELF = os.path.join("scripts", os.path.basename(__file__))


def run(*args: str) -> str:
    return subprocess.run(args, capture_output=True, text=True, check=True).stdout


def live_lean_files() -> list[str]:
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in PRUNE_DIRS]
        for f in files:
            if f.endswith(".lean"):
                out.append(os.path.normpath(os.path.join(root, f)))
    return out


def citer_files() -> list[str]:
    out = []
    for r in SCAN_ROOTS:
        if os.path.isfile(r):
            out.append(r)
            continue
        for root, dirs, files in os.walk(r):
            dirs[:] = [d for d in dirs if d not in PRUNE_DIRS]
            for f in files:
                if f.endswith(SCAN_EXTS):
                    out.append(os.path.normpath(os.path.join(root, f)))
    return sorted(f for f in out if f != SELF)


def make_resolver(live: list[str]):
    by_base: dict[str, list[str]] = {}
    for p in live:
        by_base.setdefault(os.path.basename(p), []).append(p)

    def resolve(ref: str):
        if "/" in ref:
            c = [p for p in live if p == ref or p.endswith(os.sep + ref.replace("/", os.sep))]
        else:
            c = by_base.get(ref, [])
        return c[0] if len(c) == 1 else None

    return resolve


def leading_docstring_end(lines: list[str]) -> int | None:
    """1-indexed line of the closing `-/` of the file's leading `/-! … -/` block.

    Returns None when there is no such block, or when its close cannot be found:
    the caller refuses the file rather than guessing a boundary.
    """
    PREAMBLE = ("import", "set_option", "open", "universe", "namespace",
                "assert_not_exists", "assert_exists")
    start = None
    prev_preamble = False
    i = 1
    while i <= len(lines):
        raw = lines[i - 1]
        s = raw.strip()
        if not s or s.startswith("--"):
            i += 1
            continue
        if prev_preamble and raw[:1].isspace():
            # a wrapped continuation of the preamble line above (assert_not_exists
            # and open both wrap across lines in this tree)
            i += 1
            continue
        if s.startswith("/-!"):
            start = i
            break
        if s.startswith("/-"):
            # a copyright header or other block comment sitting above the docstring
            prev_preamble = False
            if s.endswith("-/") and len(s) > 3:
                i += 1
                continue
            i += 1
            while i <= len(lines) and not lines[i - 1].rstrip().endswith("-/"):
                i += 1
            if i > len(lines):
                return None
            i += 1
            continue
        if s.split(" ", 1)[0] in PREAMBLE:
            prev_preamble = True
            i += 1
            continue
        return None
    if start is None:
        return None
    if lines[start - 1].rstrip().endswith("-/") and len(lines[start - 1].strip()) > 3:
        return start
    for j in range(start + 1, len(lines) + 1):
        if lines[j - 1].rstrip().endswith("-/"):
            return j
    return None


def old_content(rev: str, path: str) -> str | None:
    p = subprocess.run(["git", "show", f"{rev}:{path}"], capture_output=True, text=True)
    return p.stdout if p.returncode == 0 else None


def delta_map(old: list[str], new: list[str], path: str):
    """The plan's single-Δ model, with its assumption verified rather than trusted."""
    end = leading_docstring_end(old)
    if end is None:
        return None, "no leading /-! … -/ block found (or its close is unlocatable)"
    delta = len(new) - len(old)
    new_end = end + delta
    if new_end < 0 or old[end:] != new[new_end:]:
        return None, (
            "content below the leading docstring changed, so a single Δ does not "
            "describe this file; rerun it under --exact"
        )

    def f(n: int):
        if n <= end:
            # A citation INTO the edited docstring. The single-Δ model says nothing about
            # it: the edit may have added or removed lines above it, inside the docstring.
            # Report it rather than silently leaving it where it was.
            f.inside.append(n)
            return n
        return n + delta

    f.inside = []
    return f, "Δ=%+d below line %d" % (delta, end)


def exact_map(old: list[str], new: list[str], path: str):
    """Per-line old->new mapping via difflib; None for a line that was deleted."""
    mapping: dict[int, int | None] = {}
    sm = difflib.SequenceMatcher(a=old, b=new, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            for k in range(i2 - i1):
                mapping[i1 + k + 1] = j1 + k + 1
        else:
            for k in range(i1, i2):
                mapping[k + 1] = None

    def f(n: int):
        return mapping.get(n, None)

    return f, "exact per-line map (%d line(s) deleted)" % sum(
        1 for v in mapping.values() if v is None
    )


def reanchor(edited: list[str], rev: str, exact: bool, dry_run: bool, quiet: bool = False) -> int:
    live = live_lean_files()
    resolve = make_resolver(live)

    maps: dict[str, callable] = {}
    refused: list[tuple[str, str]] = []
    for path in edited:
        old = old_content(rev, path)
        if old is None:
            refused.append((path, "not present at %s (new file); nothing cites it yet" % rev))
            continue
        old_lines = old.split("\n")
        new_lines = open(path, encoding="utf-8").read().split("\n")
        if old_lines == new_lines:
            continue
        fn, why = (exact_map if exact else delta_map)(old_lines, new_lines, path)
        if fn is None:
            refused.append((path, why))
            continue
        maps[os.path.normpath(path)] = fn
        if not quiet:
            print("  target %s: %s" % (path, why))

    if not maps:
        if not quiet:
            print("no target files with a usable mapping; nothing to rewrite")
        for path, why in refused:
            print("REFUSED %s -- %s" % (path, why), file=sys.stderr)
        return 1 if refused else 0

    rewritten = 0
    touched: list[str] = []
    lost: list[str] = []
    inside: list[str] = []
    for citer in citer_files():
        text = open(citer, encoding="utf-8", errors="replace").read()
        out_lines = []
        changed = False
        for lineno, line in enumerate(text.split("\n"), 1):

            def sub(m: re.Match) -> str:
                nonlocal changed
                ref, num = m.group(1), m.group(2)
                target = resolve(ref)
                if target is None or target not in maps:
                    return m.group(0)
                fn = maps[target]
                new_n = fn(int(num))
                if new_n == int(num) and getattr(fn, "inside", None) and int(num) in fn.inside:
                    inside.append("%s:%d -> %s:%s (points INTO the edited docstring; the "
                                  "single-Δ model leaves it unmoved -- check it by hand, or "
                                  "rerun that target under --exact)" % (citer, lineno, ref, num))
                if new_n is None:
                    lost.append("%s:%d -> %s:%s (target line was deleted)"
                                % (citer, lineno, ref, num))
                    return m.group(0)
                if new_n == int(num):
                    return m.group(0)
                changed = True
                return "%s:%d" % (ref, new_n)

            out_lines.append(CITE.sub(sub, line))
        if changed:
            new_text = "\n".join(out_lines)
            n = sum(1 for a, b in zip(text.split("\n"), out_lines) if a != b)
            rewritten += n
            touched.append(citer)
            if not dry_run:
                open(citer, "w", encoding="utf-8").write(new_text)

    if not quiet:
        verb = "would rewrite" if dry_run else "rewrote"
        print("%s %d citation line(s) across %d citer file(s)" % (verb, rewritten, len(touched)))
        for t in touched:
            print("    %s" % t)
    for path, why in refused:
        print("REFUSED %s -- %s" % (path, why), file=sys.stderr)
    for l in lost:
        print("LOST    %s" % l, file=sys.stderr)
    for l in inside:
        print("INSIDE  %s" % l, file=sys.stderr)
    return 1 if (refused or lost or inside) else 0


def selftest(rev: str) -> int:
    """Δ=0 over the whole tree must be a byte-exact no-op; a synthetic +3 must move
    exactly the citations into the edited file and nothing else."""
    ok = True

    print("== selftest 1: Δ=0 no-op over every live .lean file ==")
    live = live_lean_files()
    # `live` mirrors C20's own walk (it is what citation resolution must agree with),
    # but the deploy artifacts under .claude/ and .opencode/ are gitignored, so they
    # have no pre-edit content to diff against and are not sweep targets.
    tracked = [p for p in live
               if not p.startswith(".claude" + os.sep) and not p.startswith(".opencode" + os.sep)]
    clean = subprocess.run(["git", "status", "--porcelain", "--"] + tracked,
                           capture_output=True, text=True).stdout.strip()
    if clean:
        print("  SKIP: working tree has modified .lean files; run on a clean tree")
    else:
        rc = reanchor(tracked, rev, exact=False, dry_run=True, quiet=True)
        print("  %d tracked live file(s) scanned; rc=%d (0 = byte-exact no-op)"
              % (len(tracked), rc))
        if rc != 0:
            ok = False

    print("== selftest 2: synthetic +3 on a heavily-cited file ==")
    target = "FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean"
    if clean:
        # The probe measures a +3 shift against `rev`; if the file already differs from
        # `rev` the measured Δ is that difference plus 3, and the probe means nothing.
        print("  SKIP: working tree has modified .lean files; run on a clean tree")
        return 0 if ok else 1
    if not os.path.exists(target):
        print("  SKIP: %s absent" % target)
        return 0 if ok else 1
    resolve = make_resolver(live)
    before: dict[str, list[tuple[int, str, str]]] = {}
    for citer in citer_files():
        rows = []
        for i, l in enumerate(open(citer, encoding="utf-8", errors="replace").read().split("\n"), 1):
            for ref, num in CITE.findall(l):
                rows.append((i, ref, num))
        if rows:
            before[citer] = rows
    into = sum(1 for c, rows in before.items() for _, ref, _ in rows
               if resolve(ref) == os.path.normpath(target))
    print("  %d citation(s) point into %s" % (into, target))

    orig = open(target, encoding="utf-8").read()
    lines = orig.split("\n")
    end = leading_docstring_end(lines)
    if end is None:
        print("  SKIP: cannot locate the leading docstring of the probe file")
        return 0 if ok else 1
    snapshot = {c: open(c, encoding="utf-8", errors="replace").read() for c in before}
    try:
        lines[end - 1:end - 1] = ["-- selftest padding"] * 3
        open(target, "w", encoding="utf-8").write("\n".join(lines))
        reanchor([target], rev, exact=False, dry_run=False, quiet=True)
        moved = 0
        stray = 0
        for citer, rows in before.items():
            now = []
            for i, l in enumerate(open(citer, encoding="utf-8", errors="replace").read().split("\n"), 1):
                for ref, num in CITE.findall(l):
                    now.append((i, ref, num))
            for (i0, r0, n0), (i1, r1, n1) in zip(rows, now):
                if resolve(r0) == os.path.normpath(target):
                    if int(n1) == int(n0) + 3:
                        moved += 1
                    elif int(n0) > end:
                        stray += 1
                elif n0 != n1:
                    stray += 1
        print("  %d citation(s) moved by exactly +3; %d unexpected change(s)" % (moved, stray))
        if stray:
            ok = False
    finally:
        open(target, "w", encoding="utf-8").write(orig)
        for c, t in snapshot.items():
            open(c, "w", encoding="utf-8").write(t)
        print("  restored every file touched by the probe")

    return 0 if ok else 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--base", default="HEAD", help="git revision holding the pre-edit content")
    ap.add_argument("--files", nargs="*", help="edited files (default: every .lean changed vs --base)")
    ap.add_argument("--exact", action="store_true",
                    help="per-line difflib remap instead of the single-Δ model")
    ap.add_argument("--dry-run", action="store_true", help="report, change nothing")
    ap.add_argument("--selftest", action="store_true", help="run the validation probes and exit")
    args = ap.parse_args()

    if args.selftest:
        return selftest(args.base)

    if args.files:
        edited = [os.path.normpath(f) for f in args.files]
    else:
        out = run("git", "diff", "--name-only", args.base, "--", "*.lean")
        edited = [os.path.normpath(f) for f in out.split() if f]
        edited = [f for f in edited if not f.startswith("Boneyard" + os.sep)]
    if not edited:
        print("no edited .lean files vs %s" % args.base)
        return 0
    print("re-anchoring citations for %d edited file(s) vs %s" % (len(edited), args.base))
    return reanchor(edited, args.base, args.exact, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
