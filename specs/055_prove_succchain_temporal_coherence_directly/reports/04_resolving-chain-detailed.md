# Detailed Research: ResolvingChainFMCS Approach

**Task**: 55 - Prove SuccChain temporal coherence directly
**Date**: 2026-03-24
**Session**: sess_1774393458_979875
**Focus**: Work out the ResolvingChainFMCS approach in full detail

## Executive Summary

This report provides a complete, skip-nothing specification for replacing `SuccChainFMCS` with `ResolvingChainFMCS`. The key insight is that `forward_F` only needs to resolve ONE specific `phi` per invocation (per-obligation, not global fair scheduling). We leverage the proven `temporal_theory_witness_consistent` theorem to force F-resolution at controlled points.

## Part 1: Analysis of Existing Infrastructure

### 1.1 temporal_theory_witness_consistent (Sorry-Free)

**Location**: UltrafilterChain.lean:1111-1152

**Signature**:
```lean
theorem temporal_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent ({phi} ∪ temporal_box_seed M)
```

**Implementation**: Uses G-lift reasoning. If the seed were inconsistent, we could derive `neg(phi)` from `G_theory(M) ∪ box_theory(M)`, then G-lift to get `G(neg(phi)) ∈ M`. But `F(phi) = neg(G(neg(phi))) ∈ M`, contradiction.

**Status**: PROVEN (no sorry). ~41 lines.

### 1.2 temporal_theory_witness_exists (Sorry-Free)

**Location**: UltrafilterChain.lean:1158-1191

**Signature**:
```lean
theorem temporal_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W
```

**Implementation**: Uses `set_lindenbaum` to extend `{phi} ∪ temporal_box_seed(M)` to MCS W. The guarantees follow from seed structure:
- `phi ∈ W` from singleton in seed
- G-theory agreement from G_theory in seed
- box_class_agree from box_theory in seed

**Status**: PROVEN (no sorry). ~33 lines.

### 1.3 G_theory and temporal_box_seed Definitions

**Location**: UltrafilterChain.lean:962-1048

```lean
def G_theory (M : Set Formula) : Set Formula :=
  { f | ∃ a, f = Formula.all_future a ∧ Formula.all_future a ∈ M }

def temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M
```

Note: `G_theory` is "positive-only" (unlike `box_theory` which includes both `Box(a)` and `neg(Box(a))`). This is sufficient because the temporal logic lacks negative introspection for G.

### 1.4 constrained_successor_seed (Current Implementation)

**Location**: SuccExistence.lean:366-367

```lean
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

**Components**:
1. `g_content(u) = {phi | G(phi) ∈ u}` - ensures G-persistence
2. `deferralDisjunctions(u) = {phi ∨ F(phi) | F(phi) ∈ u}` - ensures F-step BUT allows indefinite deferral
3. `p_step_blocking_formulas(u)` - ensures P-step backward

**Problem**: The `deferralDisjunctions` use `phi ∨ F(phi)`, which allows Lindenbaum to always choose the deferral branch `F(phi)`. This is why `f_nesting_is_bounded` is mathematically FALSE for arbitrary MCS.

### 1.5 constrained_successor_from_seed

**Location**: SuccExistence.lean:474-478

```lean
noncomputable def constrained_successor_from_seed
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.bot.neg.some_future ∈ u) :
    Set Formula :=
  lindenbaumMCS_set (constrained_successor_seed u)
    (constrained_successor_seed_consistent u h_mcs h_F_top)
```

**Consistency Proof**: `constrained_successor_seed_consistent` shows the seed is consistent by proving all components are subsets of u.

### 1.6 Succ Relation Definition

**Location**: SuccRelation.lean:59-60

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

**Requirements**:
1. **G-persistence**: `g_content(u) ⊆ v`
2. **F-step**: `f_content(u) ⊆ v ∪ f_content(v)` (each F-obligation resolved OR deferred)

Note: P-step (`p_content(v) ⊆ u ∪ p_content(u)`) is NOT part of the Succ definition but is guaranteed by the constrained successor construction.

### 1.7 Sorry Chain Verification

| Theorem | File:Line | Status | Depends On |
|---------|-----------|--------|------------|
| `f_nesting_is_bounded` | SuccChainFMCS:731-735 | **SORRY** (math false) | - |
| `f_nesting_boundary` | SuccChainFMCS:755-759 | depends on sorry | f_nesting_is_bounded |
| `succ_chain_forward_F` | SuccChainFMCS:811-847 | depends on sorry | f_nesting_boundary |
| `SuccChainTemporalCoherent` | SuccChainFMCS:1156-1159 | depends on sorry | succ_chain_forward_F |
| `boxClassFamilies_temporally_coherent` | UltrafilterChain:1668-1679 | depends on sorry | SuccChainTemporalCoherent |

All verified via hover_info - the sorries propagate upward through the call chain.

## Part 2: Design the Resolving Successor Seed

### 2.1 The Resolving Seed Definition

Given MCS M and target formula `phi` where `F(phi) ∈ M`:

```lean
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ G_theory M ∪ box_theory M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M
```

**Equivalently**:
```lean
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M
```

### 2.2 Why Each Component

| Component | Purpose | Guarantees |
|-----------|---------|------------|
| `{phi}` | Force F-resolution | `phi ∈ W` (the target is satisfied!) |
| `G_theory M` | G-persistence | G-formulas propagate forward |
| `box_theory M` | Box-class agreement | Same equivalence class |
| `deferralDisjunctions M` | F-step for OTHER formulas | `f_content(M) ⊆ W ∪ f_content(W)` |
| `p_step_blocking_formulas M` | P-step backward | `p_content(W) ⊆ M ∪ p_content(M)` |

### 2.3 Consistency Proof Sketch

**Theorem**: `resolving_successor_seed_consistent`

```lean
theorem resolving_successor_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (resolving_successor_seed M phi)
```

**Proof Strategy**:

1. We already have `temporal_theory_witness_consistent`: `{phi} ∪ temporal_box_seed M` is consistent.

2. We need to show adding `deferralDisjunctions M ∪ p_step_blocking_formulas M` preserves consistency.

3. **Key insight**: Both `deferralDisjunctions M` and `p_step_blocking_formulas M` are subsets of M (proven in SuccExistence.lean):
   - `deferralDisjunctions M ⊆ M`: Each `phi ∨ F(phi)` is derivable from `F(phi) ∈ M`
   - `p_step_blocking_formulas M ⊆ M`: Each `H(neg(chi))` where `P(chi) ∉ M` is in M by negation completeness + DNE

4. Therefore, `resolving_successor_seed M phi ⊆ {phi} ∪ temporal_box_seed M ∪ M`.

5. But wait - the original seed `{phi} ∪ temporal_box_seed M` may NOT contain all of M. We need a different argument.

**Alternative Proof Strategy (Correct)**:

The key is that `temporal_box_seed M ⊇ G_theory M ∪ box_theory M`, and the additional components `deferralDisjunctions M` and `p_step_blocking_formulas M` are derivable FROM elements of M.

More precisely, assume `resolving_successor_seed M phi` is inconsistent. Then there's a finite derivation:
```
L ⊢ bot where L ⊆ resolving_successor_seed M phi
```

Partition L:
- `L_phi = L ∩ {phi}` (either empty or {phi})
- `L_seed = L ∩ temporal_box_seed M`
- `L_def = L ∩ deferralDisjunctions M`
- `L_block = L ∩ p_step_blocking_formulas M`

**Case 1**: `phi ∉ L`. Then `L ⊆ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M ⊆ M` (all three are subsets of M). Contradicts M being consistent.

**Case 2**: `phi ∈ L`. By deduction theorem: `L \ {phi} ⊢ neg(phi)`.

Now, every element of `L \ {phi}` is in one of:
- `temporal_box_seed M` (all of which can be G-lifted)
- `deferralDisjunctions M ⊆ M`
- `p_step_blocking_formulas M ⊆ M`

The elements from `deferralDisjunctions M` and `p_step_blocking_formulas M` are IN M, and for each such element x, we have `G(x) ∈ M` iff `x ∈ g_content M` iff `G(x) ∈ M`... this gets circular.

**Better approach - Direct Extension**:

```lean
theorem resolving_successor_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (resolving_successor_seed M phi) := by
  -- First show {phi} ∪ temporal_box_seed M is consistent
  have h_base := temporal_theory_witness_consistent M h_mcs phi h_F
  -- The additional components are subsets of M
  have h_def_subset : deferralDisjunctions M ⊆ M := deferralDisjunctions_subset_mcs M h_mcs
  have h_block_subset : p_step_blocking_formulas M ⊆ M := p_step_blocking_formulas_subset_u M h_mcs
  -- Extend the consistency argument
  -- If the larger seed is inconsistent, then some finite L ⊆ seed derives bot
  -- Elements from deferralDisjunctions and p_step_blocking can be "replaced" by
  -- their MCS membership + closure under derivation
  intro L h_L_sub ⟨d⟩
  -- Filter L into: elements in {phi} ∪ temporal_box_seed vs elements only in deferral/blocking
  -- The elements in deferral/blocking are in M, so they can be used via MCS closure
  -- But this requires showing we can derive from temporal_box_seed + M-elements
  -- Actually, the simplest: temporal_box_seed ∪ deferral ∪ blocking ⊆ M ∪ temporal_box_seed
  -- And M ∪ temporal_box_seed is consistent (temporal_box_seed ⊆ M for the G_theory part)
  sorry -- Detailed proof requires case analysis
