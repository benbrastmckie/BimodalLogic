# Teammate A: Mathematical Analysis of Coherence Gap

## Key Findings

### Forward-Only Truth Lemma Viability

**Conclusion: YES, the forward-only direction suffices for completeness. This is the correct path forward.**

The completeness proof in `bundle_validity_implies_provability` (Completeness.lean:186-214) uses a contrapositive argument:

1. Assume phi not provable
2. Then neg(phi) is consistent (`not_provable_implies_neg_consistent`)
3. Extend neg(phi) to MCS M via Lindenbaum (`set_lindenbaum`)
4. Build BFMCS_Bundle from M (`construct_bfmcs_bundle`)
5. neg(phi) is in `eval_family.mcs(0) = M` (by construction)
6. Therefore phi is NOT in M (by MCS consistency: `mcs_neg_gives_countermodel`)
7. To reach a contradiction with `h_valid : valid_over Int phi`, we need:
   - Instantiate `valid_over` on the canonical model
   - At `eval_family`, time 0, the formula phi must be **true**
   - This requires: **neg(phi) in M implies neg(phi) TRUE in model**

Step 7 is a **forward** application of the truth lemma: membership in MCS implies truth.

The backward direction (truth implies membership) is never needed in this argument. The argument does not conclude "phi is true, therefore phi is in every MCS." It concludes "phi is not in M, therefore phi is not universally valid."

### The Completeness Gap: What `bundle_validity_implies_provability` Actually Needs

The sorry at line 214 is the "model-theoretic glue." Examining the proof structure carefully:

```
h_not_prov : ¬Nonempty ([] ⊢ phi)
h_cons : SetConsistent {neg phi}           [from not_provable_implies_neg_consistent]
_h : ¬(∀ M, SetMaximalConsistent M → phi ∈ M)  [from bundle_completeness_contradiction]
h_valid : valid_over Int phi
```

The sorry needs to bridge `h_valid` and `_h`. The bridge requires showing:

> If phi is valid over Int (true in ALL TaskModel/Omega/history/time combinations),
> then phi is in every MCS.

This bridge requires the **forward** direction of the truth lemma:
- phi in MCS M at time 0 implies phi is TRUE in the canonical model at (eval_family, 0)

The backward direction would be needed for: "phi is TRUE therefore phi is in MCS" — but that is not the structure here. The argument is:
- neg(phi) in M → neg(phi) TRUE (forward direction) → phi FALSE at some point → phi not valid → contradiction

### Proof Structure Analysis

**Cases in `shifted_truth_lemma` that use the backward direction** (CanonicalConstruction.lean:648-772):

| Case | Forward Used | Backward Used | Description |
|------|-------------|---------------|-------------|
| `atom` | yes | yes (backward is just `intro ⟨_, h_val⟩; exact h_val`) | Trivial; no coherence needed |
| `bot` | yes | backward is False.elim | Trivial; no coherence needed |
| `imp` | yes (line 678) | yes (line 680-702) | MCS negation completeness argument |
| `box` | yes (line 706-728) | yes (line 730-736) | Uses modal_backward |
| `all_future` (G) | yes (line 741-743) | **YES** (line 744-754) | Uses `temporal_backward_G` with same-family forward_F |
| `all_past` (H) | yes (line 759-761) | **YES** (line 762-772) | Uses `temporal_backward_H` with same-family backward_P |

**The critical backward cases for G and H** (lines 744-754 and 762-772):

For the G case backward direction:
```
-- Backward: (∀ s ≥ t, truth_at ... fam s psi) → G(psi) in fam.mcs t
intro h_all
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam  -- REQUIRES h_tc : B.temporally_coherent
-- constructs tcf : TemporalCoherentFamily
-- calls temporal_backward_G tcf t psi h_all_mcs
```

The `temporal_backward_G` proof (TemporalCoherence.lean:165-178) works by:
1. Assume G(psi) not in fam.mcs t
2. MCS gives: neg(G(psi)) = F(neg(psi)) in fam.mcs t
3. `fam.forward_F` gives: exists s > t, neg(psi) in **fam.mcs s** (SAME family)
4. Hypothesis gives: psi in fam.mcs s (SAME family, same s)
5. Contradiction: both psi and neg(psi) in fam.mcs s

**This contradiction is only possible if the witness lives in the same MCS as the original.**

With bundle-level coherence, step 3 would give neg(psi) in fam'.mcs s for potentially fam' ≠ fam. There is no contradiction possible because the hypothesis in step 4 gives "psi in fam.mcs s" (from the IH applied to fam), not "psi in fam'.mcs s."

### Forward-Only Truth Lemma: Mathematical Structure

A forward-only truth lemma for the bundle construction would have the form:

```
theorem bundle_forward_truth_lemma (B : BFMCS_Bundle)
    (phi : Formula) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    phi ∈ fam.mcs t →
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega_from_bundle B) (to_history fam) t phi
```

**Proof sketch by induction on phi**:

