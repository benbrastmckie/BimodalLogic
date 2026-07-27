#!/usr/bin/env python3
"""Single-pass Lean 4 lexer that marks which characters are CODE.

Needed because the root-namespace rename must touch `namespace Bimodal`, `open Bimodal.X`,
`end Bimodal`, and `Bimodal.`-qualified term references, but must NOT touch the ~thousands of
prose mentions of "Bimodal" in docstrings and comments -- that string is also the name of the
LOGIC, and rewriting the prose would be wrong, not merely cosmetic.

Handles, in one pass:
  * `--` line comments (to end of line)
  * `/- -/` and `/-- -/` block comments, DEPTH-COUNTED -- Lean's block comments nest, so
    `/- outer /- inner -/ still outer -/` is ONE comment and no fixed-depth regex can track it
  * `"..."` string literals with backslash escaping

Returns a bytearray-like mask, one entry per character: True = code, False = comment/string.
This is the same technique `.claude/scripts/lean-sorry-census.sh` uses, reimplemented here so
the rename passes can consume the mask directly rather than a stripped copy.
"""


def code_mask(text):
    mask = [True] * len(text)
    i = 0
    n = len(text)
    depth = 0          # block-comment nesting depth
    in_line = False    # inside a `--` comment
    in_str = False
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if in_line:
            mask[i] = False
            if c == "\n":
                in_line = False
                mask[i] = True
            i += 1
            continue
        if depth > 0:
            mask[i] = False
            if c == "/" and nxt == "-":
                depth += 1
                mask[i + 1] = False
                i += 2
                continue
            if c == "-" and nxt == "/":
                depth -= 1
                mask[i + 1] = False
                i += 2
                continue
            i += 1
            continue
        if in_str:
            mask[i] = False
            if c == "\\":
                if i + 1 < n:
                    mask[i + 1] = False
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        # --- in code ---
        if c == "/" and nxt == "-":
            depth = 1
            mask[i] = mask[i + 1] = False
            i += 2
            continue
        if c == "-" and nxt == "-":
            in_line = True
            mask[i] = mask[i + 1] = False
            i += 2
            continue
        if c == '"':
            in_str = True
            mask[i] = False
            i += 1
            continue
        i += 1
    return mask


def sub_in_code(text, pattern, repl):
    """Apply `pattern.sub(repl, ...)` only where `code_mask` is True.

    Applied right-to-left so earlier match offsets stay valid.
    """
    mask = code_mask(text)
    out = text
    hits = 0
    for m in reversed(list(pattern.finditer(text))):
        if not all(mask[k] for k in range(m.start(), m.end())):
            continue
        out = out[: m.start()] + m.expand(repl) + out[m.end():]
        hits += 1
    return out, hits


def count_in_code(text, pattern):
    mask = code_mask(text)
    return sum(1 for m in pattern.finditer(text)
               if all(mask[k] for k in range(m.start(), m.end())))


if __name__ == "__main__":
    import re
    import sys
    pat = re.compile(sys.argv[1])
    for path in sys.argv[2:]:
        t = open(path, encoding="utf-8").read()
        c = count_in_code(t, pat)
        if c:
            print(f"{c}\t{path}")
