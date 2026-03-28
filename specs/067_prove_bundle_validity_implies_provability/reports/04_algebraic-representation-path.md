# Algebraic Representation Theorem: Concrete Path Forward

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-28
**Status**: Research complete — actionable implementation plan
**Method**: Eight specialized agents across two rounds, with synthesis
**Focus**: Algebraic representation theorem only (FMP excluded by directive)

---

## 1. The Sorry to Fill

```lean
-- FrameConditions/Completeness.lean:176
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ) := by
  ...
  sorry  -- "model-theoretic glue"
```

`valid_over Int φ` means: for ALL `TaskFrame Int`, ALL `TaskModel`, ALL shift-closed `Omega`, ALL histories `τ ∈ Omega`, ALL times `t : Int`, `truth_at M Omega τ t φ`.

---

## 2. What Is Sorry-Free (Complete Inventory of Usable Infrastructure)

### 2.1 Algebraic Core (5,300+ lines, zero sorries)
- `LindenbaumQuotient.lean`: Lindenbaum algebra as Boolean algebra
- `BooleanStructure.lean`: Boolean algebra properties
- `TenseS5Algebra.lean`: STSA instance on Lindenbaum algebra
- `InteriorOperators.lean`: G/H as monotone operators
- `UltrafilterMCS.lean`: Ultrafilter ↔ MCS bijection

### 2.2 Parametric Infrastructure (zero sorries)
- `ParametricCanonical.lean`: `ParametricCanonicalTaskFrame D` (lines 198-205)
- `ParametricHistory.lean`: `parametric_to_history` converting FMCS to WorldHistory (lines 61-89)
- `ParametricTruthLemma.lean`: Bidirectional truth lemma **conditional on `B.temporally_coherent`**
- `ParametricRepresentation.lean`: Representation theorem **conditional on `construct_bfmcs`**

### 2.3 SuccChain Construction (zero sorries for the core)
- `SuccRelation.lean`: Succ relation — g_content propagation + f_content deferral
- `SuccExistence.lean`: `successor_exists`, `predecessor_exists` (sorry-free)
- `SuccChainFMCS.lean`:
  - `SuccChainFMCS : SerialMCS → FMCS Int` (**sorry-free**, line 980)
  - `succ_chain_forward_G_le` (**sorry-free**): G-formulas propagate forward along chain
  - `succ_chain_backward_H_le` (**sorry-free**): H-formulas propagate backward
  - `restricted_forward_chain_forward_F` (**sorry-free**, line 2921): F-obligations resolved within bounded steps for deferralClosure formulas
  - `restricted_backward_chain_backward_P` (**sorry-free**, line 4262): Symmetric for P

### 2.4 Bundle Construction (zero sorries)
- `construct_bfmcs_bundle` (UltrafilterChain.lean:2853): Builds `BFMCS_Bundle` from MCS M0
  - `boxClassFamilies_modal_forward` (**sorry-free**)
  - `boxClassFamilies_modal_backward` (**sorry-free**)
  - `boxClassFamilies_bundle_forward_F` (**sorry-free**): Bundle-level F-coherence
  - `boxClassFamilies_bundle_backward_P` (**sorry-free**): Bundle-level P-coherence
- `temporal_theory_witness_exists` (line 1153): **sorry-free** — given F(φ) ∈ M, produces witness MCS W with φ ∈ W, G-theory agreement, box_class_agree
- `not_provable_implies_neg_consistent` (**sorry-free**, line 2950)
- `mcs_neg_gives_countermodel` (**sorry-free**, line 2915)

---

## 3. The Fundamental Gap: Why h_tc Is Required

### 3.1 Where h_tc Enters

`parametric_shifted_truth_lemma` (ParametricTruthLemma.lean:325) takes `h_tc : B.temporally_coherent`. It is used ONLY in the **backward direction** of the G and H cases (lines 280-289, 299-309):

```
Backward G: truth at all s ≥ t → G(psi) ∈ fam.mcs(t)
  Uses: temporal_backward_G which needs forward_F (same-family F-witness)
```

### 3.2 Why the Forward Direction Alone Is Insufficient

The forward direction of the imp case (line 206-208) uses the backward IH:
```lean
· intro h_imp h_psi_true
  have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- BACKWARD
```

For completeness, we need `neg(φ) ∈ MCS → ¬truth_at φ`. Since `neg(φ) = φ.imp bot`, this requires the forward truth lemma for `φ.imp bot`, which uses the backward IH for `φ`. If `φ` contains G/H subformulas, the backward IH eventually hits the G/H backward case, requiring h_tc.

**Conclusion**: The bidirectional truth lemma with h_tc cannot be avoided by only proving one direction.

### 3.3 What h_tc Actually Requires

`B.temporally_coherent` (TemporalCoherence.lean:216) means:
```
∀ fam ∈ B.families,
  (∀ t φ, F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s))  -- forward_F
  ∧ (∀ t φ, P(φ) ∈ fam.mcs(t) → ∃ s < t, φ ∈ fam.mcs(s))  -- backward_P
```

Family-level: witness in the SAME family, not any family.

---

