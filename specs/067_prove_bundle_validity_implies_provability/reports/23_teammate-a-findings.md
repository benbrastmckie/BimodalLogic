# Teammate A Findings: F-Persistence Root Cause Analysis

## Summary

The F-formula persistence failure in the dovetailed omega chain construction stems from a fundamental architectural mismatch: `temporal_theory_witness_exists` builds the witness MCS W by extending `{phi} ∪ G_theory(M) ∪ box_theory(M)` via Lindenbaum, but this seed contains NO F-formulas whatsoever. The Lindenbaum extension is free to add `G(neg psi)` for any psi, which axiomatically excludes `F(psi)` from W. This means F-obligations from the original MCS M can be "lost" when moving to the witness W, breaking the implicit assumption that dovetailing can check-and-resolve obligations at later steps.

The Succ relation (SuccRelation.lean) DOES require F-step: `f_content(u) ⊆ v ∪ f_content(v)`, meaning unresolved F-obligations must either resolve or persist. However, `temporal_theory_witness_exists` does NOT guarantee Succ - it only guarantees G-theory propagation and box-class agreement. The dovetailed chain uses `resolving_witness` (based on `temporal_theory_witness_exists`), which produces successors that may violate F-step for non-target obligations.

## Key Findings

### temporal_theory_witness_exists Analysis

**Location**: UltrafilterChain.lean lines 1154-1184

**Seed composition** (lines 1045-1046):
```lean
def temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M
```

Where:
- `G_theory M = {G(a) | G(a) ∈ M}` (lines 960-961) - only G-wrapped formulas
- `box_theory M = {Box(a) | Box(a) ∈ M} ∪ {neg(Box(a)) | Box(a) ∉ M}` (lines 771-773) - box and negated-box formulas

**What the witness guarantees** (lines 1156-1158):
```lean
∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
  (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
  box_class_agree M W
```

**What it does NOT guarantee**:
1. No F-formula persistence: If `F(psi) ∈ M` for `psi ≠ phi`, there is NO requirement that `F(psi) ∈ W` or `psi ∈ W`
2. No Succ relation: The seed lacks `deferralDisjunctions` which encode the F-step property
3. Lindenbaum freedom: The extension from `{phi} ∪ temporal_box_seed M` can freely add `G(neg psi)` during enumeration

**Why F-formulas can be lost**:
1. Lindenbaum extension enumerates all formulas
2. For each formula chi, it adds either chi or neg(chi) to maintain consistency
3. When considering `G(neg psi)`, nothing in the seed prevents it
4. If `G(neg psi)` is added, then `F(psi) = neg(G(neg psi))` becomes inconsistent with W
5. So `F(psi) ∉ W` even if `F(psi) ∈ M`

### Succ Relation Requirements

**Location**: SuccRelation.lean lines 59-60

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

**Two conditions**:
1. **G-persistence** (condition 1): `g_content u ⊆ v` - all `G(a) ∈ u` implies `a ∈ v`
2. **F-step** (condition 2): `f_content u ⊆ v ∪ f_content v` - for all `F(phi) ∈ u`, either `phi ∈ v` or `F(phi) ∈ v`

**Key theorem** (`single_step_forcing`, lines 232-268):
If `F(phi) ∈ u`, `FF(phi) ∉ u`, and `Succ u v`, then `phi ∈ v`.

This means: if Succ held, F-obligations would eventually resolve via bounded F-nesting.

**The gap**: `temporal_theory_witness_exists` produces witnesses that satisfy G-persistence but NOT F-step. The witness construction (`successor_deferral_seed` in SuccExistence.lean:87-88) that DOES guarantee Succ includes:
```lean
def successor_deferral_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u
```

Where `deferralDisjunctions u = {phi ∨ F(phi) | F(phi) ∈ u}` forces either resolution or deferral.

### Modification Options

**Option 1: Add deferralDisjunctions to temporal_box_seed**

Modify the seed to:
```lean
def temporal_box_seed_with_deferrals (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M ∪ deferralDisjunctions M
```

**Problems**:
1. The `deferralDisjunctions M` set can be infinite if M contains infinitely many F-formulas
2. For consistency proof, we need finite derivations - infinite seeds require different techniques
3. G_of_temporal_box_seed (line 1051) relies on all seed elements having G-liftability - deferral disjunctions do NOT lift under G

**Option 2: Build Succ-satisfying chain instead**

