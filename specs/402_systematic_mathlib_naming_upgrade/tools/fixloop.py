#!/usr/bin/env python3
"""Phase 6.2 build-fix driver: close the `.ilean` coverage gap.

`rename.py` can only rewrite spans the elaborator actually recorded.  A small fraction of
occurrences carry no `.ilean` range at all (the research experiment measured 8/512 = 1.6% on one
declaration), and those surface after the rewrite as loud name-resolution errors.  This tool
parses those errors out of `lake build` output and applies the SAME map `rename.py` used.

Discipline:
  * Only name-resolution errors are touched.  Anything else is a genuine defect and is reported,
    never patched into silence (plan, Phase 6.2 task 2).
  * A fix is applied only when the reported identifier resolves to exactly ONE target in the
    map.  Ambiguity is reported, never guessed.
  * The edit is line-scoped and whole-identifier-anchored -- never a substring replace
    (postmortem constraint 1).

Usage:
  fixloop.py --map target-names.tsv --build-log build.txt [--apply]
  fixloop.py --map target-names.tsv --loop [--max-rounds 12]
"""
import argparse
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path

REPO = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                           text=True, check=True).stdout.strip())

# lake:  `error: ./Path/File.lean:12:34: unknown identifier 'foo'`
# raw:   `./Path/File.lean:12:34: error: unknown identifier 'foo'`
LAKE_ERR = re.compile(r"^error:\s+(\S+?\.lean):(\d+):(\d+):\s*(.*)$")
RAW_ERR = re.compile(r"^(\S+?\.lean):(\d+):(\d+):\s*error:\s*(.*)$")

RESOLUTION = re.compile(
    r"unknown identifier '([^']+)'"
    r"|unknown constant '([^']+)'"
    r"|unknown namespace '([^']+)'"
    r"|[Uu]nknown identifier `([^`]+)`"
    r"|[Uu]nknown constant `([^`]+)`"
)
# Dot-notation projection: `φ.swap_temporal` where the field no longer exists.  The message
# carries the FULLY-QUALIFIED old name, which is a direct map key -- but the source text is
# `.swap_temporal`, so the edit must be anchored on the dot, not on an identifier boundary.
FIELD = re.compile(
    r"[Ii]nvalid field `([^`]+)`: [Tt]he environment does not contain `([^`]+)`")
IDENT_CHAR = r"[A-Za-z0-9_'!?À-￿]"


def load_map(path):
    """-> {old_fully_qualified: new_final}"""
    m = {}
    for raw in Path(path).read_text(encoding="utf-8").split("\n"):
        if not raw.strip() or raw.startswith("#"):
            continue
        parts = raw.split("\t")
        if len(parts) < 2 or parts[0] in ("old", "old_name", "current"):
            continue
        m[parts[0].strip()] = parts[1].strip()
    return m


def by_final(name_map):
    d = defaultdict(set)
    for fqn, new in name_map.items():
        d[fqn.split(".")[-1]].add(new)
    return d


def parse_errors(text):
    """-> list of (path, line, col, message).  Multi-line messages keep only the head line,
    which is where every resolution error states the name."""
    out = []
    for raw in text.split("\n"):
        m = LAKE_ERR.match(raw) or RAW_ERR.match(raw)
        if m:
            out.append((m.group(1), int(m.group(2)), int(m.group(3)), m.group(4)))
    return out


def resolve(msg):
    m = RESOLUTION.search(msg)
    if not m:
        return None
    ident = next(g for g in m.groups() if g)
    # Hygiene marks: a name resolved inside a `macro`/`elab` syntax quotation is reported with a
    # trailing `✝` (optionally superscript-numbered).  The source text carries no such mark.
    return re.sub(r"✝[¹²³⁰-⁹]*$", "", ident)


def plan_fixes(errors, name_map, finals):
    """-> (fixes, unresolved).  fixes: (path, line, written_name, new_written_name, mode)"""
    fixes, unresolved = [], []
    for path, line, col, msg in errors:
        fm = FIELD.search(msg)
        if fm:
            fqn = fm.group(2)
            new_final = name_map.get(fqn)
            if new_final is None:
                cands = finals.get(fqn.split(".")[-1], set())
                if len(cands) != 1:
                    unresolved.append((path, line, col, msg,
                                       "no-map-entry" if not cands else "ambiguous"))
                    continue
                new_final = next(iter(cands))
            fixes.append((path, line, fm.group(1), new_final, "field"))
            continue
        ident = resolve(msg)
        if ident is None:
            unresolved.append((path, line, col, msg, "not-a-name-resolution-error"))
            continue
        # `ident` is written form: bare (`truth_at`) or qualified (`Semantics.truth_at`).
        old_final = ident.split(".")[-1]
        # exact fully-qualified hit first
        cands = {v for k, v in name_map.items()
                 if k == ident or k.endswith("." + ident)}
        if not cands:
            cands = finals.get(old_final, set())
        if not cands:
            unresolved.append((path, line, col, msg, "no-map-entry"))
            continue
        if len(cands) > 1:
            unresolved.append((path, line, col, msg,
                               "ambiguous: " + ", ".join(sorted(cands))))
            continue
        new_final = next(iter(cands))
        new_written = ident[: len(ident) - len(old_final)] + new_final
        fixes.append((path, line, ident, new_written, "ident"))
    return fixes, unresolved


