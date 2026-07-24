#!/usr/bin/env python3
"""Boneyard archive hygiene: #exit-after-imports + ARCHIVED-header normalization.

For each .lean file under the Boneyard roots:
  1. Remove any #exit lines occurring before the import block.
  2. Locate end of import block (last leading import line; no imports -> pos 0).
  3. Ensure a module docstring /-! ... -/ at that position whose first content
     line starts "ARCHIVED (Boneyard) — never compiled."; prepend marker into an
     existing docstring, else insert a minimal header.
  4. Ensure exactly one #exit immediately after that docstring (insert or
     relocate the first later #exit; additional later #exit tokens may remain).

Modes: census (default), dry-run FILE..., apply
"""
import sys
import os

ROOTS = [
    "Theories/Bimodal/Boneyard",
    "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard",
]
MARKER = "ARCHIVED (Boneyard)"
MARKER_LINE = ("ARCHIVED (Boneyard) — never compiled. "
               "Archived material; see the Boneyard README inventory.")
MIN_HEADER = [
    "/-!",
    MARKER_LINE,
    "Do not import from live code.",
    "-/",
]


def find_lean_files():
    out = []
    for root in ROOTS:
        for dirpath, _dirs, files in os.walk(root):
            for f in files:
                if f.endswith(".lean"):
                    out.append(os.path.join(dirpath, f))
    return sorted(out)


def is_exit(line):
    return line.strip() == "#exit"


def find_import_block_end(lines):
    """Return (insert_pos, first_import_idx). insert_pos = index just after the
    last leading import line, or 0 if no imports. Raises ValueError if the
    preamble contains something unexpected (manual review)."""
    first_import = None
    depth = 0
    i = 0
    while i < len(lines):
        l = lines[i]
        s = l.strip()
        if depth > 0:
            depth += s.count("/-") - s.count("-/")
            i += 1
            continue
        if l.startswith("import "):
            first_import = i
            break
        if s == "" or s.startswith("--") or s == "#exit":
            i += 1
            continue
        if s.startswith("/-"):
            depth += s.count("/-") - s.count("-/")
            i += 1
            continue
        # content line before any import: no-import file -> position 0
        return 0, None
    if depth != 0:
        raise ValueError("unclosed block comment in preamble")
    if first_import is None:
        return 0, None
    # advance through the contiguous import block (imports, blanks, #exit,
    # -- comments interleaved) up to the last import line
    last_import = first_import
    i = first_import
    while i < len(lines):
        s = lines[i].strip()
        if lines[i].startswith("import "):
            last_import = i
            i += 1
        elif s == "" or s == "#exit" or s.startswith("--"):
            i += 1
        else:
            break
    # only count trailing blanks/#exit/comments after last_import as content
    return last_import + 1, first_import


def docstring_span(lines, start):
    """If a module docstring /-! opens at index start, return (start, end)
    inclusive of the line containing the matching -/. Else None."""
    if not lines[start].lstrip().startswith("/-!"):
        return None
    depth = 0
    for i in range(start, len(lines)):
        s = lines[i]
        depth += s.count("/-") - s.count("-/")
        if depth <= 0 and i >= start:
            # closing found on this line (handles single-line docstrings too)
            if s.count("-/") > 0 or (i == start and depth == 0 and "-/" in s):
                return (start, i)
            if depth == 0 and "-/" in s:
                return (start, i)
        if depth == 0 and "-/" in s:
            return (start, i)
    raise ValueError("unclosed module docstring at line %d" % (start + 1))


def first_content_of_docstring(lines, span):
    """First non-blank content line inside the docstring (after stripping the
    leading /-! token)."""
    s0 = lines[span[0]].lstrip()
    rest = s0[3:].strip()  # after '/-!'
    if rest and rest != "-/":
        return rest
    for i in range(span[0] + 1, span[1] + 1):
        s = lines[i].strip()
        if i == span[1]:
            s = s.split("-/")[0].strip()
        if s:
            return s
    return ""


def next_nonblank(lines, i):
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    return i