## 4. The Key Mathematical Insight: Restricted Coherence Suffices

### 4.1 What the Truth Lemma Actually Needs

In the backward G case for `G(psi)`, `temporal_backward_G` is called with formula `psi`. Internally, it uses `forward_F` on `F(neg(psi))`. Since the truth lemma is proved by structural induction, `psi` is always a **strict subformula** of the target formula.

**Therefore**: The truth lemma for target formula `φ` only needs `forward_F` for formulas `neg(psi)` where `psi` ranges over subformulas of `φ`. These are ALL in `deferralClosure(φ)`.

### 4.2 The SuccChain Resolves These Obligations

The sorry-free `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2921) proves:

> For the SuccChain from M0, if `F(ψ) ∈ chain(t)` where `ψ ∈ deferralClosure(target)`, then `∃ s > t, ψ ∈ chain(s)`.

This works because:
1. Each Succ step either resolves F(ψ) (places ψ at the next position) or defers it
2. `iter_F_not_mem_closureWithNeg` (CanonicalTaskRelation.lean:175) proves: deferral depth is bounded by `closure_F_bound(target)`
3. After bounded steps, the F-obligation MUST be resolved (it can't be deferred forever within bounded nesting)

Similarly, `restricted_backward_chain_backward_P` (line 4262) proves the symmetric past result.

### 4.3 The Gap

The SuccChainFMCS used in `construct_bfmcs_bundle` is built from `MCS_to_SerialMCS M0` — the **general** SuccChain, not the restricted one. And the other families in `boxClassFamilies` are shifted SuccChains from OTHER base MCSes W. These other chains are not targeted at the specific formula φ.

**However**: The restricted chain results apply to ANY SuccChain where the F-obligation is for a formula in the deferral closure. Since every family in `boxClassFamilies` is a shifted SuccChainFMCS, and the deferral closure depends on the target formula (not the base MCS), the restricted coherence applies to ALL families in the bundle — for the relevant formulas.

---

## 5. Concrete Implementation Strategy

### Strategy: Formula-Targeted Truth Lemma with Restricted Coherence

Rather than proving full `B.temporally_coherent`, prove a **restricted** version targeting a specific formula, then use it for completeness.

### Phase 1: Restricted Temporal Coherence for BFMCS_Bundle

**Goal**: Prove that for the `BFMCS_Bundle` from `construct_bfmcs_bundle`, every family satisfies `forward_F` and `backward_P` for formulas in `deferralClosure(φ)`.

```lean
theorem bfmcs_bundle_restricted_forward_F (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (φ : Formula) (fam : FMCS Int) (hfam : fam ∈ (construct_bfmcs_bundle M0 h_mcs).families)
    (ψ : Formula) (h_clos : ψ ∈ deferralClosure φ)
    (t : Int) (h_F : Formula.some_future ψ ∈ fam.mcs t) :
    ∃ s > t, ψ ∈ fam.mcs s
```

**Proof approach**:
- Every family in `boxClassFamilies` is a shifted SuccChainFMCS from some base MCS W
- Apply `restricted_forward_chain_forward_F` to this SuccChain
- The shift preserves the restricted temporal coherence property
- The deferral closure bound `closure_F_bound(φ)` applies uniformly

### Phase 2: Restricted Truth Lemma

**Goal**: Prove the truth lemma using restricted coherence instead of full `B.temporally_coherent`.

```lean
theorem restricted_parametric_truth_lemma
    (B : BFMCS_Bundle) (φ_target : Formula)
    (h_rtc : ∀ fam ∈ B.families, RestrictedTemporalCoherence fam (deferralClosure φ_target))
    (phi : Formula) (h_sub : phi ∈ subformulaClosure φ_target)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    phi ∈ fam.mcs t ↔ truth_at (...) (parametric_to_history fam) t phi
```

**Key insight**: The induction is on `phi ∈ subformulaClosure(φ_target)`. In the backward G case, `temporal_backward_G` invokes `forward_F` on `neg(psi)` where `psi` is a subformula. Since `neg(psi) ∈ deferralClosure(φ_target)` whenever `psi ∈ subformulaClosure(φ_target)`, the restricted coherence `h_rtc` suffices.

### Phase 3: Wire to Completeness

**Goal**: Use the restricted truth lemma to fill the sorry in `bundle_validity_implies_provability`.

```
1. Given: valid_over Int φ
2. Contrapositive: assume ¬⊢ φ
3. not_provable_implies_neg_consistent: {neg(φ)} consistent
4. Lindenbaum: extend to MCS M with neg(φ) ∈ M
5. construct_bfmcs_bundle M h_mcs: sorry-free BFMCS_Bundle with eval_family.mcs(0) = M
6. Phase 1: prove restricted temporal coherence for this bundle targeting φ
7. Build canonical TaskFrame Int, TaskModel, Omega from BFMCS_Bundle (existing infrastructure)
8. Phase 2: restricted truth lemma gives neg(φ) true at eval point
9. valid_over Int φ applied to canonical model gives φ true at eval point
10. Both truth(φ) and truth(neg(φ)) → contradiction
```

### Phase 4: Verification

Build and verify with `lake build`.

---

## 6. Dependencies and Risk Assessment

### What Needs to Be Proved (New)

1. **Restricted forward_F for shifted SuccChains** (~100-150 lines)
   - Extend `restricted_forward_chain_forward_F` to shifted chains
   - Show all families in `boxClassFamilies` satisfy the restricted property
   - Risk: LOW — the shift lemmas are sorry-free, and the restricted chain theorems are sorry-free

2. **Restricted backward_P for shifted SuccChains** (~100-150 lines)
   - Symmetric to (1)
   - Risk: LOW

3. **Restricted truth lemma** (~200-300 lines)
   - Adapt `parametric_canonical_truth_lemma` to use restricted coherence
   - Most cases identical — only G backward and H backward change
   - Risk: MEDIUM — need to verify the subformula/closure relationship at each step

4. **Completeness wiring** (~50-100 lines)
   - Connect restricted truth lemma to `bundle_validity_implies_provability`
   - Build canonical model from BFMCS_Bundle
   - Risk: LOW — existing infrastructure handles model construction

### Total Estimated New Code: 450-700 lines
### Total Risk: MEDIUM (the restricted truth lemma is the main uncertainty)

### What Is NOT Needed

- Full `B.temporally_coherent` (the unrestricted version)
- Z-chain construction or omega-enumeration
- Any of the deprecated/sorry constructions
- The FMP path

---

## 7. Why This Path Avoids the Wall

The wall (24+ failed approaches) arose from trying to prove **unrestricted** family-level temporal coherence:
- `∀ φ, F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)` for ALL formulas φ

This fails because:
1. F-nesting is unbounded for arbitrary formulas (`f_nesting_is_bounded` is FALSE)
2. Independent Lindenbaum extensions don't preserve cross-position G/H propagation

The restricted approach sidesteps both issues:
1. **Bounded nesting within the closure**: `iter_F_not_mem_closureWithNeg` (sorry-free) proves that F-nesting for closure formulas is bounded by `closure_F_bound(φ_target)`
2. **No Lindenbaum extensions needed**: The SuccChainFMCS already provides full MCSes at every position via `successor_exists` and `predecessor_exists`, which use deferral seeds — NOT independent Lindenbaum extensions
3. **The truth lemma only needs restricted coherence**: Because the induction is on subformulas of a fixed target, `forward_F` is only invoked on formulas in the deferral closure

---

## 8. Relationship to the Three-Place Task Relation

The three-place `task_rel : WorldState → D → WorldState → Prop` enters through `WorldHistory.respects_task`:
```
respects_task : ∀ s t (hs ht), s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

