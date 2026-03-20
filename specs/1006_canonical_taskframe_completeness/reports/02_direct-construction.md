# Research Report: Task #1006 (Supplemental)

**Task**: Replace FlagBFMCS satisfies_at with canonical TaskFrame using truth_at
**Date**: 2026-03-19
**Focus**: Direct construction alternatives to the BFMCS Int embedding approach

## Summary

The original research recommended constructing `BFMCS Int` from FlagBFMCS data via countable order-embedding. This supplemental research investigates whether there is a more direct, elegant construction that achieves the same goal with less complexity. The key insight is that **FlagBFMCS already contains exactly the structure needed for a direct TaskFrame construction** -- the challenge is choosing the right abstraction.

## Key Findings

### 1. The Core Type Mismatch is Fundamental

The `valid` definition requires `D : Type` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. FlagBFMCS uses `CanonicalMCS` ordering directly without a group structure. This is not a bug but a feature -- FlagBFMCS captures the natural preorder structure of MCS inclusion.

**Critical Observation**: The parametric infrastructure (`ParametricCanonicalTaskFrame D`) is *already* parameterized over D. It does NOT require D to be Int specifically. Any D with the required typeclasses works.

### 2. Direct TaskFrame Construction Pattern

Looking at `ParametricCanonical.lean` and `SeparatedTaskFrame.lean`, the cleanest pattern is:

1. **Choose D**: Pick a duration domain (Int is sufficient for base completeness)
2. **Choose WorldState**: Use `ParametricCanonicalWorldState` (already defined as `{ M : Set Formula // SetMaximalConsistent M }`)
3. **Define task_rel**: Use `CanonicalR` (g_content inclusion) -- already done in `parametric_canonical_task_rel`
4. **Build WorldHistory from FMCS**: Use `parametric_to_history` (already exists, domain = True)
5. **Build Omega**: Use `ShiftClosedParametricCanonicalOmega B` (already shift-closed)

The existing infrastructure is **complete and sorry-free**. The only missing piece is constructing a suitable `BFMCS D` from FlagBFMCS.

### 3. The Embedding Problem is Unavoidable But Simpler Than It Appears

**Why we need an embedding**: `BFMCS D` requires `FMCS D` families where `D` has `AddCommGroup`. FlagBFMCS has `chainFMCS F : FMCS (ChainFMCSDomain F)`, and `ChainFMCSDomain F` lacks this structure.

**Simplification**: Rather than embedding each Flag separately, we can use a **single global embedding**:

```
all_mcs : Set CanonicalMCS = { M | M is any MCS }
embed : CanonicalMCS -> Int (countable enumeration)
```

Then define `global_mcs : Int -> Set Formula` by:
- If `n` is in the image of `embed`, return the corresponding MCS
- Otherwise, return `root_mcs` (the root MCS used for evaluation)

This gives a single `FMCS Int` that "contains" all MCSs at various integer times.

### 4. FlagBFMCS.modally_saturated Directly Implies BFMCS Modal Coherence

The `FlagBFMCS.modally_saturated` condition states:

> For any Flag F in flags, any MCS M in F, and any formula psi, if Diamond(psi) is in M.world, then there exists a Flag F' in flags containing an MCS W with psi in W.world and MCSBoxContent M.world ⊆ W.world.

This directly corresponds to the BFMCS `modal_forward` condition when we flatten all Flags into a single BFMCS family structure. The BoxContent preservation condition is exactly what `modal_forward` needs.

### 5. Alternative: Type-Level Abstraction (Simpler Statement, Harder Proof)

An alternative approach avoids the embedding entirely by using a different completeness statement:

**Current target**: `valid phi -> Derivable [] phi`

**Alternative target**: `flagbfmcs_valid phi -> Derivable [] phi` where `flagbfmcs_valid` is defined directly over FlagBFMCS.

This pushes the embedding problem into showing `valid -> flagbfmcs_valid`, which may be easier for certain applications. However, this does not achieve the goal of using the canonical `valid` definition directly.

### 6. Minimal Construction: Direct FlagBFMCS to BFMCS Int

