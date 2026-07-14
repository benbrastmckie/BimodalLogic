# Phase 8 Handoff — HasAttainedSUP mirror + negChainOn (task 350)

**Date**: 2026-07-13
**Session**: sess_1783988294_843145
**Dispatch**: hard-mode single-phase (phase_number=8)
**Status**: Phase 8 COMPLETED (8/17 phases done)

## Immediate Next Action

Dispatch Phase 9 (B / P2b): `negBoundedRightFix(_iff)` + `negBoundedLeftFix(_iff)`
(Cor 5.4(1)/(2) fixed-formula mirrors) in `Kamp/EANegationFix.lean`. Depends on Phase 8
(now delivered). Phase 12 (D / P3-pt, AggregatePointMergeK1.lean) remains file-disjoint
and parallelizable.

## Current State

- Full `lake build` green (1739 jobs). Zero sorries in all files touched this dispatch.
- Axiom checks (`lean_verify`): `prior_hasAttainedSUP`, `negChainOn_iff`,
  `orderedPointsExist_combine` = exactly `[propext, Classical.choice, Quot.sound]`.
- Commits: 59d05c427 (8.1 SUP mirror), 68abf5178 (8.2 negChainOn kit),
  c3d360d08 (8.3 aggregator import).
- G6 territory respected: no edits to KampPrior.lean, ExteriorPinnedConverseK.lean,
  ExteriorPinnedConversePastK.lean.

## Delivered API (for Phase 9/10 consumers)

| Declaration | Location | Shape |
|---|---|---|
| `HasAttainedSUP` | PriorINF.lean (append) | structure; `last_occ`: attained last occurrence in (z0,z1), ¬P on (r0,z1), P(r0) |
| `prior_hasAttainedSUP` | PriorINF.lean | `semantic_prior_SZ → HasAttainedSUP` (mechanical mirror of `prior_hasAttainedINF`; K- case vacuous) |
| `orderedPointsExist_combine` | EANegationFix.lean | first witness r + shifted tail chain on (r,z1) → full chain on (z0,z1); standalone extraction of the inline `h_combine_witnesses` from EANegation.lean |
| `chainAllTrue Ps` | EANegationFix.lean | `BracketFormula Ps.length` = all-top-segment bracket from list `Ps`; `chainAllTrue_holds_iff` bridges to `orderedPointsExist` (`Iff.rfl`) |
| `negChainOn : List TemporalPred → VBracketFormula` | EANegationFix.lean | Lemma 5.3 fixed On-builder: `[] ↦ ⟨[]⟩`; `P::rest ↦` never-P `[¬P]` disjunct :: `prependAll ¬P P (negChainOn rest)` |
| `negChainOn_iff` | EANegationFix.lean | `(h_INF : HasAttainedINF) → z0 < z1 → ((negChainOn Ps).holds ↔ ¬(chainAllTrue Ps).holds)` |

## Key Decisions

1. **nil base = empty disjunction, NOT trivialTrue** (plan deviation, annotated in plan):
   the empty chain always exists (`orderedPointsExist_zero`), so its negation is False;
   the empty disjunct list `⟨[]⟩` is the False `VBracketFormula`. trivialTrue is
   machine-refuted by the stated iff (and by the n=0 base of the pre-existing existential
   `neg_orderedPointsExist_is_vbracket`, EANegation.lean:356-361).
2. **Refactor, not reinvention**: `negChainOn_iff` is a list-induction refactor of the
   already-green existential `neg_orderedPointsExist_is_vbracket` (EANegation.lean:347-509),
   reusing `BracketFormula.prepend_holds`, `prepend_holds_inv`,
   `orderedPointsExist_decompose` verbatim. Only new proof mass: the standalone
   `orderedPointsExist_combine` (previously inline).
3. **Mainline prependAll, not Boneyard**: `VBracketFormula.prependAll` lives in
   EANegation.lean:333 (mainline); no Boneyard salvage was needed.
   `exists_permutation_cons_head` was not needed for this construction.
4. **List indexing via `Ps.get`** (Fin-indexed): matches NfDepth0Generalized.lean
   convention; all cons/succ reductions were definitional (no simp friction).
5. `EANegationFix.lean` imports `VecEAConjFull` + `EANegation` (the latter transitively
   supplies PriorINF); registered on root build via NfMultiAnchorBridge.lean import line
   with cycle-free NOTE (same pattern as Phase 7.2, c7082617b).

## Sorry Inventory

`[]` (empty — nothing introduced, nothing inherited; repo-wide pre-existing debt in other
subsystems is untouched and out of task scope).

## References

- Plan: `specs/350_.../plans/02_offdiag-k1-aggregate-discharge.md` (Phase 8 marked COMPLETED with inline deviation annotations)
- Rabinovich Lemma 5.3 grounding: `~/Projects/Literature/sources/rabinovich_2014/chunk_0014.md` md:3-41
