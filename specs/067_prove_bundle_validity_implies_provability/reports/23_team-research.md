# Research Report: Task #67 - F-Persistence Blocker Analysis

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Mode**: Team Research (2 teammates)
**Session**: sess_1774814336_4dd1f7

## Summary

The Phase 3 blocker in Plan 08 (dovetailed OmegaFMCS) is **fundamental and unfixable with the current witness construction**. The root cause is that `temporal_theory_witness_exists` builds witnesses using a seed that contains NO F-formulas, allowing Lindenbaum extension to freely add `G(neg psi)` which axiomatically excludes F-obligations from the successor MCS. This is not a bug in the dovetailing enumeration - it's an architectural mismatch between what the witness provides (G-propagation) and what temporal coherence requires (F-step preservation).

The mathematically correct solution is to use **Succ-producing successors** that encode the deferral pattern `{phi ∨ F(phi) | F(phi) ∈ M}` in the seed, guaranteeing each F-obligation is either resolved or persisted. This infrastructure already exists in `constrained_successor_seed` (SuccExistence.lean) but has integration gaps and backward chain sorries.

## Key Findings

### 1. Root Cause: Witness Construction Architecture (Teammate A)

**Location**: `temporal_theory_witness_exists` at UltrafilterChain.lean:1154-1184

**The seed composition** (lines 1045-1046):
```lean
def temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M
```

This includes:
- `G_theory M = {G(a) | G(a) ∈ M}` - only G-wrapped formulas
- `box_theory M = {Box(a) | Box(a) ∈ M} ∪ {neg(Box(a)) | Box(a) ∉ M}` - box formulas

**What's missing**: NO F-formulas, NO deferral disjunctions

**Why F-formulas are lost**:
1. Lindenbaum extension enumerates all formulas
2. For each formula chi, it adds either chi or neg(chi)
3. When considering `G(neg psi)`, nothing in the seed prevents it
4. If `G(neg psi)` is added, then `F(psi) = neg(G(neg psi))` becomes inconsistent
5. So `F(psi) ∉ W` even if `F(psi) ∈ M`

**Consequence**: The dovetailing strategy correctly enumerates all F-obligations, but the obligations may not persist to the steps where they're checked.

### 2. Why Family-Level Coherence is Required (Teammate B)

**Bundle-level coherence** (proven sorry-free):
- `F(phi) in fam.mcs(t)` implies `∃ fam' in bundle, ∃ s > t, phi in fam'.mcs(s)`
- Witness can be in ANY family
- Sufficient for modal (S5) completeness

**Family-level coherence** (required but not proven):
- `F(phi) in fam.mcs(t)` implies `∃ s > t, phi in fam.mcs(s)`
- Witness must be in the SAME family
- Required for temporal truth lemma

**Why family-level is needed**:

The truth lemma G backward case uses contraposition:
1. Assume `G(psi)` not in `fam.mcs(t)`
2. Then `F(neg psi)` is in `fam.mcs(t)`
3. By family-level forward_F: ∃ `s > t` with `neg(psi)` in `fam.mcs(s)`
4. Semantic hypothesis gives `truth(psi)` at `s`, so by IH, `psi` in `fam.mcs(s)`
5. Contradiction: `psi` and `neg(psi)` in same consistent MCS

Step 3 is the critical use - bundle-level coherence would place the witness in a different family, breaking the argument.

**Can the truth lemma be restructured?** No:
- The forward imp case uses the backward IH (MCS modus ponens)
- This dependency is inherent and unavoidable
- No known reformulation avoids needing family-level coherence

### 3. The Succ Relation Solution (Teammate A)

**Succ definition** (SuccRelation.lean:59-60):
```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

Two conditions:
1. **G-persistence**: all `G(a) ∈ u` implies `a ∈ v`
2. **F-step**: for all `F(phi) ∈ u`, either `phi ∈ v` OR `F(phi) ∈ v`

**Key theorem** (`single_step_forcing`, lines 232-268):
> If `F(phi) ∈ u`, `FF(phi) ∉ u`, and `Succ u v`, then `phi ∈ v`.

This means: under Succ, F-obligations with bounded nesting eventually resolve.

**The solution already exists**:
```lean
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