In the canonical model, `respects_task` requires `ExistsTask (fam.mcs s) (fam.mcs t)` for `s ≤ t`, which follows from `fam.forward_G` (sorry-free from SuccChainFMCS). The three-place structure's compositionality (`forward_comp`) uses `canonicalR_transitive` (sorry-free via `temp_4: G(φ) → G(G(φ))`).

The converse property (`task_rel w d u ↔ task_rel u (-d) w`) is satisfied by construction of `parametric_canonical_task_rel`.

**The three-place relation does NOT block the restricted approach.** All TaskFrame axioms are provable from SuccChainFMCS properties.

---

## 9. Summary: What Agents Found

| Agent | Key Finding |
|-------|-------------|
| **STSA Seriality** | `temporal_theory_witness_exists` is sorry-free; STSA has seriality via discrete axioms; R_G serial in discrete extension; forward_F/backward_P for restricted formulas is provable |
| **Alt Truth Lemma** | h_tc used ONLY in backward G/H; forward imp forces bidirectionality; restricted forward_F suffices since induction only touches subformulas; correlated Henkin construction is viable |
| **Z-Chain Gap** | Z-chain cross-boundary sorry is fundamentally blocked (needs G(a)→H(G(a))); Z-chain forward_F fixable by dovetailing but moot; `construct_bfmcs_bundle` is sorry-free and sufficient |
| **Literature** | Jonsson-Tarski gives Kripke completeness automatically; bundle semantics forces chain requirement; conversion from Kripke to bundle is where chains enter; restricted coherence matches standard restricted completeness techniques |

---

## 10. Recommended Action Sequence

```
Step 1: Prove bfmcs_bundle_restricted_forward_F
  - Show every family in boxClassFamilies inherits restricted_forward_chain_forward_F
  - Handle the shift offset in the chain
  - ~100-150 lines

Step 2: Prove bfmcs_bundle_restricted_backward_P (symmetric)
  - ~100-150 lines

Step 3: Prove restricted_parametric_truth_lemma
  - Copy parametric_canonical_truth_lemma structure
  - Replace h_tc with restricted coherence hypothesis
  - Only G/H backward cases change
  - ~200-300 lines

Step 4: Wire to bundle_validity_implies_provability
  - Build canonical model from BFMCS_Bundle
  - Apply restricted truth lemma
  - ~50-100 lines

Step 5: lake build and verify
```

**Estimated total**: 450-700 new lines, MEDIUM risk, targeting the existing sorry at FrameConditions/Completeness.lean:204.
