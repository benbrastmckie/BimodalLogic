# Lean Module System: Evaluation

An evaluation of adopting the Lean module system (`module`, `public import`, `@[expose]`,
`meta import`) in this repository. It records what was tested on the pinned toolchain, what
adoption would cost here, and the order a future adoption programme should follow.

Nothing in this repository uses the module system. This document changes that for no file; it
exists so that whoever takes the programme up starts from measured constraints rather than from
recollection.

## Verdict

**Not now. Adopt it as its own programme, with a decision record first.**

- Adoption cannot be piloted locally. A `module` file cannot import a plain file, so conversion
  is bottom-up along the import graph from `FormalSystem/Init.lean`, and every one of the library's
  files sits above that root.
- It changes no citable name. Declaration names, namespaces and module paths all survive
  conversion, so publication gains nothing from doing it first; row 3a of the convention map in
  [PUBLICATION_REFACTOR.md](PUBLICATION_REFACTOR.md) already records the deliberate divergence.
- The scripted gate reads `import` lines textually. Those parsers must learn the new import forms
  *before* the first file is converted, or checks silently read an empty graph and pass.

The reasons it is eventually worth doing are in [Why it is worth doing eventually](#why-it-is-worth-doing-eventually).

## What was tested, and how

All three probes were run against this repository's own toolchain and build products
(Lean `v4.33.0-rc1`, Mathlib at tag `v4.33.0-rc1`, commit `79d0395a`), last re-run 2026-09-21.
Each is a scratch file outside the source tree, elaborated with the project's search path:

```
lake env lean Probe.lean
# with a second scratch module on the path:
LEAN_PATH="$(lake env printenv LEAN_PATH):$SCRATCH" lean --root=$SCRATCH [-o M.olean] M.lean
```

No experimental option or flag was needed to compile a `module` file on this toolchain.

### Probe 1: direction of adoption

```lean
module

public import FormalSystem.Init
```

Fails at line 1: ``cannot import non-`module` FormalSystem.Init from `module` ``. The converse
works: a plain file that imports a compiled `module` elaborates normally and sees its public
declarations.

### Probe 2: exposure of definition bodies

```lean
module

public def f (n : Nat) : Nat := n + 1

public theorem f_eq (n : Nat) : f n = n + 1 := rfl
```

Fails on the theorem: "Not a definitional equality ... This theorem is exported from the current
module. This requires that all definitions that need to be unfolded to prove this theorem must be
exposed." The same two declarations under a leading `@[expose] public section` compile.

### Probe 3: build artefacts and `private`

A compiled module emits `.olean`, `.olean.private`, `.olean.server`, `.ir` and `.ir.sig`. A plain
importer of that module resolves its `public def` and reports `Unknown identifier` for its
`private def`, exactly as `private` behaves today.

## Upstream adoption at the pinned tag

Counted with `grep -rlx 'module'` over `.lake/packages/` (2026-09-21, Mathlib commit `79d0395a`):

| Package | Files starting a `module` | `.lean` files |
|---------|---------------------------|---------------|
| Mathlib (`Mathlib/` only) | 8,199 | 8,268 |
| Batteries | 185 | 254 |
| Aesop | 135 | 250 |
| ProofWidgets | 42 | 46 |
| importGraph | 26 | 37 |

Within `Mathlib/`, 4,941 files open with `@[expose] public section` and 2,699 with a plain
`public section`; 531 lines are `meta import`, `public meta import` or `import all`. Upstream is,
for practical purposes, fully converted, and blanket exposure is the majority style.

`mk_all` already supports the module style: `.lake/packages/mathlib/scripts/mk_all.lean` takes a
`--module` flag and otherwise infers the style from the existing aggregator. A module-style root
begins `module  -- shake: keep-all --deprecated_module: ignore` and uses `public import` lines.

## The two binding constraints

1. **Bottom-up only.** Because a `module` cannot import a non-`module` (Probe 1), conversion must
   start at `FormalSystem/Init.lean` and `FormalSystem/ForMathlib/` and climb the import graph.
   `Tests/` and `BimodalTools/` sit at the top and can stay plain indefinitely, since plain files
   may import modules. A leaf-first pilot, or a one-directory pilot in the middle of the graph, is
   impossible. In particular, neither of the library's longest files could be converted on its own.
2. **Blanket exposure is the only mechanical route.** A public theorem proved by unfolding needs
   the unfolded definitions exposed (Probe 2). About 1,500 lines under `FormalSystem/` use
   `:= rfl`, `by rfl`, `by decide` or `native_decide` (1,497 by `grep`, 2026-09-21). Opening every
   converted file with `@[expose] public section` preserves today's behaviour; deciding per
   definition what to hide is a per-file judgement and belongs to a later refinement pass.

## Local cost inventory

Counts as of 2026-09-21 on the toolchain above. Each is a snapshot; re-derive before relying on it.

| Item | Count | Why it matters |
|------|-------|----------------|
| `.lean` files under `FormalSystem/` | 508 | All must convert, bottom-up, for the library to be a module library |
| `.lean` files under `Tests/` | 65 | May stay plain; must keep compiling against a module library |
| `.lean` files under `BimodalTools/` | 27 | As for `Tests/` |
| Top-level `private` declarations (`^private `) | 765 in `FormalSystem/`, 167 in `Tests/`, 62 in `BimodalTools/` | Meaning unchanged, but anything a test reaches into needs `import all` |
| Files with `elab` / `macro` / `syntax` / `initialize` / `register_simp_attr` | 14 | Need `meta import` / `public meta import` discipline for anything used at compile time |

Tooling that reads `import` lines as text, all of which must accept `public import`,
`meta import`, `public meta import` and `import all`, and must tolerate a leading `module` line:

- `scripts/lib/import_graph.py` — the shared leading-import parser. It stops at the first line
  that is not blank, a comment, `prelude` or an `import`; a leading `module` line would end the
  scan before any import is read, yielding an empty import list for that file. Its consumers
  inherit this: `scripts/check-metalogic-cycles.sh` and `scripts/measure-refactor-partitions.py`.
- `scripts/check-metalogic-cycles.sh` — also carries its own `^import FormalSystem.Metalogic...`
  regular expression for its first assertion.
- `scripts/check-module-invariants.sh` — several anchored `^import\s+...` expressions (the
  archive-import and tools-import checks, the import-resolution checks), and the build-free
  re-implementation of the root generator, which compares `FormalSystem.lean` byte-for-byte
  against plain `import` lines and would have to learn the module-style root.
- `scripts/move-modules.py` — its import-line rewrite class is anchored on `^(import\s+)`; its
  fixtures in `scripts/test-move-modules.py` are plain-import only.
- `scripts/reanchor-lean-citations.py` — recognises preamble lines by a keyword list that begins
  with `import`.

The failure mode to design against is a check that parses zero imports and therefore passes. Every
parser change needs a fixture that fails when the new forms are not recognised.

## Why defer

- **All or nothing.** 508 files, one direction, no partial landing that leaves the library
  coherent except a prefix of the import graph.
- **No publication benefit.** No declaration name, namespace or module path changes, so nothing a
  paper or a downstream user cites is affected either way.
- **Harness first.** Converting before the parsers are taught the new forms would weaken the gate
  exactly when the tree is changing most.

## Why it is worth doing eventually

- **Upstream has converted.** Plain-import consumers of a module ecosystem are the legacy path;
  tooling and documentation will increasingly assume modules.
- **Rebuild fan-out.** A non-exposed body can change without invalidating importers. This library's
  critical path includes a single proof that takes about two minutes to elaborate
  (`obtain_split_point_props` in
  `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean`), and any edit below it
  re-pays that cost today.
- **Honest interfaces.** `public` versus non-public is a checked statement of what a file offers,
  which the current `private`-only discipline cannot express for definitions that must stay
  nameable within a directory.

## Recommended programme order

1. **Decision record.** A new ADR under `docs/architecture/`, stating the blanket-exposure starting point
   and the plain status of `Tests/` and `BimodalTools/`.
2. **Parsers, with fixtures, while the tree is still plain.** Teach `scripts/lib/import_graph.py`
   and the other readers listed above the four import forms and the leading `module` line. The
   gate stays green throughout because the tree has not changed yet.
3. **Convert bottom-up** from `FormalSystem/Init.lean`, each file opening with
   `@[expose] public section`. Convert the 14 meta-code files early within their layer so that
   `meta import` questions surface before hundreds of dependents exist.
4. **Regenerate the root** with `lake exe mk_all --lib FormalSystem --module`, and update the
   build-free root check in `scripts/check-module-invariants.sh` to the module-style shape.
5. **Only then narrow exposure**, file by file, where a hidden body buys a measurable rebuild
   saving.

## Related documents

- [PUBLICATION_REFACTOR.md](PUBLICATION_REFACTOR.md) — convention-map row 3a and the optional
  post-publication phase that called for this evaluation.
- [MODULE_INVARIANTS.md](MODULE_INVARIANTS.md) — the scripted gate whose import parsers are
  inventoried above.
- [MODULE_RELOCATION.md](MODULE_RELOCATION.md) — `scripts/move-modules.py`, one of the import
  rewriters that must learn the new forms.
- [`ORGANISATION.md`](../../ORGANISATION.md) — "Module size": why long files are split along
  dependency seams, which is independent of this question.