Where `deferralDisjunctions u = {phi ∨ F(phi) | F(phi) ∈ u}` forces resolution or deferral.

### 4. Existing Infrastructure Status

| Component | Status | Notes |
|-----------|--------|-------|
| `constrained_successor` (forward) | Sorry-free | Produces Succ |
| `constrained_predecessor` (backward) | Has sorries | Lines 3944, 4001 |
| `restricted_forward_chain_forward_F` | Sorry-free | But only for restricted MCS |
| `boxClassFamilies_bundle_forward_F` | Sorry-free | Bundle-level only |
| `succ_chain_forward_F` | Has sorry | Line 2424-2485 |

**The backward chain sorries** (SuccChainFMCS.lean):
- Line 3944: `constrained_predecessor_restricted_g_persistence_reverse`
- Line 4001: `constrained_predecessor_restricted_f_step_forward`

These block full Z-chain coherence proof.

## Synthesis

### Conflicts Resolved

Both teammates agree on:
1. Root cause is witness construction (no F-formulas in seed)
2. Family-level coherence is mathematically required
3. Succ-based construction is the correct approach

Teammate A recommends using existing `constrained_successor`.
Teammate B recommends "fair-scheduling chain construction".

**Resolution**: These are the same approach. The deferralDisjunctions pattern `{phi ∨ F(phi)}` IS fair scheduling - it encodes "either resolve now or defer to next step". The existing `constrained_successor_seed` implements this. The challenge is:
1. Wiring it to the omega chain (replacing `temporal_theory_witness_exists`)
2. Fixing the backward chain sorries for full Z-chain coherence

### Gaps Identified

1. **Integration gap**: `constrained_successor` is in SuccExistence.lean but not wired to `omega_chain_forward`
2. **Backward chain sorries**: Lines 3944, 4001 block symmetric construction
3. **Fuel exhaustion cases**: Several bounded-witness lemmas have fuel exhaustion sorries

### Recommended Approach

**Option 1: Fix Backward Chain Sorries (Most Direct)**

Focus on proving:
- `constrained_predecessor_restricted_g_persistence_reverse` (line 3944)
- `constrained_predecessor_restricted_f_step_forward` (line 4001)

These would enable full SuccChainFMCS coherence, giving family-level temporal coherence.

**Estimated effort**: 4-8 hours
**Risk**: Medium - may uncover deeper issues

**Option 2: Wire Constrained Successor to Omega Chain**

Replace the omega chain witness construction:
- Instead of `resolving_witness` (based on `temporal_theory_witness_exists`)
- Use `constrained_successor` (Succ-producing)

This would give F-step preservation for the forward chain. Backward chain still needs separate treatment.

**Estimated effort**: 6-10 hours
**Risk**: Medium-high - requires restructuring omega chain infrastructure

**Option 3: Accept Restricted Completeness**

Use `restricted_forward_chain_forward_F` which is sorry-free within `deferralClosure(phi)`.

For the target sorry in `bundle_validity_implies_provability`, if we can show the relevant formulas are in the deferral closure, the restricted construction suffices.

**Estimated effort**: 2-4 hours
**Risk**: Low - but may not cover all cases

### NOT Recommended

1. **More dovetailing variations** - The enumeration is not the problem
2. **Adding F-formulas to temporal_box_seed** - Breaks G-liftability, infinite seed
3. **Bundle-level workaround** - Truth lemma structure requires family-level
4. **New axioms** - Compromises mathematical integrity

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Root cause analysis | completed | high |
| B | Mathematical approaches | completed | medium-high |

## References

- UltrafilterChain.lean:1045-1046 - temporal_box_seed (no F-formulas)
- UltrafilterChain.lean:1154-1184 - temporal_theory_witness_exists
- SuccRelation.lean:59-60 - Succ definition
- SuccRelation.lean:232-268 - single_step_forcing
- SuccExistence.lean:77-78 - deferralDisjunctions
- SuccExistence.lean:401-402 - constrained_successor_seed
- SuccChainFMCS.lean:3067-3075 - restricted_forward_chain_forward_F (sorry-free)
- SuccChainFMCS.lean:3944 - backward chain sorry
- SuccChainFMCS.lean:4001 - backward chain sorry
- ParametricTruthLemma.lean:322-351 - G/H backward cases using forward_F/backward_P
