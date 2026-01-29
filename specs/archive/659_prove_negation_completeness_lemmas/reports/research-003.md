# Research Report: Task #659 (Research Focus: forward_H and Witness Extraction)

**Task**: 659 - Prove negation completeness lemmas
**Started**: 2026-01-29
**Completed**: 2026-01-29
**Effort**: 6-10 hours (estimated for resolution)
**Priority**: Low
**Dependencies**: None (self-contained analysis)
**Sources/Inputs**: CoherentConstruction.lean, IndexedMCSFamily.lean, TruthLemma.lean, CrossOriginCases.lean
**Artifacts**: specs/659_prove_negation_completeness_lemmas/reports/research-003.md
**Standards**: report-format.md
**Focus**: What is required to prove forward_H or add explicit witness extraction to complete the backward Truth Lemma

## Executive Summary

- **forward_H** (line 681 in CoherentConstruction.lean) is fundamentally different from the other coherence conditions
- The other conditions (forward_G, backward_H, backward_G) follow from **seed containment** during construction
- forward_H requires a **reverse direction** property: proving something about the *source* MCS from information in the *target* MCS
- Three approaches identified, each with different trade-offs
- **Best approach**: Semantic contrapositive using forward_G + negation + T-axiom (cleaner, more elegant)

## Context & Scope

### The Core Problem

The task is blocked because witness extraction from `P(¬ψ) ∈ mcs(t)` (or equivalently `Hψ ∉ mcs(t)`) requires proving `forward_H`:

```lean
forward_H : ∀ t t' φ, t < t' → Formula.all_past φ ∈ mcs t' → φ ∈ mcs t
```

This says: "If Hφ is in a future MCS, then φ was in all past MCS."

### Why forward_H is Hard

The coherent construction builds MCS chains from Gamma at origin:
- **Forward chain** (t ≥ 0): `mcs(n+1) = extendToMCS(forward_seed(mcs(n)))`
- **Backward chain** (t < 0): `mcs(-n-1) = extendToMCS(backward_seed(mcs(-n)))`

The other coherence conditions follow naturally:
- **forward_G**: `Gφ ∈ mcs(n)` → `φ ∈ forward_seed(mcs(n))` → `φ ∈ mcs(n+1)` ✓
- **backward_H**: `Hφ ∈ mcs(-n)` → `φ ∈ backward_seed(mcs(-n))` → `φ ∈ mcs(-n-1)` ✓
- **backward_G**: Uses G-persistence through forward chain + seed containment ✓

But **forward_H** goes backwards in the construction:
- **forward_H**: `Hφ ∈ mcs(n+1)` → need `φ ∈ mcs(n)` (reverse direction!)

The construction doesn't preserve this automatically - the Lindenbaum extension can add `Hφ` to `mcs(n+1)` without `φ` being in `mcs(n)`.

## Findings

### Approach A: Strengthen the Construction (Seed Modification)

**Idea**: Modify `forward_seed` to include an "H-compatibility" condition:
```lean
def forward_seed_v2 (S_prev S_curr : Set Formula) : Set Formula :=
  {φ | Formula.all_future φ ∈ S_prev} ∪
  {φ | Formula.all_past φ ∈ S_curr → φ ∈ S_prev}  -- Problem: circular!
```

**Problem**: The seed at time n+1 depends on what will be in `mcs(n+1)`, but `mcs(n+1)` is built from the seed. This creates a circular dependency.

**Resolution**: Would require a fixed-point construction or iterative refinement.

**Estimated effort**: 15-20 hours (significant architecture change)

### Approach B: Add Explicit Witness Property to IndexedMCSFamily

**Idea**: Add `witness_past` and `witness_future` as explicit conditions:
```lean
structure IndexedMCSFamily where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ...
  backward_H : ...
  forward_H : ...  -- or just:
  witness_past : ∀ t φ, Formula.some_past φ ∈ mcs t → ∃ s < t, φ ∈ mcs s
  witness_future : ∀ t φ, Formula.some_future φ ∈ mcs t → ∃ s > t, φ ∈ mcs s
```

**Analysis**: The witness properties are NOT implied by forward_H/backward_G because:
- `some_past φ = ¬H¬φ`, which is "there exists a past time where φ holds"
- `forward_H` says `Hφ ∈ mcs(t') → φ ∈ mcs(t)` for t < t'
- The contrapositive gives: `φ ∉ mcs(t) → Hφ ∉ mcs(t')` for all t < t'
- This is universal (all past), not existential (some past)

**Actually needed**: The witness extraction relates to the **semantic meaning** of `Pφ`:
- `Pφ ∈ mcs(t)` means "φ was true at some past time"
- To extract a witness, we need the MCS construction to "remember" this

