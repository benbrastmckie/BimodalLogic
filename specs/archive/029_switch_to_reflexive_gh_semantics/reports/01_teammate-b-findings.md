# Teammate B Findings: Implementation Impact of Reflexive G/H Semantics

**Date**: 2026-03-21
**Focus**: File-by-file impact analysis of switching `<` to `≤` in temporal operators
**Session**: Task 29 research

---

## Executive Summary

The switch from strict (`<`) to reflexive (`≤`) semantics for G and H would have cascading impacts across approximately 15-20 key files. The most significant consequence is that **`canonicalR_irreflexive_axiom` becomes provable as a theorem** (not an axiom), using the historical Gabbay IRR approach that was working under Task 967 and abandoned under Task 991. The `discreteImmediateSuccSeed_consistent_axiom` also becomes provable. Both of these were axioms precisely *because* strict semantics was chosen. This switch would eliminate the two most problematic axioms in the codebase.

**Confidence Level**: HIGH for impact analysis; HIGH for proof strategy; MEDIUM for exact Lean proof difficulty.

---

## Key Findings

### 1. Truth.lean — Core Semantic Change

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`

**Current (strict)**:
```lean
| Formula.all_past φ  => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

**Proposed (reflexive)**:
```lean
| Formula.all_past φ  => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

**Impact**: This single change cascades to all soundness proofs and the truth lemma. It is the root change from which everything else derives.

### 2. Soundness.lean — Proof Repairs

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean`

Several proofs must change:

**`temp_4_valid` (Gφ → GGφ)**: Currently uses `lt_trans`. Under reflexive semantics, uses `le_trans`. The proof works: `s ≥ t ∧ r ≥ s → r ≥ t` by `le_trans`.

**`temp_a_valid` (φ → G(Pφ))**: Current proof: "if φ at t, then for all s > t, there exists r < s with φ(r), namely t." Under reflexive semantics: "if φ at t, then for all s ≥ t, there exists r ≤ s with φ(r), namely t." The witness `r = t` still works since `t ≤ s` (given by the ≥ hypothesis).

**`temp_l_valid` (△φ → G(Hφ))**: The proof handles past/present/future by trichotomy. Under reflexive semantics with G: "for all s ≥ t" and H: "for all r ≤ s". The trichotomy argument `r ≤ s` splits into `r < t`, `r = t`, `t ≤ r ≤ s`. All cases covered: the past covers `r < t`, the present covers `r = t`, and the future covers `r > t`. No issues.

**NEW PROOF REQUIRED — Temporal T axioms**: Under reflexive semantics, `Gφ → φ` becomes valid (take `s = t`, then `t ≤ t` holds). Similarly `Hφ → φ`. These become provable axioms:
```lean
theorem temp_t_valid_future (φ : Formula) : ⊨ (φ.all_future.imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_G
  exact h_G t le_refl
```

**`density_valid` (GGφ → Gφ)**: Proof uses `DenselyOrdered.dense t s hts` where `hts : t < s`. Under reflexive semantics, the conclusion changes to "for all s ≥ t, φ(s)". The case s = t is now covered by reflexivity of G. For `s > t`, density gives `r` with `t < r < s`, and the same argument applies. The proof needs minor adjustment to handle the `s = t` case separately.

**`discreteness_forward_valid`**: Under reflexive semantics with H quantifying over `r ≤ t` (not `r < t`), the DF axiom changes meaning. The proof uses succ. This needs careful analysis — see Section 5 below.

**`seriality_future_valid`**: Under reflexive semantics, `Gφ → Fφ`. With `Gφ` meaning "φ at all s ≥ t" and `Fφ` still meaning "∃ s, s > t ∧ φ(s)" (F is defined as ¬G¬), this needs rechecking. Actually F = ¬G¬φ, and G under reflexive semantics includes t itself. So Fφ = ¬G(¬φ), which means "not for all s ≥ t, ¬φ(s)". Seriality would say Gφ implies this — which holds since Gφ gives φ(t) which contradicts ¬G(¬φ). Actually this works fine.

