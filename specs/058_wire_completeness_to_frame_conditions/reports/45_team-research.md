# Team Research Report: Task #58 - Bidirectional Truth Lemma Deep Analysis

**Task**: Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Mode**: Team Research (4 teammates)
**Session**: sess_1774547973_caf33a
**Focus**: Strict semantics adherence, F backward gap, G-Box interaction, alternative paths

## Summary

**CRITICAL CORRECTION**: Plan 07's "F Backward Problem" is based on a WRONG reading of the official TM semantics. The plan claims `truth_at F(φ) = ∃ σ ∈ Omega, ∃ s > t, truth_at (σ, s) φ`, which incorrectly adds cross-history quantification. The actual definition:

```
truth_at F(φ) at (τ, t) = ∃ s ≥ t, truth_at (M, Omega, τ, s) φ  (SAME τ!)
```

Temporal operators (G, H, F, P) do NOT change the history. Only Box (□) quantifies over different histories. **The "cross-family F transfer" problem was a phantom** — but an underlying obstruction IS real, just located elsewhere.

**The ACTUAL obstruction**: The truth lemma backward G case uses `temporal_backward_G`, which relies on `forward_F` (same-family F witnesses) via contraposition. The `BFMCS_Bundle` construction only proves **bundle-level** F coherence (cross-family witnesses), not **family-level** (same-family witnesses). This gap cannot be bridged because G(φ) → □G(φ) is not derivable.

## Key Findings

### 1. Semantics Misreading in Plan 07 (Lead Analysis)

Plan 07's "F Backward Problem in Detail" (lines 45-51) states:
```
1. truth_at F(φ) = ∃ σ ∈ Omega, ∃ s > t, truth_at (σ, s) φ
```

This is **WRONG**. From Truth.lean:125:
```lean
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

The history `τ` is the **SAME** throughout temporal evaluation. F(φ) = ¬G(¬φ), so:
```
truth_at F(φ) at (M, Omega, τ, t) = ∃ s ≥ t, truth_at (M, Omega, τ, s) φ
```

No σ ∈ Omega quantification. The cross-history quantification is ONLY for Box:
```lean
| Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```

**Teammate A partially repeated this error** in their finding #3 (line 74 of their report). Teammate D correctly identified that the current semantics already restricts F to same-history witnesses.

### 2. The Backward Direction IS Required (Teammates A, D conflict resolved)

**Teammate A**: Backward direction IS required — CORRECT
**Teammate D**: Forward-only suffices — INCORRECT

Evidence from ParametricTruthLemma.lean:

**Forward imp case (line 208)** uses backward IH:
```lean
have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
```

The forward direction of the truth lemma for implication inherently needs the backward IH:
- To prove (φ → ψ) ∈ MCS implies (truth φ → truth ψ)
- Assume truth φ
- Need to get φ ∈ MCS (backward IH!) to apply MCS modus ponens
- Then get ψ ∈ MCS, then apply forward IH

This cannot be avoided — the imp case creates a mutual dependency between forward and backward. The proof is **inherently bidirectional**.

### 3. G(φ) → □G(φ) is NOT Derivable (Teammates B, C converge)

Both teammates independently produced semantic countermodels:

**Countermodel**: Two-family bundle:
- Family fam1: atom p TRUE at all t ≥ 0
- Family fam2: atom p FALSE at t ≥ 1

At (fam1, t=0): G(p) is TRUE but □G(p) is FALSE.

**Syntactic argument**: No TM axiom or rule introduces □ from G. MF gives □φ → □G(φ), TF gives □φ → G(□φ) — both require □ as INPUT. Necessitation only applies to theorems, not contingent truths.

**Confidence**: 95% from both teammates.

### 4. The REAL Obstruction (Lead Synthesis)

The truth lemma requires `B.temporally_coherent` (TemporalCoherence.lean:216):
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t φ, F(φ) ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧  -- forward_F (SAME family!)
    (∀ t φ, P(φ) ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s)    -- backward_P (SAME family!)
```

This is used in the backward G case (ParametricTruthLemma.lean:280-289):
```lean
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
let tcf : TemporalCoherentFamily D := { toFMCS := fam, forward_F := h_forward_F, backward_P := h_backward_P }
...
exact temporal_backward_G tcf t psi h_all_mcs
```