**Estimated effort**: 10-15 hours (requires changing construction fundamentally)

### Approach C: Semantic Contrapositive (RECOMMENDED)

**Key Insight**: The backward truth lemma cases can be proven WITHOUT forward_H, by using a semantic argument based on what we already have.

**Proof Strategy for `all_past` backward case**:
```
Goal: (∀ s ≤ t, truth_at s ψ) → H ψ ∈ mcs t

By contrapositive: ¬(H ψ ∈ mcs t) → ¬(∀ s ≤ t, truth_at s ψ)

1. Assume Hψ ∉ mcs(t)
2. By negation completeness: ¬(Hψ) ∈ mcs(t)
3. But ¬(Hψ) is NOT the same as Pψ syntactically
   - ¬(Hψ) = (Hψ → ⊥)
   - P(¬ψ) = ¬H¬(¬ψ) = ¬H(ψ → ⊥)
4. However, we can use the T-axiom + forward direction semantically:
   - From ¬(Hψ) ∈ mcs(t), we need to find s ≤ t where ψ fails
   - By T-axiom: Hψ ∈ mcs(t) → ψ ∈ mcs(t)
   - Contrapositive: ψ ∉ mcs(t) → Hψ ∉ mcs(t)
   - So if Hψ ∉ mcs(t), EITHER ψ ∉ mcs(t) OR ψ ∈ mcs(t) but Hψ ∉ mcs(t)
5. Case 1: ψ ∉ mcs(t)
   - By negation completeness: ¬ψ ∈ mcs(t)
   - By forward IH: truth_at t (¬ψ)
   - Since t ≤ t, this witnesses the failure at s = t
6. Case 2: ψ ∈ mcs(t) but Hψ ∉ mcs(t)
   - This is harder - need to find s < t where ψ fails
   - Would require forward_H or witness extraction
```

**Breakthrough**: Case 1 covers the important case!

If `Hψ ∉ mcs(t)` but `ψ ∈ mcs(t)`, this means the MCS "knows" ψ is true now but doesn't commit to it having always been true. But by maximality, either `Hψ ∈ mcs(t)` or `¬Hψ ∈ mcs(t)`.

Actually, the T-axiom gives us: `⊢ Hψ → ψ` (not the converse).

**Revised Analysis**: The semantic approach shows:
- If `ψ ∉ mcs(t)`, we have a witness at t itself
- If `ψ ∈ mcs(t)` but `Hψ ∉ mcs(t)`, we need a past witness

For Case 2, we need a property that the MCS construction satisfies:

**Derived Property from Construction**:
If `ψ ∈ mcs(t)` for all s ≤ t, then by backward_H coherence applied iteratively:
- If `Hψ ∈ mcs(t)`, then `ψ ∈ mcs(s)` for all s < t
- Combined with T-axiom: `ψ ∈ mcs(t)`
- So `ψ ∈ mcs(s)` for all s ≤ t

Contrapositive: If `∃ s ≤ t. ψ ∉ mcs(s)`, then `Hψ ∉ mcs(t)`.

This is the direction we need! The proof works by **semantic completeness** of the construction:
```
If Hψ ∉ mcs(t), then either:
(a) ψ ∉ mcs(t) - witness at t
(b) ∃ s < t. ψ ∉ mcs(s) - witness at some s
```

**Key Question**: Does the construction guarantee (a) ∨ (b)?

### Approach C Validation

Let's verify this by examining the construction more carefully.

**Claim**: For the unified chain construction, if `Hψ ∉ mcs(t)`, then `∃ s ≤ t. ψ ∉ mcs(s)`.

**Proof attempt** (by contrapositive):
Assume `∀ s ≤ t. ψ ∈ mcs(s)`. We need to show `Hψ ∈ mcs(t)`.

For the backward chain (t < 0):
- If ψ ∈ mcs(s) for all s ≤ t (which are times t, t-1, t-2, ... toward -∞)
- Since t < 0, t-1 < t, so ψ ∈ mcs(t-1)
- The backward chain builds mcs(-n-1) from backward_seed(mcs(-n))
- backward_seed contains φ where Hφ ∈ mcs(-n)
- But we don't have Hψ ∈ mcs(-n); we have ψ ∈ mcs(-n-1)

This doesn't directly give us Hψ. The construction seeds with H-formulas, not their unwrapped versions.

**Conclusion**: The construction does NOT automatically satisfy this property.

### Resolution: What Would Be Sufficient

**Option 1**: Prove forward_H directly (hard - requires construction changes)

**Option 2**: Accept a weaker result:
- The backward Truth Lemma is NOT REQUIRED for completeness
- Document this as an architectural limitation
- The forward direction + box case limitations are the real barriers

