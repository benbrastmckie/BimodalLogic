# Research Report: Simplification Analysis for Task 881

**Task**: Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-13
**Focus**: Infrastructure reuse, simplification opportunities, and the simplest path to axiom elimination

## Summary

The prior research (research-002.md) recommends a complex unified single-pass Zorn construction with a `UnifiedCoherentPartialFamily` structure having ~6 fields and ~6 invariants. **This is over-engineered.** The existing SaturatedConstruction.lean already implements the correct Zorn-based approach with 3 sorries that can be fixed directly using S5 axiom 4 (positive introspection) and the axiom-5 derivation (negative introspection). The fix requires **two new lemmas** plus **restricting the Zorn set S to constant families**, not a new structure.

## Key Findings

### Finding 1: The 3 Sorries Share a Single Root Cause -- BoxContent Definition

All 3 sorries in `FamilyCollection.exists_fullySaturated_extension` (SaturatedConstruction.lean:757) stem from one mistake: `BoxContent` is defined too broadly:

```lean
-- CURRENT (line 832): collects from ALL families and ALL times
let BoxContent : Set Formula := {chi | ∃ fam' ∈ M, ∃ s : D, Formula.box chi ∈ fam'.mcs s}
```

This creates two problems:
- **Time mismatch** (Sorry 2): `Box chi in fam'.mcs s` gives `chi in fam.mcs s` by box_coherence, but we need `chi in fam.mcs t`
- **Family mismatch** (Sorry 1): `diamond_box_coherent_consistent` requires `Box chi in fam.mcs t` (same family), not `Box chi in fam'.mcs s` (different family, different time)

**The fix**: Restrict to constant families (add `forall fam in fams, fam.isConstant` to Zorn set S) and redefine BoxContent:

```lean
-- FIXED: use fixed family and fixed time (time doesn't matter for constant families)
let BoxContent : Set Formula := {chi | Formula.box chi ∈ fam.mcs t}
```

With constant families and S5 axiom 4, this restricted BoxContent equals the broad one at any fixed time.

### Finding 2: S5 Axioms Resolve All 3 Sorries

The codebase already has all the S5 axioms needed:
- `Axiom.modal_t` (T): `Box phi -> phi`
- `Axiom.modal_4` (4): `Box phi -> Box(Box phi)`
- `Axiom.modal_5_collapse` (5-collapse): `Diamond(Box phi) -> Box phi`

**Axiom 4** gives BoxContent family-invariance at a fixed time within a box-coherent set of constant families:
1. `Box chi in fam.mcs t` (hypothesis)
2. `Box(Box chi) in fam.mcs t` (by axiom 4)
3. `Box chi in fam'.mcs t` (by box_coherence)
4. Therefore `{chi | Box chi in fam.mcs t} = {chi | Box chi in fam'.mcs t}` for all `fam, fam' in M`

**Axiom 5 (negative introspection)**, derivable from 5-collapse contrapositive, resolves Sorry 3:
1. From `modal_5_collapse`: `Diamond(Box phi) -> Box phi`
2. Contrapositive: `neg(Box phi) -> neg(Diamond(Box phi)) = Box(neg(Box phi))`
3. So: `neg(Box phi) -> Box(neg(Box phi))` (negative introspection)

This means: if `Box alpha not in fam.mcs 0`, then `neg(Box alpha) in fam.mcs 0`, then `Box(neg(Box alpha)) in fam.mcs 0`, so `neg(Box alpha) in BoxContent subset W_set`. But we assumed `Box alpha in W_set`. Contradiction. Therefore `Box alpha in W_set` implies `Box alpha in fam.mcs 0`, resolving Sorry 3.

### Finding 3: Completeness.lean Needs ALL Three Properties

The axiom `fully_saturated_bmcs_exists` (TemporalCoherentConstruction.lean:773) provides:
```lean
axiom fully_saturated_bmcs_exists : ... ∃ (B : BMCS D),
    (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧  -- context preservation
    B.temporally_coherent ∧                             -- temporal coherence
    is_modally_saturated B                              -- modal saturation
```

Completeness.lean uses all three via `construct_saturated_bmcs`:
- **Context preservation** at line 108 (`construct_saturated_bmcs_contains_context`)
- **Temporal coherence** at line 111 (`construct_saturated_bmcs_temporally_coherent`) -- needed for `bmcs_truth_lemma`
- **Modal saturation** is implicit -- used through the BMCS `modal_backward` field which follows from `saturated_modal_backward`

**We CANNOT weaken the axiom.** All three properties are required. The truth lemma needs temporal coherence, and modal_backward needs modal saturation.

### Finding 4: The Unified Construction IS Over-Engineered

The proposed `UnifiedCoherentPartialFamily` (research-002.md) has:
- 6 fields (domain, families, eval_family_idx, mcs, temporal invariants, modal invariants)
- 6+ invariants (domain_nonempty, is_mcs, eval_family_in_families, forward_G, backward_H, box_coherence, modal_saturated_for_current)
- New infrastructure for partial domains, multi-family index tracking