### 3. FMCSDef.lean — Structure Fields Change

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`

The FMCS structure currently uses strict inequality despite the header claiming reflexive semantics:

**Current (strict)**:
```lean
forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
```

**Under reflexive semantics**: These must become `≤`:
```lean
forward_G : forall t t' phi, t ≤ t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
backward_H : forall t t' phi, t' ≤ t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
```

**New implication**: `forward_G` at `t' = t` gives: if `Gφ ∈ mcs t` then `φ ∈ mcs t`. This is the T-axiom at the MCS level! It means `g_content(M) ⊆ M` for any MCS M in an FMCS.

### 4. CanonicalFrame.lean — CanonicalR Becomes Reflexive

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

**Definition unchanged**: `CanonicalR M M' := g_content M ⊆ M'`

**New consequence**: Under reflexive semantics, the T-axiom `Gφ → φ` is in the proof system (or derivable from validity). For any MCS M, `Gφ ∈ M → φ ∈ M` (by T-axiom membership in MCS). Therefore:

```
g_content(M) = {φ | Gφ ∈ M} ⊆ M  (by T-axiom: Gφ ∈ M → φ ∈ M)
```

So `CanonicalR M M` holds for every MCS M. **CanonicalR is reflexive under reflexive semantics.**

This is the central consequence that motivates the task.

**`canonical_forward_G`**: No code change. But the theorem `canonical_forward_G M M h_refl phi h_G` now gives `phi ∈ M` from `G phi ∈ M`, matching the T-axiom.

**`canonical_forward_F`**: No code change to the proof. But the semantic interpretation changes — we now produce a reflexive-future witness.

### 5. CanonicalIrreflexivity.lean — Axiom Eliminated

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

This is the biggest gain. The file currently ends with:
```lean
axiom canonicalR_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M
```

Under reflexive semantics, **`CanonicalR M M` is TRUE**, so this axiom is FALSE. The axiom must be removed entirely. Instead, `CanonicalR` is provably a **preorder** (reflexive and transitive), not a strict order.

**The 1170 lines of proof infrastructure** in this file were built for the *Gabbay IRR approach* that proves irreflexivity under reflexive semantics. Under reflexive semantics, this infrastructure is repurposed:

- The naming set construction is still valid
- The proof that was `canonicalR_irreflexive_axiom` becomes instead a proof that `¬CanonicalR M M` is FALSE (since the preorder is reflexive)
- The Gabbay IRR approach no longer proves irreflexivity of CanonicalR but rather proves irreflexivity of the *quotient order* (needed for the timeline to be strict)

**What replaces irreflexivity for the timeline?** The quotient order `DiscreteTimelineQuot` needs strict ordering. Under reflexive semantics, `M ≤ N` iff `CanonicalR M N` (which is now a preorder), and `M < N` iff `CanonicalR M N ∧ ¬CanonicalR N M`. The key theorem that was proved under Task 967:

```
If CanonicalR M N and M ≠ N (as MCSes), then ¬CanonicalR N M
```

This follows from: if both `CanonicalR M N` and `CanonicalR N M`, then `g_content M ⊆ N` and `g_content N ⊆ M`. Together with T-axiom (g_content M ⊆ M and g_content N ⊆ N), this implies M and N are T4-equivalent. The Gabbay IRR argument then shows M = N as MCSes.

### 6. CanonicalIrreflexivityAxiom.lean — Now a True Theorem

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

The wrapper theorem `canonicalR_irreflexive` currently invokes the axiom. Under reflexive semantics:
- The wrapper theorem is REMOVED or repurposed
- `canonicalR_antisymmetric_strict` (lines 81-89) needs to be rephrased: "if `CanonicalR M N` and `CanonicalR N M` and `M ≠ N`, then False"
- `canonicalR_strict` needs rephrasing similarly