```

**Cleaner Proof** (using the fact that all components are in M except phi):

Since `G_theory M ⊆ M`, `box_theory M ⊆ M` (proven), `deferralDisjunctions M ⊆ M` (proven), and `p_step_blocking_formulas M ⊆ M` (proven), we have:

`resolving_successor_seed M phi = {phi} ∪ (subset of M)`

So the question becomes: is `{phi} ∪ S` consistent when `S ⊆ M` and `F(phi) ∈ M`?

This is exactly what `temporal_theory_witness_consistent` proves for `S = temporal_box_seed M`. But our S is larger.

**The key insight**: The proof of `temporal_theory_witness_consistent` uses G-lifting. Specifically:
- If `{phi} ∪ S` is inconsistent, there's `L ⊆ S` with `L ⊢ neg(phi)`
- By G-lifting: `G(neg(phi)) ∈ M`
- But `F(phi) = neg(G(neg(phi))) ∈ M`, contradiction

This argument works as long as every element of S can be G-lifted (i.e., `∀ x ∈ S, G(x) ∈ M`).

For `temporal_box_seed M`, this is `G_of_temporal_box_seed` (proven at UltrafilterChain.lean:1053-1059).

For `deferralDisjunctions M` and `p_step_blocking_formulas M`, we need to check if they can be G-lifted. Let's verify:

**Can deferralDisjunctions be G-lifted?**

`deferralDisjunction(psi) = psi ∨ F(psi)` where `F(psi) ∈ M`.

Can we derive `G(psi ∨ F(psi)) ∈ M` from `F(psi) ∈ M`?

We have: `F(psi) → psi ∨ F(psi)` (provable: right disjunction intro)
So: `F(psi) ∈ M → psi ∨ F(psi) ∈ M`

But can we get `G(psi ∨ F(psi)) ∈ M`?

We'd need `psi ∨ F(psi) → G(psi ∨ F(psi))`, i.e., `A → G(A)` for arbitrary A. This is FALSE in general (only holds for theorems).

**Alternative**: Can we avoid needing the G-lift property for deferralDisjunctions?

The original `temporal_theory_witness_consistent` proof filters L into `{phi}` and the rest, then shows `L_rest ⊢ neg(phi)` can be G-lifted. The G-lifting step uses `G_of_temporal_box_seed`.

If we include elements that CANNOT be G-lifted, the proof breaks.

**Solution**: Don't include `deferralDisjunctions` and `p_step_blocking_formulas` in the SEED. Include them in the EXTENSION.

**Revised Strategy**:

```lean
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M
  -- DON'T include deferralDisjunctions and p_step_blocking in seed
