#!/usr/bin/env python3
"""Load the project's `.ilean` reference corpus.

`.ilean` v5 schema (verified against `.lake/build/lib/lean/Bimodal/Semantics/Truth.ilean`):

    {"version": 5,
     "module": "Bimodal.Semantics.Truth",
     "directImports": [...],
     "decls": [[name, [sl, sc, el, ec, selSl, selSc, selEl, selEc]], ...],
     "references": {
        '{"c":{"m":<defining module>,"n":<fully-qualified name>}}':
            {"definition": <range or null>,
             "usages": [[sl, sc, el, ec], [sl, sc, el, ec, <enclosing decl>], ...]}
     }}

Lines and columns are **0-indexed**; columns are **UTF-16 code units** (verified empirically:
`Truth.ilean` records `TaskFrame` at line 94 col 82, and `src[94][82:91] == "TaskFrame"`).

Every range inside module M's `.ilean` addresses M's own source file.

Postmortem constraint 11: any `.ilean` whose module has no source file is STALE and skipped.
"""
import json
import os
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
BUILD = REPO / ".lake" / "build" / "lib" / "lean"


def source_roots():
    """Map a module-name first component to its source directory, from lakefile layout."""
    roots = {}
    for lib_root, src_dir in module_roots():
        roots[lib_root] = REPO / src_dir
    return roots


def module_roots():
    """(root module name, srcDir) pairs, parsed from lakefile.lean's lean_lib stanzas."""
    text = (REPO / "lakefile.lean").read_text(encoding="utf-8")
    import re

    out = []
    for m in re.finditer(r"lean_lib\s+(\w+)\s+where(.*?)(?=\nlean_|\Z)", text, re.S):
        name, body = m.group(1), m.group(2)
        sd = re.search(r'srcDir\s*:=\s*"([^"]*)"', body)
        out.append((name, sd.group(1) if sd else "."))
    return out


def module_to_source(module):
    """Absolute source path for a module name, or None if it does not exist."""
    roots = source_roots()
    head = module.split(".")[0]
    base = roots.get(head)
    if base is None:
        return None
    p = base / (module.replace(".", "/") + ".lean")
    return p if p.exists() else None


def iter_ileans(include_stale=False):
    """Yield (ilean_path, parsed_json, source_path).  Stale entries are skipped by default."""
    for path in sorted(BUILD.rglob("*.ilean")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:  # pragma: no cover - corrupt artifact
            print(f"WARN: unreadable {path}: {exc}", file=sys.stderr)
            continue
        src = module_to_source(data.get("module", ""))
        if src is None and not include_stale:
            continue
        yield path, data, src


def parse_key(key):
    """`references` key -> (defining module, fully-qualified name), or (None, None)."""
    try:
        obj = json.loads(key)
    except Exception:
        return None, None
    c = obj.get("c")
    if not isinstance(c, dict):
        return None, None
    return c.get("m"), c.get("n")


# --- UTF-16 column arithmetic -------------------------------------------------

def u16_to_py(line, col):
    """Convert a 0-indexed UTF-16 code-unit column to a Python string index on `line`."""
    if col <= 0:
        return 0
    units = 0
    for i, ch in enumerate(line):
        if units >= col:
            return i
        units += 2 if ord(ch) > 0xFFFF else 1
    return len(line)


def stale_ileans():
    out = []
    for path, data, src in iter_ileans(include_stale=True):
        if module_to_source(data.get("module", "")) is None:
            out.append((path, data.get("module")))
    return out


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "summary"
    if cmd == "stale":
        for path, mod in stale_ileans():
            print(f"{mod}\t{path.relative_to(REPO)}")
    elif cmd == "summary":
        n_files = n_refs = n_usages = 0
        for _path, data, _src in iter_ileans():
            n_files += 1
            for _k, v in data["references"].items():
                n_refs += 1
                n_usages += len(v.get("usages") or [])
                if v.get("definition"):
                    n_usages += 1
        print(f"ilean files (live): {n_files}")
        print(f"reference entries:  {n_refs}")
        print(f"recorded ranges:    {n_usages}")
        print(f"stale ilean files:  {len(stale_ileans())}")
    elif cmd == "roots":
        for name, sd in module_roots():
            print(f"{name}\t{sd}")
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
