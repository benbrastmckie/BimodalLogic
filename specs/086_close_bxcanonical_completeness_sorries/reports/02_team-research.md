# Research Report: Task #86 Round 2 — Fragment Completeness Details

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-08
**Mode**: Team Research (3 teammates, Opus model)
**Session**: sess_1775687783_57f767
**Focus**: Fragment completeness for {⊥, →, □, G, H}, decidability audit, model embedding

## Executive Summary

Three teammates worked through the details of fragment completeness. **The truth lemma for {⊥, →, □, G, H} is COMPLETELY proved with zero Until/Since dependencies.** The decidability path (soundness + decidability = completeness) does NOT work because FMP provides MCS-completeness, not semantic completeness. The sole remaining obstacle is the **canonical model embedding** (sorry #5): constructing a TaskModel from BXPoints so that MCS-level truth lifts to semantic truth_at.

The embedding has a concrete obstacle: **G/H truth requires WorldHistory functions that surject onto all bx_le-successors**, but D = Int only provides countably many time points while bx_le-successors may be uncountable. A permissive task_rel (`d ≠ 0 ∨ w = u`) resolves the nullity_identity constraint, and an inductive/tailored construction may dodge the surjectivity problem. Estimated effort: 150-300 lines.

## Key Findings

### 1. Fragment Truth Lemma Is COMPLETELY Proved (Teammate A, HIGH confidence)

All six MCS-level truth lemma cases in TruthLemma.lean are sorry-free:
- `atom_iff_mcs` — proved
- `bot_iff_mcs` — proved
- `imp_iff_mcs` — proved
- `box_iff_mcs` — proved (uses `bx_modal_witness`, sorry-free)
- `G_iff_mcs` — proved (uses `bx_G_forward`, `bx_G_backward`, both sorry-free)
- `H_iff_mcs` — proved (uses `bx_H_forward`, `bx_H_backward`, both sorry-free)

The dependency graph is completely clean: NO hidden dependencies on the 4 Until/Since sorry sites in Frame.lean. The Until/Since sorry sites are exclusively called by `until_iff_mcs` and `since_iff_mcs`.

### 2. Decidability Route Does NOT Work (Teammate B, HIGH confidence)

The entire Decidability tree (16 files) is **sorry-free**. Soundness is also sorry-free. However:

- FMP provides `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)` — this is MCS-completeness, NOT semantic completeness
- The bridge `valid φ → φ ∈ every MCS` IS the truth lemma / completeness proof itself
- No Post-completeness (∀ φ, ⊢ φ ∨ ⊢ ¬φ) exists in the codebase
- The composition `soundness + decidability = completeness` requires semantic decidability, not just proof-theoretic decidability

**Verdict**: Decidability route is definitively ruled out.

### 3. Model Embedding Is the Sole Remaining Obstacle (Teammate C, HIGH confidence)

The sorry at Completeness.lean:144 has goal `False`, given `h_valid : valid φ` and `φ ∉ M` for some MCS M. To derive the contradiction, we must construct a concrete TaskModel where φ evaluates to false, contradicting validity.

**Required components**:
- `D` = Int (or other ordered abelian group)
- `TaskFrame D` with `WorldState = BXPoint`
- `TaskModel F` with `valuation w p := atom p ∈ w.formulas`
- `WorldHistory F` — monotone functions D → BXPoint
- `Omega` — shift-closed set of histories in the same modal class
- Truth lemma bridge: `truth_at M Omega τ t φ ↔ φ ∈ τ(t).formulas`

### 4. The Nullity Identity Obstacle Is Solved (Teammate C)

TaskFrame requires `task_rel w 0 u ↔ w = u`, but bx_le is a preorder (not antisymmetric). **Solution**: use permissive task_rel `task_rel w d u := d ≠ 0 ∨ w = u` (mirrors existing `nat_frame` design). All TaskFrame axioms are trivially satisfied; canonical structure lives entirely in WorldHistory/Omega.

### 5. The G/H Surjectivity Problem (Teammate C, CRITICAL)

The truth lemma bridge for G requires:
```
truth_at M Omega τ t (G φ) = ∀ s ≥ t, truth_at M Omega τ s φ
                            ↔ ∀ s ≥ t, φ ∈ τ(s).formulas    (by IH)
```
But G_iff_mcs says: `G(φ) ∈ w ↔ ∀ v with bx_le w v, φ ∈ v.formulas`

These match only if `{τ(s) | s ≥ t} = {v | bx_le (τ t) v}` — i.e., the history surjects onto all bx_le-successors. With D = Int (countable), this may fail if bx_le-successors are uncountable.

**Possible resolutions**:
1. **Inductive/tailored construction**: Build histories tailored to specific subformulas rather than needing universal surjectivity. For proving `¬truth_at ... φ`, we only need the truth lemma for subformulas of φ, which is finite.
2. **Use D = large ordered group**: Pick D with enough cardinality.
3. **Lowenheim-Skolem**: The logic has countable language, so the canonical model has a countable elementary submodel.

### 6. `valid` Definition (Teammate A/C)

```lean
def valid (phi : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau ∈ Omega) (t : D),
    truth_at M Omega tau t phi
```

To contradict `h_valid`, we choose specific D, F, M, Omega, tau, t and show `¬truth_at M Omega tau t φ`.

## Synthesis

### Conflicts Resolved

All three teammates agree on the core picture: truth lemma is complete, decidability doesn't help, model embedding is the bottleneck. No conflicts between findings.

### The Single Remaining Problem

The entire task reduces to ONE construction problem: build a TaskModel from BXPoints such that the MCS-level truth lemma lifts to truth_at. The fragment-specific version (no Until/Since) is easier because:
1. The MCS-level truth lemma cases for {⊥, →, □, G, H} are sorry-free
2. The Until/Since cases of truth_at don't need to be bridged
3. Fragment completeness can be stated by restricting to formulas without Until/Since constructors

### Estimated Effort by Approach

| Approach | Effort | Confidence | Gives |
|----------|--------|------------|-------|
| Inductive/tailored embedding (fragment) | 100-200 LOC | 60% | Fragment completeness |
| Full canonical model embedding (fragment) | 150-300 LOC | 50% | Fragment completeness |
| Full canonical model embedding (all) | 250-400 LOC | 30% | Full completeness (needs Until/Since too) |

## Recommendations

### 1. PRIMARY: Fragment Completeness via Tailored Embedding (100-200 LOC)

Build the countermodel by induction on φ, tailoring the WorldHistory construction to the specific formula. For G(ψ): if G(ψ) ∉ M, by G_iff_mcs backward, there exists v with bx_le M v and ψ ∉ v. Build a 2-point history {M, v} at times {0, 1}. For H(ψ): symmetric with times {-1, 0}. For □(ψ): use a 1-point history through a modally inequivalent MCS.

This avoids the surjectivity problem entirely by building tiny targeted countermodels rather than one universal canonical model.

### 2. SECONDARY: Define `UntilSinceFree` predicate

Add a predicate `Formula.untilSinceFree : Formula → Prop` that is true for formulas built from {⊥, →, □, G, H, atoms}. State fragment completeness as:
```lean
theorem fragment_completeness (φ : Formula) (h_frag : φ.untilSinceFree) :
    valid φ → Nonempty (DerivationTree [] φ)
```

### 3. DO NOT PURSUE

- **Decidability route**: FMP gives MCS-completeness not semantic completeness
- **Universal canonical model for Int**: Surjectivity problem makes this harder than needed
- **bx_le redefinition**: Ruled out in Round 1

## Teammate Contributions

| Teammate | Angle | Key Contribution |
|----------|-------|-----------------|
| A | Truth lemma audit | Confirmed all 6 fragment cases are sorry-free with zero Until/Since dependencies |
| B | Decidability audit | Confirmed 16 files sorry-free; proved decidability route does NOT compose to semantic completeness |
| C | Model embedding | Identified nullity_identity obstacle + resolution; surjectivity problem; tailored embedding as most practical approach |
