# Research Report: Task #84 — Until/Since Coherence Blockers

**Task**: 84 — Establish Until/Since Coherence for Bundle Completeness
**Date**: 2026-04-08
**Mode**: Team Research (3 teammates)
**Session**: sess_1775671193_0aef6e

## Summary

Three teammates investigated the X-vs-G mismatch blocker from complementary angles: (A) codebase trace of the mismatch origin, (B) task 83 alternative approaches review, (C) quasimodel analysis and synthesis. The core finding is that **the X-vs-G mismatch is a legacy artifact of incomplete BX migration, and the backward Until/Since direction is immediately closable** via a derivation that all three teammates independently identified.

## Key Findings

### 1. X Is Trivial Under BX Reflexive Semantics (HIGH confidence)

`X(phi) = bot U phi` is a derived operator. Under BX8 (`psi -> phi U psi`) and BX9 (`phi U psi -> phi or psi`):
- BX9: `bot U alpha -> bot or alpha = alpha`
- BX8: `alpha -> bot U alpha`

So `X(alpha) <-> alpha` in any MCS. **X adds no information under reflexive Until semantics.** The user's intuition is confirmed: X and Y should not appear in the general completeness path, and they are incompatible with density (X-K and X-Det axioms require discrete structure, currently sorry-blocked in TemporalContent.lean:274,306,351,415).

### 2. The X-vs-G Mismatch Is a Legacy of Incomplete BX Migration (HIGH confidence)

The old strict axiom system used `until_unfold: (phi U psi) -> X(psi or (phi and (phi U psi)))`, producing an X-wrapped formula. The BX refactoring replaced the axioms but left downstream consumers using X-based patterns. Multiple sites have `sorry /- removed in BX -/` markers confirming incomplete migration.

Under BX, the correct unfolding uses BX5 (self-accumulation) + BX9 (elimination) to get:
```
(phi U psi) -> (psi or (phi and (phi U psi)))
```
This is a **current-time disjunction**, not a next-step obligation. No X needed.

### 3. `until_intro` IS Derivable from BX Axioms (HIGH confidence, 90%)

The critical breakthrough identified by teammates B and C independently:

1. `X(alpha) -> alpha` is derivable (see finding 1 above)
2. `or_until_in_mcs` is already proved sorry-free at `SuccRelation.lean:578-594`: `(psi or (phi and (phi U psi))) in M -> (phi U psi) in M`
3. Composing: `X(psi or (phi and (phi U psi))) -> (psi or (phi and (phi U psi))) -> (phi U psi)`

This gives `until_intro`. Symmetrically, `since_intro` follows from BX8' + BX9' + `or_since_in_mcs`.

### 4. Backward Until/Since Is Closable NOW (~200 LOC, 90% confidence)

The Boneyard `DeterministicFMCS.lean:340-440` has complete backward Until/Since proofs using induction on chain distance, with only two sorry sites where `until_intro`/`since_intro` were removed. With the derivation above, these close immediately. The proof works for ANY chain with the successor relation — deterministic, enriched, or dovetailed.

### 5. Forward Until via Enriched Seed Is Viable (65-85% confidence)

The enriched seed approach (pull-before-push):
- Seed: `g_content(w_n) union {phi U psi : (phi U psi) in w_n and psi not in w_n}`
- Consistency: Under BX1, `g_content(w_n) subset w_n`. Active Untils in `w_n`. So enriched seed subset `w_n`.
- BX5 self-accumulation keeps Until formulas alive at each step without G-liftability
- Dovetailed scheduling eventually resolves each witness
- Guard extraction: BX9 gives `phi in w_r` for intermediate r where `psi not in w_r`

**Key risk**: Joint consistency of `{dovetailed_target} union g_content(w_n) union active_untils`. Standard G-lift covers `{target} union g_content`. Active Untils are in w_n and added after G-lift.

### 6. Negation Unfolding Strategy Is INVALID (HIGH confidence)

Task 83 implementation found a countermodel disproving the derivation `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))`. Do NOT pursue this approach.

### 7. Tuple/Quasimodel Approaches Are Not Recommended

