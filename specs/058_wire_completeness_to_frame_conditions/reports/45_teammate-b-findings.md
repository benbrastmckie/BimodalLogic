# Teammate B Findings: Cross-Family F Transfer Investigation

**Task**: 58 - Wire Completeness to Frame Conditions
**Focus**: Investigate whether cross-family F transfer is mathematically provable
**Date**: 2026-03-26

---

## Key Findings

### 1. The Cross-Family F Transfer Theorem is **UNPROVABLE**

The theorem in question:
```lean
theorem cross_family_F_transfer (B : BFMCS_Bundle)
    (fam fam' : FMCS Int) (hfam : fam ∈ B.families) (hfam' : fam' ∈ B.families)
    (t s : Int) (h_lt : t < s) (phi : Formula)
    (h_phi : phi ∈ fam'.mcs s) :
    Formula.some_future phi ∈ fam.mcs t
```

**Verdict**: This theorem is FALSE. It cannot be proven because it would require information transfer between histories that is not supported by the TM semantics or axiom system.

### 2. The Contrapositive Chain Breaks at Step 3

The plan proposed this contrapositive approach:
```
1. F(φ) ∉ fam.mcs t (assumption for contrapositive)
2. G(¬φ) ∈ fam.mcs t (by MCS maximality + F ↔ ¬G¬)
3. □G(¬φ) ∈ fam.mcs t (NEED: does G(ψ) imply □G(ψ)?)
4. G(¬φ) ∈ fam'.mcs t (via modal_forward with □G(¬φ))
5. ¬φ ∈ fam'.mcs s for all s > t (via fam'.forward_G)
6. φ ∉ fam'.mcs s (MCS consistency)
7. Contradiction with hypothesis φ ∈ fam'.mcs s
```

**The critical failure point is Step 3**: G(ψ) does NOT imply □G(ψ).

---

## Proof Attempt Analysis

### Why G(ψ) → □G(ψ) is NOT a Theorem of TM

#### Semantic Counterexample

Consider a bundle with two histories τ₁ and τ₂:
- At history τ₁: atom p is true at all times s ≥ 0
- At history τ₂: atom p is false at all times

Evaluation at (τ₁, 0):
- **G(p) is TRUE**: ∀ s ≥ 0, p holds at (τ₁, s) ✓
- **□G(p) is FALSE**: G(p) at (τ₂, 0) requires p at all s ≥ 0 on τ₂, but p is false everywhere on τ₂ ✗

This is a valid TM model (satisfies all axioms) where G(p) ∧ ¬□G(p) holds.

#### Axiomatic Analysis

The TM axioms include:
- **MF**: □φ → □G(φ) — box implies box-of-G
- **TF**: □φ → G(□φ) — box implies G-of-box

Neither axiom provides G(φ) → □G(φ). The axioms only govern what happens when you START with □φ. There is no axiom or derivable rule that "lifts" a temporal fact to a modal fact.

This is by design: the modal and temporal dimensions are orthogonal in TM. Modal necessity (□) quantifies over histories at a fixed time, while temporal necessity (G) quantifies over times within a fixed history. There's no built-in mechanism to transfer information between these dimensions.

### What modal_forward Actually Provides

From `UltrafilterChain.lean:2765-2767`:
```lean
modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
  ∀ fam' ∈ families, φ ∈ fam'.mcs t
```

This transfers **φ** from fam to fam' at the **SAME time t**, but ONLY when **□φ** ∈ fam.mcs(t).

For the contrapositive chain to work, we would need □G(¬φ) ∈ fam.mcs(t), but we only have G(¬φ) ∈ fam.mcs(t). The "box-lifting" step is the unbridgeable gap.

### Why box_class_agree is Insufficient

The `boxClassFamilies` construction creates families that agree on Box-formulas (same Box-content), but this gives NO constraint on temporal formulas.

From report 30 (teammate-a-findings.md:100-104):
> "Let M0 contain G(p). Let W be in the box class of M0 but containing neg(G(p)). This W exists as long as G(p) is not in the box theory of M0. The family from W will NOT satisfy p ∈ fam_W.mcs(s) for all s."

Two MCS can be box-class equivalent while having opposite temporal content.

---

## Critical Gap

### The Fundamental Obstruction

**The TM semantics allows histories to disagree on temporal content while agreeing on modal content.**

