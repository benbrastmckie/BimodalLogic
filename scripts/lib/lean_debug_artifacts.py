"""Comment-aware debug-artifact scanner for the module-invariant harness (C27).

A debug directive (`#check`, `#eval`, `#print`, `#reduce`, `dbg_trace`, `dbgTrace`) that sits
inside a docstring usage block or a line comment is documentation, not a debug artifact, so a
plain line-anchored grep over-counts.  This module masks everything a Lean lexer would not treat
as live command text -- nested block comments (including `/--` docstrings and `/-!` module
docs), line comments, string literals (plain and raw) and character literals -- and only then
matches directives, one count per line.

The masker is the part that is easy to get wrong: a naive scanner that does not track string and
character-literal state lets a `"/-"` inside a string open a phantom comment that swallows the
rest of the file.  `self_test()` pins the tricky shapes, and the harness runs it before trusting
any count.
"""

import re

_CHAR_LIT = re.compile(r"'(?:\\(?:u\{[0-9a-fA-F]+\}|x[0-9a-fA-F]{2}|.)|[^'\\\n])'")
_IDENT_CHAR = re.compile(r"[A-Za-z0-9_'!?·-￿]")

# A directive at the start of a (masked) line, or immediately after an `in` combinator on the
# same line (`#guard_msgs in #eval ...`, `set_option ... in #check ...`).
DIRECTIVE = re.compile(r"(?:^\s*|\bin\s+)(#check|#eval|#print|#reduce)(?![A-Za-z0-9_'])")
DBG = re.compile(r"\b(?:dbg_trace|dbgTrace)\b")


def mask(text):
    """Return `text` with every comment, string and char literal replaced by spaces.

    Newlines are always preserved, so line numbers in the masked text match the source.
    """
    out = list(text)
    n = len(text)
    i = 0
    depth = 0  # block-comment nesting depth

    def blank(a, b):
        for k in range(a, b):
            if out[k] != "\n":
                out[k] = " "

    while i < n:
        c = text[i]
        if depth > 0:
            if text.startswith("/-", i):
                depth += 1
                blank(i, i + 2)
                i += 2
            elif text.startswith("-/", i):
                depth -= 1
                blank(i, i + 2)
                i += 2
            else:
                blank(i, i + 1)
                i += 1
            continue
        if text.startswith("/-", i):
            depth = 1
            blank(i, i + 2)
            i += 2
            continue
        if text.startswith("--", i):
            j = text.find("\n", i)
            j = n if j < 0 else j
            blank(i, j)
            i = j
            continue
        # Raw string r"..." / r#"..."#, only when `r` is not the tail of an identifier.
        if c == "r" and (i == 0 or not _IDENT_CHAR.match(text[i - 1])):
            m = re.match(r'r(#*)"', text[i:])
            if m:
                close = '"' + m.group(1)
                j = text.find(close, i + len(m.group(0)))
                j = n if j < 0 else j + len(close)
                blank(i, j)
                i = j
                continue
        if c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            j = min(n, j + 1)
            blank(i, j)
            i = j
            continue
        if c == "'" and (i == 0 or not _IDENT_CHAR.match(text[i - 1])):
            m = _CHAR_LIT.match(text, i)
            if m:
                blank(i, m.end())
                i = m.end()
                continue
        i += 1
    return "".join(out)


def count_lines(text):
    """(count, [line numbers]) of lines carrying a live debug directive."""
    hits = []
    for ln, line in enumerate(mask(text).split("\n"), 1):
        if DIRECTIVE.search(line) or DBG.search(line):
            hits.append(ln)
    return len(hits), hits


# Each fixture is (source, expected live-line count).  Every shape here is one a naive masker
# gets wrong in a direction that would either hide a live directive or invent one.
_FIXTURES = [
    ('#eval 1\n', 1),
    ('  #check Nat\n', 1),
    ('#print axioms foo\n', 1),
    ('#reduce 1 + 1\n', 1),
    ('#check_failure foo\n', 0),                         # a different command
    ('-- #eval 1\n', 0),                                 # line comment
    ('/-- doc\n#check foo\n-/\ndef x := 1\n', 0),        # docstring code block
    ('/-! module doc\n```lean\n#eval x\n```\n-/\n', 0),  # module doc code block
    ('/- outer /- inner -/ still\n#eval 1\n-/\n#eval 2\n', 1),  # nested comment
    ('def s := "/-"\n#eval s\n', 1),                     # `/-` inside a string
    ('def s := "--"\n#eval s\n', 1),                     # `--` inside a string
    ('def s := "a \\" /-"\n#eval s\n', 1),               # escaped quote then `/-`
    ("def c := '\"'\n#eval c\ndef d := \"/-\"\n#eval d\n", 2),  # '"' char literal
    ("theorem foo' : True := trivial\n#eval 1\n", 1),    # prime is not a char literal
    ('def r := r#"/- "#\n#eval r\n', 1),                 # raw string
    ('/-- info: 3 -/\n#guard_msgs in\n#eval 3\n', 1),    # guard on its own line
    ('/-- info: 3 -/\n#guard_msgs in #eval 3\n', 1),     # guard on the same line
    ('set_option pp.all true in #check Nat\n', 1),
    ('def f (x : Nat) := dbg_trace "hi"; x\n', 1),
    ('def g := dbgTrace "x" fun _ => 1\n', 1),
    ('def s := "#eval inside string"\n', 0),
    ('def t := "dbg_trace"\n', 0),
]


def self_test():
    """Return a list of (fixture index, expected, got) failures; empty means the masker is sound."""
    failures = []
    for k, (src, want) in enumerate(_FIXTURES):
        got, _ = count_lines(src)
        if got != want:
            failures.append((k, want, got))
    # Line numbers must survive masking.
    _, hits = count_lines('/- a\nb -/\n\n#eval 1\n')
    if hits != [4]:
        failures.append(("line-number preservation", [4], hits))
    return failures


if __name__ == "__main__":
    import sys
    bad = self_test()
    for b in bad:
        print("self-test failure:", b)
    sys.exit(1 if bad else 0)