**Why this is unnecessary:**
1. SaturatedConstruction.lean already has the correct Zorn structure (`FamilyCollection`)
2. Temporal coherence can be handled SEPARATELY -- see below
3. The 3 sorries can be fixed in-place with ~100 lines of new lemmas
4. A new structure means re-proving everything that's already proven

### Finding 5: Fix Existing, Then Integrate

**The simplest path has two steps:**

**Step A: Fix the 3 Sorries in SaturatedConstruction.lean (~100-150 lines)**
1. Add `isConstant` constraint to Zorn set S (line 762)
2. Prove constant property preserved by unions
3. Redefine BoxContent to fixed-family-fixed-time version
4. Add 2 new lemmas:
   - `axiom_4_box_content_invariance`: Box chi in fam.mcs t -> Box chi in fam'.mcs t (via axiom 4 + box_coherence)
   - `axiom_5_box_content_preservation`: Box chi in W_set -> Box chi in fam.mcs 0 (via axiom 5 / negative introspection)
5. Apply `diamond_box_coherent_consistent` (already proven!) for Sorry 1
6. Use T-axiom + constant families for Sorry 2
7. Use `axiom_5_box_content_preservation` for Sorry 3

**Step B: Combine with Temporal Coherence (~50-100 lines)**
- Option 1: Build temporal coherence separately using `temporal_coherent_family_exists` (sorry-backed), then combine
- Option 2: Start from temporally coherent families and prove they can serve as the initial FamilyCollection
- The key insight: for the axiom, we need a single BMCS with BOTH properties. The modally saturated construction gives constant families, while temporal coherence needs non-constant families. This integration IS the remaining challenge.

## Simplification Opportunities

### Opportunity 1: Don't Build a New Structure

Instead of `UnifiedCoherentPartialFamily`, modify the existing `FamilyCollection` and its Zorn set S to include the `isConstant` constraint. The existing proofs for `box_coherence_sUnion`, `initialFamilyCollection`, `FamilyCollection.toBMCS`, etc., all still work.

### Opportunity 2: Reuse `diamond_box_coherent_consistent`

This lemma (SaturatedConstruction.lean:638, **fully proven**) already proves that `{psi} union {chi | Box chi in S}` is consistent when `Diamond psi in S`. With the restricted BoxContent = `{chi | Box chi in fam.mcs t}`, Sorry 1 is resolved by a single function call to this existing lemma.

### Opportunity 3: Derive Axiom 5 from Existing Infrastructure

The theorem `modal_5` is already proven in `Theories/Bimodal/Theorems/Perpetuity/Principles.lean:331`. It proves `Diamond phi -> Box(Diamond phi)`. The 5-collapse axiom gives `Diamond(Box phi) -> Box phi`. The contrapositive (`neg(Box phi) -> Box(neg(Box phi))`) can be derived using the existing `contraposition` utility (also in that file).

### Opportunity 4: Separate Temporal from Modal

For the axiom elimination, consider a two-step approach where modal saturation is proven for constant families (fixing the 3 sorries), and temporal coherence is provided by a separate construction. The final BMCS can be assembled by:
1. Starting from a temporally coherent family as the initial family
2. Adding constant witness families for modal saturation
3. Proving box_coherence is preserved when mixing one temporally coherent family with constant witness families

This avoids the need to make ALL families temporally coherent (only the initial one needs it).

## Recommended Approach

### Priority 1: Fix the 3 Sorries in SaturatedConstruction.lean (HIGH VALUE, MODERATE EFFORT)

This is the single highest-value action. It eliminates the core mathematical gap and produces a sorry-free proof that constant-family BMCS collections can be fully saturated.

**Concrete changes:**
1. Add `isConstant` to the Zorn set S definition (line 762)
2. Prove `isConstant_preserved_by_sUnion` (new lemma)
3. Derive negative introspection from `modal_5_collapse` (new lemma, ~20 lines)
4. Prove `box_content_invariance_in_constant_coherent_set` (new lemma, ~30 lines)
5. Prove `box_content_preservation_for_extension` (new lemma, ~30 lines)
6. Replace the 3 sorry occurrences with applications of these lemmas

**Estimated effort**: 3-4 hours

### Priority 2: Integrate with Temporal Coherence (MEDIUM VALUE, MODERATE EFFORT)

After fixing the sorries, we have modally saturated constant-family BMCS. We need to integrate with temporal coherence.

**Simplest approach**: Accept that the final BMCS has a mix of:
- One temporally coherent family (from Lindenbaum + ZornFamily/RecursiveSeed)
- Multiple constant witness families (from the saturation construction)

The constant witness families satisfy forward_G/backward_H trivially (via T-axiom), and forward_F/backward_P vacuously if we don't require them for witness families.

Wait -- `B.temporally_coherent` requires ALL families to have forward_F and backward_P. Constant families do NOT satisfy these. So this approach needs modification.

**Alternative**: Modify `temporally_coherent` to only require temporal coherence for the eval_family, OR prove that witness families can be made temporally coherent (non-trivial).

