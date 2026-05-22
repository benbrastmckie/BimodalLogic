# Burgess Omega-Chain Construction and Gap Elimination

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Why succ_cofinal Step 9 is hard and what the literature says

---

## 1. How the Burgess Construction Works

### Base construction (Burgess 1982, Section 2; 1984, Section 1)

1. Fix a consistent formula φ₀ and MCS C₀ ∋ φ₀
2. Start with singleton chronicle: dom = {x₀}, f(x₀) = C₀
3. Enumerate all "potential counterexamples" (pairs (x, F(ψ)) or (x, P(ψ)) or (x, U(ψ,η)) etc.)
4. For each alive counterexample: add a witness point to "kill" it (Killing Lemma)
5. Take the union over ω stages: limit domain with limit chronicle satisfying C0-C5

### Discrete extension (Burgess 1984, Section 2.6)

6. Add an S relation marking immediate successors
7. When xSy: NEVER insert points between x and y (guaranteed by Lemma parts (c),(d))
8. Kill "successor requirements" (form (e): ∃ y with xSy) using the Lemma's MCS B with T(x) →' B
9. Result: a discrete total order where every element has an immediate successor/predecessor

### Key property of S

The Lemma (Section 2.6) shows: if A →' B (A immediately precedes B), then:
- (c) for any C with A → C: either B = C or B → C (nothing fits between A and B from above)
- (d) for any C with C → B: either A = C or C → A (nothing fits between A and B from below)

This means once xSy is set, the construction PROVABLY never needs to insert between them.

---

## 2. Why the Construction CAN Produce Gaps

### The constant-MCS scenario

If all limit_dom points have the same MCS M, then:
- F(φ) ∈ M iff φ ∈ M (every future point has M)
- G(φ) ∈ M iff φ ∈ M (dually)
- U(φ,ψ) at x is resolved by y = succ(x) (discrete: no intermediates, so ψ vacuously true on (x,y))
- ALL temporal formulas at ALL points are resolved by immediate successors

In this scenario, the construction adds points in a forward chain from any starting point, and a backward chain from any other point. If these chains converge to different limits L and L', a gap persists between them. The construction never encounters a counterexample that requires a point in the gap (because all formulas are uniformly resolved by immediate successors).

### Verification against axioms

| Axiom | Status in constant-MCS gap scenario |
|-------|-------------------------------------|
| Z1: G(Gφ→φ) → (FGφ→Gφ) | Trivially satisfied (F,G = identity on truth values) |
| Prior-UZ: Fp → U(p,¬p) | Vacuously satisfied in discrete (no intermediates) |
| Prior-SZ: Pp → S(p,¬p) | Dually |
| c5 (Until resolution) | Resolved by immediate successor |
| c5' (Since resolution) | Resolved by immediate predecessor |
| □(G'⊥ ∧ H'⊥) (box-discrete) | Satisfied: every point is discrete |

**Conclusion**: The gap scenario IS consistent with all temporal/bimodal axioms under strict (irreflexive) semantics in the constant-MCS case. No temporal formula distinguishes the orbit points from the pred-chain points.

### Reynolds confirms this

Reynolds 1994, Corollary 3 (p.301): the Burgess construction for US/Z-consistent formulas produces "a countable, discrete [order] without endpoints." Reynolds does NOT claim the order is isomorphic to ℤ — he proves it separately via the Reynolds gap elimination pipeline (Lemmas 6-14, Theorem 14).

---

## 3. What This Means for the Lean Proof

### succ_cofinal Step 9 cannot use temporal axioms alone

The existing comments in the code correctly identify this: "the gap scenario is consistent with all temporal axioms (Z1, Prior-UZ, c5) under strict semantics in the constant-MCS case."

### Three viable paths

