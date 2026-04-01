# Research Report: Task #81 (Run 3) — Teammate B Findings
# Zorn's Lemma Approach for F/P Witnesses

**Date**: 2026-03-31
**Scope**: Zorn on partial temporal families for constructing temporally coherent FMCS
**Focus**: Partial order definition, chain upper bounds, maximal = total, coherence preservation

---

## Executive Summary

**Confidence: MEDIUM-HIGH (theoretical soundness) / MEDIUM (implementation feasibility)**

The Zorn approach is **mathematically sound in principle** but faces significant **formalization complexity**. The construction requires:

1. A well-defined partial order on "partial FMCS" (functions from finite subsets of Z to MCS)
2. Proof that chains have upper bounds (via union)
3. Proof that maximal elements have total domain (Z itself)
4. Proof that maximal elements satisfy `forward_F` and `backward_P`

The key insight is that `temporal_theory_witness_exists` and `past_theory_witness_exists` provide the "finite consistency engine" needed to extend partial families, but the full construction requires careful handling of coherence conditions on partial domains.

---

## 1. Partial Order Formulation

### Definition: Partial FMCS

A **partial FMCS** is a structure:

```lean
structure PartialFMCS where
  dom : Finset Int              -- Finite domain
  mcs : Int → Set Formula       -- MCS assignment (only meaningful on dom)
  is_mcs : ∀ t ∈ dom, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t' φ, t ∈ dom → t' ∈ dom → t ≤ t' →
              Formula.all_future φ ∈ mcs t → φ ∈ mcs t'
  backward_H : ∀ t t' φ, t ∈ dom → t' ∈ dom → t' ≤ t →
               Formula.all_past φ ∈ mcs t → φ ∈ mcs t'
```

**Key Design Choice**: The coherence conditions (`forward_G`, `backward_H`) are restricted to the **finite domain**. This is essential because:
- Full G/H coherence on infinite domain would be impossible to satisfy during construction
- Finite coherence can be verified for each extension step
- The full coherence emerges in the limit (maximal element)

### Partial Order Definition

The partial order is **domain extension with agreement**:

```
p ≤ q iff
  (1) p.dom ⊆ q.dom
  (2) ∀ t ∈ p.dom, p.mcs t = q.mcs t
```

This is clearly reflexive, antisymmetric (by function extensionality on common domain), and transitive.

**Mathlib Reference**: This pattern matches `zorn_le₀` and `zorn_subset` in `Mathlib.Order.Zorn`.

---

## 2. Chain Upper Bound Argument

### Claim: Every chain of PartialFMCS has an upper bound

**Proof Sketch**:

Let `C` be a chain of PartialFMCS (totally ordered by ≤).

**Step 1: Define the union**
```
dom_union = ⋃ {p.dom | p ∈ C}
mcs_union(t) = p.mcs(t) for any p ∈ C with t ∈ p.dom
```

The union is well-defined because C is a chain: if `t ∈ p.dom ∩ q.dom` for `p, q ∈ C`, then either `p ≤ q` or `q ≤ p`, so `p.mcs t = q.mcs t`.

**Step 2: Union satisfies is_mcs**

For any `t ∈ dom_union`, there exists `p ∈ C` with `t ∈ p.dom`. Then `mcs_union(t) = p.mcs(t)`, which is MCS by `p.is_mcs t`.

**Step 3: Union satisfies forward_G on finite queries**

For any `t, t' ∈ dom_union` with `t ≤ t'`, there exist `p, q ∈ C` with `t ∈ p.dom` and `t' ∈ q.dom`. Since C is a chain, WLOG `p ≤ q`, so `t ∈ q.dom`. Then the forward_G property follows from `q.forward_G`.

**Step 4: Union is an upper bound**

For any `p ∈ C`: `p.dom ⊆ dom_union` and `p.mcs t = mcs_union t` for `t ∈ p.dom`.

**Caveat: dom_union may be infinite**

The union of a chain of finite sets may be infinite (e.g., {0}, {0,1}, {0,1,2}, ...). This is actually **required** for the maximal element to have domain Z.

However, we must verify that the coherence conditions still hold on the infinite domain. This requires showing that `forward_G` and `backward_H` are preserved under directed unions.

**Mathlib References**:
- `IsChain.pairwise_iUnion₂` for properties preserved under chain union
- `Submodule.mem_iSup_of_directed` for membership in directed supremum

---

## 3. Maximal = Total Argument

### Claim: A maximal PartialFMCS has domain = Z

**Proof by Contradiction**:

Suppose `p` is maximal but `dom(p) ≠ Z`. Then there exists `n ∈ Z \ dom(p)`.

**Case A: n > max(dom(p))**

We construct `q` extending `p` by adding time `n`:

1. Take any `t₀ ∈ dom(p)` (exists by construction starting from nonempty)
2. Let `M₀ = p.mcs(t₀)`
3. If `F(φ) ∈ M₀` for some obligation, use `temporal_theory_witness_exists` to get `W` with:
   - `SetMaximalConsistent W`
   - `φ ∈ W`
   - `G_theory M₀ ⊆ G_theory W` (G-formulas preserved)
   - `box_class_agree M₀ W`