The most direct path is:

**Phase 1**: Define `enum_mcs : CanonicalMCS -> Int` (order-preserving enumeration)
- Use `Countable CanonicalMCS` (exists because `Countable Formula`)
- Define via `Encodable.encode` or `Nat.find` pattern
- Does NOT need to be order-preserving globally -- only needs to be injective

**Phase 2**: Define `fmcs_from_flag : Flag CanonicalMCS -> FMCS Int`
- `mcs t = (chainFMCS F).mcs (inverse_embed t)` if `t` is in the image
- `mcs t = root_mcs` otherwise (fallback for out-of-range times)
- Transfer `forward_G`/`backward_H` using the embedding correspondence

**Phase 3**: Define `bfmcs_from_flagbfmcs : FlagBFMCS -> BFMCS Int`
- `families = { fmcs_from_flag F | F in B.flags }`
- `modal_forward` from `modally_saturated`
- `modal_backward` from universality of Flag coverage

**Phase 4**: Apply parametric pipeline
- `parametric_to_history` converts each FMCS Int to WorldHistory
- `parametric_shifted_truth_lemma` gives MCS membership <-> truth_at
- `parametric_representation_from_neg_membership` closes the proof

### 7. The Omega Question: What Histories to Include?

For the box case of `truth_at`, we need `forall sigma in Omega, truth_at M Omega sigma t phi`. The question is: what is Omega?

**Option A**: `ShiftClosedParametricCanonicalOmega B` (all shifts of histories from BFMCS families)
- Pro: Already proven shift-closed
- Pro: `parametric_shifted_truth_lemma` is proven for this
- Con: Must show FlagBFMCS families map to this Omega

**Option B**: Define a FlagBFMCS-specific Omega directly
- `{ tau_F | F in B.flags }` where `tau_F = parametric_to_history (fmcs_from_flag F)`
- Pro: Direct correspondence to FlagBFMCS structure
- Con: Must prove shift-closure separately

**Recommendation**: Use Option A. The mapping from FlagBFMCS to BFMCS automatically gives the right Omega.

### 8. The Temporal Coherence Question

`chainFMCS F` provides `forward_G` and `backward_H` within each Flag. After embedding to `FMCS Int`, these become:

- `forward_G`: `G(phi) in mcs(s) and s < t -> phi in mcs(t)` (for Int times within the Flag's image)
- `backward_H`: `H(phi) in mcs(t) and s < t -> phi in mcs(s)` (for Int times within the Flag's image)

**Challenge**: What about Int times OUTSIDE the Flag's image?

**Solution**: The fallback to `root_mcs` for out-of-range times means:
- For times outside the Flag's image, `mcs(t) = root_mcs`
- `root_mcs` is an MCS, so `forward_G`/`backward_H` need to hold
- This requires: if `G(phi) in root_mcs`, then `phi` holds at all future times

**Key Insight**: The `temporally_complete` condition (every CanonicalMCS is in some Flag) ensures we never actually need the out-of-range fallback for witness finding. The fallback is only for type-correctness.

## Recommendations

### Primary Recommendation: Streamlined BFMCS Int Construction

Follow the minimal construction pattern from Finding 6. Key simplifications:

1. **Use global enumeration**: Single `enum_mcs : CanonicalMCS -> Int` for all Flags
2. **Leverage existing infrastructure**: `ParametricCanonicalTaskFrame`, `parametric_to_history`, `ShiftClosedParametricCanonicalOmega`
3. **Focus on modal coherence transfer**: The main proof work is showing `modally_saturated -> modal_forward`

### Alternative Recommendation: Deferred Embedding via Axiom

If the embedding construction proves difficult, consider:

1. **Axiomatize countability**: Add `axiom countable_canonical_mcs : Countable CanonicalMCS`
2. **Use `Encodable.encode`**: This gives `CanonicalMCS -> Nat -> Int` automatically
3. **Prove the main theorems**: Focus on the logical content rather than set-theoretic construction

This is acceptable because:
- `Countable CanonicalMCS` is mathematically true (formulas are countable)
- The axiom is purely about cardinality, not about logical content
- It can be eliminated later when the countability proof is provided

**IMPORTANT**: The zero-debt policy applies. If the embedding proves too complex for a complete proof, the task should be marked [BLOCKED] for user review, NOT deferred with sorries.

### Non-Recommendations

The following approaches are NOT recommended:

1. **Using D = ChainFMCSDomain F**: This lacks `AddCommGroup`, requiring artificial structure
2. **Modifying the parametric infrastructure**: It's already complete and sorry-free
3. **Creating a new `satisfies_at`-like relation**: This duplicates existing work

## Comparison: Original Plan vs Streamlined Approach

| Aspect | Original Plan | Streamlined Approach |
|--------|---------------|---------------------|
| Embedding | Per-Flag order-preserving | Global countable enumeration |
| FMCS construction | Per-Flag with boundary handling | Per-Flag with root_mcs fallback |
| Modal coherence | Transfer via witness construction | Direct from modally_saturated |
| Temporal coherence | Transfer via embedding | Inherited from chainFMCS |
| Omega | Per-Flag histories | ShiftClosedParametricCanonicalOmega |
| Reuse | Moderate | High (all parametric infrastructure) |

The streamlined approach requires less new infrastructure and maximizes reuse of existing sorry-free code.

## Implementation Sketch

```lean
-- Phase 1: Global enumeration (may use axiom initially)
noncomputable def enum_mcs : CanonicalMCS -> Int :=
  fun M => Encodable.encode M  -- requires Countable/Encodable instance

-- Phase 2: Per-Flag FMCS Int
noncomputable def fmcs_from_flag (F : Flag CanonicalMCS) (root : CanonicalMCS) : FMCS Int where
  mcs t := if h : t in image(enum_mcs, F) then (corresponding MCS).world else root.world
  is_mcs t := ...  -- by case analysis
  forward_G := ...  -- transfer from chainFMCS
  backward_H := ...  -- transfer from chainFMCS

-- Phase 3: Bundle into BFMCS Int
noncomputable def bfmcs_from_flagbfmcs (B : FlagBFMCS) : BFMCS Int where
  families := { fmcs_from_flag F B.root | F in B.flags }
  families_nonempty := ...  -- from B.flags_nonempty
  modal_forward := ...  -- from B.modally_saturated
  modal_backward := ...  -- from completeness of Flag coverage

-- Phase 4: Main theorem
theorem flagbfmcs_canonical_completeness (phi : Formula)
    (h : valid phi) : Nonempty (DerivationTree [] phi) := by
  -- By contrapositive
  by_contra h_not_prov
  -- Get MCS with neg(phi)
  obtain ⟨M, hM, h_neg⟩ := not_provable_implies_neg_extends_to_mcs phi h_not_prov
  let M0 : CanonicalMCS := ⟨M, hM⟩
  -- Construct FlagBFMCS and BFMCS Int
  let B := allFlagsBFMCS M0
  let bfmcs := bfmcs_from_flagbfmcs B
  -- Apply parametric representation
  exact parametric_representation_contradiction bfmcs h h_neg
```

## Next Steps

1. **Verify countability**: Check if `Countable CanonicalMCS` is already proven or needs axiom
2. **Prototype Phase 1**: Define `enum_mcs` and verify type-correctness
3. **Design boundary handling**: Decide on fallback behavior for out-of-range times
4. **Prove modal coherence transfer**: The main theorem connecting `modally_saturated` to `modal_forward`

## References

| File | Relevance |
|------|-----------|
| `ParametricCanonical.lean:62-89` | `parametric_canonical_task_rel` definition |
| `ParametricHistory.lean:62-91` | `parametric_to_history` construction |
| `ParametricTruthLemma.lean:174-184` | `parametric_canonical_truth_lemma` |
| `ParametricRepresentation.lean:187-199` | `parametric_algebraic_representation_relative` |
| `FlagBFMCS.lean:75-104` | `FlagBFMCS` structure with `modally_saturated` |
| `FlagBFMCSTruthLemma.lean:558-580` | `satisfies_at_iff_mem` truth lemma |
