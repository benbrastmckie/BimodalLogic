"""Leading-import graph over the live ``FormalSystem/`` and ``Tests/`` trees.

This module is the one place that turns a Lean file into its module name, a
module name back into a path, and a file's *leading* ``import`` block into a
list of edges.  ``scripts/measure-refactor-partitions.py`` builds every
structural measurement on top of it; ``scripts/check-metalogic-cycles.sh``
predates it and keeps its own regex, deliberately, because that script is a
single-subtree assertion with its own exit code.

Why the leading block, and not ``grep '^import'``
-------------------------------------------------

Lean only honours ``import`` commands before the first non-import command, so
the *leading* block is the whole import surface of a file.  A naive
``grep '^import'`` additionally matches usage examples inside module
docstrings -- the root aggregators carry ``import FormalSystem`` in a fenced
code block, and nine live files differ between the two readings -- and one of
those matches turns into a false self-cycle on the root module.  The parser
below skips the copyright comment, any block or line comment, and blank lines,
consumes ``import`` lines, and stops at the first line that is none of those.

The archive is excluded through ``live_walk.live_files``, which filters on the
``Boneyard`` directory *name* (ADR-005); nothing here re-implements that walk.
"""

import os
import re

try:  # imported with scripts/lib on sys.path, the way the harness does it
    from live_walk import line_count, live_files
except ImportError:  # imported as scripts.lib.import_graph from a test runner
    from .live_walk import line_count, live_files  # type: ignore[no-redef]

LIBRARY_ROOT = "FormalSystem"
TEST_ROOT = "BimodalTest"
TEST_DIR = "Tests"
LOCAL_PREFIXES = (LIBRARY_ROOT, TEST_ROOT)

_IMPORT_RE = re.compile(r"\bimport\s+([A-Za-z_][A-Za-z0-9_.]*)")


# ---------------------------------------------------------------------------
# module <-> path
# ---------------------------------------------------------------------------

def module_of(path):
    """``FormalSystem/Syntax/Formula.lean`` -> ``FormalSystem.Syntax.Formula``.

    Test files live under ``Tests/`` with the ``BimodalTest`` module root, so
    ``Tests/BimodalTest/Foo.lean`` -> ``BimodalTest.Foo``.  The root aggregator
    ``FormalSystem.lean`` maps to ``FormalSystem``.  Returns ``None`` for a path
    that is not a ``.lean`` file under either root.
    """
    p = os.path.normpath(path)
    if not p.endswith(".lean"):
        return None
    p = p[: -len(".lean")]
    if p.startswith(TEST_DIR + os.sep):
        p = p[len(TEST_DIR) + 1:]
    parts = p.split(os.sep)
    if parts[0] not in LOCAL_PREFIXES:
        return None
    return ".".join(parts)


def path_of(module):
    """Inverse of :func:`module_of`; the path may or may not exist on disk."""
    parts = module.split(".")
    base = TEST_DIR if parts[0] == TEST_ROOT else "."
    return os.path.normpath(os.path.join(base, *parts)) + ".lean"


def is_local(module):
    """True for a module under either local root (never Mathlib/Batteries)."""
    return module.split(".")[0] in LOCAL_PREFIXES


# ---------------------------------------------------------------------------
# leading import block
# ---------------------------------------------------------------------------

def leading_imports(path, local_only=False):
    """Every module named in the file's leading ``import`` block, in order.

    Comments (``--`` and nested ``/- ... -/``), blank lines and a ``prelude``
    line are skipped; the first line that is none of those and is not an
    ``import`` ends the block.  With ``local_only`` only ``FormalSystem.*`` and
    ``BimodalTest.*`` modules are returned.
    """
    out = []
    depth = 0
    with open(path, encoding="utf-8", errors="replace") as fh:
        for raw in fh:
            line = raw.strip()
            if depth > 0:
                depth += line.count("/-") - line.count("-/")
                continue
            if not line or line.startswith("--") or line == "prelude":
                continue
            if line.startswith("/-"):
                depth += line.count("/-") - line.count("-/")
                continue
            if line.startswith("import "):
                out.extend(_IMPORT_RE.findall(line.split("--")[0]))
                continue
            break
    if local_only:
        out = [m for m in out if is_local(m)]
    return out


