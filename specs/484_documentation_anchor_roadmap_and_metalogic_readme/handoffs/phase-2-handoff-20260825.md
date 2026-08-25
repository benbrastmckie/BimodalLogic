# Phase 2 handoff (ROADMAP A2/A3 + D2)

**Next action**: Phase 3 — ROADMAP A4, `completeness_dedekind` at the C2-axiom-baseline block
(now `specs/ROADMAP.md:357-359` after Phase 1's +9 line shift; the plan cites `:348-350`).

**State**: headline `:15-19` now "45 axiom constructors in nine layers"; `## BX Axiom System`
intro rewritten and re-anchored on `Axioms.lean:571-582`; layer table rebuilt as ten sections
across nine layers.

**Verified at implementation time** (script cross-check, not transcription): the 45 rows in the
table are exactly the 45 `inductive Axiom` constructors, every `Axioms.lean:NN` citation matches
the enumerated line, no duplicates, no phantoms. Per-layer 4/5/18/4/1/5/2/1/2/3 = 45.

**Divergences from research report §3.2** (source won):
- References are at `Axioms.lean:72-74`, not `:55-59`.
- Reynolds 1992 is cited inline at `:426`/`:437`/`:449`, not `:309`.
Constructor names and all 45 line numbers matched the report exactly.

**Note**: `42` survives at `ROADMAP.md:377` only as an explicit quotation of the stale
`Axioms.lean:58`/`:84` docstrings, labelled stale.
