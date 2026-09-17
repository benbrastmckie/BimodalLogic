# ADR-009: The Archive Ships, and Says Why

## Status

**Accepted** - 2026-09-07

## Context

`FormalSystem/Boneyard/` holds 168 archived `.lean` files totalling 91,539 lines — roughly a
quarter of the repository by line count, and the only place in the tree where a `sorry` appears
in proof position. A reader encountering it for the first time reasonably asks two questions:
does this code affect the results, and why is it here at all?

The first question already has a machine-checked answer. The archive is excluded from the build
by construction, not by convention: `lakefile.toml`'s `lean_lib FormalSystem` roots only
`FormalSystem`, nothing under a `Boneyard` directory is reachable from any Lake root, and a full
`lake build` produces **zero** `.olean` files under any `Boneyard` path out of 546 built. Check
**C3** independently asserts that the structural `sorry` count across the live tree is **zero**;
check **B0** asserts that exactly one `Boneyard` directory exists and that excluding it removes a
non-zero count (168 of 646 files). [ADR-005](ADR-005-Single-Boneyard.md) records why the
exclusion filters on the directory *name* rather than a path prefix, which is what makes those
assertions robust against a second archive appearing.

The second question had no recorded answer. The tree simply shipped, undecided and unexplained —
which is the worst of the available states, because it leaves a reviewer to guess whether the
archive is deliberate curation or accumulated neglect.

Three dispositions were available: keep the archive as-is with a clearer framing, split it
(retaining the subtrees with provenance value and cutting the rest), or cut it entirely with the
history preserved in git and a pointer recorded.

## Decision

**Keep the archive, and repair the documentation that describes it.**

### Why not CUT ENTIRELY

Cutting is not merely undesirable; it is unavailable at acceptable cost. The archive is cited
from 96 files outside itself, and those citations are load-bearing rather than incidental:

- **The published prose depends on it.** `latex/subfiles/04-Metalogic.tex` cites the archive
  twice, at lines 383 and 389, in the course of explaining which completeness routes are current
  and which are historical record. Cutting the tree would leave the paper pointing at nothing.
- **45 live `.lean` files name it in their docstrings**, usually to explain why a definition has
  the shape it does — the alternative was tried, and where it went.
- **Two gates already govern it.** C11 asserts that all 536 archived import lines in all 168
  archived files resolve (7 waived in `scripts/boneyard-import-waivers.txt`); B0 asserts the
  single-archive invariant. Both would have to be retired, and with them the only mechanism
  preventing the archive from silently rotting while it exists.

Deleting a tree that the published paper cites, that 45 live files reference, and that two
enforced checks maintain is not a cleanup. It is the removal of evidence.

### Why not SPLIT

Splitting sounds like the balanced option and is not. Measured against the archive's actual
composition, the subtrees with no provenance value are a rounding error: the candidates for
cutting amount to roughly 2% of the archive's lines. Against that, splitting costs ADR-005's
single-archive invariant — the property that B0 asserts and that exists precisely because this
repository has already been burned once by a second archive silently counting as live code.

Worse, the largest single split candidate records a *refuted* approach. That is the category with
the **most** scholarly value, not the least: a formalization's record of what was tried and shown
impossible is often more useful to a subsequent researcher than the route that happened to work.
Splitting would preferentially delete the most valuable material while surrendering a gate.

### What KEEP obliges

Keeping is not the null action. It carries four obligations, all of which this decision commits
to:

1. **Counts are generated, never typed.** The archive's own README is the single source for its
   counts, and those counts are produced by `scripts/check-module-invariants.sh --emit-inventory`
   and gated by `INV`, exactly as every other README in the tree already is. Before this
   decision, the archive was the one tree the inventory generator could not see, and three
   different hand-typed file counts disagreed with each other and with the filesystem.
2. **Provenance is keyed to durable anchors.** Archival events are recorded by date and commit
   SHA — anchors an external reader of a published formalization can actually follow — not by
   repository-internal identifiers that resolve only against `specs/`.
3. **The archive describes all of itself.** Every top-level subtree is classified by the archival
   reason taxonomy and has a subdirectory detail entry, and every subtree has its own README.
4. **The framing leads with the machine-checked facts.** The archive README opens by stating what
   the tree is, that no `.olean` is produced under any `Boneyard` path, that the live tree's
   structural sorry count is zero while the archive carries every `sorry` in the repository *by
   design*, and that both facts are asserted by named checks rather than by prose.

## Consequences

- The archive's size stops being a red flag and becomes what it is: a governed quarantine whose
  inertness is asserted by C1/C3/B0/C11 rather than promised.
- `FormalSystem/Boneyard/README.md` becomes the sole surface stating any archive count, extending
  ADR-005 decision 4 from a convention to a gate-enforced one. Other surfaces link rather than
  restate.
- The inventory generator's markdown walk now includes the archive. Previously it pruned
  `Boneyard` outright, which is the mechanical reason the archive's counts drifted while every
  other README's stayed correct.
- Retired-attempt provenance ships as part of the formalization's contribution. A reader who
  wants to know whether an approach was tried can find out, with the reason it failed recorded
  next to the code that failed.
- Nothing is deleted. Should a future decision revisit this, the material is intact and the git
  history is unrewritten.

## Related

- [ADR-005](ADR-005-Single-Boneyard.md) — one archive, excluded by directory name (B0, C11)
- [`FormalSystem/Boneyard/README.md`](../../FormalSystem/Boneyard/README.md) — the archive's own
  framing, counts, taxonomy and provenance
- `scripts/check-module-invariants.sh` — B0, C1, C3, C11, `--emit-inventory` / `INV`
- `scripts/boneyard-import-waivers.txt` — the 49 recorded C11 waivers