Use `constrained_successor_seed` (SuccExistence.lean:401):
```lean
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

This produces successors satisfying Succ, which DOES preserve F-step.

**Problems**:
1. The backward chain symmetric construction has two sorries (lines 3944, 4001 in SuccChainFMCS.lean)
2. The existing infrastructure (`constrained_successor`, `constrained_predecessor`) is in SuccExistence.lean, not wired to the omega chain
3. SuccChainFMCS uses `forward_chain`/`backward_chain` which ARE Succ-based, but the F-coherence proof (`succ_chain_forward_F`) is missing

**Option 3: Use the restricted chain approach**

`DeferralRestrictedSerialMCS` limits formulas to `deferralClosure phi`, making the formula space finite.

The restricted chain `restricted_forward_chain` (SuccChainFMCS.lean) has a sorry-free `restricted_forward_chain_forward_F` theorem (lines 3067-3075):
```lean
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m
```

**Problems**:
1. Completeness uses `boxClassFamilies` built from arbitrary SerialMCS, not restricted
2. No clear mapping from restricted chain properties to unrestricted chain properties
3. Integration gap: "which phi to restrict to?" is undefined for arbitrary MCS

### Existing Construction Review

**omega_chain_resolving_at_1** (lines 3181-3203):

This construction resolves a SPECIFIC F-obligation at step 1, NOT all obligations:
```lean
noncomputable def omega_chain_resolving_at_1
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
```

It builds:
- chain(0) = M0
- chain(1) = resolving_witness for phi
- chain(n+2) = continue with F_top

This proves phi ∈ chain(1), but says nothing about OTHER F-obligations in M0.

**restricted_forward_chain_forward_F** (lines 3067-3075):

This IS sorry-free and provides F-coherence, but ONLY within the restricted formula space:
- Works for `DeferralRestrictedSerialMCS phi`
- F(psi) must be in `deferralClosure phi` for the theorem to apply
- For arbitrary F-formulas outside deferralClosure, no guarantee

**The key sorries** (from SuccChainFMCS.lean):
1. Line 2913: `restricted_bounded_witness_wf` fuel exhaustion case
2. Line 2915: same construction, deferred case
3. Line 3944: `constrained_predecessor_restricted_g_persistence_reverse`
4. Line 4001: `constrained_predecessor_restricted_f_step_forward`
5. Line 4341, 4499, 4695: fuel exhaustion cases in various bounded witness lemmas

## Recommended Approach

**Short-term (patch current blocker)**: The dovetailed construction cannot be fixed by changing the enumeration strategy - the problem is the witness construction itself. The correct fix requires using Succ-producing successors instead of `temporal_theory_witness_exists`.

**Concrete recommendation**: Replace `resolving_witness` with `constrained_successor` from SuccExistence.lean. The constrained successor:
1. Produces Succ u v (G-persistence + F-step)
2. Is already sorry-free for the forward direction
3. Needs the backward sorries fixed (lines 3944, 4001) for full Z-chain coherence

**Alternative approach**: Accept bundle-level coherence. The theorem `boxClassFamilies_bundle_forward_F` (if it exists sorry-free) proves F-coherence at the bundle level, not family level. This avoids the chain-level F-persistence problem entirely but changes the completeness architecture.

**Do NOT pursue**:
1. Adding all F-formulas to the seed (infinite, breaks G-liftability)
2. Trying to prove F-persistence for `temporal_theory_witness_exists` (mathematically impossible - the extension is free to add G(neg psi))
3. More dovetailing variations (the enumeration is not the problem; the witness construction is)

## Confidence Level

**High** - The root cause is definitively identified: `temporal_theory_witness_exists` uses a seed (`temporal_box_seed`) that lacks any F-preservation mechanism. The Lindenbaum extension is axiomatically free to exclude F-formulas by adding their G-negations. This is not a proof gap but a fundamental architectural mismatch between:
1. What `temporal_theory_witness_exists` provides (G-propagation, box-class, target formula inclusion)
2. What the dovetailed chain needs (F-step preservation for ALL F-formulas, not just the target)

The fix requires using different witness constructions that produce Succ relations, not patches to the enumeration strategy.

## References

- `UltrafilterChain.lean:1045-1046` - temporal_box_seed definition (NO F-formulas)
- `UltrafilterChain.lean:1154-1184` - temporal_theory_witness_exists (only guarantees G-propagation)
- `SuccRelation.lean:59-60` - Succ definition (requires F-step)
- `SuccRelation.lean:232-268` - single_step_forcing (F resolves under Succ)
- `SuccExistence.lean:77-78` - deferralDisjunctions definition
- `SuccExistence.lean:401-402` - constrained_successor_seed (produces Succ)
- `SuccChainFMCS.lean:3067-3075` - restricted_forward_chain_forward_F (sorry-free F-coherence, restricted scope)
- `SuccChainFMCS.lean:3944` - constrained_predecessor_restricted_g_persistence_reverse (sorry)
- `SuccChainFMCS.lean:4001` - constrained_predecessor_restricted_f_step_forward (sorry)