**Option 3**: Prove a restricted form:
For the specific case where `t = 0` (origin), if `Hψ ∉ mcs(0)` then:
- We have Gamma = mcs(0), which is the root MCS
- By construction, past times use backward_seed(Gamma)
- If Hψ ∉ Gamma, then ψ is NOT forced into past MCS by the seed
- The Lindenbaum extension MAY or MAY NOT add ψ

This still doesn't give a witness.

## Critical Analysis: Why forward_H Cannot Be Proven

**Root Cause**: The Lindenbaum lemma is non-constructive.

When we build `mcs(n+1) = extendToMCS(forward_seed(mcs(n)))`, the extension can add arbitrary formulas (consistent with the seed) including `Hψ` for any ψ.

If `Hψ` gets added to `mcs(n+1)` during extension, there's no guarantee that `ψ` was in `mcs(n)` - the extension doesn't "look back" at previous MCS.

**What would fix this**:
1. **Coherent extension**: Build the chain so that extensions are coherent with previous MCS
2. **H-closed seeds**: Ensure that if Hψ will be in the result, ψ is in the source
3. **Dependent choice**: Use a construction that picks coherent MCS at each step

All of these require significant changes to the construction.

## Recommendations

### Primary Recommendation: Document Limitation

The backward Truth Lemma cases (lines 423, 441) should remain as `sorry` with documentation:
- They are NOT required for completeness (representation theorem uses forward direction only)
- Proving them requires architectural changes to the MCS construction
- The construction would need to ensure "backward coherence" during Lindenbaum extension

### Alternative: Prove forward_H

If the backward Truth Lemma becomes necessary (e.g., for soundness proofs), the path forward is:

**Phase 1**: Modify the construction to use "coherent extension"
- When extending forward_seed to MCS, also check backward compatibility
- Add constraint: if Hψ would be added, verify ψ is in previous MCS
- This may require dependent choice or iterative refinement

**Estimated effort**: 20-30 hours

**Phase 2**: Prove forward_H from modified construction
- The construction guarantees the property by design
- Extraction is straightforward

**Estimated effort**: 5-10 hours

### Explicit Witness Extraction Alternative

Add witness properties directly to IndexedMCSFamily:
```lean
witness_past : ∀ t φ, Formula.some_past φ ∈ mcs t → ∃ s < t, φ ∈ mcs s
witness_future : ∀ t φ, Formula.some_future φ ∈ mcs t → ∃ s > t, φ ∈ mcs s
```

This bypasses forward_H entirely but requires:
1. Proving the current construction satisfies these (it doesn't)
2. OR modifying the construction to satisfy them
3. OR accepting them as axioms (not ideal)

## Decisions

1. **Acknowledge architectural limitation**: The backward Truth Lemma cannot be proven with current construction
2. **Document clearly**: Add comments explaining why forward_H is hard
3. **Keep task blocked**: Task 659 remains blocked on architecture changes
4. **Future work**: If needed, implement coherent extension approach

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Backward Truth Lemma needed for future proofs | Medium | Document workarounds; forward direction usually sufficient |
| Coherent extension approach is harder than expected | High | May need full reconstruction of MCS chain theory |
| Witness properties not satisfiable | Medium | Semantic approach may provide alternative |

## Appendix

### Construction Diagram

```
                    backward_seed            forward_seed
        mcs(-2) <---------------- mcs(-1) <------ Gamma = mcs(0) ------> mcs(1) -------> mcs(2)
           |                         |                |                    |               |
           |   backward_H OK         |                |                    |    forward_G OK
           |                         |                |                    |
           v                         v                v                    v               v
     H-formulas               H-formulas          Root MCS           G-formulas      G-formulas
     persist                  persist                                 persist         persist

     BUT: forward_H (Hφ ∈ mcs(1) → φ ∈ mcs(0)) NOT GUARANTEED
          because Lindenbaum extension can add Hφ independently
```

### Relevant Code Locations

| File | Line | Content |
|------|------|---------|
| CoherentConstruction.lean | 681 | `forward_H` sorry |
| CoherentConstruction.lean | 711, 714 | `backward_G` sorries (cross-origin) |
| TruthLemma.lean | 423 | `all_past` backward sorry |
| TruthLemma.lean | 441 | `all_future` backward sorry |
| CrossOriginCases.lean | 62-77 | forward_H documentation |

### Search Queries Used

- `lean_loogle`: `?φ ∈ ?S → ∃ ?s, ?s < ?t` (no results)
- `lean_leansearch`: witness extraction from maximal consistent set temporal logic
- `lean_leanfinder`: witness extraction from existential temporal formula

## Next Steps

1. Update TODO.md to reflect that task is blocked on architecture changes
2. Consider if a simplified witness extraction property could be added
3. If backward Truth Lemma becomes critical, invest in coherent extension approach
