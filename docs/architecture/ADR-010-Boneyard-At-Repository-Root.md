# ADR-010: The Archive Moves to the Repository Root

## Status

**Proposed** - 2026-09-19

Supersedes the *location* clause of [ADR-009](ADR-009-Boneyard-Retention.md) and retires one of
its three "why not cut" rationale bullets. ADR-009's retention decision, its four obligations
and its "why not split" argument are untouched and remain in force. ADR-009 stays **Accepted**
until this record is; the publication refactor programme's Boneyard phase
(`docs/development/PUBLICATION_REFACTOR.md`) is what accepts it.

## Context

ADR-009 decided that the archive ships. It did not decide *where*: `FormalSystem/Boneyard/` was
where the two archives happened to be consolidated under [ADR-005](ADR-005-Single-Boneyard.md),
and the question of placement was never separately put.

Two things have changed since.

**The location is now load-bearing.** The publication programme adopts Mathlib's
`lake exe mk_all --check`, which demands that the root aggregator import *every* `.lean` file
under the library root. cslib's own archive README argues that this is exactly why its `Boneyard/`
is a sibling of `Cslib/` rather than a child: an archive under the library root would be demanded
in the aggregator, and so pulled into the build, the linters and every census. The same holds
here. With the archive under `FormalSystem/`, `mk_all --check` cannot be adopted at all; with it at
the root, the check is one CI step. A root-level archive also keeps `FormalSystem.Boneyard.*` out
of the library's module namespace and out of generated API documentation, which currently lists
169 modules that are never built.

**One of ADR-009's three rationale bullets cites a frozen artefact.** "The published prose
depends on it" points at `latex/subfiles/04-Metalogic.tex`, and `latex/README.md` now marks the
whole LaTeX edition as a superseded reference edition that is not kept in sync with the Lean
source. A rationale that rests on a document the repository has itself frozen is not a live
rationale. The live justification is the maintained typst manual, which cites the archive from
5 of its source files, together with the 48 live `.lean` docstrings, 43 markdown files and about
a dozen scripts that name it. ADR-009's other two bullets stand unchanged.

## Decision

1. **Retention stands.** Nothing in ADR-009's "why not cut" and "why not split" arguments, nor in
   its four obligations (generated counts, durable provenance anchors, self-description, and
   machine-checked framing), is revisited. The archive still ships, and still says why.

2. **The archive moves to the repository root**, from `FormalSystem/Boneyard/` to `Boneyard/`,
   as a sibling of `FormalSystem/`, `Tests/`, `docs/` and `typst/`. Its module names change from
   `FormalSystem.Boneyard.*` to `Boneyard.*`. Nothing under it is ever built, so this is a
   change of module *name* only, never of a compiled artefact; the `#exit` guard at the top of
   every archived file is unchanged.

3. **The move is scripted, never hand-edited.** The 538 archived `import FormalSystem.*` lines,
   the 48 live docstrings, the 43 markdown files, the scripts and the typst sources are rewritten
   by the programme's module-move tool in a single commit, and that commit ends with
   `bash scripts/check-module-invariants.sh` green. This is the same answer ADR-006 asked for
   before any large relocation: one audited tool rather than a half-updated tree.

4. **The LaTeX rationale bullet is retired.** ADR-009's "the published prose depends on it" is
   replaced by the typst manual's citations as the live justification. The frozen LaTeX file's
   two citations of the archive are historical text; the programme's deliverable-hygiene phase
   retires the frozen edition from the tracked tree, and this record does not depend on it.

5. **C11 stays enforced.** cslib's archive policy reads "import lines inside archived files are
   historical text, not build edges; stale imports are cosmetic", and it runs no resolution
   check. This repository deliberately diverges: C11 asserts that every archived import resolves
   or is waived (`scripts/boneyard-import-waivers.txt`), because the same move tool that
   relocates live modules rewrites the archive's imports as a side effect, so keeping the
   provenance pointers correct costs nothing extra. Dropping C11 would surrender a gate for no
   saving.

### What the gate changes

The invariant harness asserts the archive's inertness today through B0 and C11, and both are
written against the current location. Accepting this record changes them as follows, and adds
two invariants cslib's `check-boneyard-quarantine.sh` inspired:

| Check | Today | After the move |
|---|---|---|
| B0 | `find FormalSystem -type d -name Boneyard` must find exactly 1 directory | The same search over the whole repository (excluding `.lake/`, `.git/`) must find exactly 1, and it must be the root-level `Boneyard/` |
| B0 (load-bearing half) | Archived `.lean` count under `FormalSystem/` is non-zero | Archived `.lean` count under `Boneyard/` is non-zero, and the live walk over `FormalSystem/` finds none |
| C11 | Scans `FormalSystem/Boneyard/**` for `import FormalSystem.*` / `import BimodalTest.*` | Scans `Boneyard/**`; the same resolution rule and the same waiver file |
| New | — | `Boneyard` appears nowhere in `lakefile.toml` and nowhere in the root aggregator `FormalSystem.lean` |
| New | — | No live `.lean` file under `FormalSystem/` or `Tests/` imports `Boneyard.*` (today: zero live files import `FormalSystem.Boneyard.*`, so this starts green) |

`scripts/lib/live_walk.py` keeps filtering on the directory *name* (ADR-005's rule); the name
does not change, so every traversal that uses it is correct before and after the move without
edit. The archive's own README stays the single source of its counts (ADR-005 decision 4,
ADR-009 obligation 1), regenerated by `--emit-inventory` from the new location.

## Consequences

- `lake exe mk_all --check` becomes adoptable: every file under `FormalSystem/` is then a live
  module the aggregator must import, and the programme's CI-parity phase can wire it in.
- Generated API documentation and the library's module namespace no longer carry 169 modules
  that are never built.
- Every citer of the archive changes path once, in one scripted commit, before publication;
  this is a **[CITE]** change in the programme's sense and lands before the first release tag.
- The five ADR-009 obligations and gates (B0, C11, `INV`, the archive README, the waiver file)
  survive with their scan roots moved; none is retired.
- A future archive is a subdirectory of the root `Boneyard/`, never a new `Boneyard/` elsewhere;
  B0 enforces this exactly as it does today, one directory up.

## Related

- [ADR-005](ADR-005-Single-Boneyard.md) — one archive, excluded by directory name; unchanged by
  this record, its name-glob rule is what makes the move safe for every traversal
- [ADR-009](ADR-009-Boneyard-Retention.md) — retention and the four obligations; this record
  supersedes its location clause and one rationale bullet only
- [`FormalSystem/Boneyard/README.md`](../../FormalSystem/Boneyard/README.md) — the archive's own
  framing and counts (this path is the *current* one; it moves with the archive)
- `scripts/check-module-invariants.sh` — B0, C11, `--emit-inventory` / `INV`
- `docs/development/PUBLICATION_REFACTOR.md` — the programme phase that performs the move and
  accepts this record