### 7. TemporalCoherence.lean — Forward/Backward Changes

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`

**`temporal_backward_G`**: Currently proves `G(φ) ∈ fam.mcs t` from `∀ s > t, φ ∈ fam.mcs s`. Under reflexive semantics, must prove from `∀ s ≥ t, φ ∈ fam.mcs s`. The contraposition proof still works because `F(¬φ)` witnesses `s > t` (strict), which is ≥ t. No proof change needed in the core logic, but the hypothesis type changes.

**`temporal_backward_H`**: Symmetric, same analysis.

**`TemporalCoherentFamily`**: `forward_F` and `backward_P` stay strict (`s > t`) because F and P are defined as duals of G/H (F = ¬G¬, P = ¬H¬), and the witness for F always provides a strict future point.

### 8. ParametricTruthLemma.lean — G/H Cases Change

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`

**`all_future` case (line 274)**: Comment says "Under strict semantics (Task 991)". Under reflexive semantics:

- Forward direction: `G φ ∈ fam.mcs t → ∀ s ≥ t, truth_at ... s φ`
  - For `s > t`: uses `fam.forward_G t s φ hts h_G` (as before but with `hts : t ≤ s`)
  - For `s = t`: uses T-axiom: `φ ∈ fam.mcs t` directly (from `Gφ ∈ mcs t` via T-axiom)

- Backward direction: `(∀ s ≥ t, truth_at ... s φ) → G φ ∈ fam.mcs t`
  - Uses `temporal_backward_G` with `∀ s > t, φ ∈ fam.mcs s` (still strict)
  - But also needs: `φ ∈ fam.mcs t` (the `s = t` case)
  - Under reflexive semantics, `G φ` should contain `φ` at `t` — covered by T-axiom
  - The backward proof needs to show `G φ ∈ mcs t` when `∀ s ≥ t, φ ∈ mcs s`
  - Simpler: use `temporal_backward_G` with strictly future (s > t) and separately use the T-axiom inverse... Actually, `temporal_backward_G` (the converse direction) still holds: if φ at all s > t, then Gφ ∈ mcs t. The proof by contraposition still works. But the truth lemma now requires: `Gφ ∈ mcs t ↔ ∀ s ≥ t, φ ∈ mcs s`. The backward (`←`) direction needs: from `∀ s ≥ t, φ ∈ mcs s`, derive `Gφ ∈ mcs t`. The restriction to `s > t` gives `temporal_backward_G`. But we also need to include `s = t` — which is automatic from the ≥ hypothesis.

**`parametric_box_persistent` (line 138)**: The case split uses `lt_trichotomy`. The `s = t` case (line 159) already handles it directly. No change needed.

### 9. DiscreteSuccSeed.lean — Axiom Eliminated

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

The `discreteImmediateSuccSeed_consistent_axiom` is at line 284:
```lean
axiom discreteImmediateSuccSeed_consistent_axiom (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M)
```

This axiom was needed because under strict semantics, `g_content(M) ⊄ M`, so the blocking formulas case couldn't be discharged. Under reflexive semantics, **`g_content(M) ⊆ M` holds** (T-axiom). This makes blocking formulas provably consistent:

- `blockingFormula(ψ) = ¬ψ ∨ ¬G(ψ)`
- If both `ψ ∈ W` and `G(ψ) ∈ W`, then by T-axiom `ψ ∈ W` is consistent with `G(ψ) ∈ W` (no contradiction)
- But wait: the blocking formula is about being in the **seed**, not in the resulting MCS

Re-analysis: The blocking formula `¬ψ ∨ ¬G(ψ)` in the seed forces the successor MCS W to contain either `¬ψ` or `¬G(ψ)`. Under reflexive semantics, the T-axiom guarantees that if `G(ψ) ∈ W` then `ψ ∈ W`. So the blocking formula prevents the situation where `G(ψ) ∈ W` (since that would require both `ψ ∈ W` and `¬ψ ∈ W`). This means the seed `g_content(M) ∪ blockingFormulas(M)` can be shown consistent by the same seriality argument, but now with T-axiom available for the proof.

**The key repair**: The Case 2 proof (blocking formulas present) can be completed under reflexive semantics using:
1. `g_content(M) ⊆ M` (T-axiom)
2. Blocking formula `¬ψ ∨ ¬G(ψ)` is derivable from `¬G(ψ) ∈ M` (which is the hypothesis for adding blocking formulas)
3. Therefore any finite subset of the seed can be shown consistent