- `atom p`: phi in MCS → p in valuation → truth_at holds. (Trivial, no coherence needed.)
- `bot`: phi in MCS → False (since MCS is consistent). Vacuously true.
- `imp psi chi`: If psi → chi in MCS and psi is true, then psi in MCS (by backward IH applied to psi), then chi in MCS (MCS closure), then chi is true (by forward IH). **But this requires the backward IH for psi!**
- `box psi`: Box psi in MCS → psi in all families → truth for all histories in Omega. (Forward only; uses modal_forward.)
- `all_future psi` (G): G(psi) in MCS t → psi in fam.mcs s for all s ≥ t (by forward_G field of FMCS) → truth for all s ≥ t (by forward IH). **(Forward only; no temporal coherence needed for this direction!)**
- `all_past psi` (H): H(psi) in MCS t → psi in fam.mcs s for all s ≤ t (by backward_H field of FMCS) → truth for all s ≤ t (by forward IH). **(Forward only; no temporal coherence needed for this direction!)**

**Critical observation**: The `imp` case requires the backward direction of the IH for the antecedent `psi`. This is NOT avoidable in the standard formulation.

However, the completeness proof does not use `shifted_truth_lemma` on arbitrary formulas at the outermost level — it uses it on `neg(phi)`. For the negation case, `neg(phi) = phi.imp bot`. The imp backward case still requires the backward direction for phi, which recursively requires... the full biconditional for all subformulas.

### The `imp` Case is the Obstacle

The backward direction of the `imp` case (lines 679-702 of shifted_truth_lemma) uses:
```
rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
· exact h_imp  -- forward
· exfalso
  -- derives ψ ∈ fam.mcs t (backward IH application)
  have h_ψ_mcs : ψ ∈ fam.mcs t := ...
  -- derives neg(χ) ∈ fam.mcs t
  have h_neg_χ_mcs : χ.neg ∈ fam.mcs t := ...
  -- Forward IH: ψ ∈ MCS → truth ψ
  have h_ψ_true := (ih_ψ fam hfam t).mp h_ψ_mcs
  -- Applies hypothesis: truth ψ → truth χ
  have h_χ_true := h_truth_imp h_ψ_true
  -- Backward IH: truth χ → χ ∈ MCS
  have h_χ_mcs := (ih_χ fam hfam t).mpr h_χ_true
  exact set_consistent_not_both ...
```

The backward IH for `χ` is invoked at line 701. This is in the **backward** case of `imp`, not the forward case. The forward case (lines 676-678) uses only forward IH.

**However**: For the completeness proof, we apply the truth lemma to `neg(phi)` to get "neg(phi) is true." To conclude "phi is false," we use the semantics of neg(phi) = phi.imp bot:
- `phi.imp bot` is true means: if phi is true, then bot is true
- Since bot is never true, phi must be false

For this, we only need the **forward direction** of the truth lemma for `phi.imp bot`. The forward direction of the `imp` case is:
```
(ψ.imp χ) in MCS → (truth ψ → truth χ)
```
This uses the forward direction only (lines 676-678).

### Reconciliation: Forward Sufficiency for Completeness

The completeness argument via contrapositive needs precisely:

1. neg(phi) in M → neg(phi) true in model at (eval_family, time 0)
2. neg(phi) = phi.imp bot true → (phi true → bot true) → phi false

Step 1 requires: forward direction of truth lemma for `phi.imp bot`
Step 1 requires for `imp` forward: `(phi.imp bot) in MCS → (phi true → bot true)` ✓ (no backward direction)
The recursion over phi inside step 1... wait.

**Re-examining**: "neg(phi) in M implies neg(phi) true" is the forward direction of the truth lemma for `phi.imp bot`. But the **forward direction for `imp`** is:

```
(ψ.imp χ) in MCS → (truth_at ... ψ → truth_at ... χ)
```

This does NOT require backward IH at all! It uses forward IH for both ψ and χ... actually no. Looking at lines 676-678:
```lean
· intro h_imp h_ψ_true
  have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true   -- BACKWARD IH for ψ!
  exact (ih_χ fam hfam t).mp (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
```

The forward direction of `imp` uses the **backward IH for ψ** to convert "truth ψ" back to "ψ ∈ MCS"! This means the forward direction of `imp` itself requires the full biconditional for ψ.

Therefore, a forward-only truth lemma for `imp` is impossible in the current proof strategy. The MCS-membership-based proof strategy inherently requires the full biconditional.

### Alternative: Semantic Strategy Avoiding `imp` Backward Direction

The existing `bundle_completeness_contradiction` already avoids the truth lemma entirely:

```lean
theorem bundle_completeness_contradiction (phi : Formula)
    (h_cons : SetConsistent {neg phi}) :
    ¬(∀ M : SetMaximalConsistent, phi ∈ M)
```

This theorem shows: if neg(phi) is consistent, then there exists an MCS M that does NOT contain phi. This is a purely algebraic fact (Lindenbaum + consistency), requiring no truth lemma at all.

