# ADR-005: One Archive, Excluded by Directory Name

## Status

**Accepted** - 2026-09-07

## Context

Archived Lean code lived in **two** places: `Boneyard/`, and a second archive nested
several levels down, inside the `Kamp/` subtree of `Metalogic/WeakCanonical/`.

Every count of the tree's size is produced by a `find` filter that excludes the archive. A filter
naming only the top-level directory — the obvious way to write it — silently counted the nested
archive as live. That is not a hypothetical failure: repeated past descriptions of this
repository's size were wrong for exactly this reason, and the error was invisible because the
number always looked plausible.

The defect is structural, not clerical. Any filter written as a *path prefix* is correct only for
the archives that happen to exist when it is written, and a new nested archive silently breaks
every count in the repository at once.

## Decision

1. **Consolidate.** The archives are merged into a single tree at `Boneyard/`; the
   former `Kamp/Boneyard/` now lives at `Boneyard/Kamp/KampWeakCanonical/`.
2. **Filter on the directory NAME, never a path prefix.** Every traversal in
   `scripts/check-module-invariants.sh` excludes `*/Boneyard/*` by name glob, so a second archive
   appearing anywhere under `FormalSystem/` is excluded from live counts automatically rather
   than leaking into them.
3. **Assert the count.** Check **B0** asserts the number of directories named `Boneyard` under
   `FormalSystem/` is exactly **1**, and additionally proves the exclusion is load-bearing by
   requiring the archived file count to be non-zero. A second archive reappearing fails the gate
   instead of silently splitting the counts again.
4. **State the archive's own counts in exactly one place** —
   [`Boneyard/README.md`](../../Boneyard/README.md). No other surface
   restates them.

## Consequences

- Live and archived counts are generated, never hand-typed: `--emit-inventory` writes them into
  the registered README tables and the `INV` check fails if any has drifted.
- The single-name-glob rule is what makes the generator correct by construction. It is
  implemented once, in `scripts/lib/live_walk.py`, and shared by the C4-C11 graph checks and the
  inventory generator, so those two can never disagree about what "live" means.
- A future archive must be a subdirectory of `Boneyard/`, not a new `Boneyard/`
  elsewhere. B0 enforces this.

## Related

- `scripts/check-module-invariants.sh` — B0, C7, `--emit-inventory`
- [`FormalSystem/README.md`](../../FormalSystem/README.md) — "Counting Live Files"
- [`FormalSystem/Metalogic/README.md`](../../FormalSystem/Metalogic/README.md) — "Counting Live Files"
