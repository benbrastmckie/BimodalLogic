#!/usr/bin/env python3
"""Stratify C17's dead-declaration census into disposition tiers.

Replicates check-module-invariants.sh's C17 scan exactly (verified: same count),
then annotates each flagged declaration with the evidence needed to triage it.

The six tiers below are the six filters C17 now applies itself: after those landed,
this tool's SURVIVOR count and C17's printed headline are the same number, and a
divergence between them is a defect in this tool (C17 is authoritative), not a
rounding difference.

Tiers:

  T0_parse_artifact   the C17 decl regex matched a line inside a comment -- not
                      a declaration at all
  T1_instance         `instance`; reached by typeclass resolution, never by name
  T2_simp             `@[simp]`; reached through the default simp set
  T3_custom_simp      `@[<attr>]` for an attr declared via `register_simp_attr`
  T4_corpus_external  referenced from a file C17 does not scan (typst/**/*.typ,
                      scripts/*.sh -- notably the C2/C14 axiom baselines)
  T5_examples         declared under FormalSystem/Examples/, whose contract is to
                      be READ rather than called -- nothing calling it is the
                      intended state, so a census row for it is never actionable
  SURVIVOR            no known false-positive mechanism applies

Survivors additionally carry `boneyard_refs` (occurrences in FormalSystem/Boneyard,
comment-stripped) and `orphan_module` (the declaring module is not import-reachable
from any lakefile lib/exe root).

Run from the repository root.  Writes a TSV to stdout unless --summary is given.
"""
import os, re, sys, collections

DECL_RE = re.compile(
    r"^(?:@\[[^\]]*\]\s*)*"
    r"(?:private\s+|protected\s+|noncomputable\s+|scoped\s+|local\s+|mutual\s+)*"
    r"(structure|inductive|def|abbrev|theorem|lemma|instance|class)\s+"
    r"([A-Za-z_][A-Za-z0-9_'.]*)")
TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_']*")
ATTR_INLINE_RE = re.compile(r"^((?:@\[[^\]]*\]\s*)+)")
IMPORT_RE = re.compile(r"^import\s+([A-Za-z_][A-Za-z0-9_'.]*)")
EXAMPLES_DIR = os.path.join("FormalSystem", "Examples") + os.sep


def lean_files(base, skip_boneyard=True):
    out = []
    for root, dirs, files in os.walk(base):
        if skip_boneyard:
            dirs[:] = [d for d in dirs if d != "Boneyard"]
        out += [os.path.join(root, f) for f in files if f.endswith(".lean")]
    return sorted(out)


def prose_files():
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in
                   (".git", ".lake", "specs", "Boneyard", "build", "__pycache__")]
        out += [os.path.relpath(os.path.join(root, f), ".")
                for f in files if f.endswith(".md")]
    return sorted(out)


def comment_mask(lines):
    """Return (starts_inside_block_comment, comment_stripped_text) per line."""
    depth, inside, code = 0, [], []
    for raw in lines:
        inside.append(depth > 0)
        out, i, n = [], 0, len(raw)
        while i < n:
            if depth == 0 and raw.startswith("--", i):
                break
            if raw.startswith("/-", i):
                depth += 1; i += 2; continue
            if depth > 0 and raw.startswith("-/", i):
                depth -= 1; i += 2; continue
            if depth == 0:
                out.append(raw[i])
            i += 1
        code.append("".join(out))
    return inside, code


def build_occ(paths, comment_aware=False):
    occ = {}
    for path in paths:
        try:
            lines = open(path, encoding="utf-8", errors="replace").readlines()
        except OSError:
            continue
        src = lines
        if comment_aware and path.endswith(".lean"):
            _, src = comment_mask(lines)
        for i, line in enumerate(src, 1):
            for tok in set(TOKEN_RE.findall(line)):
                occ.setdefault(tok, set()).add((path, i))
    return occ


def custom_simp_attrs():
    """Attribute names registered via `register_simp_attr` in live library code."""
    attrs = set()
    for p in lean_files("FormalSystem"):
        for line in open(p, encoding="utf-8", errors="replace"):
            m = re.match(r"\s*register_simp_attr\s+([A-Za-z_][A-Za-z0-9_']*)", line)
            if m:
                attrs.add(m.group(1))
    return attrs