# ---------------------------------------------------------------------------
# the graph
# ---------------------------------------------------------------------------

class ImportGraph:
    """Forward and reverse local-import edges over the live tree.

    ``modules`` maps each live module to its path; ``edges`` maps a module to
    the local modules its leading block imports (in file order, duplicates
    kept); ``reverse`` maps a module to the set of live modules that import it.
    A dangling import (a name with no file) appears in ``edges`` but not in
    ``modules`` -- C4 in the invariant harness is what reports those.
    """

    def __init__(self, roots=(LIBRARY_ROOT, TEST_DIR), include_root_file=True):
        files = []
        for r in roots:
            files.extend(live_files(r, ".lean"))
        if include_root_file and os.path.isfile(LIBRARY_ROOT + ".lean"):
            files.append(LIBRARY_ROOT + ".lean")
        self.modules = {}
        self.edges = {}
        self.reverse = {}
        for p in sorted(files):
            m = module_of(p)
            if m is None:
                continue
            self.modules[m] = p
            self.edges[m] = leading_imports(p, local_only=True)
        for src, tgts in self.edges.items():
            for t in tgts:
                self.reverse.setdefault(t, set()).add(src)
        self._closure_cache = {}

    def closure(self, module, exclude=frozenset()):
        """Transitive local imports of ``module`` (excluding itself).

        Modules in ``exclude`` are neither returned nor traversed through, so a
        caller can ask "what does the library need if these files did not
        exist".  Results are cached per ``(module, exclude)``.
        """
        key = (module, exclude)
        hit = self._closure_cache.get(key)
        if hit is not None:
            return hit
        seen = set()
        stack = [t for t in self.edges.get(module, ()) if t not in exclude]
        while stack:
            m = stack.pop()
            if m in seen or m in exclude:
                continue
            seen.add(m)
            stack.extend(t for t in self.edges.get(m, ()) if t not in seen and t not in exclude)
        seen.discard(module)
        self._closure_cache[key] = seen
        return seen

    def line_count(self, module):
        return line_count(self.modules[module])

    def under(self, prefix):
        """Live modules whose name is ``prefix`` or starts with ``prefix + '.'``."""
        return sorted(m for m in self.modules if m == prefix or m.startswith(prefix + "."))


# ---------------------------------------------------------------------------
# namespace reading (comment-aware, first declaration only)
# ---------------------------------------------------------------------------

_NAMESPACE_RE = re.compile(r"^\s*namespace\s+([A-Za-z_][A-Za-z0-9_.!?']*)", re.M)


def strip_comments(text):
    """Blank out ``--`` line comments and nested ``/- ... -/`` blocks.

    Newlines are preserved so line numbers survive; string literals are not
    modelled, which is adequate for finding a file's first ``namespace`` line.
    """
    out = []
    i, n, depth = 0, len(text), 0
    while i < n:
        two = text[i:i + 2]
        if depth > 0:
            if two == "-/":
                depth -= 1
                i += 2
            elif two == "/-":
                depth += 1
                i += 2
            else:
                out.append("\n" if text[i] == "\n" else " ")
                i += 1
            continue
        if two == "/-":
            depth += 1
            i += 2
            continue
        if two == "--":
            j = text.find("\n", i)
            if j < 0:
                break
            i = j
            continue
        out.append(text[i])
        i += 1
    return "".join(out)


def first_namespace(path):
    """The first ``namespace X`` outside comments, or ``None``."""
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = strip_comments(fh.read())
    m = _NAMESPACE_RE.search(text)
    return m.group(1) if m else None
