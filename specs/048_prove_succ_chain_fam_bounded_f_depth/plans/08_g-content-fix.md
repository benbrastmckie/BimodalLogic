# Implementation Plan: Task #48 (v8)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: v6 implementation complete (bounded witness structure in place)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/10_g-content-path.md
- **Previous Plans**:
  - plans/07_boundary-resolution.md (SUPERSEDED - assumed g_content path was blocked)
- **Artifacts**: plans/08_g-content-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v7 assumed the boundary case was easy because f_content deferral is blocked when `FF(psi) ∉ dc`. **This was wrong.** Research report 10 discovered that the **g_content path** (g_persistence) can still inject `F(psi)` into `chain(k+1)` when `G(F(psi)) ∈ chain(k)`.

### The Problem

The theorems `restricted_succ_propagates_F_not` and `restricted_single_step_forcing` are **FALSE as stated** when:
- `F(psi) ∈ deferralClosure(phi)`
- `FF(psi) ∉ deferralClosure(phi)`
- `GF(psi) ∈ deferralClosure(phi)` (which CAN happen independently!)

Concrete counterexample: `phi = G(F(p))` has `GF(p) ∈ dc` but `FF(p) ∉ dc`.

### The Solution (Option D from research)

**Strategy**: Strengthen theorem hypotheses to explicitly block the g_content path, then handle `GF(psi) ∈ chain(k)` separately in `restricted_bounded_witness` using lexicographic termination on g_depth within the finite subformulaClosure.

## Goals & Non-Goals

**Goals**:
- Fix `restricted_succ_propagates_F_not` by adding hypothesis `GF(psi) ∉ chain(k)`
- Fix `restricted_single_step_forcing` by adding hypothesis `GF(psi) ∉ chain(k)`
- Update `restricted_bounded_witness` to handle `GF(psi) ∈ chain(k)` case separately
- Net sorry reduction: from 4 to 2 (removing the 2 boundary sorries)

**Non-Goals**:
- Restructuring the entire bounded_witness approach (we build on v6)
- Touching the 2 preexisting deprecated sorries (lines 736, 971)
- Major changes to deferralClosure or chain construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lexicographic termination argument is complex | Medium | Medium | Use finite subformulaClosure for g_depth bound |
| GF(psi) case requires new infrastructure | Medium | Medium | Leverage existing Finset.card decrease lemmas |
| Call sites need hypothesis propagation | Low | High | Most callers don't hit boundary case |

## Implementation Phases

### Phase 1: Define g_depth and prove boundedness [BLOCKED]

**Goal**: Define a "G-depth" measure for formulas in deferralClosure.

**Key definitions**:
```lean
/-- The maximum n such that G^n(chi) ∈ subformulaClosure(phi) -/
noncomputable def g_nesting_depth (phi chi : Formula) : Nat :=
  if chi ∈ subformulaClosure phi then
    -- Count how many G-prefixes we can add while staying in closure
    (Finset.filter (fun psi => psi ∈ subformulaClosure phi)
      (all_future_prefix_closure chi (subformulaClosure phi).card)).card
  else 0

/-- G-depth is bounded by closure size -/
theorem g_nesting_depth_bounded (phi chi : Formula) :
    g_nesting_depth phi chi ≤ (subformulaClosure phi).card := by
  sorry -- Finite closure means finite nesting
```

**Why this works**: `subformulaClosure(phi)` is finite. The chain `G(chi), G(G(chi)), G(G(G(chi))), ...` must eventually leave the closure. The depth where this happens is bounded by `|subformulaClosure(phi)|`.

**Tasks**:
- [ ] Define `g_nesting_depth` (or similar measure)
- [ ] Prove `g_nesting_depth` is bounded by closure size
- [ ] Prove `G(chi) ∈ subformulaClosure ⟹ g_nesting_depth chi > 0`
- [ ] Prove `g_nesting_depth (G chi) < g_nesting_depth chi` when both in closure

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (add near F_bounded section)

---

### Phase 2: Strengthen helper theorems with GF hypothesis [NOT STARTED]

**Goal**: Add `GF(psi) ∉ chain(k)` hypothesis to block g_content path.

**Theorem modifications**:

```lean
/-- MODIFIED: Added h_GF_not hypothesis -/
theorem restricted_succ_propagates_F_not' (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_FF_not : Formula.some_future (Formula.some_future psi) ∉ restricted_forward_chain phi M0 k)
    (h_GF_not : Formula.all_future (Formula.some_future psi) ∉ restricted_forward_chain phi M0 k) :
    Formula.some_future psi ∉ restricted_forward_chain phi M0 (k + 1) := by
  -- Existing proof for FF ∈ dc case still works
  -- For FF ∉ dc case:
  --   f_content path blocked: FF ∉ dc ⟹ FF ∉ chain(k+1)
  --   g_content path blocked: GF ∉ chain(k) ⟹ F ∉ g_content(chain(k))
  -- Therefore F ∉ chain(k+1)
  sorry

/-- MODIFIED: Added h_GF_not hypothesis -/
theorem restricted_single_step_forcing' (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F_in : Formula.some_future psi ∈ restricted_forward_chain phi M0 k)
    (h_FF_not : Formula.some_future (Formula.some_future psi) ∉ restricted_forward_chain phi M0 k)
    (h_GF_not : Formula.all_future (Formula.some_future psi) ∉ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1) := by
  -- Use f_step: psi ∈ chain(k+1) OR psi ∈ f_content(chain(k+1))
  -- Case B (f_content) means F(psi) ∈ chain(k+1)
  -- But restricted_succ_propagates_F_not' says F(psi) ∉ chain(k+1)
  -- Therefore Case A: psi ∈ chain(k+1)
  sorry
```

