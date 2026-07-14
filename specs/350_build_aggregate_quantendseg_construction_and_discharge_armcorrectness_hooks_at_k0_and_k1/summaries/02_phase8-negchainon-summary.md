# Phase 8 Implementation Summary — HasAttainedSUP mirror + negChainOn

**Task**: 350 | **Plan**: plans/02_offdiag-k1-aggregate-discharge.md | **Phase**: 8 of 17
**Session**: sess_1783988294_843145 | **Date**: 2026-07-13
**Dispatch mode**: hard (single-phase, H1 per-phase dispatch)

## Phases Executed

Phase 8 only (per phase_number=8 dispatch contract). Phase marked [COMPLETED] in plan.

## Theorems/Definitions Delivered

| Declaration | File | Notes |
|---|---|---|
| `HasAttainedSUP` (structure) | Kamp/PriorINF.lean (append) | Attained last-occurrence surrogate for Dedekind sup; mirror of `HasAttainedINF` |
| `prior_hasAttainedSUP` | Kamp/PriorINF.lean | `semantic_prior_SZ → HasAttainedSUP`; fully mechanical mirror of `prior_hasAttainedINF` — R8 risk retired |
| `orderedPointsExist_combine` | Kamp/EANegationFix.lean (new) | Standalone extraction of the inline `h_combine_witnesses` from `neg_orderedPointsExist_is_vbracket` |
| `chainAllTrue` + `chainAllTrue_holds_iff` | Kamp/EANegationFix.lean | All-top-segment bracket from a `List TemporalPred`; definitional bridge to `orderedPointsExist` |
| `negChainOn` | Kamp/EANegationFix.lean | Rabinovich Lemma 5.3 fixed-formula On-builder (list recursion, attained simplification: K+ disjunct vacuous) |
| `negChainOn_iff` | Kamp/EANegationFix.lean | `HasAttainedINF → z0 < z1 → ((negChainOn Ps).holds ↔ ¬(chainAllTrue Ps).holds)` |

## Final Verification Results

| Gate | Result |
|---|---|
| Full `lake build` | GREEN (1739 jobs) |
| Sorries in touched files | 0 (census + git-diff cross-check: 0 added lines containing sorry) |
| Vacuous definitions | 0 |
| New axioms | 0 (the 2 repo `axiom` lines are pre-existing Boneyard, untouched) |
| `lean_verify` axioms | `prior_hasAttainedSUP`, `negChainOn_iff`, `orderedPointsExist_combine` = exactly `[propext, Classical.choice, Quot.sound]` |
| Plan compliance | All 5 Phase-8 checklist items checked; named identifiers exist |
| G6 territory guard | Respected — no edits to KampPrior.lean / ExteriorPinnedConverseK.lean / ExteriorPinnedConversePastK.lean |

## Sorry Inventory

Empty. Nothing introduced; empty inventory inherited from Phase 7 handoff.

## Plan Deviations (annotated inline in plan)

1. **nil base case**: plan text said `nil ↦ trivialTrue`; implemented `nil ↦ ⟨[]⟩` (empty
   disjunction = False). Machine-forced: the empty chain always exists
   (`orderedPointsExist_zero`), so its negation is False; trivialTrue contradicts the stated
   iff and the n=0 base of the pre-existing existential `neg_orderedPointsExist_is_vbracket`.
2. **Boneyard salvage unnecessary**: `VBracketFormula.prependAll` and
   `BracketFormula.prepend(_holds)(_holds_inv)` live in mainline EANegation.lean;
   `exists_permutation_cons_head` was not needed.
3. **Import set**: EANegationFix imports VecEAConjFull + EANegation (transitively PriorINF),
   rather than PriorINF directly.

## Key Insight

`negChainOn_iff` is a refactor, not new mathematics: EANegation.lean already carried the
Lemma 5.3 recursion machine-checked in existential form (`∃ v, ...`). Phase 8 names the
witness (`negChainOn`), which downstream Phases 9-11 need in order to recurse through it.
Proof reuses `prepend_holds`, `prepend_holds_inv`, `orderedPointsExist_decompose` verbatim.

## Commits

- 59d05c427 — task 350 phase 8.1: HasAttainedSUP mirror + prior_hasAttainedSUP (R8 probe)
- 68abf5178 — task 350 phase 8.2: negChainOn + negChainOn_iff (Lemma 5.3 fixed On-builder)
- c3d360d08 — task 350 phase 8.3: register EANegationFix on the root build
