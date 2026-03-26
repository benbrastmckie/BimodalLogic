# Team Research Report: Task #58 - Options 1 & 3 Deep Analysis

**Task**: Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Mode**: Team Research (4 teammates)
**Session**: sess_1774549250_6a7845
**Focus**: Full detail analysis of Option 3 (direct algebraic completeness without truth lemma) and Option 1 (family-level temporal coherence construction)

## Summary

**Option 3 (algebraic completeness without truth lemma) is NOT VIABLE.** The algebraic path proves `(∀ MCS M, φ ∈ M) → prov φ`, but the target theorem is `valid_over Int φ → prov φ`. Connecting these requires showing `valid_over Int φ → ∀ MCS M, φ ∈ M`, which IS the truth lemma (contrapositive). There is no algebraic bypass.

**Option 1 (family-level temporal coherence) is BLOCKED for arbitrary MCS** because `f_nesting_is_bounded` is mathematically false. However, **restricted completeness via RestrictedMCS is viable** because F-nesting within `closureWithNeg(φ)` IS bounded.

**Recommended path**: Restricted completeness using RestrictedMCS, where the SuccChain approach succeeds because the formula closure is finite.

## Key Findings

### 1. Option 3: Truth Lemma Cannot Be Bypassed (Teammate A, HIGH confidence)

The algebraic completeness path IS sorry-free and proves:
```
¬prov(φ) → ∃ MCS M, φ ∉ M
```

But `valid_over Int φ` quantifies over ALL TaskModels, while MCS membership is syntactic. The truth lemma IS the canonical model theorem — it establishes that the canonical model "represents" the logic. Any completeness proof for semantic validity MUST establish this representation.

**Key evidence**: The forward direction of the truth lemma at the implication case (ParametricTruthLemma.lean:208) uses `.mpr` (backward IH):
```lean
have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
```

This creates an inherent mutual dependency between forward and backward directions. The truth lemma is **inherently bidirectional** — claims that "forward-only suffices" are incorrect.

**Attempted alternatives**:
- Syntactic completeness (`∀ MCS M, φ ∈ M → prov φ`): Already provable, but different theorem
- Restricted validity: Still requires truth lemma for connection
- Forward-only truth lemma: Impossible due to imp case bidirectionality

### 2. Option 1: f_nesting_is_bounded is FALSE for Arbitrary MCS (Teammate B, HIGH confidence)

**Counterexample**: The set `S = {F^n(p) | n ∈ ℕ}` is finitely consistent (any finite subset is satisfiable on ℤ). By Lindenbaum, S extends to an MCS M where F^n(p) ∈ M for ALL n. The F-nesting depth is unbounded.

**Consequence**: The SuccChain approach, which assumed F-nesting would be bounded so obligations eventually resolve, is fundamentally broken for arbitrary MCS. The sorry at `boxClassFamilies_temporally_coherent` (UltrafilterChain.lean:1822) is **permanent** via this approach.

**Omega-enumeration also fails**: The current `omega_chain_forward` only resolves `F_top` (= F(¬⊥)) at each step, NOT arbitrary F(φ) obligations. The sorry at `Z_chain_forward_F` (line 2485) reflects this.

### 3. G(φ) → □G(φ) is NOT Derivable (Teammate C, HIGH confidence)

**Countermodel**: Two-family bundle where fam1 has atom p TRUE at all times, fam2 has p FALSE at t ≥ 1. At (fam1, t=0): G(p) is TRUE but □G(p) is FALSE.

**Syntactic proof**: No TM axiom introduces □ from G. The axioms TF (`□φ → G(□φ)`) and MF (`□φ → □G(φ)`) both require □ as INPUT.

**Impact**: Bundle-level temporal coherence CANNOT be upgraded to family-level. The transfer from fam' to fam would require G(¬φ) → □G(¬φ), which is not derivable.

### 4. Restricted Completeness is the Viable Path (Teammate D synthesis, MEDIUM confidence)

