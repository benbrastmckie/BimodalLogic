# Teammate A: Survey of `until` Branch -- Reflexive Completeness Status

## Executive Summary

The `until` branch has **5 executable sorry sites**, all in `RootScopedChain.lean` (lines 1111, 1138, 1145, 1153, 1160). These are the ONLY blocking obstacles to sorry-free completeness. The entire rest of the critical path -- OrderedSeedConsistency, Frame, TruthLemma, Completeness, ParametricRepresentation, RestrictedParametricTruthLemma, CanonicalModel, Axioms, Soundness -- is sorry-free.

## Architecture of the Completeness Proof

The completeness path on `until` is:

```
bx_completeness (Completeness.lean)
  -> dd_countermodel (RootScopedChain.lean)
    -> dd_bfmcs (BFMCS construction)
      -> dd_bfmcs_restricted_tc   [3 sorries: lines 1111, 1138, 1145]
      -> dd_bfmcs_restricted_buc  [1 sorry: line 1153]
      -> dd_bfmcs_restricted_fuc  [1 sorry: line 1160]
    -> fully_restricted_parametric_representation_from_neg_membership
      (sorry-free, in RestrictedParametricTruthLemma.lean)
```

## The 5 Sorry Sites in Detail

### Sorry 1: `fwd_chain_forward_F` (line 1111)

**Statement**: If `F(phi) in chain(n)` with `phi in sigma_list`, then `exists m > n, phi in chain(m)`.

**What it needs**: A termination/convergence argument showing that eventually the preserving forward step resolves phi directly. The chain uses `preserving_fwd_step` which resolves at least one defect at each step while preserving all F-obligations. The argument is: (a) F(phi) persists forever (by `fwd_chain_F_persistent`), (b) each step resolves some defect w directly (by `resolving_enriched_fwd_exists`), (c) the set of active defects is finite (bounded by `sigma_list.length`), (d) by pigeonhole, phi must eventually be the one resolved.

**Obstacle**: The proof needs well-founded induction on defect count (or a pigeonhole argument over the finite sigma_list). The infrastructure is all there (`defect_step_from_earliest`, `preserving_fwd_step_F_preserved`, `fwd_chain_F_persistent`). The gap is formulating and proving the termination argument.

**Difficulty estimate**: MEDIUM. The mathematical argument is clear (finite defects + at least one resolved per step = eventual resolution of any given defect). The challenge is expressing this in Lean using well-founded induction or Finset/List cardinality arguments.

### Sorry 2: `dd_bfmcs_restricted_tc` forward, backward chain case (line 1138)

