# Phase 7 Handoff — Excise UntilSinceCoherence whole 6-declaration set

## Immediate Next Action

Phase 8 (final gate): full `lake build` + BimodalTest green, repo-wide 49-name orphan
sweep, keep-set liveness spot-check, census delta (expect 32 → 7), README reconciliation
(convert "Planned File Inventory" wording to actual in both Boneyard READMEs), write
summary, final commit.

## Current State

- Phases 1-7 complete. Phase 7: all 6 declarations of `Metalogic/Bundle/UntilSinceCoherence.lean`
  (two 3-link chains rooted at `backward_until_reflexive` / `backward_since_reflexive`) moved
  verbatim to `Theories/Bimodal/Boneyard/SorriedDeclExcisions/UntilSinceCoherence.lean`
  (imports verbatim, ARCHIVED docstring, `#exit`, code verbatim).
- Live file reduced to module docstring + retained 3-line import block (deviation, see below).
- `lake build` green (1789 jobs). Axiom gate byte-identical:
  `completeness_discrete` = [propext, Classical.choice, Quot.sound].
- Sorry census: UntilSinceCoherence 2 → 0. Cumulative in-scope: 32 → 7 expected at Phase 8.

## Key Decisions

- **Import block retained in reduced live file**: `ChronicleToCountermodelBasic.lean:3`
  imports this module (kept per SETTLED design); retaining the live file's own imports
  guarantees identical transitive imports for that importer, eliminating any build risk.
  Unused-import cleanup is follow-up-task territory per the sweep's existing convention.
- Post-excision non-Boneyard hits for the 6 names are exactly the two archival-note
  docstring lines in the reduced live file — comment hits, classified per Phase 6 precedent.
- Boneyard README rows for `UntilSinceCoherence.lean` (6 decls, 2 sorries) already accurate
  in both inventory tables; no edit needed this phase (Phase 8 reconciles "Planned" wording).

## Sorry Inventory

Empty. No sorries introduced; 2 removed (archive files are `#exit`-guarded, never built).