For a SPECIFIC formula φ, `closureWithNeg(φ)` is **finite**. Within this closure:
- F-nesting IS bounded: `iter_F_not_mem_closureWithNeg` proves that `F^n(φ) ∉ closureWithNeg(φ)` for n ≥ `closure_F_bound(φ)`
- RestrictedMCS (M ⊆ closureWithNeg(φ)) avoids the unboundedness issue
- SuccChain-style construction SHOULD work for RestrictedMCS

**The restricted completeness path**:
1. For any unprovable φ, ¬φ is consistent
2. Extend to RestrictedMCS within closureWithNeg(φ)
3. Build restricted bundle with family-level temporal coherence (F-nesting bounded!)
4. Prove restricted truth lemma
5. Show restricted canonical model IS a valid TaskModel over ℤ
6. Derive contradiction with valid_over Int φ

## Synthesis

### Conflicts Resolved

**Conflict 1: Is the algebraic path a viable bypass?**
- Teammate A: NOT viable (proves different theorem) — **CORRECT**
- Prior plan 07: Suggested "algebraic alternative" as fallback — **INCORRECT**
- Resolution: The algebraic path proves `(∀ MCS, φ ∈ M) → prov φ`. Connecting to `valid_over Int φ` requires the truth lemma. No bypass exists.

**Conflict 2: Can we avoid family-level temporal coherence?**
- Teammate B: Proposes fair-scheduling to achieve family-level coherence
- Teammate C: Suggests "Accept Bundle-Level + Model Glue"
- Resolution: C's suggestion is **INCORRECT** — bundle-level alone doesn't suffice because `temporal_backward_G` requires same-family F-witnesses. B's fair-scheduling is viable but complex; **restricted completeness is simpler**.

**Conflict 3: Is restricted completeness sufficient?**
- Teammate B: RestrictedMCS avoids unboundedness; could prove restricted completeness first — **CORRECT direction**
- Teammate D: Identifies this as primary recommendation — **CONFIRMED**
- Open question: Does restricted completeness lift to full completeness? (70% confidence it does)

### Gaps Identified

1. **RestrictedMCS forward_F/backward_P status**: Not verified whether existing code already proves temporal coherence for restricted families
2. **Fair-scheduling consistency**: If fair-scheduling is needed, maintaining consistency across forced resolutions needs careful proof
3. **Restricted-to-full lifting**: Need to verify that RestrictedMCS countermodel is a valid TaskModel for the `valid_over` quantification

## Obstruction Chain (Final)

```
G(φ) → □G(φ) NOT DERIVABLE
    ├── Blocks bundle-to-family coherence upgrade
    ├── Blocks cross-family F transfer
    └── Forces same-family witnesses for truth lemma
            │
Imp case inherently bidirectional (ParametricTruthLemma.lean:208)
    └── Truth lemma MUST be bidirectional
            │
Truth lemma needs h_tc (family-level forward_F/backward_P)
    └── h_tc needs family-level temporal coherence
            │
f_nesting unbounded for arbitrary MCS
    ├── SuccChain BLOCKED (permanent)
    ├── Omega-enumeration BLOCKED (only resolves F_top)
    │
    └── BUT: f_nesting IS bounded for RestrictedMCS
             └── Restricted completeness path VIABLE
```

## Comparison of Approaches

| Approach | Complexity | Confidence | Risk | Status |
|----------|------------|------------|------|--------|
| **Restricted completeness** | LOW | 70% | May not lift to full | **RECOMMENDED** |
| Fair-scheduling chain | HIGH | 60% | Consistency proof hard | FALLBACK |
| Per-family Omega | MEDIUM | LOW | Changes semantics? | NOT ANALYZED |
| Algebraic bypass | N/A | 0% | Proves wrong theorem | **RULED OUT** |
| Accept gap | ZERO | N/A | Permanent sorry | LAST RESORT |