**Tasks**:
- [ ] Create new primed versions with additional hypothesis
- [ ] Fill in proofs using g_content blocking argument
- [ ] Verify: `GF ∉ chain(k)` + `FF ∉ dc` ⟹ `F ∉ chain(k+1)`

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 3: Restructure bounded_witness with case analysis [NOT STARTED]

**Goal**: Handle `GF(psi) ∈ chain(k)` separately using g_depth decrease.

**Key insight**: When `GF(psi) ∈ chain(k)` at the boundary, we can't use `restricted_succ_propagates_F_not'`. Instead:
1. Track `g_nesting_depth` of the current formula
2. Show that `G(G(F(psi)))` (= `GGF(psi)`) is NOT in `dc` when `FF(psi) ∉ dc` (usually true)
3. Therefore `GF(psi)` cannot persist indefinitely via g_content
4. Use lexicographic induction on `(f_depth, g_depth)` to prove termination

**Modified theorem structure**:

```lean
theorem restricted_bounded_witness' (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula) (d : Nat)
    (h_d_ge : d ≥ 1)
    (h_Fd : iter_F d psi ∈ restricted_forward_chain phi M0 k)
    (h_Fd1_not : iter_F (d + 1) psi ∉ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + d) := by
  -- Lexicographic induction on (d, g_depth of G(iter_F d psi))
  --
  -- Case A: G(iter_F d psi) ∉ chain(k)
  --   Use restricted_single_step_forcing' directly
  --   Get: iter_F (d-1) psi ∈ chain(k+1)
  --   Recurse with smaller d
  --
  -- Case B: G(iter_F d psi) ∈ chain(k)
  --   Then F(iter_F (d-1) psi) ∈ chain(k+1) via g_persistence
  --   But does iter_F (d-1) psi ∈ chain(k+1)?
  --   Need to track whether G^2(iter_F (d-1) psi) ∈ chain(k)
  --   If not, use restricted_single_step_forcing'
  --   If yes, g_depth decreases (eventually GG...G leaves closure)
  sorry
```

**Tasks**:
- [ ] Analyze when `GGF(psi) ∈ dc` vs `GGF(psi) ∉ dc`
- [ ] Implement lexicographic induction on `(f_depth, g_depth)`
- [ ] Handle base cases: g_depth = 0, f_depth = 1
- [ ] Prove termination using Finset.card decrease

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 4: Update callers and verify [NOT STARTED]

**Goal**: Update `restricted_forward_chain_iter_F_witness` to use new theorems.

**Tasks**:
- [ ] Update main entry point to use `restricted_bounded_witness'`
- [ ] Run `lake build` to verify compilation
- [ ] Count sorries: should be 2 (preexisting deprecated ones)
- [ ] Clean up: remove old primed versions if redundant, add documentation

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -c "sorry" SuccChainFMCS.lean` returns 2 (only deprecated sorries at lines 736, 971)
- [ ] `restricted_bounded_witness'` has no sorries
- [ ] `restricted_forward_chain_iter_F_witness` compiles and has no new sorries
- [ ] Counterexample `phi = G(F(p))` doesn't break the new theorems

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fixed boundary case
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/08_g-content-fix-summary.md` - Summary

## Rollback/Contingency

If lexicographic induction is too complex:

1. **Alternative: Finite chain property**
   Prove that the restricted chain is eventually periodic (since `dc` is finite, only `2^|dc|` distinct states). Use periodicity to derive eventual resolution.

2. **Alternative: Direct model argument**
   Construct the canonical model and show F-coherence using the omega-rule interpretation.

3. **Alternative: Modify chain construction**
   Change `constrained_successor_seed_restricted` to explicitly resolve F-obligations when at the boundary.

## Key Insight (Updated)

The v7 plan missed the g_content path. The correct insight is:

**f_content path**: `F(psi)` persists from chain(k) to chain(k+1) via f_content iff `FF(psi) ∈ chain(k)`. BLOCKED when `FF(psi) ∉ dc`.

**g_content path**: `F(psi)` enters chain(k+1) via g_persistence iff `GF(psi) ∈ chain(k)`. NOT automatically blocked by `FF(psi) ∉ dc`.

The fix is to:
1. Add `GF(psi) ∉ chain(k)` as an explicit hypothesis to the helper lemmas
2. Handle the `GF(psi) ∈ chain(k)` case separately using g_depth decrease
3. Use lexicographic termination: primary = f_depth, secondary = g_depth
