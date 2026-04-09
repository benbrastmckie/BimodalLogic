# Research Report: Task #86 — Close BXCanonical Completeness Sorry

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Mode**: Team Research (3 teammates)
**Session**: sess_1775710453_d45c96

## Summary

The remaining sorry in `usf_completeness` (CanonicalEmbedding.lean:409, imp Case B) is closeable but requires restructuring the proof architecture. All three teammates converge on the same diagnosis: the current proof-theoretic reduction approach (peel off outermost operator) is fundamentally incompatible with the implication case when sub-formulas contain temporal operators G/H. The standard textbook approach — build canonical model with non-constant histories, prove bidirectional truth lemma, use contrapositive — handles imp trivially and is the recommended path.

## The Exact Problem

### Goal State at the Sorry

```lean
case neg
psi chi : Formula
ih_psi : untilSinceFree psi → valid psi → Nonempty (DerivationTree [] psi)
ih_chi : untilSinceFree chi → valid chi → Nonempty (DerivationTree [] chi)
h_usf : untilSinceFree (psi.imp chi)
h_valid : valid (psi.imp chi)
h_psi_valid : ¬(valid psi)
h_not_deriv : ¬(Nonempty (DerivationTree [] (psi.imp chi)))
w : BXPoint  -- MCS with psi ∈ w, chi ∉ w, (psi → chi) ∉ w
⊢ False
```

### Why It's Stuck

To derive `False`, we must contradict `h_valid` by constructing a model where `truth_at ... psi` holds but `truth_at ... chi` does not. This requires:

- **(A) Forward bridge**: `psi ∈ w → truth_at ... psi` — needs to work even when psi contains G/H
- **(B) Backward bridge**: `chi ∉ w → ¬(truth_at ... chi)` — equivalently, `truth_at ... chi → chi ∈ w`

On **constant histories** (current approach), both bridges work for temporal-free formulas. But for G/H:
- Forward works: `G(α) ∈ w → α ∈ w` (by BX1) → `truth_at α` at w → `truth_at G(α)` (since all times map to w)
- Backward FAILS: `truth_at G(α)` on constant history through w gives `truth_at α` at w, which gives `α ∈ w` (by backward IH), but NOT `G(α) ∈ w`. Getting `G(α) ∈ w` requires `α ∈ v` for ALL `bx_le`-successors v, not just w itself.

### The Three-Way Tension (Teammate A)

There is a fundamental conflict between:
1. **Forward G/H truth**: requires histories visiting bx_le-ordered chains
2. **Backward G/H truth**: requires histories visiting specific witness BXPoints
3. **Box truth + ShiftClosed**: requires Omega to contain histories through modally-equivalent points; shift-closure forces shifted histories into Omega, polluting box semantics

### Root Cause

The current proof architecture uses **validity reduction** (valid G(φ) → valid φ → derivable φ → derivable G(φ)) which works at the outermost level but cannot handle temporal operators NESTED inside implications. This is structurally mislocated — the imp case needs a semantic argument, not proof-theoretic reduction.

## Key Findings

### Finding 1: The Theorem Is Mathematically True (All teammates, 95% confidence)

Burgess (1984) and Xu (1988) prove completeness for S5 + tense logic. The USF fragment is a sub-fragment. Soundness is sorry-free. The issue is purely the proof strategy, not the mathematical claim.

### Finding 2: Standard Textbook Approach Handles Imp Trivially (Teammates B, C)

In Burgess/Goldblatt/BRV, completeness is proved by:
1. Build canonical model (MCS as worlds, non-trivial temporal ordering)
2. Prove truth lemma: `φ ∈ w ↔ truth_at ... φ` for all φ, w
3. Contrapositive: not derivable → MCS w with φ ∉ w → φ false in model → not valid

The imp case of the truth lemma is the SIMPLEST case:
```
(ψ → χ) ∈ w  ↔  (ψ ∈ w → χ ∈ w)     [imp_iff_mcs, already proved]
              ↔  (truth_at ψ → truth_at χ)  [by IH on ψ and χ]
              ↔  truth_at (ψ → χ)           [by definition of truth_at]
```

No validity reduction, no case split on `valid psi` — just direct MCS properties.

### Finding 3: Chain History Construction Works for Box-Free Fragment (Teammate A, 90% confidence)

For formulas without box (fragment {atom, bot, imp, G, H}), build chain histories:
- Recursively place BXPoint witnesses along the integer timeline based on formula structure
- Non-decreasing in future (bx_le chain), non-increasing in past
- Omega = {time_shift(σ, Δ) | Δ ∈ ℤ} (automatically shift-closed)
- Forward truth lemma via bx_G_forward + chain monotonicity
- Backward countermodel by witness placement construction
- No box truth lemma needed (vacuous)

### Finding 4: Box Interaction Creates Additional Complexity (Teammate A, medium confidence)