| Path | Approach | Effort | Status |
|------|----------|--------|--------|
| A | Construction-level: show omega_chain_elim_result never produces constant-MCS | ~500+ lines | Unclear if true: constant-MCS MAY be a valid construction output |
| B | Reynolds gap elimination (Theorem 14): prove no gaps in Prior structures | ~1000-1500 lines | Mathematically correct, requires Phases 4-6B |
| C | Alternative model construction: build a ℤ-model directly without omega-chain | ~300-500 lines | Henkin-style, task 129 approach |

### Path A assessment (construction-level argument)

The construction-level argument must show: the omega-chain construction for BX-consistent sets NEVER produces a constant-MCS limit domain with gaps. This requires proving that some feature of the BX construction forces non-constant MCS labels.

**Challenge**: In the pure temporal case, constant-MCS IS a valid construction output (Burgess doesn't prevent it). The BX box modality adds □(G'⊥ ∧ H'⊥) but this is trivially satisfied. The box resolution mechanism (adding accessible worlds) doesn't force MCS variation in the S5 case (all worlds already see each other).

**Verdict**: Path A is UNLIKELY to work unless there is a specific BX construction property that forces MCS variation. No such property has been identified.

### Path B assessment (Reynolds gap elimination)

This is the mathematically correct and literature-supported approach:
1. Complete Phase 4 (stavi_expressive_completeness — currently orphaned but needed here)
2. Prove Reynolds Theorem 5 (US expressively complete over Prior)
3. Prove Reynolds Lemmas 6-14 (gap elimination for Prior structures)
4. Apply Theorem 14 to the chronicle's limit domain

**Challenge**: ~1000-1500 lines of new proof code. Requires completing the orphaned EFGames.lean infrastructure.

**Verdict**: Path B is the mathematically virtuous path. It's the approach Reynolds 1994 actually uses.

### Path C assessment (alternative model construction)

Build a countermodel directly on ℤ without going through the omega-chain construction:
1. Take the MCS family from the chronicle
2. Construct a valuation on ℤ directly (using the chronicle's truth data)
3. Prove truth preservation
4. This avoids the gap issue entirely because ℤ has no gaps by definition

**Challenge**: Matching the type signatures of `dd_countermodel_chronicle_discrete`. The chronicle construction provides specific coherence properties (C0-C5, BurgessR3Maximal) that the truth lemma depends on.

**Verdict**: Path C is the most pragmatic approach if the chronicle's OrderIso to ℤ can be used to transport the valuation. `chronicle_is_good` provides this OrderIso but it depends on `succ_cofinal` (circular).

---

## 4. Recommendation

**Path B (Reynolds gap elimination) is the only non-circular path.** Paths A and C both face fundamental obstacles (A: likely impossible; C: circular dependency through succ_cofinal).

The work needed:
1. Close EFGames.lean Phase 4 sorry sites (stavi_expressive_completeness, ghr93_decomposition_implies_game) — currently orphaned but needed for Path B
2. Complete Phase 1 (d-consistency) — needed for stavi_expressive_completeness via Theorem 6
3. Prove Reynolds Theorem 5 (Phase 5)
4. Prove Reynolds Lemmas 6-14 (Phases 6A-6B)
5. Apply Theorem 14 to close succ_cofinal

This is ~2000-3000 lines of additional proof code. It IS the full Reynolds pipeline that task 155 was originally designed for.

**The "orphaned" EFGames infrastructure is NOT orphaned — it IS the Reynolds pipeline.**

---

## 5. Summary

| Finding | Detail |
|---------|--------|
| Burgess construction | CAN produce gaps (ℤ+ℤ models) |
| Constant-MCS scenario | Consistent with ALL temporal/bimodal axioms |
| Reynolds 1994 | Proves gap elimination SEPARATELY via Lemmas 6-14 |
| Path A (construction-level) | Unlikely to work |
| Path B (Reynolds) | Correct, ~2000-3000 lines |
| Path C (direct ℤ-model) | Circular (depends on succ_cofinal via chronicle_is_good) |
| EFGames sorry sites | NOT orphaned — needed for Path B |
| **Conclusion** | The full Reynolds pipeline (Phases 1-6B) IS necessary for sorry-free bx_completeness |