The `temporal_backward_G` proof works by contraposition:
1. Assume G(φ) ∉ fam.mcs t
2. Then F(¬φ) ∈ fam.mcs t (MCS maximality + temporal duality)
3. By **forward_F (SAME family!)**: ∃ s > t, ¬φ ∈ fam.mcs s
4. But backward IH gives φ ∈ fam.mcs s for all s > t — contradiction

Step 3 is where the gap lies. `BFMCS_Bundle` only proves:
```lean
-- Bundle-level (sorry-free, UltrafilterChain.lean:2730):
theorem boxClassFamilies_bundle_temporally_coherent :
    BundleTemporallyCoherent (boxClassFamilies M0 h_mcs)
-- Gives: F(φ) ∈ fam.mcs t → ∃ fam' ∈ bundle, ∃ s > t, φ ∈ fam'.mcs s
```

But the truth lemma needs **family-level** (same family, BLOCKED):
```lean
-- Family-level (sorry at line 1822):
theorem boxClassFamilies_temporally_coherent :
    ∀ fam ∈ boxClassFamilies M0 h_mcs, forward_F ∧ backward_P  -- SORRY
```

**Why bundle-level doesn't suffice**: The contraposition gives ¬φ ∈ fam'.mcs s (different family). We need ¬φ ∈ fam.mcs s (same family) to contradict the hypothesis. Transferring from fam' to fam would require G(¬φ) → □G(¬φ), which is not derivable.

### 5. Alternative Paths Assessment (Teammate D + Lead correction)

| Strategy | Teammate D Assessment | Lead Correction |
|----------|----------------------|-----------------|
| A: Bundle-quantified semantics | Would break soundness | MOOT — semantics already uses same history for F |
| B: Algebraic bypass | Already sorry-free | Incomplete — still needs TaskModel bridge |
| C: Restricted fragment | F-free doesn't help | Correct — G backward needs forward_F regardless |
| D: Accept gap | "Not an open problem" | Wrong — it IS a genuine construction gap |

**Teammate D's core error**: Claiming the "forward-only truth lemma suffices" ignores the inherent bidirectionality at line 208. The model-theoretic bridge requires the full truth lemma, which requires temporal coherence.

## Synthesis

### Conflicts Resolved

**Conflict 1: Forward-only vs. bidirectional truth lemma**
- Teammate A: Bidirectional required — **CORRECT**
- Teammate D: Forward-only suffices — **INCORRECT**
- Evidence: ParametricTruthLemma.lean:208 uses `.mpr` in the forward imp case
- The mutual induction is inherent to the proof structure