## Mathematical Summary

```
PROVEN (sorry-free):
  bundle_completeness_contradiction : ¬prov φ → ∃ MCS M, φ ∉ M
  not_provable_implies_neg_consistent : ¬prov φ → SetConsistent {¬φ}
  construct_bfmcs_bundle : MCS → BFMCS_Bundle
  boxClassFamilies_bundle_temporally_coherent : BundleTemporallyCoherent

BLOCKED (sorry, permanent for current approach):
  boxClassFamilies_temporally_coherent (line 1822) : family-level forward_F/backward_P
    → f_nesting_is_bounded FALSE for arbitrary MCS (counterexample: {F^n(p) | n ∈ ℕ})

RULED OUT:
  Option 3 (algebraic bypass) : proves (∀ MCS M, φ ∈ M) → prov φ, NOT valid_over → prov
  G(φ) → □G(φ) : NOT derivable (countermodel exists)
  Forward-only truth lemma : inherent bidirectionality at imp case

VIABLE (needs implementation):
  Restricted completeness via RestrictedMCS:
    f_nesting_is_bounded_restricted : TRUE (closureWithNeg is finite)
    iter_F_not_mem_closureWithNeg : F^n(φ) leaves closure at bounded n
    → restricted family-level temporal coherence achievable
    → restricted truth lemma provable
    → restricted completeness → full completeness (to verify)
```

## Recommendations

### Immediate Next Steps

1. **Verify RestrictedMCS infrastructure**: Check whether `f_nesting_is_bounded_restricted` is fully proven and whether restricted temporal coherence already exists
2. **Trace restricted truth lemma path**: Determine what's missing for a restricted truth lemma connecting RestrictedMCS to truth_at
3. **Verify lifting**: Confirm that for any unprovable φ, the restricted countermodel suffices for `¬valid_over Int φ`

### Implementation Path

**Phase 1**: Restricted family-level temporal coherence
- Use `f_nesting_is_bounded_restricted` + SuccChain to build coherent restricted families
- Prove `restricted_forward_F` and `restricted_backward_P`

**Phase 2**: Restricted truth lemma
- Adapt `parametric_canonical_truth_lemma` for RestrictedMCS
- The bounded F-nesting makes the G backward case go through

**Phase 3**: Wire to completeness
- Show restricted canonical model is valid TaskModel over ℤ
- Connect `valid_over Int φ` to restricted MCS membership
- Eliminate the sorry in `bundle_validity_implies_provability`

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Accuracy |
|----------|-------|--------|------------------|----------|
| A | Option 3 algebraic bypass | completed | Proved algebraic bypass impossible; traced imp bidirectionality | HIGH (95%) |
| B | Option 1 temporal coherence | completed | Explained f_nesting failure; proposed fair-scheduling + restricted path | HIGH |
| C | Mathematical obstructions | completed | Proved G→□G not derivable; mapped obstruction chain | HIGH (95-100%) |
| D | Synthesis | completed | Identified restricted completeness as best path; resolved conflicts | MEDIUM (70%) |

## References

- `ParametricTruthLemma.lean:200-309` — Truth lemma proof (imp at 200, G at 270, H at 290)
- `TemporalCoherence.lean:146-219` — TemporalCoherentFamily, temporally_coherent definitions
- `UltrafilterChain.lean:1816-1822` — Family-level temporal coherence (SORRY)
- `UltrafilterChain.lean:2424-2485` — Z_chain_forward_F (SORRY, omega only resolves F_top)
- `UltrafilterChain.lean:2725-2877` — Bundle-level coherence (sorry-free)
- `FrameConditions/Completeness.lean:186-214` — Target sorry (model-theoretic glue)
- `SubformulaClosure.lean:395-446` — f_nesting_depth, max_F_depth_in_closure
- `CanonicalTaskRelation.lean:175-182` — iter_F_not_mem_closureWithNeg (bounded within closure)