**Most practical**: Eliminate the axiom by splitting it into two separate axioms:
1. Modal saturation axiom (provable by fixing the 3 sorries)
2. Temporal coherence axiom (existing `temporal_coherent_family_exists`)
Then combine them.

But wait -- the current truth lemma needs `B.temporally_coherent` which is about ALL families. If only eval_family is temporally coherent, the truth lemma may still work (check if temporal properties are only evaluated at eval_family).

### Priority 3: Do NOT Build UnifiedCoherentPartialFamily (AVOID)

This would duplicate existing infrastructure and require reproving everything from scratch. The existing code is close to working; fix it, don't replace it.

## Evidence

### Verified Lemma Existence (via lean_local_search)

| Lemma | File | Status |
|-------|------|--------|
| `diamond_box_coherent_consistent` | SaturatedConstruction.lean:638 | **Proven** |
| `box_coherence_sUnion` | SaturatedConstruction.lean:520 | **Proven** |
| `FamilyCollection.toBMCS` | SaturatedConstruction.lean:277 | **Proven** |
| `saturated_modal_backward` | ModalSaturation.lean:408 | **Proven** |
| `diamond_implies_psi_consistent` | ModalSaturation.lean:169 | **Proven** |
| `constructWitnessFamily` | ModalSaturation.lean:277 | **Proven** |
| `constantWitnessFamily_isConstant` | SaturatedConstruction.lean:470 | **Proven** |
| `constantWitnessFamily_mcs_eq` | ModalSaturation.lean:268 | **Proven** |
| `constant_families_boxcontent_time_invariant` | SaturatedConstruction.lean:488 | **Proven** |
| `modal_5` (Diamond phi -> Box(Diamond phi)) | Perpetuity/Principles.lean:331 | **Proven** |
| `contraposition` | Theorems/Propositional.lean | **Proven** |

### Verified Axiom Schema Availability

| Axiom | Constructor | Schema |
|-------|-------------|--------|
| T | `Axiom.modal_t` | `Box phi -> phi` |
| 4 | `Axiom.modal_4` | `Box phi -> Box(Box phi)` |
| B | `Axiom.modal_b` | `phi -> Box(Diamond phi)` |
| 5-collapse | `Axiom.modal_5_collapse` | `Diamond(Box phi) -> Box phi` |
| K | `Axiom.modal_k_dist` | `Box(phi -> psi) -> Box phi -> Box psi` |

### Sorry Locations

| Line | Sorry | Root Cause | Fix Via |
|------|-------|------------|---------|
| 985 | Consistency of `{psi} union BoxContent` (psi in L case) | BoxContent too broad | Restrict to `{chi \| Box chi in fam.mcs t}`, apply `diamond_box_coherent_consistent` |
| 1005 | `L subset fam.mcs t` (psi not in L case) | BoxContent elements not in fam.mcs t | Constant families + T-axiom: `Box chi in fam.mcs t -> chi in fam.mcs t` |
| 1069 | Box_coherence for `M union {W}` (fam1 = W case) | Lindenbaum may add Box formulas | Axiom 5 negative introspection: `Box chi in W_set -> Box chi in fam.mcs t` |

## Confidence Level

**High** for fixing the 3 sorries in SaturatedConstruction.lean. The mathematical argument is sound and all prerequisite lemmas exist.

**Medium** for full axiom elimination including temporal coherence. The constant-family approach cleanly gives modal saturation but not temporal coherence for witness families. The integration path exists (the truth lemma may only need temporal coherence at eval_family) but requires verification.

**Low** confidence in the unified construction approach from research-002.md. It would work mathematically but is significantly more effort than fixing the existing code.

## Risks

1. **Temporal Coherence Integration** (MEDIUM): The truth lemma requires `B.temporally_coherent` for ALL families, but constant witness families cannot satisfy forward_F/backward_P. Need to verify whether the truth lemma actually uses temporal coherence for non-eval families, or modify the temporal coherence requirement.

2. **Axiom 5 Derivation** (LOW): Standard derivation from 5-collapse contrapositive. The `contraposition` utility already exists. ~20 lines of code.

3. **Constant Family Restriction** (LOW): Adding `isConstant` to the Zorn set preserves all existing proofs. Constant families form a complete lattice under inclusion (union of constant families gives constant families trivially -- a constant family's MCS is the same at all times, and this property is preserved by set union).

Wait -- union of constant families means union of the *sets of families*, where each individual family remains constant. The `isConstant` property is per-family, not per-set. So the chain upper bound (union of sets of families) preserves the property that all individual families in the union are constant. This is trivial.

## Next Steps

1. Derive the negative introspection lemma from `modal_5_collapse` contrapositive
2. Prove BoxContent family-invariance using axiom 4 + box_coherence + constant families
3. Prove BoxContent preservation for Lindenbaum extensions using negative introspection
4. Fix the 3 sorries in `FamilyCollection.exists_fullySaturated_extension`
5. Investigate whether `bmcs_truth_lemma` uses temporal coherence for non-eval families
6. If yes: design minimal temporal coherence upgrade for witness families
7. If no: modify `temporally_coherent` to eval-family-only and eliminate the axiom