**Conflict 2: Is cross-family F transfer the real problem?**
- Teammates B, C: Cross-family F transfer impossible (G → □G fails) — **CORRECT finding, WRONG framing**
- The "cross-family F transfer" was never about truth_at semantics (Plan 07's error)
- The real issue is family-level vs bundle-level temporal coherence
- But the impossibility of G → □G IS why bundle-level can't be upgraded to family-level

**Conflict 3: Is this "just model-theoretic plumbing"?**
- Teammate D: Yes, just plumbing — **INCORRECT**
- Lead analysis: The plumbing REQUIRES the bidirectional truth lemma, which REQUIRES family-level temporal coherence, which is a deep construction problem (the original SuccChain approach failed)

### Gaps Identified

1. **No family-level temporal coherence proof** for `BFMCS_Bundle` families (the sorry at UltrafilterChain.lean:1822)
2. **No alternative construction** that provides family-level forward_F/backward_P
3. **No proof that the gap is unbridgeable** — the SuccChain approach failed due to `f_nesting_is_bounded` being false, but other constructions might work

### The Mathematically Correct Path Forward

**Option 1: Prove family-level temporal coherence (NEW CONSTRUCTION)**

Build FMCS families where forward_F holds within each family. This requires:
- Constructing MCS chains over ℤ where F-obligations are resolved within the same chain
- The omega-enumeration approach (construct_bfmcs_omega) tried this but only achieved bundle-level
- A Henkin-style construction that explicitly handles F-obligations at each successor step might work
- Key challenge: ensuring the chain is consistent AND handles ALL F-obligations (not just finitely many)

**Option 2: Alternative truth lemma formulation**

Restructure the truth lemma to use bundle-level coherence:
- Define Omega as histories from a SINGLE family (not the whole bundle)
- Then F witnesses are automatically same-family
- But this changes what □ quantifies over (only same-family histories)
- Would require re-proving soundness

**Option 3: Direct algebraic completeness without truth lemma**

The algebraic side is sorry-free:
- `not_provable_implies_neg_consistent` ✓
- `construct_bfmcs_bundle` ✓
- `mcs_neg_gives_countermodel` ✓

What's missing: connecting `valid_over Int φ` to "all MCSes contain φ" without a truth lemma. This seems fundamentally difficult because `valid_over` is defined semantically and MCS membership is syntactic — the truth lemma IS the bridge.

**Option 4: Restricted Omega per family**

For each family fam, define `Omega_fam = {parametric_to_history fam'}` restricted to family-compatible histories. Use a per-family truth lemma where temporal witnesses are same-family by construction, then combine across families for the Box case.

This is architecturally similar to Option 2 but preserves the Box quantification structure.

## Recommendations

**Recommended path**: Option 1 (new construction for family-level temporal coherence), with Option 4 as fallback.

The mathematical question reduces to: **Can we build FMCS families over ℤ where each family satisfies forward_F and backward_P (same-family witnesses)?**

This is a constructive existence question. The SuccChain approach failed because it depended on the false `f_nesting_is_bounded`. But formulas are finite structures — F-nesting IS bounded by formula size. The original proof may have had a more subtle error. A fresh investigation of this construction, with correct nesting bounds, could resolve the gap.

**Immediate next steps**:
1. Investigate WHY `f_nesting_is_bounded` was false — was it the definition or the bound?
2. Determine if a corrected version can provide family-level forward_F
3. If yes: implement and connect to the existing truth lemma
4. If no: pursue Option 4 (per-family Omega restriction)

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Accuracy |
|----------|-------|--------|------------------|----------|
| A | Semantics adherence | completed | Confirmed backward direction required; identified .mpr usage | HIGH (minor error on F semantics line 74) |
| B | Cross-family F transfer | completed | Proved F transfer impossible via G → □G | HIGH (correct finding, wrong framing) |
| C | G-Box interaction | completed | Proved G → □G not derivable with countermodel | HIGH |
| D | Alternative paths | completed | Identified algebraic path is sorry-free | MEDIUM (incorrectly claimed forward-only suffices) |

## Mathematical Summary

```
PROVEN (sorry-free):
  construct_bfmcs_bundle : MCS → BFMCS_Bundle                    [UltrafilterChain.lean:2853]
  boxClassFamilies_bundle_temporally_coherent : BundleTemporallyCoherent  [UltrafilterChain.lean:2730]
  bundle_completeness_contradiction : ¬prov φ → ¬(∀ M, MCS M → φ ∈ M)  [UltrafilterChain.lean]
  parametric_shifted_truth_lemma : h_tc → (φ ∈ M ↔ truth_at ...)       [ParametricTruthLemma.lean:325]

BLOCKED (sorry):
  boxClassFamilies_temporally_coherent : family-level forward_F/backward_P  [UltrafilterChain.lean:1822]

KEY INSIGHT:
  parametric_shifted_truth_lemma NEEDS family-level h_tc (ParametricTruthLemma.lean:280)
  bundle-level coherence is NOT sufficient (G → □G not derivable)

SEMANTICS CORRECTION:
  truth_at F(φ) at (τ, t) = ∃ s ≥ t, truth_at (τ, s) φ  -- SAME τ, no σ ∈ Omega!
  Plan 07 INCORRECTLY states: truth_at F(φ) = ∃ σ ∈ Omega, ∃ s > t, truth_at (σ, s) φ
  Cross-family F transfer was a phantom problem based on this misreading
  The REAL gap is family-level temporal coherence for the G backward contraposition
```

## References

- `Semantics/Truth.lean:118-126` — Official truth_at definition
- `ParametricTruthLemma.lean:200-309` — Truth lemma proof (imp at 200, G at 270, H at 290)
- `TemporalCoherence.lean:146-219` — TemporalCoherentFamily, temporally_coherent definitions
- `UltrafilterChain.lean:1816-1822` — Family-level temporal coherence (SORRY)
- `UltrafilterChain.lean:2725-2877` — Bundle-level coherence and BFMCS_Bundle (sorry-free)
- `FrameConditions/Completeness.lean:186-214` — Target sorry (model-theoretic glue)
- `ParametricRepresentation.lean:193,212` — .mpr usage confirming backward direction needed