def process(text):
    """Return (new_text, changed, notes)."""
    lines = text.split("\n")
    notes = []

    insert_pos, first_import = find_import_block_end(lines)

    # Rule 1: remove #exit lines before the import block / before insert_pos
    before = lines[:insert_pos]
    removed_pre = [l for l in before if is_exit(l)]
    if removed_pre:
        before = [l for l in before if not is_exit(l)]
        # collapse doubled blanks left behind
        collapsed = []
        for l in before:
            if l.strip() == "" and collapsed and collapsed[-1].strip() == "":
                continue
            collapsed.append(l)
        before = collapsed
        notes.append("removed %d pre-import #exit" % len(removed_pre))
    after = lines[len(lines[:insert_pos]):] if False else lines[insert_pos:]
    lines = before + after
    insert_pos = len(before)

    # Rules 2-3: docstring at insert_pos (skip blank lines)
    ds_start = next_nonblank(lines, insert_pos)
    span = None
    if ds_start < len(lines):
        span = docstring_span(lines, ds_start)
    if span is not None:
        first_content = first_content_of_docstring(lines, span)
        if not first_content.startswith(MARKER):
            # prepend marker inside existing docstring
            head = lines[span[0]]
            indent = head[: len(head) - len(head.lstrip())]
            rest = head.lstrip()[3:].strip()
            new = [indent + "/-!", indent + MARKER_LINE, indent + ""]
            if rest:
                new.append(indent + rest)
            lines = lines[: span[0]] + new + lines[span[0] + 1:]
            span = docstring_span(lines, span[0])
            notes.append("prepended marker into existing docstring")
    else:
        # insert minimal header at insert_pos, with a separating blank line
        header = list(MIN_HEADER)
        pre_blank = [] if (insert_pos == 0) else [""]
        # avoid doubling blanks
        if insert_pos > 0 and insert_pos <= len(lines) and \
                (insert_pos < len(lines) and lines[insert_pos].strip() == ""):
            pre_blank = [""]
            # consume nothing; just insert after
        lines = lines[:insert_pos] + pre_blank + header + lines[insert_pos:]
        span = (insert_pos + len(pre_blank),
                insert_pos + len(pre_blank) + len(header) - 1)
        notes.append("inserted minimal ARCHIVED header")

    # Rule 4: exactly one #exit immediately after the docstring
    after_ds = next_nonblank(lines, span[1] + 1)
    if after_ds < len(lines) and is_exit(lines[after_ds]):
        pass  # already conforming
    else:
        # relocate: remove the first later #exit if present
        for j in range(span[1] + 1, len(lines)):
            if is_exit(lines[j]):
                del lines[j]
                # collapse doubled blank
                if (j < len(lines) and j > 0 and lines[j].strip() == ""
                        and lines[j - 1].strip() == ""):
                    del lines[j]
                notes.append("relocated post-import #exit")
                break
        else:
            notes.append("inserted #exit")
        lines = lines[: span[1] + 1] + ["", "#exit"] + lines[span[1] + 1:]
        # ensure a blank line follows #exit if content follows directly
        k = span[1] + 3
        if k < len(lines) and lines[k].strip() != "":
            lines.insert(k, "")

    new_text = "\n".join(lines)
    return new_text, new_text != text, notes


def classify(path):
    text = open(path, encoding="utf-8").read()
    lines = text.split("\n")
    try:
        insert_pos, first_import = find_import_block_end(lines)
    except ValueError as e:
        return "UNPARSEABLE: %s" % e
    exit_before = any(is_exit(l) for l in lines[:insert_pos])
    ds_start = next_nonblank(lines, insert_pos)
    span = docstring_span(lines, ds_start) if ds_start < len(lines) else None
    marker = (span is not None and
              first_content_of_docstring(lines, span).startswith(MARKER))
    exit_ok = False
    if span is not None:
        j = next_nonblank(lines, span[1] + 1)
        exit_ok = j < len(lines) and is_exit(lines[j])
    has_any_exit = any(is_exit(l) for l in lines)
    if exit_before:
        exit_class = "exit-before-imports"
    elif has_any_exit:
        exit_class = "exit-after-imports"
    else:
        exit_class = "no-exit"
    conforms = (not exit_before) and marker and exit_ok
    return ("CONFORMS" if conforms else
            "%s|marker=%s|exit_after_docstring=%s" %
            (exit_class, marker, exit_ok))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "census"
    if mode == "census":
        counts = {}
        for p in find_lean_files():
            c = classify(p)
            key = c.split("|")[0] if c != "CONFORMS" else "CONFORMS"
            counts.setdefault(key, []).append(p)
        for k in sorted(counts):
            print("%-24s %d" % (k, len(counts[k])))
        for k in sorted(counts):
            if k.startswith("UNPARSEABLE"):
                for p in counts[k]:
                    print("  ", p, classify(p))
        print("TOTAL", sum(len(v) for v in counts.values()))
    elif mode == "list-nonconforming":
        for p in find_lean_files():
            c = classify(p)
            if c != "CONFORMS":
                print(p, "::", c)
    elif mode == "dry-run":
        import difflib
        for p in sys.argv[2:]:
            text = open(p, encoding="utf-8").read()
            new, changed, notes = process(text)
            print("=== %s (%s) ===" % (p, "; ".join(notes) or "no-op"))
            if changed:
                diff = difflib.unified_diff(
                    text.split("\n"), new.split("\n"),
                    fromfile=p, tofile=p + " (new)", lineterm="", n=2)
                print("\n".join(list(diff)[:60]))
    elif mode == "apply":
        n_changed = 0
        failures = []
        for p in find_lean_files():
            text = open(p, encoding="utf-8").read()
            try:
                new, changed, notes = process(text)
            except ValueError as e:
                failures.append((p, str(e)))
                continue
            if changed:
                open(p, "w", encoding="utf-8").write(new)
                n_changed += 1
        print("changed %d files" % n_changed)
        for p, e in failures:
            print("FAILED", p, e)
        sys.exit(1 if failures else 0)
    else:
        print("unknown mode", mode)
        sys.exit(2)


if __name__ == "__main__":
    main()