**Statement**: When `t - s < 0` (we're in the backward chain portion), `F(phi) in fam.mcs(t)` implies `exists u > t, phi in fam.mcs(u)`.

**What it needs**: Forward temporal resolution from a point in the backward chain. Since t - s < 0 but we need a future witness u > t, the witness could be either (a) still in the backward chain (if u - s < 0), (b) at the origin (if u = s), or (c) in the forward chain (if u - s >= 0).

**Obstacle**: The backward chain (`bwd_chain_of_sigma`) uses round-robin `bwd_pred` targeting P-formulas, not F-formulas. So F-formulas are not systematically preserved in the backward direction. However, the key insight is that under reflexive semantics, `F(phi) in M` with `phi in M` means the witness is the current point itself (u = t works because of BX1: G(neg phi) -> neg phi, so F(phi) -> phi... wait, that's not right. F(phi) = neg G(neg phi), not phi).

Actually, a simpler approach: if F(phi) in chain(t) and t < s, we can propagate F(phi) forward through g_content to chain(s) = M0, then use `fwd_chain_forward_F` to get a witness m > 0 with phi in chain(s + m), giving u = s + m > s > t.

**Difficulty estimate**: LOW-MEDIUM, once Sorry 1 is resolved. The key step is showing F(phi) propagates from chain(t) to chain(s) via h_content/g_content relationships. The infrastructure for g_content/h_content propagation across the Int chain is already proved (`dd_chain_g_content`).

### Sorry 3: `dd_bfmcs_restricted_tc` backward direction (line 1145)

**Statement**: `P(phi) in fam.mcs(t)` implies `exists u < t, phi in fam.mcs(u)`.

**What it needs**: The exact dual of the forward direction. When t - s >= 0 (in forward chain), P(phi) needs a past witness. When t - s < 0 (in backward chain), P(phi) needs resolution in the backward chain.

**Obstacle**: Same structure as the forward case but for P-formulas in the backward chain. The backward chain uses round-robin `bwd_pred` which resolves P(target) when scheduled. Needs a `bwd_chain_backward_P` analog of `fwd_chain_forward_F`.

**Difficulty estimate**: MEDIUM. Requires building the backward analog of `preserving_fwd_step` (a `preserving_bwd_step` that preserves all P-obligations for sigma_list formulas). The forward infrastructure exists as a template.

### Sorry 4: `dd_bfmcs_restricted_buc` (line 1153)

**Statement**: Backward Until/Since coherence -- if `phi U psi in fam.mcs(t)`, the full Until witness structure (guard interval + witness point) exists in the chain.

**What it needs**: For `phi U psi in M` (under reflexive Until with BX8), the witness is s >= t with psi(s) and phi holds on [t, s). Under reflexive semantics, BX8 gives `psi -> phi U psi`, so the trivial witness s = t always works. But the coherence property requires the CHAIN to reflect this, meaning either:
  - (a) psi in M (trivial witness, s = t), or
  - (b) phi in M and (phi U psi) propagates forward via BX5/BX6 until psi is reached.

**Obstacle**: The comment says "requires the step transfer property which is blocked for Lindenbaum-based chains." This means the non-deterministic Lindenbaum extension doesn't guarantee that Until formulas propagate correctly between chain steps. Under reflexive semantics, BX9 gives `(phi U psi) -> phi v psi`, and BX5 gives self-accumulation. The chain step needs to ensure that if `phi U psi in chain(n)` and `psi not in chain(n)`, then `phi in chain(n)` and `phi U psi in chain(n+1)` (or psi eventually appears).

**Difficulty estimate**: HARD. This is the hardest sorry. The Until/Since coherence problem is where reflexive semantics actually helps compared to irreflexive: BX8 (`psi -> phi U psi`) provides a way to trivially satisfy Until when psi holds at the current time. But ensuring the full interval guard structure across chain steps requires more careful chain construction -- potentially replacing the current `preserving_fwd_step` with one that also tracks and resolves Until/Since defects.

### Sorry 5: `dd_bfmcs_restricted_fuc` (line 1160)

**Statement**: Forward Until/Since coherence -- the forward direction analog of Sorry 4.

**What it needs**: Same structure as Sorry 4 but for the forward direction.

**Obstacle**: The comment says it "depends on restricted_tc and Until propagation. Requires proving that Until defects eventually resolve using BX10 + BX12." BX10 gives `(phi U psi) -> F(psi)` and BX12 gives `F(phi) -> (top U phi)`. So Until defects reduce to F-defects (which the chain already resolves), and F-defects can be lifted to Until form.

**Difficulty estimate**: MEDIUM-HARD. If Sorry 1 is resolved (forward_F), then BX10 + BX12 give a path: `phi U psi in M` => `F(psi) in M` (BX10) => `psi in chain(m)` for some m > n (forward_F) => the Until is satisfied with witness at m. The guard interval [n, m) needs phi to hold, which follows from BX5 (self-accumulation) ensuring phi persists until psi appears.

## Sorry-Free Infrastructure on `until`

### OrderedSeedConsistency.lean (255 lines, 0 sorries)

Fully proved. Contains:
- `enriched_resolving_seed_consistent`: If F(psi ^ alpha) in M, then {psi, alpha} union g_content(M) is consistent
- `ordered_two_defect_seed_consistent`: The ordered seed consistency theorem for two defects
- `temp_linearity_mcs`: BX11 at MCS level (three-way case split on future witnesses)
- `two_defect_consistent_seed`: Two-defect seed consistency with linear ordering
- `no_new_f_defects`: F-defect monotonicity

### Frame.lean (673 lines, 0 executable sorries)

Fully proved. Contains:
- `bx_le_refl`: Reflexivity of canonical temporal ordering (from BX1: G(phi) -> phi)
- `bx_le_trans`: Transitivity (from temp_4: G(phi) -> G(G(phi)))
- `bx_modal_witness`: Modal witness construction for S5
- `bx_modal_equiv`: Full modal equivalence (including the reverse direction via S5 negative introspection -- the "sorry" mention on line 440 is in a COMMENT, the actual code below it is fully proved)

### CanonicalModel.lean (498 lines, 0 executable sorries)

Fully proved. Contains:
- Forward/backward chain infrastructure (fwd_succ, bwd_pred, f_carry, p_carry)
- Int-indexed chain assembly with g_content/h_content propagation
- Box stability across the chain
- FMCS and shifted FMCS construction
- Removed dead code (former sorry sites moved to Boneyard)

### TruthLemma.lean (320 lines, 0 executable sorries)

Fully proved for atom, bot, imp, box, G, H cases. The Until/Since truth lemma cases are handled via the restricted parametric representation theorem.

### Completeness.lean (152 lines, 0 executable sorries)

Fully proved. Contains:
- `neg_consistent_of_not_derivable`: If phi is not derivable, {neg phi} is consistent
- `bx_completeness`: The main completeness theorem, wired through `dd_countermodel`

### Axioms.lean (325 lines, 0 sorries)

37 axiom constructors organized in 4 layers. Key additions over irreflexive branch:
- BX1/BX1': Temporal reflexivity (G(phi) -> phi, H(phi) -> phi)
- BX8/BX8': Reflexive Until/Since introduction (psi -> phi U psi)
- BX9-BX12: Until elimination, eventuality extraction, linearity, F-Until bridge

### TemporalDerived.lean (526 lines, 0 executable sorries)

All "sorry" mentions are in section header comments only. Fully proved. Contains:
- `psi_imp_until`: psi -> phi U psi (derived from BX8)
- `until_unfold_thm`: (phi U psi) -> psi v (phi ^ (phi U psi))
- `since_unfold_thm`: (phi S psi) -> psi v (phi ^ (phi S psi))
- `refl_F`, `refl_P`: phi -> F(phi), phi -> P(phi) (from BX1/BX1')
- `until_F_expansion`, `since_P_expansion`: (phi U psi) -> psi v (phi ^ F(phi U psi))

### Soundness.lean (0 executable sorries)

All "sorry" mentions are in comments only. Fully proved.

### ParametricRepresentation.lean, RestrictedParametricTruthLemma.lean (0 sorries each)

The algebraic representation theorem and restricted truth lemma are both fully proved.

## Dependency Structure of Sorries

```
Sorry 1 (fwd_chain_forward_F)
  |
  v
Sorry 2 (restricted_tc forward, backward-chain case)  <-- depends on Sorry 1
  |
Sorry 3 (restricted_tc backward direction)  <-- independent, needs backward analog
  |
  v
Sorry 5 (restricted_fuc)  <-- depends on Sorry 1 (via BX10 reduction)
  |
Sorry 4 (restricted_buc)  <-- independent, hardest
```

## Gap Assessment

**Total effort to sorry-free completeness**: The gap is small in mathematical terms but requires careful Lean formalization work.

1. **Sorry 1** (fwd_chain_forward_F): The mathematical argument is a simple pigeonhole/finite-defect-count argument. Infrastructure exists. Estimate: 1-2 days of focused Lean work.

2. **Sorry 2** (tc forward, bwd case): Once Sorry 1 is done, this follows by propagating F(phi) from the backward chain to the origin and then using fwd_chain_forward_F. Estimate: 0.5-1 day.

3. **Sorry 3** (tc backward): Requires building a preserving backward step that tracks P-obligations, mirroring the forward infrastructure. Estimate: 1-2 days (mostly mechanical duplication of forward code).

4. **Sorry 4** (restricted_buc): Hardest. Requires Until/Since coherence in the chain. Under reflexive semantics, BX8 provides `psi -> phi U psi`, so the trivial witness s = t always exists when psi holds. The non-trivial case is when phi U psi holds but psi does not hold at t -- then the chain must provide a future witness. This may require augmenting the chain construction to track Until defects alongside F-defects. Estimate: 2-4 days.

5. **Sorry 5** (restricted_fuc): Once Sorry 1 is solved, the BX10+BX12 reduction path should make this tractable. Until defects reduce to F-defects, and forward_F handles those. Estimate: 1-2 days after Sorry 1.

**Total estimate: 5-11 days of focused Lean work for sorry-free reflexive completeness.**

## Key Observations

1. **The `until` branch is much closer to complete than the `irr_until` branch.** Only 5 executable sorries remain, all in one file, all with clear mathematical arguments.

2. **The BX11 fold infrastructure is impressive and sorry-free.** The enriched forward step existence theorem (`resolving_enriched_fwd_exists`) is fully proved and handles the multi-defect case correctly.

3. **OrderedSeedConsistency.lean is the mathematical breakthrough.** It's sorry-free and provides the key lemma that BX11 linearity enables ordered defect discharge.

4. **Frame.lean is fully proved**, including the hard S5 modal equivalence (using negative introspection: neg Box phi -> Box(neg Box phi), derived from modal_5_collapse).

5. **The reflexive axioms (BX1, BX8) provide crucial advantages** not available on the irreflexive branch: phi -> F(phi) and psi -> phi U psi are trivially derivable, simplifying many chain arguments.

6. **Sorry 4 (backward Until/Since coherence) is the genuine hard problem.** It may require a more sophisticated chain construction. However, under reflexive semantics, the "trivial witness" via BX8 may provide a simpler path than appears at first glance.