- **Quasimodels**: Standard construction (GHR 1994) requires reflexive G semantics for the meta-to-object conversion. The BX system has reflexive G (BX1), but the existing chain constructions still use strict-era patterns. Quasimodel ideas inform the approach but don't provide a ready-made solution.
- **Tuple approach**: Reinvention of quasimodel with constraint-satisfaction framing. Duration resolution is provably satisfiable, but Until/Since handling is explicitly underspecified — same guard persistence gap exists. Cost: 1500-2000 LOC vs 600-1000 for enriched seed. Not recommended as primary approach.

## Synthesis

### Conflicts Resolved

1. **Quasimodel applicability**: Teammate C initially stated quasimodels fail due to "strict temporal semantics," but also noted BX has reflexive G (BX1). Resolution: the BX framework IS reflexive, but the chain constructions haven't been updated to exploit this. The mismatch is in the implementation, not the axioms. Quasimodel ideas are relevant but don't provide a drop-in solution because the existing infrastructure uses a different architecture.

2. **Backward Until confidence**: Teammate B rated backward Until at 55% (matching report 02), while Teammate C rated it at 90% after discovering the `until_intro` derivation. Resolution: **Teammate C's higher confidence is justified** — the derivation from BX8+BX9 via `or_until_in_mcs` is straightforward, and the Boneyard proof is complete modulo this one gap.

### Gaps Identified

1. **Forward Until joint seed consistency**: The three-way consistency of `{target} union g_content union active_untils` needs explicit verification. The standard G-lift argument covers two-way; the third component (active Untils) is subset of w_n so should not interfere, but a formal argument is needed.

2. **Port compatibility**: The Boneyard backward proofs use the deterministic chain's `x_content` successor relation. Porting to the enriched/dovetailed chain requires showing the backward induction still works with the different successor structure.

3. **Line 322 circular dependency**: The sorry at line 322 also needs `temporally_coherent` (sorry at line 239). The backward Until proof via DeterministicFMCS may not directly apply if TC is also sorry. Lines 356 and 450 have sorry-free TC.

### Recommendations

**Revised Implementation Strategy (3 phases)**:

**Phase 1 — Derive until_intro + Port backward proofs** (~200 LOC, 90% confidence)
1. Derive `until_intro` from BX8+BX9 via `or_until_in_mcs` composition
2. Derive `since_intro` symmetrically
3. Port `backward_until_chain` and `backward_since_chain` from DeterministicFMCS
4. Close Boneyard sorry sites at DeterministicFMCS lines 371, 395, 427, 451
5. Verify the backward proofs work for the enriched/dovetailed chain

**Phase 2 — Forward Until/Since via enriched dovetailed chain** (~400-600 LOC, 65% confidence)
1. Replace `until_unfold_in_mcs` with BX-native derivation (BX5+BX9, no X)
2. Build enriched seed with Until persistence for dovetailed chain
3. Prove forward_until and forward_since for dovetailed construction
4. Target line 450 first (has sorry-free TC)

**Phase 3 — Fallback: split definition** (~300 LOC refactoring, 80% confidence)
If Phase 2 stalls, split `until_since_coherent` into forward and backward halves. Close backward for all paths immediately. Leave forward as a more precisely scoped sorry.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | X-vs-G mismatch origin | completed | Traced X as derived operator; confirmed incomplete BX migration; identified BX5+BX9 replacement for until_unfold |
| B | Task 83 approaches review | completed | Full technical extraction of pull-before-push and tuple approaches; countermodel invalidation of negation strategy; backward Until strategy comparison |
| C | Quasimodel + synthesis | completed | Discovered `until_intro` derivability from BX8+BX9; proposed 3-phase implementation; identified port compatibility gap |

## References

- `SuccRelation.lean:558-594` — `or_until_in_mcs` (key backward Until building block)
- `SuccRelation.lean:514-531` — `until_unfold_in_mcs` / `since_unfold_in_mcs` (sorry, needs BX-native replacement)
- `DeterministicFMCS.lean:338-440` — backward Until/Since proofs (Boneyard, modulo until_intro)
- `TemporalCoherence.lean:466-479` — `until_since_coherent` definition
- `TemporalContent.lean:274-415` — X-K/X-Det sorry sites (discrete-only, incompatible with density)
- `DovetailedChain.lean:611-626` — forward_step (still uses old X-based reasoning)
- `Completeness.lean:322,356,450` — target sorry sites
- Task 83 reports 24, 30, 37, 38, 39 — prior research iterations
- Task 84 reports 01, 02 — prior synthesis and team findings