The gap in `bundle_validity_implies_provability` is:
- We have `_h : ¬(∀ M : SetMaximalConsistent, phi ∈ M)` (algebraic)
- We have `h_valid : valid_over Int phi` (semantic)
- We need a bridge: valid_over → all MCS contain phi

**This bridge is exactly the forward direction of the truth lemma**, applied specifically at the evaluation point.

## Recommendation

### Recommended Approach: Weaker Forward Truth Lemma

Implement a `bundle_forward_truth_lemma` with signature:

```lean
theorem bundle_forward_truth_lemma (B : BFMCS_Bundle)
    (φ : Formula) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t →
    truth_at CanonicalTaskModel Omega_from_B (to_history fam) t φ
```

**Mathematical justification**: This forward direction is provable with ONLY bundle-level coherence because:

- `atom`, `bot`: No coherence needed.
- `imp` forward: Requires backward IH for antecedent — this propagates the need for full biconditional to all proper subformulas. **This is unavoidable in standard strategy.**
- `box` forward: Needs `modal_forward` only (already in BFMCS_Bundle).
- `G`/`H` forward: Needs FMCS.forward_G / FMCS.backward_H only (built into FMCS structure), no temporal coherence needed.

The obstacle for `imp` is fundamental: any formula of the form `psi -> chi` in an MCS requires knowing that the truth of psi implies the truth of chi via the MCS structure, which inherently requires "truth of psi implies psi in MCS."

### True Resolution: The `valid_over` Bridge

The actual missing piece in `bundle_validity_implies_provability` is NOT the full truth lemma. It is a simpler bridge lemma:

```lean
-- If phi is valid over Int, then phi is in the canonical model's MCS at time 0
lemma valid_over_implies_in_canonical_mcs (phi : Formula)
    (h_valid : valid_over Int phi)
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    phi ∈ M
```

This would bridge `h_valid` to `¬_h` (contradicting that some MCS lacks phi).

But this bridge itself requires showing the canonical model satisfies valid_over, which requires the full truth lemma — the biconditional. We cannot escape the backward direction for the canonical model characterization.

### Summary of Mathematical Situation

| What We Want | What We Need | What We Have |
|---|---|---|
| Completeness: valid → provable | Full truth lemma (biconditional) | Bundle-level coherence only |
| Forward truth lemma | Still needs full biconditional for `imp` case | Bundle-level coherence |
| Bridge: valid_over → all MCS contain phi | Full truth lemma (for canonical model) | Sorry |

**The fundamental obstruction is not G/H backward cases — it is the `imp` forward case, which requires the backward IH for the antecedent.** The G/H backward cases are a secondary obstruction (requiring family-level coherence), but even eliminating G/H backward cases does not escape the `imp` issue.

The only viable paths are:
1. **Omega-enumeration construction**: Build families with actual family-level temporal coherence, enabling the full `shifted_truth_lemma` as proven.
2. **Alternative semantic argument**: Bypass the truth lemma entirely using a purely algebraic completeness argument (which appears to already exist in `bundle_completeness_contradiction` but lacks the bridge to `valid_over`).
3. **Alternative bridge lemma**: Prove valid_over implies membership in all MCS via soundness + proof-theoretic properties, not via truth lemma.

## Evidence

| Claim | File | Lines |
|-------|------|-------|
| G backward requires same-family forward_F | CanonicalConstruction.lean | 744-754 |
| H backward requires same-family backward_P | CanonicalConstruction.lean | 762-772 |
| `temporal_backward_G` contradiction requires same MCS | TemporalCoherence.lean | 165-178 |
| `imp` forward case uses backward IH for antecedent | CanonicalConstruction.lean | 677 (`.mpr`) |
| `imp` backward case uses backward IH for consequent | CanonicalConstruction.lean | 701 (`.mpr`) |
| Bundle-level coherence: witnesses in ANY family | UltrafilterChain.lean | 2536-2538 |
| Family-level coherence: witnesses in SAME family | TemporalCoherence.lean | 146-152 |
| `bundle_validity_implies_provability` sorry: model-theoretic glue | Completeness.lean | 186-214 |
| Core algebraic completeness (sorry-free) | UltrafilterChain.lean | 2931-2945 |
| valid_over definition: truth at ALL models/histories/times | Validity.lean | 53-58 |

## Confidence Level

**High** for the main structural finding: the backward direction of `imp` requires a full biconditional IH, making a purely forward truth lemma impossible in the current proof strategy.

**High** for the G/H backward cases: these genuinely require same-family temporal coherence (family-level, not bundle-level).

**Medium** for the alternative bridge approach (path 3 above): this would require tracing whether there is a proof-theoretic argument that avoids the semantic model entirely for the validity-to-provability bridge.

**High** that the omega-enumeration construction (path 1) is the most direct fix: it achieves family-level temporal coherence by construction, enabling the existing `shifted_truth_lemma` proof to go through unchanged.
