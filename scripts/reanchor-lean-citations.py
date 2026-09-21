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
and run once. To recover from a double run, use `--recompute`, which recomputes every
citation from `--base` by content alignment and is idempotent -- `--selftest` probe 3
asserts exactly that sequence. Its one blind spot, pinned by probe 4: a citer line whose
CONTENT was also edited in the same batch is left as it is, because there is no
base-revision number on that line to trust. Re-anchor such a line by hand.

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

    # repair a tree the Δ pass was run over twice (idempotent; safe to rerun)
    python3 scripts/reanchor-lean-citations.py --recompute

    # validation probes: (1) a Δ=0 run over the whole tree changes zero bytes; (2) a
    # synthetic +3 moves exactly the citations it should; (3) a doubled Δ pass is repaired
    # by --recompute and a second --recompute is a no-op; (4) --recompute's one blind spot,
    # a citer line content-edited in the same batch, is left un-repaired, by design
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


def recompute(rev: str, dry_run: bool) -> int:
    """Recompute EVERY citation from `rev`, once, ignoring what the working tree holds.

    This is the idempotent counterpart to the Δ pass, and the way to repair a tree the
    Δ pass was run over twice. It aligns each citer file against its `rev` content with
    difflib; for a line that differs from `rev` ONLY in its citation numbers, it takes
    `rev`'s number and maps it through the target file's own `rev`->now line map. A line
    carrying a real content edit is left alone, since there is no `rev` number to trust.

    Both properties are asserted, not narrated: `--selftest` probe 3 runs the Δ pass twice,
    recomputes, and requires a SECOND recompute to report 0 citation lines across 0 citer
    files; probe 4 pins the content-edited-line limitation above as the stated
    refuse-rather-than-guess behaviour.
    """
    fixed, touched = recompute_counts(rev, dry_run)
    verb = "would recompute" if dry_run else "recomputed"
    print("%s %d citation line(s) across %d citer file(s)" % (verb, fixed, touched))
    return 0


def recompute_counts(rev: str, dry_run: bool) -> tuple[int, int]:
    """`recompute`'s body: returns (citation lines rebuilt, citer files touched)."""
    live = live_lean_files()
    resolve = make_resolver(live)

    maps: dict[str, dict[int, int]] = {}
    for p in live:
        o = old_content(rev, p)
        if o is None:
            continue
        o = o.split("\n")
        n = open(p, encoding="utf-8").read().split("\n")
        if o == n:
            continue
        m: dict[int, int] = {}
        for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(a=o, b=n, autojunk=False).get_opcodes():
            if tag == "equal":
                for k in range(i2 - i1):
                    m[i1 + k + 1] = j1 + k + 1
        maps[os.path.normpath(p)] = m

    def strip_nums(l: str) -> str:
        return CITE.sub(lambda m: m.group(1) + ":N", l)

    fixed = touched = 0
    for citer in citer_files():
        o = old_content(rev, citer)
        if o is None:
            continue
        o = o.split("\n")
        n = open(citer, encoding="utf-8").read().split("\n")
        if o == n:
            continue
        out = list(n)
        changed = False
        for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(a=o, b=n, autojunk=False).get_opcodes():
            if tag != "replace" or (i2 - i1) != (j2 - j1):
                continue
            for k in range(i2 - i1):
                ol, nl = o[i1 + k], n[j1 + k]
                if strip_nums(ol) != strip_nums(nl):
                    continue
                def redo(m: re.Match) -> str:
                    ref, num = m.group(1), int(m.group(2))
                    t = resolve(ref)
                    if t is None or t not in maps:
                        return m.group(0)
                    want = maps[t].get(num)
                    return m.group(0) if want is None else "%s:%d" % (ref, want)
                rebuilt = CITE.sub(redo, ol)
                if rebuilt != nl:
                    out[j1 + k] = rebuilt
                    changed = True
                    fixed += 1
        if changed:
            touched += 1
            if not dry_run:
                open(citer, "w", encoding="utf-8").write("\n".join(out))
    return fixed, touched


