# Research Report: Task #93 — Closing BXCanonical Sorries (Round 6)

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776104784_75bf79
**Focus**: Study the backward Until step transfer blocker and find the mathematically correct resolution

## Summary

Four researchers investigated the backward Until step transfer blocker from different angles: deep step transfer analysis (A), BX axiom inventory (B), critical validation of alternatives (C), and strategic/literature horizons (D). The **unanimous conclusion** is that the Round 5 contrapositive argument is fundamentally flawed (the biconditional reverse direction is semantically invalid), and backward Until step transfer cannot be proved from BX axioms alone. However, Teammate D discovered a **simple, elegant chain modification** — `until_neg_carry` — that resolves the blocker with minimal code changes and trivial consistency proof. This approach is independently confirmed by Teammates B and C through different reasoning paths.

## Key Findings

### 1. Round 5 Contrapositive Argument Definitively Refuted

**Unanimous (all 4 teammates, HIGH confidence)**: The contrapositive argument from Research Report 05 (Finding 5) has a fundamental gap. The argument requires deriving `G(¬(φ U ψ)) ∈ chain(t)` from `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`. This requires the biconditional reverse direction: `¬(φ U ψ) ∧ φ → G(¬(φ U ψ))`.

This formula is **semantically invalid**. Counterexample: T = {0, 1, 2}, φ holds at 0 only, ψ holds at 2, (φ U ψ) fails at 0 (because φ fails at 1), but (φ U ψ) holds at 2. So `¬(φ U ψ)` at time 0 does NOT imply `G(¬(φ U ψ))` at time 0.

The handoff document (section "Critical Finding") correctly identified this: "the contrapositive argument IS the step transfer in disguise."

### 2. All Three Handoff Alternatives Have Fatal Flaws

**Teammate C (Critic) systematically demolished all three**:

| Alternative | Fatal Flaw | Confidence |
|-------------|-----------|------------|
| P-step (Alt 1) | P-step gives info about P-formulas, not Until-formulas. Cannot derive P(φ U ψ) from (φ U ψ). Infinite regress with no termination. | HIGH |
| Until-induction (Alt 2) | The reverse biconditional `φ ∧ F(φ U ψ) → (φ U ψ)` is semantically false. `until_induction` was explicitly removed from BX (Soundness.lean:794). | VERY HIGH |
| Quasimodel (Alt 3) | `hintikka_step` propagates Until FORWARD (defect propagation), not backward. Incompatible with int_chain structure. Realization.lean explicitly states this approach was reverted. | HIGH |

### 3. The Solution: `until_neg_carry` — Negative Until Stability

**Discovered by Teammate D, confirmed by B and C**: The minimal chain modification that resolves backward Until step transfer:

**Definition**: `until_neg_carry(M) = {¬(φ U ψ) | ¬(φ U ψ) ∈ M}` — all negated Until formulas in M.

**Modification**: Add `until_neg_carry(M)` to the `fwd_succ` seed (both resolving and non-resolving cases).

**Consistency**: Trivial. `until_neg_carry(M) ⊆ M`, and M is consistent. Any subset of a consistent set is consistent.

**Step transfer proof**:
1. `¬(φ U ψ) ∈ chain(n)` → `¬(φ U ψ) ∈ until_neg_carry(chain(n))` → `¬(φ U ψ) ∈ seed(chain(n))` → `¬(φ U ψ) ∈ chain(n+1)` (by Lindenbaum extension of seed).
2. By induction: `¬(φ U ψ) ∈ chain(n)` → `∀ m ≥ n, ¬(φ U ψ) ∈ chain(m)` (**forward stability of negated Until**).
3. Contrapositive: `(φ U ψ) ∈ chain(n+1)` → `¬(φ U ψ) ∉ chain(n+1)` → `¬(φ U ψ) ∉ chain(n)` → `(φ U ψ) ∈ chain(n)`.

**This gives backward Until step transfer unconditionally** — the guard condition `φ ∈ chain(n)` is not even needed!

**Symmetric fix for Since**: Add `since_neg_carry(M) = {¬(φ S ψ) | ¬(φ S ψ) ∈ M}` to `bwd_pred` seeds. Same argument gives backward Since step transfer.

### 4. Why This Works Mathematically

The key insight (Teammate D): `¬(φ U ψ)` is a "negative Until certificate" — once `(φ U ψ)` fails at some chain position, it should remain failed at all future positions (unless the chain provides new evidence). The current chain does NOT preserve this because:

- `¬(φ U ψ)` is not a G-formula, so `g_content` doesn't carry it forward
- The Lindenbaum extension of the seed is free to choose either `(φ U ψ)` or `¬(φ U ψ)` if neither is forced by the seed

By explicitly including `¬(φ U ψ)` in the seed, we force the Lindenbaum extension to preserve it.

### 5. Alternative: x_content Enrichment (Teammate B)

Teammate B found that the Boneyard `DeterministicChain.lean` solves step transfer via x_content:
- `until_unfold_in_mcs`: `(φ U ψ) ∈ M → X(ψ ∨ (φ ∧ (φ U ψ))) ∈ M`
- x_content carries the X-wrapped formula to the successor
- `or_until_in_mcs` reconstructs `(φ U ψ)` in the successor

This gives **forward** Until persistence: `(φ U ψ) ∈ chain(n) ∧ ¬ψ ∈ chain(n) → (φ U ψ) ∈ chain(n+1)`. Combined with backward step transfer from until_neg_carry, this would give full Until coherence.

**However**, x_content requires the X-operator infrastructure (bot-Until as next-step), which BXCanonical deliberately dropped. The `until_neg_carry` approach is simpler and sufficient alone.