With box in the formula, shift-closed Omega = shifts-of-chain means:
- truth_at(□δ) at (time_shift(σ,Δ), 0) = ∀Δ', truth_at δ at σ(Δ')
- Forward: `□δ ∈ w → G(δ) ∈ w` (via modal_future + modal_t) → `δ ∈ σ(Δ)` for Δ ≥ 0 (bx_G_forward). Past direction uses `□δ ∈ w → δ ∈ w` + chain stays at w for t < 0
- Backward: truth_at(□δ) gives δ at all chain points, but □δ requires δ at all modal-equivalents, which may not all be chain points

However, for the **specific sorry** (imp Case B), we only need the FORWARD bridge for ψ and BACKWARD for χ. If box only appears in ψ, the forward box bridge is sufficient.

### Finding 5: IH Is Unusable in Case B (Teammate C)

Neither `ih_psi` nor `ih_chi` can fire in Case B:
- `ih_psi` needs `valid psi` but we have `¬(valid psi)`
- `ih_chi` needs `valid chi` but we cannot derive it (splitting on `valid chi` doesn't help — Teammate B verified the same gap arises)

The proof MUST build a countermodel, not use the IH.

### Finding 6: Flatten-Then-Lift Fails (Teammates A, B)

Define flatten(G(φ)) = flatten(φ). Then `φ ⊢ flatten(φ)` holds (via BX1: G(α) → α). But `flatten(φ) ⊢ φ` fails because `α ⊢ G(α)` is not derivable. The imp case of the lift needs the reverse direction for sub-formulas in antecedent position. Dead end.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Teammate A proposes box-free fragment first; B proposes full canonical model | **Full restructure preferred.** Box-free is a stepping stone but doesn't close the sorry. The restructured proof handles all cases uniformly. |
| Approaches ranked differently by A and B | **Standard contrapositive (B's Rank 1/4) is the clearest path.** A's chain construction provides the needed history construction within the standard framework. |

### Gaps Identified

1. **Two-point histories were planned but never built** — the plan's Phase 2 specified `bxpoint_two_history` but only constant histories were implemented
2. **Per-formula countermodel not explored for imp** — the plan's core strategy was abandoned in favor of proof-theoretic reduction
3. **The backward truth lemma's surjectivity problem** — a single chain cannot visit ALL bx_le-successors, so a full bidirectional iff for G/H on chain histories needs careful formulation (forward direction works, backward only for the specific formula being refuted)

### What Does NOT Need to Be Solved

The sorry does NOT require the backward iff `truth_at G(α) → G(α) ∈ w` in full generality. It only needs:
- **Forward**: `φ ∈ w → truth_at ... φ` for the subformula ψ (to make ψ true)
- **Backward countermodel**: `φ ∉ w → ¬truth_at ... φ` for the subformula χ (to make χ false)

These are ONE-DIRECTIONAL requirements on the specific formulas ψ and χ. This is weaker than a full bidirectional truth lemma.

## Recommended Strategy

### Architecture: Restructured Contrapositive Completeness

Replace the current `usf_completeness` proof with the standard contrapositive approach:

```
usf_completeness (φ : Formula) (h_usf : φ.untilSinceFree) (h_valid : valid φ) :
    Nonempty (DerivationTree [] φ) := by
  by_contra h_not_deriv
  -- Step 1: Get MCS w with φ ∉ w
  obtain ⟨w, hw_mcs, h_not_in⟩ := neg_consistent_of_not_derivable ... h_not_deriv
  -- Step 2: Build canonical model with chain histories
  let model := canonical_chain_model w φ   -- tailored to φ's witnesses
  -- Step 3: Forward truth lemma (by induction on φ)
  have h_truth : truth_at model.M model.Omega model.tau model.t φ :=
    h_valid model.D model.F model.M ⟨model.Omega, model.shift_closed⟩ ⟨model.tau, model.tau_mem⟩ model.t
  -- Step 4: Backward truth bridge gives φ ∈ w, contradiction
  have h_mem := backward_truth_bridge model φ h_truth
  exact absurd h_mem h_not_in
```

The imp case of the truth bridge is immediate from `imp_iff_mcs` (already proved). The G/H cases use chain history witness placement. The box case uses modal_omega construction.

### Concrete Steps

**Step 1**: Define chain history builder — given MCS w and formula φ with φ ∉ w, recursively build a chain of BXPoints witnessing the falsity of φ:
- `atom p ∉ w`: chain = {0 ↦ w} (base case)
- `⊥ ∉ w`: impossible (bot never in MCS)
- `(ψ → χ) ∉ w`: ψ ∈ w, χ ∉ w. Recursively build chain for χ ∉ w at w.
- `□ψ ∉ w`: by bx_modal_witness, get v ~ w with ψ ∉ v. Use modal_omega approach at v.
- `G(ψ) ∉ w`: by bx_G_backward, get v ≥ w with ψ ∉ v. Place v at time 1, recursively build chain for ψ ∉ v starting at v.
- `H(ψ) ∉ w`: by bx_H_backward, get v ≤ w with ψ ∉ v. Place v at time -1, recursively build chain for ψ ∉ v starting at v.

**Step 2**: Prove forward truth direction: for all ψ ∈ w (where w is the base MCS at time 0), `truth_at ... ψ` on this chain history:
- Atom: by valuation definition
- Bot: vacuous
- Imp: by imp_iff_mcs + IH on sub-formulas
- Box: by modal_omega construction (all histories through modal-equivalents of w)
- G: `G(ψ) ∈ w → ψ ∈ v` for all v on the forward chain (since chain is non-decreasing and bx_G_forward gives membership propagation) → by IH, truth_at ψ at each future time
- H: mirror of G using backward chain

**Step 3**: Prove backward countermodel: `truth_at ... φ` gives contradiction with `φ ∉ w`:
- The chain is constructed so that φ is false at the evaluation point
- For imp: truth_at(ψ→χ) = (truth_at ψ → truth_at χ). By forward step, truth_at ψ (since ψ ∈ w). By chain construction, ¬truth_at χ. So truth_at(ψ→χ) is false. Contradicts h_valid.

### Why This Works for Imp

The crucial insight: we don't need a bidirectional truth lemma at all. We need:
1. **Forward**: membership in w → truth in model (for making ψ true)
2. **Backward countermodel**: non-membership of φ → φ is false in model (for the contradiction)

The forward direction is uniform and works for all formulas. The backward countermodel is built SPECIFICALLY for the failing formula φ by recursive witness placement. The imp case of the backward countermodel works because:
- `(ψ→χ) ∉ w` gives `ψ ∈ w` and `χ ∉ w`
- Forward bridge: `ψ ∈ w → truth_at ψ` ✓
- Recursive countermodel: `χ ∉ w → ¬truth_at χ` (by IH on χ) ✓
- Therefore `truth_at(ψ→χ) = False` ✓

This is EXACTLY the standard canonical model argument, just expressed in terms of one-directional bridges instead of a full iff.

### Estimated Effort

| Component | Lines | Hours |
|-----------|-------|-------|
| Chain history builder (recursive on formula) | 40-60 | 2 |
| Forward truth lemma (membership → truth) | 60-80 | 3 |
| Backward countermodel (non-membership → falsity) | 40-60 | 2 |
| Integration (restructure usf_completeness) | 20-30 | 1 |
| Testing and debugging | — | 2 |
| **Total** | **160-230** | **10** |

### Key Risk: Box Case Interaction

The box case in the forward truth lemma requires Omega to contain histories through all modal-equivalents of w. The chain Omega (shifts-of-chain) does NOT satisfy this. Solutions:
- Use `modal_omega` for the box case (constant histories through modal-equivalents), separate from the chain
- Or: use Omega = modal_omega ∪ {chain shifts} with appropriate union shift-closure proof
- Or: handle box purely by reduction (as currently done) and only use chain construction for G/H inside imp

The existing `valid_of_valid_box` reduction (valid □φ → valid φ) still works at the top level. The issue is box INSIDE imp. For the forward bridge: `□φ ∈ w → G(φ) ∈ w` (via modal_future + modal_t) → `φ ∈ v` for all chain points v ≥ w → truth_at φ at all future chain points. Combined with `φ ∈ w` (from modal_t), truth_at φ at time 0. If Omega = shifts-of-chain, truth_at(□φ) = ∀Δ, truth_at φ at σ(Δ), which follows from φ ∈ σ(Δ) for all chain points. This WORKS for the forward direction thanks to modal_future + temp_future propagating box-formulas through the chain.

For the backward countermodel: `□φ ∉ w` gives (by bx_modal_witness) some v ~ w with φ ∉ v. The chain may not visit v. Solution: for the box case of the backward countermodel, use modal_omega at v (constant history through v) as a separate Omega, not the chain Omega. Since the backward countermodel is formula-specific (not a universal model), we can choose the Omega case-by-case.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach | completed | medium-high | Chain history construction, three-way tension analysis, box interaction via temp_future |
| B | Alternatives | completed | high | Standard contrapositive is the right architecture, flatten-then-lift fails, FMP bridge viable |
| C | Risks/gaps | completed | medium-high | Exact goal state, IH unusable, surjectivity problem, two-point histories never built |

## References

- Burgess, J. (1984). "Basic Tense Logic" — canonical model completeness for tense logic
- Goldblatt, R. (1992). "Logics of Time and Computation" — temporal logic completeness
- Blackburn, de Rijke, Venema (2001). "Modal Logic" Ch 4.2 — multimodal completeness
- Xu, M. (1988). On some U,S-tense logics — completeness for Until/Since extensions
