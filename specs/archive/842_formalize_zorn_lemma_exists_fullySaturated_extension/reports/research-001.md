# Research Report: Task #842

**Task**: Formalize Zorn's lemma proof in exists_fullySaturated_extension
**Date**: 2026-02-03
**Focus**: Zorn's lemma formalization for exists_fullySaturated_extension: partial order setup, chain upper bounds, maximality implies full saturation

## Summary

The sorry at `SaturatedConstruction.lean:482` in `FamilyCollection.exists_fullySaturated_extension` requires a Zorn's lemma proof. Mathlib provides `zorn_subset_nonempty` which is well-suited for this proof pattern. The main challenges are: (1) defining the set S of valid extensions, (2) proving union of chains preserves `box_coherence`, and (3) proving maximality implies `isFullySaturated`.

## Current Sorry Analysis

### Location and Context

```lean
-- SaturatedConstruction.lean:469-482
theorem FamilyCollection.exists_fullySaturated_extension {phi : Formula}
    (C : FamilyCollection D phi) :
    ∃ C' : FamilyCollection D phi, C.families ⊆ C'.families ∧
      C'.eval_family = C.eval_family ∧ C'.isFullySaturated := by
  sorry
```

### Proof Obligation

Need to show: Given any `FamilyCollection D phi`, there exists a fully saturated extension. The mathematical argument (outlined in comments at lines 418-468) uses Zorn's lemma:

1. Consider all family collections extending C that preserve `box_coherence`
2. Order by family inclusion (`⊆`)
3. Chains have upper bounds (union preserves `box_coherence`)
4. By Zorn's lemma, maximal element exists
5. Maximal element is fully saturated (otherwise could add witness)

## Mathlib Zorn's Lemma API

### Recommended Theorem: `zorn_subset_nonempty`

Located in `Mathlib.Order.Zorn`:

```lean
theorem zorn_subset_nonempty (S : Set (Set α))
    (H : ∀ c ⊆ S, IsChain (· ⊆ ·) c → c.Nonempty → ∃ ub ∈ S, ∀ s ∈ c, s ⊆ ub)
    (x) (hx : x ∈ S) :
    ∃ m, x ⊆ m ∧ Maximal (· ∈ S) m
```

**Why this variant**:
- Works with sets ordered by `⊆` (our families form a set)
- Has `_nonempty` suffix, so we only need to prove chains have upper bounds for non-empty chains
- Returns `Maximal (· ∈ S) m` which gives us both `m ∈ S` and `∀ m' ∈ S, m ⊆ m' → m' ⊆ m`

### Alternative: `zorn_subset`

```lean
theorem zorn_subset (S : Set (Set α))
    (h : ∀ c ⊆ S, IsChain (· ⊆ ·) c → ∃ ub ∈ S, ∀ s ∈ c, s ⊆ ub) :
    ∃ m, Maximal (· ∈ S) m
```

This requires proving the empty chain case explicitly (construct a bound for `∅`).

### Key Supporting Definitions

| Definition | Module | Signature |
|------------|--------|-----------|
| `IsChain` | `Mathlib.Order.Preorder.Chain` | `def IsChain (s : Set α) : Prop := s.Pairwise fun x y => x ≺ y ∨ y ≺ x` |
| `Maximal` | `Mathlib.Order.Defs.Unbundled` | `Maximal P x = (P x ∧ ∀ ⦃y⦄, P y → x ≤ y → y ≤ x)` |

## Proof Strategy

### Step 1: Define the Set S

Define `S` as the set of family sets that:
- Extend `C.families`
- Preserve `box_coherence`
- Share `C.eval_family`

```lean
let S : Set (Set (IndexedMCSFamily D)) :=
  { fams | C.families ⊆ fams ∧
           (∀ fam ∈ fams, ∀ psi t, Formula.box psi ∈ fam.mcs t → ∀ fam' ∈ fams, psi ∈ fam'.mcs t) ∧
           C.eval_family ∈ fams }
```

### Step 2: Prove C.families in S (Non-emptiness)

```lean
have hC_in_S : C.families ∈ S := ⟨Subset.rfl, C.box_coherence, C.eval_family_mem⟩
```