### 6. BX Axiom Inventory Complete

Teammate B catalogued all 37 BX axiom constructors and all derived Until/Since theorems. Key confirmed facts:
- `until_F_expansion` is sorry-free (TemporalDerived.lean:469)
- `until_unfold_thm` biconditional `(φ U ψ) ↔ ψ ∨ (φ ∧ (φ U ψ))` is proved
- `until_induction` was explicitly removed (Soundness.lean:794)
- `F(⊤)` derives directly from `refl_F` (no Boneyard port needed)
- `backward_until_from_step` is sorry-free and parameterized by step transfer hypothesis
- `until_persists_through_succ` (SuccRelation.lean:542) is sorry-blocked — documents the same gap

### 7. Interaction with Other Blockers

The `until_neg_carry` modification is **independent** of the deferral seed work needed for forward_F:
- Deferral disjunctions resolve forward_F/backward_P (restricted temporal coherence)
- until_neg_carry resolves backward Until/Since step transfer
- Both are seed enrichments with trivial consistency proofs (subset of M)
- They can be applied separately or together without interference

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Teammate A: quasimodel is best path | Teammate D's until_neg_carry is simpler, equally correct, and doesn't require quasimodel integration |
| Teammate B: x_content from Boneyard | x_content gives FORWARD Until persistence; until_neg_carry gives BACKWARD step transfer more directly. x_content requires X-operator infrastructure BXCanonical dropped. |
| Teammate C: seed enrichment needs circularity-breaking | until_neg_carry avoids circularity: it carries ALL negated Until formulas, not filtered by guard. The guard condition is not needed for step transfer. |
| Teammate D initially tried contrapositive | D self-corrected within the report, arriving at until_neg_carry as the clean solution |

### Gaps Remaining

1. **Consistency proof for combined seed**: When until_neg_carry is combined with deferral disjunctions AND f_carry/p_carry in the same seed, need to verify the combined set is still ⊆ M. This should be trivial since each component ⊆ M.

2. **int_chain boundary at t=0**: The int_chain splices fwd_chain (t ≥ 0) and bwd_chain (t < 0). until_neg_carry applies to fwd_succ; since_neg_carry applies to bwd_pred. Need to verify the boundary position handles both correctly.

3. **Forward Until guard**: Forward Until coherence still requires forward_F (via deferral seeds) + guard argument. The guard argument now has a clean proof path: contrapositive using backward Until step transfer (just proved) to show (φ U ψ) persists at intermediate times.

4. **Deferral seed consistency**: The deferral disjunction seed enrichment (for forward_F) still needs its consistency proof. Teammate B noted (75% confidence) that compatibility with the existing seed structure needs checking.

### Recommendations

**Phase 1** (backward Until/Since — the focus of this round):
1. Define `until_neg_carry(M)` and `since_neg_carry(M)` in CanonicalModel.lean
2. Add to `fwd_succ` and `bwd_pred` seeds respectively
3. Prove forward stability: `¬(φ U ψ) ∈ chain(n) → ¬(φ U ψ) ∈ chain(n+1)`
4. Derive backward Until step transfer (contrapositive of stability)
5. Plug into `backward_until_from_step` to close `bx_bfmcs_restricted_buc`
6. Symmetric: close Since case for `bx_bfmcs_restricted_buc`

**Estimated effort**: 2-3 hours (simple seed modification + inductive proof + wiring)

**Phase 2** (forward_F/backward_P — pre-existing from Plan 04/05):
7. Add deferral disjunctions to fwd_succ/bwd_pred seeds
8. Prove restricted forward_F via bounded_witness termination
9. Rewrite `bx_bfmcs_restricted_tc`

**Phase 3** (forward Until/Since):
10. Prove forward Until coherence using restricted forward_F + backward Until step transfer for guard

**Phase 4** (cleanup):
11. Delete unrestricted dead code, verify `lake build`, `#print axioms`

**Estimated total**: 8-10 hours

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Deep step transfer analysis | completed | High (95%) on diagnosis, Medium on quasimodel recommendation |
| B | BX axiom inventory | completed | High (90%) on inventory, Medium (75%) on x_content compatibility |
| C | Critic — validate alternatives | completed | Very High on alternative refutations, Medium-High on seed enrichment |
| D | Strategic horizons + literature | completed | High (90%) on until_neg_carry solution |

## References

### Codebase
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — sorry sites at lines 497, 503, 586, 591, 621, 627
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean:111` — `backward_until_from_step` (sorry-free, parameterized)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:542` — `until_persists_through_succ` (sorry, same gap)
- `Theories/Bimodal/Theorems/TemporalDerived.lean:469` — `until_F_expansion` (sorry-free)
- `Theories/Bimodal/Theorems/TemporalDerived.lean:373` — `until_unfold_thm` (sorry-free biconditional)
- `Theories/Bimodal/Theorems/TemporalDerived.lean:426` — `refl_F` (sorry-free, gives F(⊤))
- `Theories/Bimodal/ProofSystem/Axioms.lean` — 37 BX axiom constructors
- `Theories/Bimodal/ProofSystem/Soundness.lean:794` — `until_induction` explicitly removed

### Literature
- Burgess 1982 "Axioms for Tense Logic I: Since and Until" — omega-sequence canonical model
- Xu 1988 "On some U,S-tense logics" — simplified completeness for reflexive linear orders
- Goldblatt 1992 "Logics of Time and Computation" — discrete canonical models with negative Until certificates
- Gabbay-Hodkinson-Reynolds 1994 "Temporal Logic" — comprehensive Until/Since canonical model construction