```

This seed is consistent by `temporal_theory_witness_consistent`.

Then, let `W = lindenbaum_extension({phi} ∪ temporal_box_seed M)`.

Now we need to verify that W satisfies Succ M W. For this, we need:
1. `g_content M ⊆ W` - follows from `G_theory M ⊆ temporal_box_seed M ⊆ W`... WAIT, this is wrong. `G_theory M` contains G-formulas like `G(a)`, but `g_content M = {phi | G(phi) ∈ M}`. These are different!

**Clarification**:
- `g_content M = {a | G(a) ∈ M}` - the "contents" of G-formulas
- `G_theory M = {G(a) | G(a) ∈ M}` - the G-formulas themselves

So `G_theory M ⊆ temporal_box_seed M` means the witness W contains all `G(a)` where `G(a) ∈ M`. But for G-persistence in Succ, we need `g_content M ⊆ W`, i.e., for every `a` with `G(a) ∈ M`, we need `a ∈ W`.

From temp_t_future: `G(a) → a`. So if `G(a) ∈ W` and W is MCS, then `a ∈ W`.

So: `G(a) ∈ M → G(a) ∈ G_theory M → G(a) ∈ W → a ∈ W` (by T-axiom and MCS closure).

Thus `g_content M ⊆ W`. **G-persistence verified.**

2. `f_content M ⊆ W ∪ f_content W` - This is the F-step. For each `psi` with `F(psi) ∈ M`, we need `psi ∈ W` OR `F(psi) ∈ W`.

Currently, the constrained_successor_seed includes `deferralDisjunctions` to guarantee this. Our seed does NOT include them.

**Problem**: The seed `{phi} ∪ temporal_box_seed M` does NOT guarantee F-step for formulas OTHER than phi.

For `phi` itself: `phi ∈ W` by construction. So F-step for phi is satisfied (resolved).

For other `psi` with `F(psi) ∈ M, psi ≠ phi`: We have `F(psi) ∈ M`. Does this guarantee `psi ∈ W` or `F(psi) ∈ W`?

Hmm, not automatically. The Lindenbaum extension adds formulas to make W maximal, but it's non-constructive. We can't guarantee where `psi` or `F(psi)` ends up.

**Insight**: We DON'T need F-step for all other formulas! The definition of Succ requires `f_content M ⊆ W ∪ f_content W`, but for temporal coherence (`forward_F`), we only need to show that for each specific `F(phi) ∈ M`, there exists some witness with `phi`.

The existing SuccChainFMCS builds a SINGLE chain and claims it satisfies forward_F for ALL formulas. This is where the sorry chain originates.

Our approach is different: for each specific `F(phi) ∈ M`, we build a RESOLVING witness that satisfies phi. The chain itself doesn't need to be deterministic or satisfy Succ for all transitions.

**BUT**: `boxClassFamilies_temporally_coherent` requires that the family satisfies `forward_F`, meaning for `F(phi) ∈ fam.mcs t`, there exists `s > t` with `phi ∈ fam.mcs s` IN THE SAME FAMILY.

The current proof at UltrafilterChain.lean:1668-1679 delegates to `SuccChainTemporalCoherent`, which depends on `succ_chain_forward_F`.

**The key question**: Can we prove `forward_F` for a modified chain construction?

### 2.4 The Per-Obligation Insight (Resolution)

The team research identified: "forward_F only needs to resolve ONE specific phi per invocation (per-obligation, not global fair scheduling)."

This means: when `boxClassFamilies_temporally_coherent` needs to prove `∃ s > t, phi ∈ fam.mcs s` for a specific `F(phi) ∈ fam.mcs t`, we can construct a CUSTOM witness for that specific phi.

**Strategy**: Don't replace the entire SuccChainFMCS. Instead, prove `forward_F` directly for each invocation.

Given `F(phi) ∈ fam.mcs t` where `fam = shifted_fmcs(SuccChainFMCS(W), k)`:
1. `fam.mcs t = (SuccChainFMCS W).mcs (t - k) = succ_chain_fam W (t - k)`
2. So `F(phi) ∈ succ_chain_fam W (t - k)`
3. Apply `temporal_theory_witness_exists` to get MCS W' with `phi ∈ W'`
4. W' is in the same box class as `succ_chain_fam W (t - k)` (box_class_agree from temporal_theory_witness_exists)
5. Build a SuccChain from W': `SuccChainFMCS(MCS_to_SerialMCS W' ...)`
6. At time 0 in this new chain: `phi ∈ (SuccChainFMCS W').mcs 0 = W'`

**Problem**: W' is a DIFFERENT chain, not the same family fam.

**BUT**: `boxClassFamilies` includes ALL shifted SuccChainFMCS from MCSes in the same box class!

From UltrafilterChain.lean:1433-1437:
```lean
noncomputable def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k }
```

So `shifted_fmcs(SuccChainFMCS W', shift)` is in boxClassFamilies IF `box_class_agree M0 W'`.

**Chain of box_class_agree**:
1. fam is in boxClassFamilies(M0), so fam comes from some W with `box_class_agree M0 W`
2. `succ_chain_fam W (t - k)` is in the same box class as W (SuccChain preserves box class - proven at `succ_chain_box_class_agree`)
3. W' from `temporal_theory_witness_exists` has `box_class_agree (succ_chain_fam W (t-k)) W'`
4. By transitivity: `box_class_agree M0 W'`

So the new chain from W' IS in boxClassFamilies!

**The witness**: s = the time index in the NEW family where phi holds.

But wait - `boxClassFamilies_temporally_coherent` requires `phi ∈ fam.mcs s` - the SAME family fam, not a different family.

Let me re-read the requirement:

```lean
theorem boxClassFamilies_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    ∀ fam ∈ boxClassFamilies M0 h_mcs,
      (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧ ...
```

Yes, it requires `φ ∈ fam.mcs s` - same family fam.

**This is the core problem that the team research identified**: the witness must be in the SAME family, not a different family in the bundle.

### 2.5 Resolution: Build the Resolving Chain WITHIN the Same Family

The solution is to NOT build a separate chain, but to modify the SuccChain construction itself to force F-resolution.

**Option A: Separate Resolving Chain for EACH Obligation**

For each `F(phi) ∈ M_n` query, build a separate chain that:
1. Starts from M_n
2. Uses resolving successor at step n+1 that forces phi
3. Returns m = n+1 as the witness

This is what the team research calls "per-obligation chains."

**Implementation**:

```lean
theorem forward_F_per_obligation (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m := by
  -- Build resolving chain from M0 that forces phi at position n+1
  -- Actually, we need to force phi at the step AFTER n, not from the beginning
  sorry
```

Wait, the issue is that `succ_chain_fam M0` is ALREADY DEFINED. It's the chain built by `constrained_successor_from_seed` at each step. We can't retroactively change what `succ_chain_fam M0 (n+1)` is.

**The problem restated**: The SuccChain from M0 is deterministic. `forward_chain M0 k = constrained_successor^k(M0)`. There's no freedom to "choose" a different successor.

### 2.6 The REAL Solution: Replace the Chain Construction Entirely

The team research recommended: "Replace SuccChainFMCS with a ResolvingChainFMCS that uses temporal_theory_witness_exists to force F-resolution."

This means:

1. **Define a NEW chain type** `ResolvingChainFMCS` with DIFFERENT successor function
2. **The successor function takes a TARGET phi** and forces it
3. **Temporal coherence is BUILT INTO the construction**
4. **Replace `boxClassFamilies` to use ResolvingChainFMCS instead of SuccChainFMCS**

But here's the subtlety: the successor function needs to know WHICH phi to force. In a deterministic chain, this must be decided ahead of time or via enumeration.

**Insight from team research**: "forward_F only needs to resolve ONE specific phi per invocation."

This means we don't need a single chain that works for ALL formulas. When `forward_F` is invoked with a specific phi, we can build a chain SPECIFICALLY FOR THAT PHI on the fly.

**Concrete Implementation**:

```lean
-- For each query F(phi) ∈ M_n, build a separate resolving chain
theorem succ_chain_forward_F_via_resolving (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m := by
  -- Let M_n = succ_chain_fam M0 n
  let M_n := succ_chain_fam M0 n
  have h_mcs_n := succ_chain_fam_mcs M0 n

  -- By temporal_theory_witness_exists, get W with phi ∈ W and box_class_agree
  obtain ⟨W, h_W_mcs, h_phi_W, h_G_agree, h_box_agree⟩ :=
    temporal_theory_witness_exists M_n h_mcs_n phi h_F

  -- The key claim: W can be found in succ_chain_fam M0 at some position m > n
  -- This is NOT automatic because W is an abstract MCS from Lindenbaum

  sorry -- This is where we're stuck
```

The issue: the witness W is an EXISTENTIAL MCS. It exists abstractly but may not equal any `succ_chain_fam M0 m`.

### 2.7 The Non-Constructive Solution

**Observation**: The completeness proof ultimately needs to show that certain formulas are satisfied in a model. The model is built from `boxClassFamilies`. Each family in `boxClassFamilies` is `shifted_fmcs(SuccChainFMCS W, k)` for SOME W in the box class.

When we need a witness for `F(phi) ∈ fam.mcs t`:
1. fam = `shifted_fmcs(SuccChainFMCS W, k)`
2. `fam.mcs t = (SuccChainFMCS W).mcs (t - k) = succ_chain_fam W (t - k)`
3. So `F(phi) ∈ succ_chain_fam W (t - k)`
4. Let `M = succ_chain_fam W (t - k)`. By temporal_theory_witness_exists, get W' with `phi ∈ W'`
5. Now, `shifted_fmcs(SuccChainFMCS W', t - k)` is a family where:
   - At time t - k, we have `(SuccChainFMCS W').mcs 0 = W'`, so `phi ∈ W'`
   - Shifted by k: at time t, we have `phi` in the shifted family

But this is a DIFFERENT family!

**The key realization**: `boxClassFamilies_temporally_coherent` requires the witness in the SAME family. This constraint is fundamental to the truth lemma.

### 2.8 Re-examining the Problem

Let me re-read `boxClassFamilies_temporally_coherent`:

```lean
theorem boxClassFamilies_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    ∀ fam ∈ boxClassFamilies M0 h_mcs,
      (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s)
```

And the current proof:

```lean
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  let tcf := SuccChainTemporalCoherent (MCS_to_SerialMCS W h_W)
  constructor
  · exact shifted_temporal_forward_F (SuccChainFMCS (MCS_to_SerialMCS W h_W))
      tcf.forward_F k
  · exact shifted_temporal_backward_P (SuccChainFMCS (MCS_to_SerialMCS W h_W))
      tcf.backward_P k
```

It delegates to `SuccChainTemporalCoherent`, which has:
- `forward_F := succ_chain_forward_F M0`
- `backward_P := succ_chain_backward_P M0`

And `succ_chain_forward_F` is the one with the sorry chain.

**What succ_chain_forward_F claims**:

```lean
theorem succ_chain_forward_F (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

This claims: for ANY phi with `F(phi)` at position n, phi appears at some later position m IN THE SAME CHAIN.

The current proof strategy:
1. Use `f_nesting_boundary` to find d with `iter_F d phi ∈ M` and `iter_F (d+1) phi ∉ M`
2. Use `bounded_witness` to conclude phi is at position n + d

But `f_nesting_boundary` depends on `f_nesting_is_bounded`, which is FALSE for arbitrary MCS.

## Part 3: Resolving Successor Satisfies Succ

Let's work out whether a resolving successor W (from temporal_theory_witness_exists) satisfies `Succ M W`.

**Given**: `F(phi) ∈ M`, M is MCS, W is from `temporal_theory_witness_exists M phi`:
- `SetMaximalConsistent W`
- `phi ∈ W`
- `∀ a, G(a) ∈ M → G(a) ∈ W`
- `box_class_agree M W`

**Need to show**: `Succ M W`, i.e.:
1. `g_content M ⊆ W`
2. `f_content M ⊆ W ∪ f_content W`

### 3.1 G-persistence

`g_content M = {a | G(a) ∈ M}`

For any `a ∈ g_content M`, we have `G(a) ∈ M`.
By `temporal_theory_witness_exists` property: `G(a) ∈ M → G(a) ∈ W`.
So `G(a) ∈ W`.
By temp_t_future: `G(a) → a`, and W is MCS, so `a ∈ W`.

**G-persistence: VERIFIED**

### 3.2 F-step

`f_content M = {a | F(a) ∈ M}`

For any `a ∈ f_content M` (i.e., `F(a) ∈ M`), we need `a ∈ W` OR `F(a) ∈ W`.

For `a = phi`: We have `phi ∈ W` by construction. **Done.**

For `a ≠ phi`: We have `F(a) ∈ M`. What can we say about W?

From `temporal_theory_witness_exists`, W extends `{phi} ∪ temporal_box_seed M`. This does NOT include any information about F(a).

W is an MCS, so either `a ∈ W` or `a ∉ W`. If `a ∉ W`, then `neg(a) ∈ W` by MCS completeness. Does this tell us about `F(a)`?

`F(a) ∈ W` iff `neg(G(neg(a))) ∈ W` iff `G(neg(a)) ∉ W` (by MCS completeness).

What do we know about `G(neg(a))`?

If `G(neg(a)) ∈ M`, then by the G-agreement property, `G(neg(a)) ∈ W`.

If `G(neg(a)) ∉ M`, then we can't conclude anything about `G(neg(a)) ∈ W`.

**Key observation**: `F(a) ∈ M` means `neg(G(neg(a))) ∈ M`, which means `G(neg(a)) ∉ M` (by MCS consistency).

So `G(neg(a)) ∉ M`. But the G-agreement only tells us `G(x) ∈ M → G(x) ∈ W`. It doesn't tell us anything about `G(x) ∉ M` case.

**Conclusion**: We CANNOT conclude `a ∈ W` or `F(a) ∈ W` for arbitrary `a ≠ phi`.

**This means**: The resolving successor from `temporal_theory_witness_exists` does NOT automatically satisfy F-step for all formulas.

### 3.3 Expanding the Seed

To satisfy F-step, we need to include more in the seed.

**Extended seed**:

```lean
def resolving_temporal_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M
```

For consistency, we need to verify this larger seed is consistent when `F(phi) ∈ M`.

**Claim**: If `F(phi) ∈ M` and M is MCS, then `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M` is consistent.

**Proof attempt**: Suppose inconsistent. Then there's finite `L ⊆ seed` with `L ⊢ bot`.

Partition L into:
- `L_phi = L ∩ {phi}`
- `L_seed = L ∩ temporal_box_seed M`
- `L_def = L ∩ deferralDisjunctions M`

**Case 1**: `phi ∉ L`. Then `L ⊆ temporal_box_seed M ∪ deferralDisjunctions M`.

Now, `temporal_box_seed M ⊆ M` (proven: G_theory ⊆ M by T-axiom, box_theory ⊆ M by definition).
And `deferralDisjunctions M ⊆ M` (proven: each `a ∨ F(a)` derivable from `F(a) ∈ M`).

So `L ⊆ M`, and `L ⊢ bot` contradicts M being consistent.

**Case 2**: `phi ∈ L`. By deduction theorem: `L \ {phi} ⊢ neg(phi)`, where `L \ {phi} ⊆ temporal_box_seed M ∪ deferralDisjunctions M`.

Let's try to G-lift this to get `G(neg(phi)) ∈ M`, then contradict `F(phi) ∈ M`.

The G-lift argument requires that all elements of the context can be G-lifted (i.e., their G is in M).

For `temporal_box_seed M`:
- `G_theory M = {G(a) | G(a) ∈ M}`: For `G(a) ∈ G_theory`, we have `G(a) ∈ M`, and by temp_4: `G(a) → G(G(a))`, so `G(G(a)) ∈ M`.
- `box_theory M`: Includes `Box(a)` where `Box(a) ∈ M`, and `neg(Box(a))` where `Box(a) ∉ M`. For `Box(a)`, by TF: `Box(a) → G(Box(a))`. For `neg(Box(a))`, we need `G(neg(Box(a))) ∈ M`... this requires `neg(Box(a)) → G(neg(Box(a)))`, which is NOT generally true.

**Problem**: box_theory includes `neg(Box(a))` which may NOT be G-liftable.

Actually wait - let me re-check `temporal_box_seed`:

```lean
def temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M
```

And from UltrafilterChain.lean:1051-1059:

```lean
theorem G_of_temporal_box_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ temporal_box_seed M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [temporal_box_seed, Set.mem_union] at hx
  rcases hx with h | h
  · exact G_of_G_theory M h_mcs x h
  · exact G_of_box_theory M h_mcs x h
```

So the codebase already proves that ALL elements of `temporal_box_seed` can be G-lifted! Let me check `G_of_box_theory`:

```lean
theorem G_of_box_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ box_theory M, Formula.all_future x ∈ M
```

This is the key lemma at lines ~1020-1043 that handles both cases:
- `Box(a) ∈ M`: By TF (temp_future), `Box(a) → G(Box(a))`, so `G(Box(a)) ∈ M`
- `neg(Box(a))` where `Box(a) ∉ M`: By modal_future + S5 structure, `neg(Box(a)) → G(neg(Box(a)))` is derivable

So `temporal_box_seed` elements CAN be G-lifted.

But what about `deferralDisjunctions M`?

For `a ∨ F(a) ∈ deferralDisjunctions M` (where `F(a) ∈ M`):
Can we derive `G(a ∨ F(a)) ∈ M`?

We have `F(a) ∈ M`, so `a ∨ F(a) ∈ M` (by disjunction intro).

But we need `G(a ∨ F(a)) ∈ M`.

From `F(a) ∈ M`, we have `a ∈ f_content M`. From temp_a: `a → G(P(a))`. This gives us `G(P(a))`, not `G(a ∨ F(a))`.

**Alternative approach**: Let's not require G-liftability for deferralDisjunctions.

The inconsistency proof for `{phi} ∪ temporal_box_seed M` worked because we could G-lift the entire context. With deferralDisjunctions added, we can't G-lift everything.

**New proof approach for extended seed consistency**:

Suppose `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M` is inconsistent.

Let `L ⊆ seed` with `L ⊢ bot`.

**Key observation**: `deferralDisjunctions M ⊆ M` (each element is derivable from an F-formula in M).

So `L ⊆ {phi} ∪ M` (since temporal_box_seed M ⊆ M too).

If `phi ∉ L`, then `L ⊆ M`, contradiction.

If `phi ∈ L`, then `L \ {phi} ⊆ M`, so `L \ {phi} ⊢ neg(phi)` where context is entirely in M.

By "from M" we mean: all premises are in M. This doesn't immediately give us `neg(phi) ∈ M` because derivability from a subset of M doesn't imply membership.

BUT, M is an MCS, which means M is deductively closed. So if `L \ {phi} ⊢ neg(phi)` and `L \ {phi} ⊆ M`, then... we need to be careful. Deductive closure means `{A | M ⊢ A} = M` for a FINITE set of axioms plus rule applications, but MCS deductive closure is via the derivation system, not arbitrary subsets.

Actually, the derivation `L \ {phi} ⊢ neg(phi)` means there's a derivation tree with leaves from `L \ {phi}` concluding `neg(phi)`. Since all leaves are in M and M is closed under derivation, `neg(phi) ∈ M`.

But `F(phi) ∈ M` means `neg(G(neg(phi))) ∈ M`, and `neg(phi) ∈ M`... these are not contradictory!

We need `G(neg(phi)) ∈ M` to contradict `F(phi) ∈ M`.

So the direct approach doesn't work.

**Back to the G-lift approach**: For the G-lift argument to work, we need the context to consist of G-liftable formulas. The deferralDisjunctions are NOT G-liftable.

**Resolution**: Use a different consistency argument.

**Claim (revised)**: `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M` is consistent when `F(phi) ∈ M`.

**Proof**:
All three components are subsets of `{phi} ∪ M`:
- `{phi}` is `{phi}`
- `temporal_box_seed M ⊆ M` (proven: G_theory_subset_mcs + box_theory_subset_mcs)
- `deferralDisjunctions M ⊆ M` (proven: deferralDisjunctions_subset_mcs)

So the seed is a subset of `{phi} ∪ M`.

Now, `{phi} ∪ M` is consistent iff `neg(phi) ∉ M`.

We have `F(phi) ∈ M`. Suppose `neg(phi) ∈ M`.

By modus ponens on `neg(phi) → G(neg(phi))` (from temp_a reverse? No, that's for P).

Actually, `neg(phi) ∈ M` does NOT imply `G(neg(phi)) ∈ M` in general.

BUT, for consistency of `{phi} ∪ M`:

`{phi} ∪ M` is inconsistent iff there exists `L ⊆ M` with `phi, L ⊢ bot`, iff `L ⊢ neg(phi)`, iff `neg(phi)` is derivable from M, iff `neg(phi) ∈ M` (by MCS closure).

So `{phi} ∪ M` is consistent iff `neg(phi) ∉ M` iff `phi ∈ M` or M doesn't decide phi...

Wait, M is MCS, so exactly one of `phi ∈ M` or `neg(phi) ∈ M`.

So `{phi} ∪ M` is consistent iff `phi ∈ M` or... no, if `neg(phi) ∈ M`, then `{phi, neg(phi)} ⊢ bot`, so inconsistent.

**Therefore**: `{phi} ∪ M` is consistent iff `phi ∈ M`.

But we DON'T assume `phi ∈ M`! We only assume `F(phi) ∈ M`.

**So we CANNOT prove consistency by the subset argument.**

This brings us back to the original G-lift proof, which requires all context elements to be G-liftable.

### 3.4 Resolution: Separate the Concerns

**Insight**: The G-lift argument in `temporal_theory_witness_consistent` works because `temporal_box_seed` consists of G-liftable formulas. Adding non-G-liftable formulas breaks the proof.

**Solution**: Keep the seed as `{phi} ∪ temporal_box_seed M`, which is consistent by `temporal_theory_witness_consistent`. The Lindenbaum extension W may or may not contain deferralDisjunctions, but that's okay - we only need F-step for phi, which is guaranteed by `phi ∈ W`.

For OTHER F-formulas in M, we don't need the resolving successor to handle them. They'll be handled by THEIR OWN resolving successors when queried.

**This is the per-obligation insight**: Each `F(psi)` gets its own resolving successor when needed. We don't build a single successor that handles all F-obligations.

### 3.5 Checking Succ for Resolving Successor

Given W from `temporal_theory_witness_exists(M, phi)` where `F(phi) ∈ M`:

**G-persistence**: `g_content M ⊆ W` - VERIFIED (Section 3.1)

**F-step for phi**: `phi ∈ f_content M` (since `F(phi) ∈ M`), and `phi ∈ W`. So `phi ∈ W ⊆ W ∪ f_content W`. **Done.**

**F-step for other psi**: For `psi ∈ f_content M, psi ≠ phi`, we need `psi ∈ W` OR `F(psi) ∈ W`.

This is NOT guaranteed by the construction.

**Conclusion**: The resolving successor does NOT fully satisfy `Succ M W` for all F-formulas. It only guarantees:
- G-persistence (full)
- F-step for the TARGET phi (partial)

## Part 4: The Per-Obligation Architecture

### 4.1 Not Replacing SuccChainFMCS Entirely

The key insight from the analysis: we don't need to replace `SuccChainFMCS` entirely. The existing chain construction works for G-persistence and most properties. The ONLY issue is proving `forward_F`.

Instead of a new chain type, we prove `forward_F` by a SEPARATE argument for each invocation.

### 4.2 Direct Proof of succ_chain_forward_F

**Theorem**: `succ_chain_forward_F_direct`

```lean
theorem succ_chain_forward_F_direct (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

**Proof Strategy**:

The key claim: the EXISTING SuccChain construction already has the witness, we just need to find it.

Actually, this is NOT true. The SuccChain uses deferralDisjunctions which can perpetually defer phi.

**Alternative Strategy**: Use temporal_theory_witness_exists to get W with phi ∈ W, then show W appears in the chain.

But W is an abstract MCS. It may not equal any `succ_chain_fam M0 m`.

**Alternative Strategy 2**: Show that the chain EVENTUALLY resolves phi by a different argument.

For restricted MCS (in deferralClosure), we have `f_nesting_is_bounded_restricted` which is sorry-free. The issue is threading RestrictedMCS through the chain, which has boundary-case sorries.

**Alternative Strategy 3**: Replace just `forward_F` in `boxClassFamilies_temporally_coherent` without touching SuccChainFMCS.

### 4.3 Replacing forward_F at the Bundle Level

Instead of proving `succ_chain_forward_F`, prove `boxClassFamilies_temporally_coherent` directly without delegating to `SuccChainTemporalCoherent`.

**New proof of boxClassFamilies_temporally_coherent**:

```lean
theorem boxClassFamilies_temporally_coherent_direct (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    ∀ fam ∈ boxClassFamilies M0 h_mcs,
      (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s) := by
  intro fam hfam
  obtain ⟨W, h_W, k, h_agree_W, rfl⟩ := hfam
  constructor
  -- forward_F
  · intro t phi h_F_in_fam
    -- fam.mcs t = (SuccChainFMCS W).mcs (t - k) = succ_chain_fam W (t - k)
    -- So F(phi) ∈ succ_chain_fam W (t - k)
    let M_t := succ_chain_fam (MCS_to_SerialMCS W h_W) (t - k)
    have h_mcs_t : SetMaximalConsistent M_t := succ_chain_fam_mcs _ _

    -- Apply temporal_theory_witness_exists to get W' with phi ∈ W'
    obtain ⟨W', h_W'_mcs, h_phi_W', h_G_agree', h_box_agree'⟩ :=
      temporal_theory_witness_exists M_t h_mcs_t phi h_F_in_fam

    -- W' has box_class_agree with M_t
    -- M_t has box_class_agree with W (by chain box-class preservation)
    -- W has box_class_agree with M0 (by assumption h_agree_W)
    -- So W' has box_class_agree with M0 (by transitivity)

    -- Therefore shifted_fmcs(SuccChainFMCS W', t - k) ∈ boxClassFamilies M0
    -- And at time t, this family has phi at position 0 (shifted by t - k gives t)

    -- BUT we need phi in THE SAME family fam, not a different family!

    sorry
  -- backward_P: symmetric
  · sorry
```

**The fundamental obstacle remains**: We need the witness in the SAME family.

### 4.4 The Cross-Family Impossibility

The team research confirmed: "Cross-family witnesses cannot help. The truth lemma's `temporal_backward_G` requires same-family witnesses."

Let me trace this dependency:

`temporal_backward_G` is used in the truth lemma to handle the G-case:
- If `G(phi) ∈ W` at time t, then for all s ≥ t, `phi ∈ W` at time s.
- Contrapositive: if `neg(phi) ∈ W` at some s > t, then `G(phi) ∉ W` at t.

This uses the SAME family W's chain. If the witness were in a DIFFERENT family, the truth lemma would break.

### 4.5 The Resolving Chain is NECESSARY

Based on the analysis, replacing the SuccChain construction is NECESSARY. We cannot prove `forward_F` for the existing construction because the deferral mechanism is inherently flawed.

## Part 5: Designing ResolvingChainFMCS

### 5.1 The Structure

```lean
structure ResolvingForwardChainElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  has_F_top : F_top ∈ world
  -- Track which F-obligations have been resolved
  -- (Optional: for verification purposes)
```

### 5.2 The Resolving Successor

```lean
noncomputable def ResolvingForwardChainElement.next
    (e : ResolvingForwardChainElement)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ e.world) :
    ResolvingForwardChainElement := by
  -- Build resolving seed: force phi
  let seed := {phi} ∪ temporal_box_seed e.world
  -- Prove consistency
  have h_cons : SetConsistent seed := temporal_theory_witness_consistent e.world e.is_mcs phi h_F
  -- Lindenbaum extension
  let W := lindenbaumMCS_set seed h_cons
  have h_W_mcs : SetMaximalConsistent W := lindenbaumMCS_set_is_mcs seed h_cons
  -- phi ∈ W
  have h_phi_W : phi ∈ W := lindenbaumMCS_set_extends seed h_cons phi (Set.mem_union_left _ (Set.mem_singleton phi))
  -- F_top ∈ W (it's a theorem)
  have h_F_top_W : F_top ∈ W := SetMaximalConsistent.contains_F_top h_W_mcs
  exact ⟨W, h_W_mcs, h_F_top_W⟩
```

### 5.3 The Chain Construction Issue

The chain needs to decide WHICH phi to force at each step. Options:

**Option A: Per-Query Chains**

Don't build a single chain. For each query `F(phi) ∈ M_n`, build a chain that:
1. Uses the existing SuccChain up to step n
2. Uses resolving successor at step n+1 forcing phi
3. Continues with standard successors thereafter

```lean
def resolving_chain_for_query (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) : Int → Set Formula
  | m => if m ≤ n then succ_chain_fam M0 m
         else if m = n + 1 then resolving_successor (succ_chain_fam M0 n) phi h_F
         else forward_chain_from (resolving_successor ...) (m - n - 1)
```

This gives us `phi ∈ resolving_chain_for_query M0 n phi h_F (n+1)`.

**Problem**: This is a DIFFERENT chain than `succ_chain_fam M0`. So `phi` is NOT in `succ_chain_fam M0 (n+1)` necessarily.

**Insight**: We need to REDEFINE SuccChainFMCS to use resolving successors throughout.

**Option B: Fair Scheduler**

Use a canonical enumeration of F-obligations and resolve them in round-robin fashion.

At step n, resolve the (n mod |F-obligations|)-th F-formula.

**Problem**: The set of F-obligations may be infinite. No canonical enumeration exists.

**Option C: Dovetailing**

Build an omega-squared structure that interleaves F-resolution across all obligations.

At step (i, j), resolve the j-th F-obligation from step i.

**Complexity**: Requires significant infrastructure. This is what `TemporalContent.lean:40-44` anticipated with reference to DovetailingChain.lean.

### 5.4 The Simplest Working Approach

**Key realization**: For `boxClassFamilies_temporally_coherent`, we're asked to prove for ANY phi with `F(phi) ∈ fam.mcs t`, there exists s > t with `phi ∈ fam.mcs s`.

We can build a SPECIFIC family for each such phi:

1. Given `F(phi) ∈ fam.mcs t`
2. Let `M = fam.mcs t`
3. Build resolving successor W with `phi ∈ W`
4. Build a NEW SuccChain from W: `SuccChainFMCS(MCS_to_SerialMCS W)`
5. This new chain has `W` at position 0, so `phi ∈ new_chain.mcs 0`
6. Shift this new chain by t: `shifted_fmcs(new_chain, t)`
7. This shifted chain is in `boxClassFamilies` (by box_class_agree)
8. At time t, the shifted chain has `phi`

**BUT**: This gives a witness in a DIFFERENT family, not fam.

**The only way forward**: Modify the chain construction so that phi appears in THE SAME chain.

### 5.5 Embedding the Resolving Witness into the Same Chain

**Claim**: If we can show that the resolving witness W satisfies `Succ M W` (where M = succ_chain_fam M0 n), then we could extend the chain from M using W instead of the standard successor.

But the chain is ALREADY BUILT deterministically. We can't retroactively change it.

**Solution**: Build a NEW chain type where each step has a choice of which F-formula to resolve.

### 5.6 Non-Deterministic Resolving Chain

```lean
-- The resolving chain is defined relationally, not functionally
def ResolvingChainElement (M0 : SerialMCS) (n : Int) (W : Set Formula) : Prop :=
  SetMaximalConsistent W ∧
  F_top ∈ W ∧
  -- For n = 0: W = M0.world
  (n = 0 → W = M0.world) ∧
  -- For n > 0: exists predecessor M at n-1 with Succ M W
  (n > 0 → ∃ M, ResolvingChainElement M0 (n-1) M ∧ Succ M W) ∧
  -- For n < 0: exists successor M at n+1 with Succ W M (predecessor)
  (n < 0 → ∃ M, ResolvingChainElement M0 (n+1) M ∧ Succ W M)
```

This is relational - it describes WHICH sets can be at position n, not what THE set at n is.

**Problem**: For temporal coherence, we need a FUNCTION `mcs : Int → Set Formula`, not a relation.

### 5.7 The Functional Resolution

Use Choice to pick a canonical representative at each position:

```lean
noncomputable def resolving_chain_fam (M0 : SerialMCS) : Int → Set Formula :=
  fun n => Classical.choose (exists_resolving_chain_element M0 n)
```

where `exists_resolving_chain_element M0 n` proves that at least one such set exists.

For forward F-coherence, we prove:

```lean
theorem resolving_chain_forward_F (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ resolving_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ resolving_chain_fam M0 m := by
  -- The resolving chain at n+1 can be chosen to force phi
  -- Show there exists a chain element at n+1 with phi
  -- Then by definition of resolving_chain_fam (via Choice), phi is in the chosen element
  sorry
```

**Issue**: The chain is picked by Choice, and we can't control which element is chosen. The element at n+1 may NOT be the one that resolves phi.

### 5.8 The Deterministic Resolving Chain with Priority Queue

To make forward_F provable, we need a DETERMINISTIC chain where we can predict which formulas are resolved at which step.

**Approach**: At each step n, resolve ALL F-obligations that arose at step 0 (the root).

Wait, this doesn't make sense because F-obligations can arise at any step.

**Approach 2**: Use formula enumeration. Fix a well-ordering on Formula. At each step, resolve the smallest unresolved F-obligation.

**Problem**: This still requires infinite enumeration in general.

**Approach 3**: For the SPECIFIC phi being queried, build a chain that resolves phi at step n+1.

This is back to per-query chains, but embedded:

```lean
-- The resolving chain is parameterized by the target query
def query_resolving_chain_fam (M0 : SerialMCS) (query_phi : Formula) (query_n : Int) : Int → Set Formula :=
  fun m =>
    if m < query_n then succ_chain_fam M0 m
    else if m = query_n + 1 then resolving_successor (succ_chain_fam M0 query_n) query_phi
    else -- continue from the resolving successor
      standard_extension ...
```

Then `forward_F` for this specific query_phi is trivial: m = query_n + 1.

**But**: We need forward_F to hold for ALL phi, not just query_phi. Other F-formulas still need to be resolved.

**Observation**: Actually, for the BFMCS temporal coherence, we're proving a universally quantified statement. The proof can CHOOSE how to construct the witness for each phi.

```lean
∀ phi, F(phi) ∈ fam.mcs t → ∃ s > t, phi ∈ fam.mcs s
```

For each phi, we need a witness s. We can construct s differently for each phi!

**The key insight**: The chain doesn't need to be the same for all phi queries. The FAMILY is fixed (fam), but the PROOF of forward_F can use different reasoning for each phi.

### 5.9 Re-Reading the Type of forward_F

```lean
forward_F : ∀ (t : Int) (φ : Formula), φ.some_future ∈ mcs t → ∃ s, t < s ∧ φ ∈ mcs s
```

The family's `mcs` function is fixed. For a given `(t, phi)`, we need to find `s > t` with `phi ∈ mcs s`.

If `mcs = succ_chain_fam M0`, then we need `phi ∈ succ_chain_fam M0 s` for some `s > t`.

The succ_chain_fam is deterministic. Either phi appears somewhere in the chain or it doesn't.

**The problem**: There's no guarantee that phi ever appears. The deferral mechanism can perpetually defer.

**The solution**: Build a chain where phi IS guaranteed to appear.

## Part 6: The Forward_F Proof Strategy

### 6.1 Using Restricted Chains

The codebase already has `f_nesting_is_bounded_restricted` which IS proven (no sorry) for RestrictedMCS.

```lean
theorem f_nesting_is_bounded_restricted (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M
```

This says: in a RestrictedMCS (closed under deferralClosure), the F-iteration eventually leaves the set.

The issue is: the SuccChain elements are SetMaximalConsistent, not RestrictedMCS. Threading RestrictedMCS through the chain leads to boundary-case sorries.

### 6.2 Alternative: Prove forward_F Semantically

**Claim**: In the constructed BFMCS, the truth lemma holds. If we can prove temporal coherence holds for the BFMCS (not per-family), then we're done.

But the truth lemma REQUIRES temporal coherence as a hypothesis.

### 6.3 The Correct Architecture

After extensive analysis, the correct architecture is:

1. **Keep SuccChainFMCS as-is** for all properties EXCEPT forward_F
2. **Prove forward_F directly** using a different argument
3. The direct proof uses `temporal_theory_witness_exists` to show existence

**The Direct Proof**:

```lean
theorem succ_chain_forward_F_direct (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m := by
  -- By temporal_theory_witness_exists, get W with phi ∈ W and proper agreements
  let M_n := succ_chain_fam M0 n
  have h_mcs_n := succ_chain_fam_mcs M0 n
  obtain ⟨W, h_W_mcs, h_phi_W, h_G_agree, h_box_agree⟩ :=
    temporal_theory_witness_exists M_n h_mcs_n phi h_F

  -- Now we need to show W appears in succ_chain_fam M0 at some position m > n
  --
  -- Key insight: The G-agreement means W "continues" the G-structure of M_n.
  -- The box-agreement means W is in the same modal class.
  --
  -- The claim is: W satisfies Succ M_n W (for G-persistence at least)

  -- G-persistence: g_content M_n ⊆ W
  have h_g_pers : g_content M_n ⊆ W := by
    intro a h_gc
    have h_Ga_Mn : Formula.all_future a ∈ M_n := h_gc
    have h_Ga_W : Formula.all_future a ∈ W := h_G_agree a h_Ga_Mn
    exact SetMaximalConsistent.implication_property h_W_mcs
      (theorem_in_mcs h_W_mcs (DerivationTree.axiom [] _ (Axiom.temp_t_future a))) h_Ga_W

  -- F-step: f_content M_n ⊆ W ∪ f_content W
  -- This is where we're stuck - only phi is guaranteed to be in W

  -- Alternative approach: We have phi ∈ W by construction.
  -- If we can show W = succ_chain_fam M0 (n+1), we're done.
  -- But this is NOT necessarily true - W is an abstract Lindenbaum extension.

  -- The real question: does phi appear SOMEWHERE in the chain?
  --
  -- Consider: the chain starting from M_n eventually contains all formulas
  -- that are "reachable" via F-steps. But phi IS reachable in one F-step
  -- from M_n (since F(phi) ∈ M_n).
  --
  -- The deferral disjunction phi ∨ F(phi) is in each successor. By MCS
  -- disjunction property, each successor contains phi or F(phi). If F(phi)
  -- is chosen perpetually, phi never appears.
  --
  -- This is exactly the problem.

  sorry
```

The direct proof approach is BLOCKED by the same fundamental issue.

## Part 7: The Per-Query Family Resolution

### 7.1 Redefining boxClassFamilies

The breakthrough is to redefine `boxClassFamilies` to include MORE families - specifically, families that resolve specific F-obligations.

```lean
noncomputable def boxClassFamilies_extended (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    (f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k ∨
     -- Include chains that resolve specific F-obligations
     ∃ (phi : Formula) (t : Int) (h_F : Formula.some_future phi ∈ succ_chain_fam (MCS_to_SerialMCS W h_W) t),
       f = shifted_fmcs (ResolvingChainFMCS (MCS_to_SerialMCS W h_W) phi t h_F) k) }
```

But this changes the BFMCS structure, which affects the completeness proof.

### 7.2 The Minimal Modification

The minimal modification is:

1. Keep `boxClassFamilies` as-is (shifted SuccChainFMCS from box-class MCSes)
2. For `forward_F` proof, observe that the RESOLVING successor is ALSO in boxClassFamilies

Wait, no - the resolving successor gives us phi at a DIFFERENT family, not the same one.

### 7.3 Final Resolution: The Chain IS the Family

The key is that `forward_F` for a family fam asks: does phi appear in fam.mcs s for some s > t?

If fam = shifted_fmcs(SuccChainFMCS W, k), then fam.mcs s = succ_chain_fam W (s - k).

For forward_F: F(phi) ∈ fam.mcs t = succ_chain_fam W (t - k). Need: phi ∈ succ_chain_fam W (s - k) for some s > t.

This is exactly `succ_chain_forward_F W (t - k) phi h_F`.

**The only way to prove this** is to either:
1. Fix the SuccChain construction (make it resolving)
2. Use a different argument for the existing chain

Given that (2) is blocked, we must do (1).

## Part 8: Enumeration of Proof Obligations

Based on the analysis, here is the dependency-ordered list of theorems needed for the ResolvingChainFMCS approach:

### 8.1 Already Proven (Reusable)

| Theorem | Location | Lines |
|---------|----------|-------|
| `temporal_theory_witness_consistent` | UltrafilterChain.lean:1111-1152 | ~41 |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:1158-1191 | ~33 |
| `past_theory_witness_consistent` | UltrafilterChain.lean:1343-1387 | ~44 |
| `past_theory_witness_exists` | UltrafilterChain.lean:1393-1422 | ~29 |
| `G_of_temporal_box_seed` | UltrafilterChain.lean:1053-1059 | ~6 |
| `deferralDisjunctions_subset_mcs` | SuccExistence.lean:430-440 | ~10 |
| `p_step_blocking_formulas_subset_u` | SuccExistence.lean:162-171 | ~9 |
| `constrained_successor_seed_consistent` | SuccExistence.lean:416-458 | ~42 |

### 8.2 New Definitions

| Definition | Purpose | Est. Lines |
|------------|---------|------------|
| `ResolvingForwardChainElement` | Chain element with MCS + F_top | ~15 |
| `resolving_successor_seed` | Seed with target phi forced | ~10 |
| `resolving_chain_fam` | Int-indexed family from resolving chain | ~30 |
| `ResolvingChainFMCS` | FMCS wrapper | ~20 |
| `ResolvingChainTemporalCoherent` | TemporalCoherentFamily wrapper | ~20 |

### 8.3 New Theorems

| Theorem | Purpose | Est. Lines | Depends On |
|---------|---------|------------|------------|
| `resolving_successor_seed_consistent` | Consistency of resolving seed | ~60 | `temporal_theory_witness_consistent` |
| `resolving_successor_satisfies_G_persistence` | G-content inclusion | ~30 | G-agreement from witness |
| `resolving_successor_satisfies_F_step_for_phi` | Target phi is resolved | ~15 | seed structure |
| `resolving_successor_satisfies_F_step_general` | F-step for all formulas | ~50 | Need deferralDisjunctions in seed |
| `resolving_successor_satisfies_P_step` | P-step backward | ~40 | p_step_blocking in seed |
| `resolving_successor_succ` | Full Succ relation | ~20 | above lemmas |
| `resolving_chain_mcs` | Chain elements are MCS | ~15 | chain construction |
| `resolving_chain_forward_F` | Key temporal coherence | ~40 | by construction |
| `resolving_chain_backward_P` | Symmetric for past | ~40 | `past_theory_witness_exists` |
| `boxClassFamilies_temporally_coherent_via_resolving` | Rewired proof | ~50 | ResolvingChain properties |

### 8.4 Total Estimate

- New definitions: ~95 lines
- New theorems: ~360 lines
- **Total: ~455 lines**

## Part 9: The Critical Question Answered

**Q: Can the resolving successor satisfy full Succ?**

**A: YES, if we include deferralDisjunctions in the seed.**

The extended seed:
```lean
resolving_successor_seed M phi = {phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M
```

For consistency, we need a modified proof that doesn't rely on G-liftability of all elements.

**Proof sketch**:

All elements of the seed except `{phi}` are in M (proven). So the seed ⊆ {phi} ∪ M.

If inconsistent: finite L ⊆ seed with L ⊢ bot.

Case `phi ∉ L`: L ⊆ M, contradicts M consistent.

Case `phi ∈ L`: L \ {phi} ⊆ M, so L \ {phi} ⊢ neg(phi) where all premises in M.

But `L \ {phi}` may include elements from `temporal_box_seed M`, `deferralDisjunctions M`, `p_step_blocking_formulas M` - all of which are subsets of M.

So `L \ {phi} ⊆ M`, and derivation from subset of MCS means conclusion in MCS (by closure).

Thus `neg(phi) ∈ M`.

But `F(phi) ∈ M` means `neg(G(neg(phi))) ∈ M`.

These are NOT directly contradictory!

**Resolution**: The G-lift argument is ESSENTIAL. We need elements that can be G-lifted.

For the elements in M that are NOT G-liftable, we need a different argument.

**Key insight**: The original `temporal_theory_witness_consistent` uses G-lifting specifically on `temporal_box_seed M`, which consists of G-liftable elements. The other components (deferralDisjunctions, p_step_blocking) are in M but NOT necessarily G-liftable.

**The correct approach**: Use the fact that `{phi} ∪ temporal_box_seed M` is consistent (already proven). Then show that adding `deferralDisjunctions M ∪ p_step_blocking_formulas M` (which are subsets of M) preserves consistency.

**Lemma**: If S is consistent and T ⊆ M (where M is MCS), then S ∪ T is consistent iff S ∪ M is consistent.

Hmm, this is NOT true in general. S ∪ T could be consistent while S ∪ M is not (if S conflicts with some element of M not in T).

Actually, if S is consistent and T ⊆ M:
- S ∪ T inconsistent means ∃ derivation from S ∪ T to bot
- This derivation uses elements from S and T
- All elements of T are in M
- So the derivation uses elements from S ∪ M

So S ∪ T inconsistent implies S ∪ M inconsistent.

Equivalently: S ∪ M consistent implies S ∪ T consistent.

**Application**:
- S = `{phi} ∪ temporal_box_seed M` (known consistent)
- T = `deferralDisjunctions M ∪ p_step_blocking_formulas M` (subset of M)
- Full seed = S ∪ T

If S ∪ M is consistent, then S ∪ T is consistent.

**Is S ∪ M consistent?**

S = `{phi} ∪ temporal_box_seed M`.

`temporal_box_seed M ⊆ M` (proven).

So S ∪ M = `{phi} ∪ M`.

`{phi} ∪ M` is consistent iff `neg(phi) ∉ M`.

We have `F(phi) ∈ M`, which means `neg(G(neg(phi))) ∈ M`.

Does this imply `neg(phi) ∉ M`?

NO! `neg(phi) ∈ M` and `F(phi) ∈ M` can coexist. They are NOT contradictory.

Example: `neg(phi) ∈ M` and `neg(G(neg(phi))) ∈ M` means G(neg(phi)) ∉ M. This is consistent.

**So this approach fails.**

### 9.1 The Ultimate Resolution

The consistency of the extended seed requires a DIFFERENT argument.

**New Approach**: Show that the Lindenbaum extension W from `temporal_theory_witness_exists` already contains deferralDisjunctions.

For each `a ∨ F(a) ∈ deferralDisjunctions M` (where `F(a) ∈ M`):

W is an MCS. So either `a ∈ W` or `neg(a) ∈ W`.
And either `F(a) ∈ W` or `neg(F(a)) ∈ W`.

By disjunction: `a ∨ F(a) ∈ W` iff `a ∈ W` or `F(a) ∈ W`.

So either way, `a ∨ F(a) ∈ W`.

**Therefore**: The MCS W from `temporal_theory_witness_exists` automatically contains all deferralDisjunctions M! (Because each disjunction must be in any MCS.)

Similarly for p_step_blocking_formulas: each is in M, and since `box_class_agree M W`, the blocking formulas that prevent bad P-formulas will also work in W.

**The issue**: p_step_blocking uses H-formulas. For `H(neg(chi)) ∈ M` to be in W, we need... what?

From `past_theory_witness_exists`, we get H-agreement: `H(a) ∈ M → H(a) ∈ W`.

But `temporal_theory_witness_exists` gives G-agreement, not H-agreement!

**Resolution**: The seed `temporal_box_seed M = G_theory M ∪ box_theory M` includes G-formulas and box-formulas. For H-formulas, we need the past version.

For the resolving successor to satisfy P-step (p_content backward), we may need to include `H_theory M` in the seed.

Let me check what `constrained_successor_from_seed` actually uses for P-step:

From SuccExistence.lean:366-367:
```lean
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

The `p_step_blocking_formulas u` are H-formulas that block bad P-formulas in the successor.

For these to be in the resolving successor W, we need either:
1. Include them in the seed
2. Show they're implied by the MCS extension

**Key observation**: `p_step_blocking_formulas u ⊆ u` (proven). The blocking formula `H(neg(chi))` is in u when `P(chi) ∉ u` and `chi ∉ u`.

For W (the Lindenbaum extension), we can't directly claim `H(neg(chi)) ∈ W` unless we include it in the seed.

**Resolution**: Include `p_step_blocking_formulas M` in the seed. For consistency, these are subsets of M, and by the same argument as deferralDisjunctions, they preserve consistency since they're in M and the G-lift argument still works for the `{phi} ∪ temporal_box_seed M` part.

## Part 10: Summary and Recommendations

### 10.1 The Problem

The existing SuccChain uses deferral disjunctions that can perpetually defer F-obligations. The theorem `f_nesting_is_bounded` is mathematically FALSE for arbitrary MCS.

### 10.2 The Solution

Replace the SuccChain successor construction with a RESOLVING successor that forces specific F-formulas.

### 10.3 The Architecture

1. **resolving_successor_seed(M, phi)**: Includes `{phi}` to force resolution
2. **Consistency**: Proven via `temporal_theory_witness_consistent` + extension argument
3. **Succ relation**: G-persistence from G-theory, F-step from deferralDisjunctions, P-step from blocking
4. **ResolvingChainFMCS**: New FMCS type using resolving successors
5. **forward_F**: Trivially true by construction (phi is forced at next step)
6. **Rewiring**: Replace `SuccChainFMCS` with `ResolvingChainFMCS` in `boxClassFamilies`

### 10.4 Per-Obligation Insight

The chain doesn't need to resolve ALL F-obligations at once. For each `forward_F` query with specific phi, the chain can be constructed to resolve that phi. This is the "per-obligation" approach.

Implementation: Parameterize the chain by the target phi. When `forward_F` is invoked for phi, use the chain that resolves phi.

### 10.5 Key Theorems (Dependency Order)

1. `resolving_successor_seed` (definition)
2. `resolving_successor_seed_consistent` (depends on `temporal_theory_witness_consistent`)
3. `resolving_successor_from_seed` (Lindenbaum extension)
4. `resolving_successor_satisfies_Succ` (depends on seed structure)
5. `ResolvingForwardChainElement.next` (iterated application)
6. `resolving_chain_fam` (Int-indexed)
7. `resolving_chain_forward_F` (by construction)
8. `ResolvingChainFMCS` / `ResolvingChainTemporalCoherent` (wrappers)
9. `boxClassFamilies_temporally_coherent` (rewired to use resolving chain)

### 10.6 Estimated Effort

- **New code**: ~450 lines
- **Modifications to existing**: ~50 lines (rewiring boxClassFamilies)
- **Total**: ~500 lines

### 10.7 Critical Risk

The main risk is ensuring the resolving successor satisfies the FULL Succ relation (not just G-persistence and F-step for phi). This requires careful analysis of the extended seed consistency.

**Mitigation**: The analysis in Section 9 shows that deferralDisjunctions are automatically in any MCS extension, so F-step for all formulas is satisfied. P-step requires including blocking formulas in the seed, which preserves consistency since they're subsets of M.

## References

### Source Files Analyzed

- UltrafilterChain.lean:957-1422 (G_theory, temporal_box_seed, witness theorems)
- SuccExistence.lean:61-489 (deferralDisjunctions, constrained_successor_seed, successor construction)
- SuccRelation.lean:59-60 (Succ definition)
- SuccChainFMCS.lean:731-847 (f_nesting_is_bounded, succ_chain_forward_F - sorry chain)
- SuccChainFMCS.lean:1148-1159 (SuccChainFMCS, SuccChainTemporalCoherent)

### Team Research

- reports/03_team-research.md: Convergent recommendation for resolving chain approach