### Step 3: Prove Chain Upper Bound

For a chain `c ⊆ S` with `c.Nonempty`, the upper bound is `⋃₀ c`:

**Need to prove**:
1. `C.families ⊆ ⋃₀ c` - Every chain element extends C, so union does too
2. `box_coherence` for `⋃₀ c` - If `Box psi ∈ fam.mcs t` for `fam ∈ ⋃₀ c`, then `fam ∈ s` for some `s ∈ c`, and by chain coherence of s, `psi ∈ fam'.mcs t` for all `fam' ∈ s ⊆ ⋃₀ c`
3. `C.eval_family ∈ ⋃₀ c` - Holds since `c.Nonempty` means some `s ∈ c` and `C.eval_family ∈ s ⊆ ⋃₀ c`

**Critical Subtlety**: The chain elements are ordered by `⊆`, so if `s1 ⊆ s2` (or `s2 ⊆ s1`), we can propagate `box_coherence` across the union.

### Step 4: Apply Zorn's Lemma

```lean
obtain ⟨M, hC_sub_M, hM_maximal⟩ := zorn_subset_nonempty S ... C.families hC_in_S
```

### Step 5: Prove Maximality Implies Full Saturation

**Goal**: If M is maximal in S, then `isFullySaturated` holds for M.

**By contradiction**: Suppose M is NOT fully saturated. Then:
- ∃ psi, fam ∈ M, t such that `diamondFormula psi ∈ fam.mcs t` but ¬∃ fam' ∈ M, `psi ∈ fam'.mcs t`

**Witness Construction**:
- `diamondFormula psi ∈ fam.mcs t` implies `{psi}` is consistent (by `diamond_implies_psi_consistent` from ModalSaturation.lean)
- Use `constructWitnessFamily` to create a witness family containing psi
- Adding witness to M gives M' = M ∪ {witness}

**Box Coherence Preservation**:
- Need to show M' preserves `box_coherence`
- For `fam ∈ M` and `fam' = witness`: If `Box psi ∈ fam.mcs t`, then `psi` must be in witness.mcs t
- This requires the witness to satisfy certain Box formulas

**This is the hardest part**: The witness family (from Lindenbaum extension) may not automatically satisfy `box_coherence` with all existing families. The proof must either:
1. Construct witnesses that inherit all necessary Box formulas, OR
2. Use a more sophisticated construction that maintains coherence

## Key Mathlib Imports Required

```lean
import Mathlib.Order.Zorn  -- zorn_subset_nonempty
import Mathlib.Order.Preorder.Chain  -- IsChain
import Mathlib.Order.Minimal  -- Maximal
```

**Note**: Already imported transitively via existing imports.

## Technical Challenges

### Challenge 1: Box Coherence Under Union

When proving `⋃₀ c` satisfies `box_coherence`:

```lean
-- Must show: ∀ fam ∈ ⋃₀ c, ∀ psi t, Box psi ∈ fam.mcs t → ∀ fam' ∈ ⋃₀ c, psi ∈ fam'.mcs t
```

The issue: `fam ∈ s1` and `fam' ∈ s2` where `s1, s2 ∈ c`. Since c is a chain, either `s1 ⊆ s2` or `s2 ⊆ s1`. Use the larger one's `box_coherence`.

**Proof sketch**:
```lean
intro fam ⟨s1, hs1_in_c, hfam_in_s1⟩ psi t h_box fam' ⟨s2, hs2_in_c, hfam'_in_s2⟩
-- c is chain, so s1 ⊆ s2 or s2 ⊆ s1
rcases hchain hs1_in_c hs2_in_c with h | h
-- Case s1 ⊆ s2: use box_coherence of s2
· have hfam_in_s2 : fam ∈ s2 := h hfam_in_s1
  exact (hs2_in_S.2.1) fam hfam_in_s2 psi t h_box fam' hfam'_in_s2
-- Case s2 ⊆ s1: use box_coherence of s1
· have hfam'_in_s1 : fam' ∈ s1 := h hfam'_in_s2
  exact (hs1_in_S.2.1) fam hfam_in_s1 psi t h_box fam' hfam'_in_s1
```

