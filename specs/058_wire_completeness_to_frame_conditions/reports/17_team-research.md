# Research Report: Task #58 — Bundle Truth Lemma Strategy

**Task**: Wire completeness to frame conditions
**Date**: 2026-03-26
**Mode**: Team Research (3 teammates, wave 3)
**Session**: sess_1774485353_66b16a
**Prior Report**: 16_mathematical-strategy.md (bundle-level coherence strategy)

## Summary

This report synthesizes findings from three complementary research angles on the bundle truth lemma approach: category-theoretic foundations (A), Lean implementation patterns (B), and modal logic theory (C).

**Convergent conclusion**: The **forward-only truth lemma** is the correct and elegant approach. Completeness only requires the forward direction (MCS membership → semantic truth), which does NOT use temporal coherence at all. The forward direction uses only `fam.forward_G` and `fam.backward_H` from the `FMCS` structure, plus `B.modal_forward` from `BFMCS_Bundle`. This requires approximately **125 lines of new Lean code** and no new mathematical insights.

## Key Findings

### 1. Forward-Only Truth Lemma Suffices for Completeness (All 3 teammates, HIGH confidence)

The completeness argument is by contraposition:
1. Assume phi is NOT provable
2. Then neg(phi) is consistent → extend to MCS M via Lindenbaum
3. Build `BFMCS_Bundle B` from M (sorry-free)
4. Apply **forward** truth lemma: neg(phi) ∈ M → truth_at(neg phi) → ¬truth_at(phi)
5. But `valid_over Int phi` says phi is true at ALL models — contradiction

Step 4 only needs the **forward** direction: MCS membership → truth in canonical model. The backward direction (truth → MCS membership) is never used.

### 2. Forward Truth Lemma Does NOT Use Temporal Coherence (A, B — HIGH confidence)

The forward direction proof by induction on phi:

| Case | Forward Direction | What It Uses |
|------|-------------------|-------------|
| atom | atom ∈ fam.mcs(t) → truth_at atom | Valuation definition |
| bot | bot ∉ MCS → ¬truth_at bot | MCS consistency |
| imp | Standard MCS closure | MCS maximality |
| box | Box(phi) ∈ fam.mcs(t) → truth at all histories | `B.modal_forward` + `parametric_box_persistent` |
| G (all_future) | G(phi) ∈ fam.mcs(t) → phi at all s ≥ t | `fam.forward_G` (FMCS field) |
| H (all_past) | H(phi) ∈ fam.mcs(t) → phi at all s ≤ t | `fam.backward_H` (FMCS field) |
| F (some_future) | F(phi) ∈ fam.mcs(t) → exists witness | `B.bundle_forward_F` + IH |
| P (some_past) | P(phi) ∈ fam.mcs(t) → exists witness | `B.bundle_backward_P` + IH |

**Critical observation** (Teammate B): `forward_G` and `backward_H` are fields of `FMCS`, NOT of `TemporalCoherentFamily`. They are available in every family without any temporal coherence hypothesis. The temporal coherence fields (`forward_F`, `backward_P`) are only used in the **backward** direction of the truth lemma (for G/H backward cases via `temporal_backward_G/H`).

### 3. Bundle Semantics is Standard and Sound (C — HIGH confidence)

- **Jonsson-Tarski canonical models** naturally produce bundles where F-witnesses can come from any family
- **Goldblatt (1992)** and **Burgess (1984)** use cross-timeline witnesses in completeness proofs
- **Soundness preserved**: the bundle model IS a standard Kripke model; all TM axioms (Box S5, G/H temporal, MF, TF) remain valid
- The forward truth lemma direction is all that completeness requires

### 4. ShiftClosedBundleOmega is Straightforward (A, B — HIGH confidence)

Define:
```lean
def ShiftClosedBundleOmega (B : BFMCS_Bundle) :
    Set (WorldHistory (ParametricCanonicalTaskFrame Int)) :=
  { σ | ∃ (fam : FMCS Int) (_ : fam ∈ B.families) (delta : Int),
    σ = WorldHistory.time_shift (parametric_to_history fam) delta }
```

Shift-closure proof is ~8 lines using `time_shift` composition (identical structure to existing `shiftClosedParametricCanonicalOmega_is_shift_closed` in ParametricHistory.lean).

### 5. Full Truth Lemma Is Also Possible (C — MEDIUM-HIGH confidence)