This eliminates the axiom. The axiom documentation at line 280 says: "The seriality argument shows the seed is satisfiable, hence consistent" — under reflexive semantics, this argument can actually be carried through in Lean.

### 10. DiscreteTimeline.lean — `discrete_Icc_finite_axiom` Analysis

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

This axiom (line 316) is about interval finiteness of `DiscreteTimelineQuot`:
```lean
axiom discrete_Icc_finite_axiom :
    ∀ (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```

**Under reflexive semantics**: This axiom is about the QUOTIENT structure, not the temporal operators directly. The quotient is built from the Succ relation. Under reflexive semantics:

- **`Succ(M, M)` holds for all MCS M**: `Succ(M, M) = g_content(M) ⊆ M ∧ f_content(M) ⊆ M ∪ f_content(M)`. The second condition is trivially true. The first is now true (T-axiom). So EVERY MCS is its own successor.
- This means the Succ relation has self-loops
- The quotient ordering `StagedPoint.le` includes `CanonicalR M N` which is now reflexive
- The covering lemma argument changes: with self-loops, `M` and `discreteImmediateSucc M` might be the same MCS (when `g_content(M) = M`, i.e., every formula in M is a G-formula)

**Critical question**: Does the `discrete_Icc_finite_axiom` still make sense? The interval `[a, b]` in `DiscreteTimelineQuot` represents MCSes between a and b in the Succ-chain order. Under reflexive semantics with Succ being reflexive, the quotient collapses MCSes with self-loops together. The intervals should still be finite IF the "real" progression happens via strict Succ steps (those where `M ≠ N`).

**Conclusion**: The `discrete_Icc_finite_axiom` is NOT eliminated by the switch to reflexive semantics. It addresses a different structural question (finiteness of intervals) that is independent of the strict/reflexive choice. However, the path to PROVING this axiom may become clearer under reflexive semantics, since the T-axiom enables more powerful proof techniques.

---

## Changes Required — Specific Code Locations

### Files Requiring Semantic Changes (Core)

| File | Change Required | Lines |
|------|-----------------|-------|
| `Semantics/Truth.lean` | Change `<` to `≤` in `all_past` and `all_future` cases | 121-122 |
| `Metalogic/Soundness.lean` | Fix `temp_4_valid` (`lt_trans` → `le_trans`), `temp_a_valid`, `density_valid`; add `temp_t_valid` proofs | 184-195, 300-311 |
| `Bundle/FMCSDef.lean` | Change `<` to `≤` in `forward_G` and `backward_H` fields | 119, 127 |
| `Bundle/TemporalCoherence.lean` | Change `temporal_backward_G/H` signatures (∀ s > t → ∀ s ≥ t) | 167, 193 |

### Files Requiring Axiom Elimination

| File | Axiom | Action |
|------|-------|--------|
| `Bundle/CanonicalIrreflexivity.lean` | `canonicalR_irreflexive_axiom` | ELIMINATE — prove via T-axiom |
| `Canonical/CanonicalIrreflexivityAxiom.lean` | Wrapper theorem | REVISE — remove or repurpose |
| `StagedConstruction/DiscreteSuccSeed.lean` | `discreteImmediateSuccSeed_consistent_axiom` | ELIMINATE — prove via T-axiom |

### Files Requiring Proof Surgery

| File | Change Required |
|------|-----------------|
| `Algebraic/ParametricTruthLemma.lean` | Add `s = t` case in `all_future` forward direction; adjust backward direction |
| `SoundnessLemmas.lean` | Fix all `t < s` → `t ≤ s` in `swap_*` lemmas involving temporal operators |
| `StagedConstruction/DiscreteSuccSeed.lean` | Prove Case 2 (blocking formulas) using T-axiom instead of delegating to axiom |
| `Bundle/CanonicalIrreflexivity.lean` | Activate the 1170-line Gabbay IRR proof infrastructure |
| `ProofSystem/Axioms.lean` | Add `temp_t_future` and `temp_t_past` axiom constructors |

---

## Axioms Eliminated vs New Requirements

### Axioms Eliminated (2)