This is not a bug but a feature of the logic:
1. □φ being true means φ is necessary across all possible histories
2. G(φ) being true means φ holds at all future times on THIS history
3. Different histories can have different futures — that's what makes them different histories

### Why This Blocks Completeness

The truth lemma for F backward requires:
```
truth_at F(φ) → F(φ) ∈ fam.mcs t
```

Where `truth_at F(φ)` = ∃ σ ∈ Omega, ∃ s > t, truth_at (σ, s) φ

The witness σ might be in a DIFFERENT family fam'. We have φ ∈ fam'.mcs(s), but need F(φ) ∈ fam.mcs(t).

The missing link: φ ∈ fam'.mcs(s) → F(φ) ∈ fam.mcs(t) (cross-family F transfer)

This is exactly the theorem that is unprovable.

---

## Evidence/Examples

### Evidence from Codebase

| Location | Finding |
|----------|---------|
| `UltrafilterChain.lean:265` | `box_class_agree` = same Box-formulas only, no temporal constraint |
| `UltrafilterChain.lean:1595-1670` | Only cross-family transfer is for Box(phi), not arbitrary phi |
| `UltrafilterChain.lean:2424-2485` | `Z_chain_forward_F` has sorry — same root cause |
| `UltrafilterChain.lean:2773-2775` | `bundle_forward_F` gives witness in SOME family, not same family |
| Report 30 (teammate-a) | Detailed analysis showing box-class equivalence doesn't constrain temporal content |

### The bundle_forward_F vs Same-Family Gap

The BFMCS_Bundle structure provides:
```lean
bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
  ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s
```

This is the "forward" direction — useful for the forward truth lemma (MCS membership → semantic truth).

But for the BACKWARD truth lemma, we need the converse:
```lean
-- What we need (but can't prove):
φ ∈ fam'.mcs s → Formula.some_future φ ∈ fam.mcs t  -- for arbitrary fam ≠ fam'
```

This converse is false because fam might not "know about" what happens in fam'.

---

## Confidence Level

**VERY HIGH (95%)** that cross-family F transfer is unprovable.

**Reasoning**:
1. Semantic counterexample shows G(ψ) → □G(ψ) is not valid
2. No TM axiom provides the required "temporal-to-modal lifting"
3. The codebase has no lemmas transferring non-modal content across families
4. Existing sorry at `Z_chain_forward_F` is at the same mathematical obstruction point
5. Report 30 (teammate-a) independently reached the same conclusion

---

## Mathematical Verdict

### **IMPOSSIBLE (with current semantics and axioms)**

The cross-family F transfer theorem cannot be proven because:

1. **Semantic Reason**: TM semantics explicitly allows histories to disagree on temporal content. The whole point of having multiple histories is that they represent different possible evolutions — they CAN disagree on what's true in the future.

2. **Axiomatic Reason**: The TM axiom system has no rule for deriving □G(φ) from G(φ). The MF and TF axioms only work in the opposite direction (starting from □φ).

3. **Structural Reason**: The `BFMCS_Bundle` construction via `boxClassFamilies` only constrains modal content. Families can have arbitrary temporal content as long as they're box-class equivalent to M0.

### Implications for Completeness

The bidirectional truth lemma CANNOT be proven with the current semantics. The F backward case has an irreducible gap.

Possible remediation paths (for plan consideration):
1. **Modify semantics**: Restrict Omega to histories that are "temporally coherent" in a stronger sense
2. **Weaker completeness**: Prove completeness for a fragment that doesn't require F backward
3. **Different construction**: Build families that share temporal content, not just modal content
4. **Accept the gap**: Document as a known limitation of TM over Int completeness

---

## Appendix: Axiom Reference

### Modal-Temporal Interaction Axioms
- **MF**: □φ → □G(φ) — "Necessary truths remain necessary in the future"
- **TF**: □φ → G(□φ) — "Necessary truths will always be necessary"

### What These Axioms Provide
- From □φ, we can derive □G(φ) and G(□φ)
- Combined with modal T (□ψ → ψ): □φ → G(φ)

### What These Axioms Do NOT Provide
- G(φ) → □G(φ) — temporal fact does not imply modal fact
- G(φ) → □φ — temporal necessity does not imply modal necessity
- φ ∈ fam'.mcs → φ ∈ fam.mcs — facts don't transfer between families