Teammate C identified that `bundle_temporal_backward_G/H` lemmas CAN be proved:

```lean
theorem bundle_temporal_backward_G (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula)
    (h_all : ∀ fam' ∈ B.families, ∀ s : Int, t < s → phi ∈ fam'.mcs s) :
    Formula.all_future phi ∈ fam.mcs t
```

Proof by contraposition: assume G(phi) ∉ fam.mcs(t), then F(¬phi) ∈ fam.mcs(t), by bundle_forward_F get fam' with ¬phi ∈ fam'.mcs(s), contradicting h_all.

**However**, this requires the truth lemma hypothesis to provide phi in ALL families, not just one. Standard Kripke semantics for G only provides truth along one history. This means:
- A full bundle truth lemma needs a modified semantic interpretation where G quantifies over the bundle, OR
- The forward-only approach is cleaner and sufficient for completeness

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A says backward direction requires new semantic framework; C says bundle_backward_G is provable | COMPATIBLE: C's lemma IS provable but requires a stronger hypothesis (phi in ALL families) than standard Kripke semantics provides. For the completeness argument, the forward-only approach (A & B) is simpler and sufficient. |
| B suggests copying existing parametric_shifted_truth_lemma forward cases; A suggests defining new BundleCanonicalOmega | COMPATIBLE: Both are needed. The forward cases are structurally identical, but the Omega definition must change to use BFMCS_Bundle families. |

### The Converged Strategy

**Single implementation path** (~125 lines new code):

1. **Define `ShiftClosedBundleOmega`** (~5 lines) — analogous to existing ShiftClosedParametricCanonicalOmega
2. **Prove shift-closure** (~8 lines) — identical structure to existing proof
3. **Prove `bundle_shifted_truth_lemma_forward`** (~80 lines) — forward direction by induction
   - Copy forward cases from existing `parametric_shifted_truth_lemma`
   - Adapt box case to use `B.modal_forward` from BFMCS_Bundle
   - F/P forward cases use `B.bundle_forward_F/P`
4. **Prove `bundle_validity_implies_provability`** (~30 lines) — the completeness wiring
   - Contrapositive: not provable → neg consistent → MCS → BFMCS_Bundle → forward truth → ¬valid

### Why This is Mathematically Correct

The forward-only truth lemma captures the essential completeness argument:
- If phi is not provable, we construct a model where phi is false
- The model construction (BFMCS_Bundle) is sorry-free
- The truth lemma (forward direction) maps MCS membership to semantic truth without any temporal coherence
- The contradiction comes from validity (phi true in ALL models) vs the constructed countermodel

This follows standard practice in modal logic completeness proofs (Goldblatt, Burgess, Blackburn-de Rijke-Venema).

## Effort Estimate

| Component | Lines | Hours | Risk |
|-----------|-------|-------|------|
| ShiftClosedBundleOmega definition + proof | 13 | 0.5 | LOW |
| bundle_shifted_truth_lemma_forward | 80 | 3 | MEDIUM |
| bundle_validity_implies_provability | 30 | 1 | LOW |
| Wire dense/discrete completeness | 20 | 1 | MEDIUM |
| **Total** | **~143** | **~5.5** | |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (category-theory) | Categorical foundations, forward-only insight | completed | HIGH |
| B (lean-implementation) | Code analysis, concrete implementation path | completed | HIGH |
| C (modal-logic) | Theoretical soundness, bundle_backward_G | completed | HIGH |

## References

### Teammate Reports
- `specs/058_wire_completeness_to_frame_conditions/reports/17_teammate-a-findings.md`
- `specs/058_wire_completeness_to_frame_conditions/reports/17_teammate-b-findings.md`
- `specs/058_wire_completeness_to_frame_conditions/reports/17_teammate-c-findings.md`

### Key Source Files
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — BFMCS_Bundle, construct_bfmcs_bundle
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` — parametric_shifted_truth_lemma (template)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` — ShiftClosedParametricCanonicalOmega (template)
- `Theories/Bimodal/FrameConditions/Completeness.lean` — Target sorries

### Literature
- Jonsson-Tarski (1951-52): "Boolean Algebras with Operators" — canonical models as bundles
- Goldblatt (1992): "Logics of Time and Computation" — completeness for tense logics
- Burgess (1984): "Basic Tense Logic" — cross-timeline witnesses
- Blackburn, de Rijke, Venema (2001): "Modal Logic" Chapter 4 — bundle completeness