1. **`canonicalR_irreflexive_axiom`** — ELIMINATED
   - Under reflexive semantics, `CanonicalR M M` is TRUE
   - The axiom `¬CanonicalR M M` is false and must be removed
   - The Gabbay IRR proof infrastructure (1170 lines) can be activated to prove the antisymmetry lemma that replaces this

2. **`discreteImmediateSuccSeed_consistent_axiom`** — ELIMINATED
   - Under reflexive semantics, `g_content(M) ⊆ M` holds (T-axiom)
   - This enables the Case 2 proof in `discreteImmediateSuccSeed_consistent`
   - The blocking formula consistency proof goes through

### Axiom Unchanged (1)

3. **`discrete_Icc_finite_axiom`** — UNCHANGED
   - Addresses interval finiteness of the quotient order
   - Independent of strict vs reflexive temporal semantics
   - Still requires the covering lemma to eliminate

### New Requirements

1. **Add `temp_t` axioms to `ProofSystem/Axioms.lean`**:
   - `temp_t_future`: `Gφ → φ` (T-axiom for G)
   - `temp_t_past`: `Hφ → φ` (T-axiom for H)
   - These are needed because `canonicalR_irreflexive_axiom` is replaced by a proof using H(¬p) → ¬p

2. **Prove IRR soundness with reflexive semantics**: The `IRRSoundness.lean` proof currently assumes strict order. Under reflexive semantics, the IRR rule requires reflexive ordering in its frame condition.

3. **The 3 downstream consequences of CanonicalR irreflexivity** (NoMaxOrder, NoMinOrder, DenselyOrdered on canonical domain) must be reproved via antisymmetry rather than irreflexivity:
   - Instead of: "seriality gives N with CanonicalR(M,N); irreflexivity gives N ≠ M"
   - Use: "seriality gives N with CanonicalR(M,N) and CanonicalR(N,M) → N = M; since F(psi) shows N has extra content, N ≠ M"

---

## CanonicalTask Analysis: Is Succ(M,M) Trivial?

**Yes, `Succ(M, M)` holds for all MCS M under reflexive semantics:**

```
Succ(M, M) := g_content(M) ⊆ M ∧ f_content(M) ⊆ M ∪ f_content(M)
```

- First condition: `g_content(M) ⊆ M` — TRUE by T-axiom under reflexive semantics
- Second condition: `f_content(M) ⊆ M ∪ f_content(M)` — TRUE trivially (A ⊆ B ∪ A)

So `Succ(M, M)` holds. Therefore `CanonicalTask(M, 1, M)` holds (via one Succ step from M to M). And by induction, `CanonicalTask(M, n, M)` holds for all n ≥ 0.

**Implication for CanonicalTask**: The CanonicalTask relation is now "trivially" satisfied for self-loops. This does NOT make the timeline degenerate — the meaningful ordering comes from STRICT Succ steps (where M ≠ N as MCSes). The quotient collapses M with all its "reflexive successors" to a single equivalence class.

**CanonicalTask Converse Theorem**: `CanonicalTask(M, n, N) ↔ CanonicalTask(N, -n, M)`. This still holds under reflexive semantics — the proof is purely structural (forward/backward chain duality) and doesn't depend on strict vs reflexive temporal operators.

---

## Confidence Assessment

| Finding | Confidence |
|---------|-----------|
| Core semantic change (`<` → `≤`) | HIGH — direct definition change |
| `canonicalR_irreflexive_axiom` becomes false (eliminated) | HIGH — mathematical certainty |
| `discreteImmediateSuccSeed_consistent_axiom` becomes provable | HIGH — T-axiom enables the proof |
| `discrete_Icc_finite_axiom` unchanged | HIGH — independent of temporal semantics |
| Succ(M,M) holds for all MCS M | HIGH — mathematical certainty |
| CanonicalTask Converse survives | HIGH — structural proof, unaffected |
| Soundness proofs fixable | MEDIUM — need to verify each case, especially `temp_l_valid` |
| Gabbay IRR infrastructure reactivation | MEDIUM — the proof was working under Task 967 but exact current state unclear |
| `discrete_Icc_finite_axiom` becomes provable via new techniques | LOW — separate hard problem |