def orphan_modules():
    """Live FormalSystem modules unreachable from any lakefile lib/exe root."""
    mods = {}
    for base, strip in (("FormalSystem", None), ("Tests", "Tests")):
        for p in lean_files(base):
            rel = os.path.relpath(p, strip) if strip else p
            mods[rel[:-5].replace("/", ".")] = p
    mods["FormalSystem"] = "FormalSystem.lean"
    mods["BimodalTest"] = "Tests/BimodalTest.lean"
    edges = collections.defaultdict(set)
    for m, p in mods.items():
        for line in open(p, encoding="utf-8", errors="replace"):
            mm = IMPORT_RE.match(line)
            if mm:
                edges[m].add(mm.group(1))
    roots = ["FormalSystem", "BimodalTest"]
    try:
        for line in open("lakefile.toml", encoding="utf-8"):
            mm = re.match(r'\s*root\s*=\s*"([^"]+)"', line)
            if mm:
                roots.append(mm.group(1))
    except OSError:
        pass
    seen, stack = set(), [r for r in roots if r in mods]
    while stack:
        m = stack.pop()
        if m in seen:
            continue
        seen.add(m)
        stack += [t for t in edges.get(m, ()) if t in mods and t not in seen]
    return {p for m, p in mods.items() if p.startswith("FormalSystem") and m not in seen}


def main():
    live = lean_files("FormalSystem")
    bone = lean_files("FormalSystem/Boneyard", skip_boneyard=False)
    tests = lean_files("Tests")
    simp_attrs = {"simp"} | custom_simp_attrs()
    orphans = orphan_modules()

    decls = []
    for path in live:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
        inside, code = comment_mask(lines)
        for i, raw in enumerate(lines, 1):
            m = DECL_RE.match(raw.strip())
            if not m:
                continue
            m2 = DECL_RE.match(code[i - 1].strip())
            real = (not inside[i - 1]) and bool(m2) and m2.group(2) == m.group(2)
            attrs, am = "", ATTR_INLINE_RE.match(raw.strip())
            if am:
                attrs += am.group(1)
            j, back = i - 2, []
            while j >= 0 and lines[j].strip().startswith("@[") and lines[j].strip().endswith("]"):
                back.append(lines[j].strip()); j -= 1
            attrs += " ".join(reversed(back))
            decls.append({"base": m.group(2).split(".")[-1], "full": m.group(2),
                          "kind": m.group(1), "file": path, "line": i,
                          "attrs": attrs.strip(), "real": real})

    occ = build_occ(live + prose_files() + tests)
    occ_bone = build_occ(bone, comment_aware=True)
    # Reference sites C17 does not scan but which are load-bearing.
    external = []
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in (".git", ".lake", "build", "__pycache__", "specs")]
        external += [os.path.join(root, f) for f in files if f.endswith((".typ", ".sh"))]
    occ_ext = build_occ(external)

    rows = []
    for d in decls:
        if occ.get(d["base"], set()) - {(d["file"], d["line"])}:
            continue
        attr_names = set(re.findall(r"[A-Za-z_][A-Za-z0-9_']*", d["attrs"]))
        if not d["real"]:
            tier = "T0_parse_artifact"
        elif d["kind"] == "instance":
            tier = "T1_instance"
        elif "simp" in attr_names:
            tier = "T2_simp"
        elif attr_names & simp_attrs:
            tier = "T3_custom_simp"
        elif occ_ext.get(d["base"]):
            tier = "T4_corpus_external"
        elif d["file"].startswith(EXAMPLES_DIR):
            tier = "T5_examples"
        else:
            tier = "SURVIVOR"
        rows.append((tier, d["file"], d["line"], d["kind"], d["full"], d["attrs"],
                     len(occ_bone.get(d["base"], set())),
                     "orphan" if d["file"] in orphans else ""))

    if "--summary" in sys.argv:
        c = collections.Counter(r[0] for r in rows)
        print(f"C17 census: {len(rows)}")
        for k in ("T0_parse_artifact", "T1_instance", "T2_simp", "T3_custom_simp",
                  "T4_corpus_external", "T5_examples", "SURVIVOR"):
            print(f"  {c.get(k, 0):5d}  {k}")
        print(f"  {c.get('SURVIVOR', 0):5d}  == C17's printed headline")
        surv = [r for r in rows if r[0] == "SURVIVOR"]
        print(f"  of survivors: {sum(1 for r in surv if r[6] > 0)} referenced only from Boneyard/, "
              f"{sum(1 for r in surv if r[7])} in import-orphan modules")
        return
    print("tier\tfile\tline\tkind\tname\tattrs\tboneyard_refs\torphan_module")
    for r in sorted(rows):
        print("\t".join(str(x) for x in r))


if __name__ == "__main__":
    main()