def apply_fixes(fixes, dry_run=False):
    per_file = defaultdict(list)
    for path, line, old, new, mode in fixes:
        per_file[path].append((line, old, new, mode))
    applied = skipped = 0
    for path, items in per_file.items():
        p = (REPO / path.lstrip("./")) if not Path(path).is_absolute() else Path(path)
        if not p.exists():
            skipped += len(items)
            continue
        lines = p.read_text(encoding="utf-8").split("\n")
        changed = False
        for line_no, old, new, mode in items:
            i = line_no - 1
            if i >= len(lines):
                skipped += 1
                continue
            if mode == "field":
                pat = re.compile(r"\." + re.escape(old) + r"(?!" + IDENT_CHAR + r")")
                new = "." + new
            else:
                pat = re.compile(r"(?<!" + IDENT_CHAR + r")(?<!\.)" + re.escape(old)
                                 + r"(?!" + IDENT_CHAR + r")")
            new_line, n = pat.subn(new, lines[i])
            if n == 0:
                skipped += 1
                continue
            lines[i] = new_line
            applied += n
            changed = True
        if changed and not dry_run:
            p.write_text("\n".join(lines), encoding="utf-8")
    return applied, skipped


def build():
    # `lake build` alone builds only the default target and leaves 22 modules unbuilt, so it
    # cannot see errors in them.  Use the full-coverage driver.
    r = subprocess.run(["bash", str(Path(__file__).resolve().parent / "build-all.sh")],
                       cwd=REPO, capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


def report(fixes, unresolved):
    print(f"resolution fixes planned: {len(fixes)}")
    for path, line, old, new, mode in fixes[:15]:
        print(f"    {path}:{line}  {old} -> {new}  [{mode}]")
    if len(fixes) > 15:
        print(f"    ... {len(fixes) - 15} more")
    print(f"unresolved errors:        {len(unresolved)}")
    for reason, n in Counter(u[4].split(":")[0] for u in unresolved).most_common():
        print(f"  {n:6d}  {reason}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", required=True)
    ap.add_argument("--build-log")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--loop", action="store_true")
    ap.add_argument("--max-rounds", type=int, default=12)
    ap.add_argument("--log-dir")
    args = ap.parse_args()

    name_map = load_map(args.map)
    finals = by_final(name_map)

    if args.build_log:
        text = Path(args.build_log).read_text(encoding="utf-8", errors="replace")
        errors = parse_errors(text)
        fixes, unresolved = plan_fixes(errors, name_map, finals)
        print(f"errors parsed: {len(errors)}")
        report(fixes, unresolved)
        if args.apply:
            a, s = apply_fixes(fixes)
            print(f"applied {a} edits ({s} skipped)")
        for u in unresolved[:40]:
            print("  UNRESOLVED", u[0], u[1], u[3][:160], "|", u[4])
        return

    if not args.loop:
        sys.exit("need --build-log or --loop")

    log_dir = Path(args.log_dir) if args.log_dir else None
    for rnd in range(1, args.max_rounds + 1):
        code, text = build()
        if log_dir:
            (log_dir / f"build-round-{rnd:02d}.txt").write_text(text, encoding="utf-8")
        if code == 0:
            print(f"round {rnd}: BUILD GREEN")
            return
        errors = parse_errors(text)
        fixes, unresolved = plan_fixes(errors, name_map, finals)
        print(f"--- round {rnd}: {len(errors)} errors")
        report(fixes, unresolved)
        if not fixes:
            print("no further automatic fixes; remaining errors need diagnosis")
            for u in unresolved[:60]:
                print("  UNRESOLVED", u[0], u[1], u[3][:200], "|", u[4])
            sys.exit(2)
        a, s = apply_fixes(fixes)
        print(f"applied {a} edits ({s} skipped)")
        if a == 0:
            print("fixes planned but none applied - stopping to avoid a spin")
            sys.exit(3)
    sys.exit("max rounds exhausted")


if __name__ == "__main__":
    main()