### Challenge 2: Maximality Implies Saturation

This is the non-trivial part. The argument requires:

1. **Witness consistency**: From `diamondFormula psi ∈ fam.mcs t`, derive `{psi}` is consistent
2. **Witness construction**: Use `lindenbaumMCS` to extend `{psi}` to an MCS
3. **Box coherence preservation**: Show M ∪ {witness} still has `box_coherence`

**The difficulty**: The witness MCS may contain `Box phi` formulas that are NOT satisfied by all families in M. This could break `box_coherence`.

**Possible resolution**: Use a more careful witness construction that:
- Takes the intersection of all boxed contents from existing families
- Or uses a specific time-indexed construction

**Alternative approach**: Frame the argument differently - show that if M lacks a witness for some Diamond, we can find a CONSISTENT extension (not arbitrary Lindenbaum).

### Challenge 3: FamilyCollection Construction

After obtaining `M : Set (IndexedMCSFamily D)` with the right properties, must construct `C' : FamilyCollection D phi`:

```lean
let C' : FamilyCollection D phi := {
  families := M,
  nonempty := ...,  -- M contains C.eval_family
  eval_family := C.eval_family,
  eval_family_mem := ...,  -- M extends C.families which contains eval_family
  box_coherence := ...  -- from S membership
}
```

## Estimated Effort

| Component | Complexity | Effort |
|-----------|------------|--------|
| Define S and prove C ∈ S | Low | 1-2 hours |
| Chain upper bound proof | Medium | 3-4 hours |
| Maximality implies saturation | High | 6-10 hours |
| FamilyCollection construction | Low | 1-2 hours |
| **Total** | | **11-18 hours** |

## Sorry Characterization

This sorry represents **technical debt requiring documentation** (Category: Development Placeholder). The mathematical argument is sound and well-understood in the metatheory. The formalization requires:
- Careful handling of set-theoretic manipulations
- Proving `box_coherence` preservation under union
- Constructing witnesses that maintain coherence

**Remediation path**: Implement the Zorn's lemma proof as outlined, potentially splitting into helper lemmas.

**Transitive impact**: All theorems using `constructSaturatedBMCS` or `construct_bmcs_saturated` inherit this sorry.

## Recommendations

1. **Start with the chain upper bound lemma** - This is the most concrete part and validates the approach works.

2. **Create helper lemma for box_coherence under union**:
   ```lean
   lemma box_coherence_sUnion (c : Set (Set (IndexedMCSFamily D)))
       (hchain : IsChain (· ⊆ ·) c)
       (h_coherence : ∀ s ∈ c, box_coherence_pred s) :
       box_coherence_pred (⋃₀ c)
   ```

3. **Consider alternative witness construction**: Instead of arbitrary Lindenbaum extension, construct witnesses that explicitly maintain `box_coherence` by including all necessary `psi` formulas where `Box psi` appears in existing families.

4. **Use `zorn_subset_nonempty`** rather than `zorn_subset` to avoid the empty chain edge case.

5. **Structure the proof as**:
   - Main theorem uses `suffices` to state the Zorn conclusion
   - Apply `zorn_subset_nonempty`
   - Prove chain bound as separate lemma
   - Prove maximality implies saturation as separate lemma

## References

- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Current implementation with sorry
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - `constructWitnessFamily`, `diamond_implies_psi_consistent`
- `.lake/packages/mathlib/Mathlib/Order/Zorn.lean` - Zorn's lemma variants
- `.lake/packages/mathlib/Mathlib/Order/Preorder/Chain.lean` - IsChain definition
- `.lake/packages/mathlib/Mathlib/Order/Minimal.lean` - Maximal definition
- `specs/841_remove_axiom_complete_multi_family_saturation/reports/research-001.md` - Previous research context

## Next Steps

1. Create implementation plan with phased approach
2. Implement chain upper bound helper lemma first
3. Formalize the Zorn's lemma application
4. Tackle maximality implies saturation (hardest part)
5. Verify transitive sorry-freedom after completion