4. Define `q.mcs(n) = W` (or any G-theory-consistent MCS if no obligations)
5. Extend coherence to new domain

**Key Lemma Required**: The extension preserves `forward_G` on the larger domain.

This is where `temporal_theory_witness_exists` provides the "finite consistency engine":
- `G(a) ∈ M → G(a) ∈ W` ensures G-formulas propagate forward
- The new MCS at `n` inherits the G-content from earlier times

**Case B: n < min(dom(p))**

Symmetric using `past_theory_witness_exists` and H-theory preservation.

**Case C: n is between elements of dom(p)**

Most complex case. Need to ensure the new MCS at `n` is consistent with both:
- G-formulas from earlier times
- H-formulas from later times

This requires showing that `G_theory(earlier) ∪ H_theory(later)` is consistent, which follows from the existing coherence of `p` and the fact that G/H formulas are dual.

**Conclusion**: If `p` is not total, we can always extend it, contradicting maximality.

---

## 4. Temporal Coherence of Maximal Elements

### Claim: A maximal (hence total) PartialFMCS satisfies forward_F and backward_P

This is the **most delicate part** of the argument.

**forward_F**: If `F(φ) ∈ fam.mcs(t)`, need `∃ s ≥ t, φ ∈ fam.mcs(s)`.

**Proof Sketch**:

1. `F(φ) ∈ fam.mcs(t)` means the F-obligation exists at time t
2. By `temporal_theory_witness_exists`, there exists an MCS `W` with:
   - `φ ∈ W`
   - `G_theory(fam.mcs(t)) ⊆ G_theory(W)`
3. The question is: **Is this W equal to fam.mcs(s) for some s ≥ t?**

**Critical Issue**: `temporal_theory_witness_exists` gives us a **fresh** MCS `W`, not necessarily one already in the family.

**Resolution via Zorn**:

During the Zorn construction, when we extend the partial family at time `n`, we can **choose** `fam.mcs(n)` to be the witness MCS for any outstanding F-obligation from earlier times.

More precisely:
- At each extension step, enumerate outstanding F-obligations (finite set for finite domain)
- Use fair scheduling (e.g., Nat.unpair) to resolve each obligation eventually
- When resolving `F(φ) ∈ fam.mcs(t)`, choose `fam.mcs(n)` to be the Lindenbaum extension containing `φ`

**Key Insight**: The Zorn approach **chooses** the MCS at each new time point. By making coherent choices guided by the witness theorems, we can ensure all F-obligations are eventually resolved within the same family.

This is analogous to the dovetailed construction (UltrafilterChain.lean:3685-3711) but phrased non-constructively.

### backward_P: Symmetric

Use `past_theory_witness_exists` for past direction. When extending domain downward (adding smaller times), resolve P-obligations using H-theory-consistent witnesses.

---

## 5. Key Lemmas Required

| Lemma | Statement | Difficulty |
|-------|-----------|------------|
| `chain_union_is_upper_bound` | Union of chain of PartialFMCS is PartialFMCS and upper bound | Medium |
| `partial_fmcs_nonempty` | PartialFMCS exists (start from single-point family) | Easy |
| `maximal_has_total_domain` | Maximal PartialFMCS has dom = Z | Medium-Hard |
| `extension_preserves_G_coherence` | Adding time point preserves forward_G | Medium |
| `extension_preserves_H_coherence` | Adding time point preserves backward_H | Medium |
| `maximal_satisfies_forward_F` | Maximal element satisfies forward_F | Hard |
| `maximal_satisfies_backward_P` | Maximal element satisfies backward_P | Hard |

**Particularly Hard Lemmas**:

`maximal_satisfies_forward_F` is hard because:
- The Zorn construction doesn't directly track F-obligations
- We need to argue that if an F-obligation is not resolved, the family could be extended
- This requires showing the extension is consistent (using witness theorems)

This is essentially proving **by contradiction in the meta-level**: if `forward_F` fails, then the family wasn't maximal.

---

## 6. Risks and Blockers

### Risk 1: Infinite Coherence Preservation (HIGH)

The chain upper bound may have infinite domain, requiring `forward_G`/`backward_H` to hold on infinitely many pairs. Need to verify this follows from the directed union structure.

**Mitigation**: Use Mathlib's `Submodule.mem_iSup_of_directed` pattern — properties that hold "eventually" in a directed system hold in the supremum.

### Risk 2: Fair Scheduling Encoding (MEDIUM)

The "resolve F-obligations fairly" argument is informal. In Lean, we'd need to either:
- Encode the scheduling explicitly (similar to dovetailed chain)
- Argue abstractly that **some** choice sequence works

**Mitigation**: The Zorn approach is inherently non-constructive. We can use classical reasoning to assert the existence of good choices without constructing them.