def selftest(rev: str) -> int:
    """Four probes. (1) Δ=0 over the whole tree must be a byte-exact no-op. (2) A synthetic
    +3 must move exactly the citations into the edited file and nothing else. (3) The Δ pass
    run TWICE must produce the doubled shift, `--recompute` must repair it to exactly +3,
    and a second `--recompute` must be a no-op. (4) A citer line that was ALSO content-edited
    in the same batch must be left un-repaired by `--recompute` -- the documented limitation,
    asserted so that it stays a stated behaviour and never becomes a silent one.

    Every probe snapshots what it will touch and restores it in a `finally`; all of them skip
    cleanly when the working tree carries modified .lean files."""
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

    norm_target = os.path.normpath(target)

    def shifts() -> dict[int, list[tuple[str, int]]]:
        """{shift: [(citer, citer line)]} over the citations into the probe file that lie
        BELOW its leading docstring, plus a -1 bucket for any other citation that moved."""
        out: dict[int, list[tuple[str, int]]] = {}
        for citer, rows in before.items():
            now = []
            for i, l in enumerate(open(citer, encoding="utf-8",
                                       errors="replace").read().split("\n"), 1):
                for ref, num in CITE.findall(l):
                    now.append((i, ref, num))
            for (i0, r0, n0), (i1, r1, n1) in zip(rows, now):
                if resolve(r0) == norm_target and int(n0) > end:
                    out.setdefault(int(n1) - int(n0), []).append((citer, i1))
                elif n0 != n1:
                    out.setdefault(-1, []).append((citer, i1))
        return out

    def double_run() -> None:
        padded = orig.split("\n")
        padded[end - 1:end - 1] = ["-- selftest padding"] * 3
        open(target, "w", encoding="utf-8").write("\n".join(padded))
        # The mistake itself: the same Δ pass over the same batch, twice.
        reanchor([target], rev, exact=False, dry_run=False, quiet=True)
        reanchor([target], rev, exact=False, dry_run=False, quiet=True)

    def restore() -> None:
        open(target, "w", encoding="utf-8").write(orig)
        for c, t in snapshot.items():
            open(c, "w", encoding="utf-8").write(t)
        print("  restored every file touched by the probe")

    print("== selftest 3: the Δ pass run twice, then --recompute, then --recompute again ==")
    try:
        double_run()
        got = shifts()
        doubled = len(got.get(6, []))
        print("  after two Δ passes: %d citation(s) at +6 where +3 is correct (the double "
              "shift C20 tier 1 cannot see)" % doubled)
        if doubled == 0 or set(got) - {6}:
            print("  FAIL: expected every citation below the docstring at +6, got shifts %s"
                  % sorted(got))
            ok = False
        fixed, touched = recompute_counts(rev, dry_run=False)
        got = shifts()
        print("  first --recompute: recomputed %d citation line(s) across %d citer file(s); "
              "%d citation(s) now at +3" % (fixed, touched, len(got.get(3, []))))
        if fixed == 0 or set(got) - {3} or len(got.get(3, [])) != doubled:
            print("  FAIL: expected all %d citation(s) back at exactly +3, got shifts %s"
                  % (doubled, {k: len(v) for k, v in got.items()}))
            ok = False
        fixed2, touched2 = recompute_counts(rev, dry_run=False)
        print("  second --recompute: recomputed %d citation line(s) across %d citer file(s) "
              "(0 across 0 = idempotent)" % (fixed2, touched2))
        if (fixed2, touched2) != (0, 0) or shifts() != got:
            print("  FAIL: a second --recompute changed the tree")
            ok = False
    finally:
        restore()

    print("== selftest 4: --recompute's content-edit blind spot (a documented limitation) ==")
    try:
        double_run()
        victim = next(((c, i) for c, i in sorted(shifts().get(6, [])) if c != norm_target), None)
        if victim is None:
            print("  SKIP: no citer other than the probe file cites below its docstring")
        else:
            vc, vi = victim
            vl = open(vc, encoding="utf-8", errors="replace").read().split("\n")
            vl[vi - 1] += " -- selftest content edit"
            open(vc, "w", encoding="utf-8").write("\n".join(vl))
            recompute_counts(rev, dry_run=False)
            got = shifts()
            left = got.get(6, [])
            print("  %s:%d was content-edited in the same batch as the double shift" % (vc, vi))
            print("  --recompute left %d citation(s) on that line at +6 and repaired %d other(s) "
                  "to +3" % (len(left), len(got.get(3, []))))
            print("  (refuse-rather-than-guess: a content-edited line has no base-revision "
                  "number to trust; re-anchor it by hand)")
            if not left or {c_i for c_i in left} != {victim} or set(got) - {3, 6}:
                print("  FAIL: expected ONLY the content-edited line un-repaired, got shifts %s"
                      % {k: sorted(set(v)) if k != 3 else len(v) for k, v in got.items()})
                ok = False
    finally:
        restore()

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
    ap.add_argument("--recompute", action="store_true",
                    help="recompute every citation from --base by content alignment; "
                         "idempotent, and the way to repair a doubled Δ pass")
    args = ap.parse_args()

    if args.selftest:
        return selftest(args.base)

    if args.recompute:
        return recompute(args.base, args.dry_run)

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