### Risk 3: Interaction Between G and H Constraints (MEDIUM)

When filling in a "gap" in the domain, the new MCS must satisfy both:
- G-formulas from the past
- H-formulas from the future

Need to verify `G_theory(past) ∪ H_theory(future) ∪ {formulas to witness}` is consistent.

**Mitigation**: This follows from the temporal duality: G and H are S4-like modalities, so their theories don't conflict when the underlying family is coherent.

### Risk 4: Formalization Complexity (HIGH)

The Zorn construction, while mathematically elegant, requires:
- Defining PartialFMCS correctly
- Proving chain upper bounds
- Handling the infinite/finite domain transition
- Connecting back to the original FMCS/TemporalCoherentFamily types

This is likely **more code** than the dovetailed chain approach.

---

## 7. Comparison with Dovetailed Approach

| Aspect | Zorn Approach | Dovetailed Chain |
|--------|--------------|------------------|
| **Constructivity** | Non-constructive (Choice, Zorn) | Constructive (explicit chain) |
| **Conceptual clarity** | High (maximal = complete) | Medium (fair scheduling) |
| **Proof complexity** | Medium-High | Medium |
| **Implementation effort** | High (new structures) | Lower (extends existing) |
| **Mathlib alignment** | Good (uses Order.Zorn) | Good (uses existing chain lemmas) |

---

## 8. Recommendation

**Verdict: DEFER in favor of dovetailed approach**

**Rationale**:

1. **Same-family forward_F is required** (confirmed in Run 2). Both approaches solve this.

2. **Dovetailed approach is closer to existing code**: UltrafilterChain.lean already sketches the construction at lines 3685-3711. The infrastructure (SuccChainFMCS, omega_chain) exists.

3. **Zorn adds structural complexity**: Defining PartialFMCS, proving chain upper bounds, and connecting to existing FMCS types requires significant new code.

4. **Zorn's non-constructivity doesn't help here**: The witness theorems (`temporal_theory_witness_exists`, `past_theory_witness_exists`) are already non-constructive (use Lindenbaum). The Zorn layer adds no essential insight.

5. **Fair scheduling is explicit in dovetailed, implicit in Zorn**: Both approaches need fair scheduling. Making it explicit (dovetailed) aids debugging and verification.

**However**, if the dovetailed approach encounters unexpected obstacles (e.g., complex induction schemes, Finset bookkeeping), the Zorn approach remains a viable fallback with well-understood mathematical foundations.

---

## 9. Key Mathlib References

| Theorem | Module | Relevance |
|---------|--------|-----------|
| `zorn_le₀` | `Mathlib.Order.Zorn` | Maximal element in subset with chain upper bounds |
| `zorn_nonempty_partialOrder₀` | `Mathlib.Order.Zorn` | Variant with nonempty starting element |
| `exists_maximal_of_chains_bounded` | `Mathlib.Order.Zorn` | General Zorn for transitive relations |
| `ChainCompletePartialOrder.cSup` | `Mathlib.Order.BourbakiWitt` | Chain supremum infrastructure |

---

## 10. Appendix: Proof Sketch Formalization

```lean
-- Sketch (not compilable)
noncomputable def temporal_coherent_family_zorn (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    TemporalCoherentFamily Int := by
  -- Step 1: Define PartialFMCS and its partial order
  let P := PartialFMCS
  let le : P → P → Prop := fun p q => p.dom ⊆ q.dom ∧ ∀ t ∈ p.dom, p.mcs t = q.mcs t

  -- Step 2: Initial element (single point at 0 with M₀)
  let p₀ : P := { dom := {0}, mcs := fun _ => M₀, ... }

  -- Step 3: Chains have upper bounds (union construction)
  have h_chain_bound : ∀ c : Set P, IsChain le c → ∃ ub ∈ {p : P | p₀.dom ⊆ p.dom}, ...

  -- Step 4: Apply Zorn
  obtain ⟨m, hm₀, hmax⟩ := zorn_nonempty_partialOrder₀ ... h_chain_bound p₀ ...

  -- Step 5: m has total domain (else could extend)
  have h_total : m.dom = Set.univ := ...

  -- Step 6: m satisfies forward_F and backward_P
  have h_fwd : ∀ t φ, F(φ) ∈ m.mcs t → ∃ s ≥ t, φ ∈ m.mcs s := ...
  have h_bwd : ∀ t φ, P(φ) ∈ m.mcs t → ∃ s ≤ t, φ ∈ m.mcs s := ...

  -- Step 7: Convert to TemporalCoherentFamily
  exact { mcs := m.mcs, forward_F := h_fwd, backward_P := h_bwd, ... }
```

---

## Confidence Level

| Claim | Confidence |
|-------|------------|
| Partial order is well-defined | High |
| Chains have upper bounds | High |
| Maximal elements have total domain | Medium-High |
| Maximal elements satisfy forward_F/backward_P | Medium |
| Zorn approach is implementable in Lean | Medium |
| Zorn approach is preferable to dovetailed | Low |
