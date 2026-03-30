# Implementation Plan: Close Z_chain_forward_F via Dovetailed Omega Construction

- **Task**: 69 - close_z_chain_forward_f
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/069_close_z_chain_forward_f/reports/12_team-research.md
- **Artifacts**: plans/13_dovetailed-omega-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Plan Version**: 13 (dovetailed omega construction)
- **Lean Intent**: true

## Overview

Both research teammates converge on the same strategy: **replace `omega_chain_forward` with `omega_chain_F_preserving_forward` in Z_chain's definition** for the forward (t >= 0) half. The F-preserving chain already has `omega_F_preserving_forward_F_resolution` fully closed, which directly solves the forward F-obligation sorries. However, `f_preserving_seed_consistent` (line 1372) must be closed first as the deepest dependency.

**Critical Path**:
```
f_preserving_seed_consistent (sorry at line 1476)
  -> temporal_theory_witness_F_preserving (line 1489, uses f_preserving_seed_consistent)
    -> omega_chain_F_preserving_forward construction
      -> omega_F_preserving_forward_F_resolution (CLOSED at line 4303)
        -> Z_chain_forward_F (sorry at line 2797)
```

### Research Integration

From team research report (12_team-research.md):
- **Root Cause**: Z_chain at line 2557 uses `omega_chain_forward` which resolves `F_top` but not arbitrary `F(phi)`
- **The Fix Exists**: `omega_chain_F_preserving_forward` (line 4185) with `omega_F_preserving_forward_F_resolution` (line 4303) is fully closed
- **Deepest Blocker**: `f_preserving_seed_consistent` (sorry at line 1476) - proof via strong induction on `List.countP`
- **Missing Infrastructure**: P-preserving backward chain doesn't exist (for `Z_chain_backward_P`)

## Goals & Non-Goals

**Goals**:
- Close `f_preserving_seed_consistent` via strong induction on F-formula count
- Redefine Z_chain to use `omega_chain_F_preserving_forward` for t >= 0
- Close `Z_chain_forward_F` (line 2797) and `Z_chain_forward_F'` (line 3965) sorries
- Unblock `bfmcs_from_mcs_temporally_coherent` and `bundle_validity_implies_provability`

**Non-Goals**:
- Building P-preserving backward chain (assess after forward direction works)
- Proving `Z_chain_backward_P` (may remain sorry with documented gap)
- Restructuring the entire chain construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| f_preserving_seed_consistent harder than estimated | High | Medium | Fall back to Lindenbaum extension approach |
| Property lemma updates cascade widely | Medium | Low | Systematic grep for all consumers before editing |
| G_monotone lemma missing for F-preserving chain | Medium | Medium | Create new lemma following existing pattern |
| Backward direction (P) remains blocked | Medium | High | Document gap, assess for future task |

## Implementation Phases

### Phase 1: Close f_preserving_seed_consistent [NOT STARTED]

**Goal**: Close the deepest blocking sorry at line 1476 using strong induction on F-formula count

**Analysis**: The proof requires extracting all F-formulas from the derivation context, building a disjunction of `G(neg sigma_i)`, and showing contradiction via MCS properties. The research recommends strong induction on `List.countP` of F-formulas.

**Key Lemmas Available**:
- `G_lift_from_context` (line 1066) - lifts derivation under G-closure
- `G_of_disjunction_in_mcs_elim` (line 1255) - extracts witness from G-disjunction in MCS
- `some_future_excludes_all_future_neg` (line 1090) - F(sigma) in MCS excludes G(neg sigma)

**Tasks**:
- [ ] Study existing proof structure at lines 1372-1476
- [ ] Implement strong induction on `List.countP (is_some_future) L`
- [ ] Base case: no F-formulas in L, falls to `temporal_theory_witness_consistent`
- [ ] Inductive case: extract F(psi), apply deduction theorem, reduce F-count
- [ ] Handle interaction between extracted F-formulas and consistency
- [ ] Close the sorry with complete proof (~60-80 lines)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1370-1476)

**Verification**:
- [ ] `lake build` succeeds with no errors in f_preserving_seed_consistent
- [ ] `lean_goal` shows no remaining goals at end of proof
- [ ] Downstream `temporal_theory_witness_F_preserving` compiles

---

### Phase 2: Add omega_chain_F_preserving_forward_G_monotone [NOT STARTED]

**Goal**: Create G_monotone lemma for F-preserving chain (needed for Z_chain_forward_G after redefinition)

**Analysis**: The existing `omega_chain_forward_G_monotone` (line 2613) shows G-formulas propagate forward through `omega_chain_forward`. We need the same property for `omega_chain_F_preserving_forward`.

**Tasks**:
- [ ] Locate `omega_chain_forward_G_monotone` (line 2613) as reference
- [ ] Create `omega_chain_F_preserving_forward_G_monotone` after line 4218:
  ```lean
  theorem omega_chain_F_preserving_forward_G_monotone (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
      (phi : Formula) (m n : Nat) (h_le : m ≤ n)
      (h_G : Formula.all_future phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 m) :
      Formula.all_future phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 n
  ```
- [ ] Proof follows same structure as `omega_chain_forward_G_monotone` using induction on n - m
- [ ] Run `lake build` to verify

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (after line 4218)

**Verification**:
- [ ] New lemma compiles
- [ ] Type signature matches expected usage pattern

---

### Phase 3: Redefine Z_chain for Forward Direction [NOT STARTED]

**Goal**: Change Z_chain to use `omega_chain_F_preserving_forward` for t >= 0

**Analysis**: Single-line change at line 2561. All downstream property lemmas must be updated to use F-preserving chain's corresponding theorems.

**Tasks**:
- [ ] Edit line 2561:
  ```lean
  -- FROM:
  omega_chain_forward M0 h_mcs0 t.toNat
  -- TO:
  omega_chain_F_preserving_forward M0 h_mcs0 t.toNat
  ```
- [ ] Run `lake build` to identify all compilation errors
- [ ] Document affected lemmas for Phase 4

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (line 2561)

**Verification**:
- [ ] Change applied
- [ ] Error list captured for systematic fix

---

### Phase 4: Update Z_chain Property Lemmas [NOT STARTED]

**Goal**: Update 5 property lemmas to use F-preserving chain theorems

**Lemmas to Update**:
1. `Z_chain_mcs` (line 2568-2574): `omega_chain_forward_mcs` -> `omega_chain_F_preserving_forward_mcs`
2. `Z_chain_box_class` (line 2579-2585): `omega_chain_forward_box_class` -> `omega_chain_F_preserving_forward_box_class`
3. `Z_chain_zero` (line 2590-2594): `omega_chain_forward_zero` -> `omega_chain_F_preserving_forward_zero`
4. `Z_chain_forward_G` (line 2648-2727): `omega_chain_forward_G_theory` -> `omega_chain_F_preserving_forward_G_theory` + new G_monotone
5. `Z_chain_backward_H` (line 2728-2750): Verify backward direction unchanged

**Tasks**:
- [ ] Update `Z_chain_mcs` to use `omega_chain_F_preserving_forward_mcs`
- [ ] Update `Z_chain_box_class` to use `omega_chain_F_preserving_forward_box_class`
- [ ] Update `Z_chain_zero` to use `omega_chain_F_preserving_forward_zero`
- [ ] Update `Z_chain_forward_G` cross-chain cases (lines 2696, 2718):
  - Use `omega_chain_F_preserving_forward_G_theory` and `omega_chain_F_preserving_forward_G_monotone`
- [ ] Verify `Z_chain_backward_H` compiles (backward chain unchanged)
- [ ] Run `lake build` after each update

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 2568-2750)

**Verification**:
- [ ] All 5 property lemmas compile
- [ ] `OmegaFMCS` structure (line 2741) compiles

---

### Phase 5: Close Z_chain_forward_F Sorries [NOT STARTED]

**Goal**: Close `Z_chain_forward_F` (line 2775) and `Z_chain_forward_F'` using F-resolution theorem

**Analysis**: With Z_chain now using `omega_chain_F_preserving_forward`, the t >= 0 case can directly use `omega_F_preserving_forward_F_resolution`. The t < 0 case (F(phi) in backward chain) may require bridge through M0.

**Tasks**:
- [ ] Update `Z_chain_forward_F` proof (line 2775-2797):
  ```lean
  -- For t >= 0 case (currently sorry at line 2797):
  -- Z_chain M0 h_mcs0 t = omega_chain_F_preserving_forward M0 h_mcs0 t.toNat
  -- Apply omega_F_preserving_forward_F_resolution directly
  have ⟨s, h_le, h_phi_s⟩ := omega_F_preserving_forward_F_resolution M0 h_mcs0 t.toNat phi h_F_nat
  exact ⟨s, Int.toNat_le.mpr h_le, h_phi_s⟩
  ```
- [ ] Handle t < 0 case: If F(phi) in backward chain:
  - Check if F(phi) ∈ M0 (bridge to forward chain)
  - If yes: use forward resolution from 0
  - If no: document gap or use semantic witness
- [ ] Update `Z_chain_forward_F'` similarly (find location after line 3965)
- [ ] Run `lake build`

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 2775-2815, ~3965)

**Verification**:
- [ ] `Z_chain_forward_F` sorry closed for t >= 0
- [ ] t < 0 case either closed or documented
- [ ] `lake build` succeeds

---

### Phase 6: Verify Downstream and Document Gaps [NOT STARTED]

**Goal**: Verify completeness impact and document any remaining gaps

**Tasks**:
- [ ] Check `bfmcs_from_mcs_temporally_coherent` status
- [ ] Check `bundle_validity_implies_provability` dependencies
- [ ] Count remaining sorries:
  ```bash
  grep -c "sorry" Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean
  ```
- [ ] Document `Z_chain_backward_P` gap (P-preserving backward chain needed)
- [ ] Verify no new axioms introduced
- [ ] Create implementation summary

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (documentation)
- Summary artifact

**Verification**:
- [ ] Sorry count decreased
- [ ] Downstream theorems unblocked or gaps documented
- [ ] Full `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Use `lean_goal` to inspect proof states during modifications
- [ ] After Phase 1: verify `temporal_theory_witness_F_preserving` compiles
- [ ] After Phase 5: verify `OmegaFMCS` temporal coherence (forward_F) is satisfied
- [ ] Final: grep for remaining sorries in UltrafilterChain.lean

## Artifacts & Outputs

- plans/13_dovetailed-omega-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- summaries/14_dovetailed-omega-summary.md (post-implementation)

## Key Code References

| Location | Description |
|----------|-------------|
| Line 1372-1476 | `f_preserving_seed_consistent` - deepest blocker |
| Line 2557-2563 | `Z_chain` definition - change to F-preserving |
| Line 2568-2750 | Z_chain property lemmas - need F-preserving versions |
| Line 2775-2797 | `Z_chain_forward_F` - target sorry |
| Line 4185 | `omega_chain_F_preserving_forward` - the fix |
| Line 4303 | `omega_F_preserving_forward_F_resolution` - closed |

## What NOT To Do

Per research recommendations:
- Don't try to prove `omega_forward_F_bounded_persistence` for `omega_chain_forward` - unprovable without F-preserving invariant
- Don't shortcut `f_preserving_seed_consistent` with direct containment - G-lift fails on F-formulas
- Don't attempt P-preserving backward chain in this task - leave as documented future work

## Rollback/Contingency

If the F-preserving approach fails:
1. Revert Z_chain definition to use `omega_chain_forward`
2. Keep `f_preserving_seed_consistent` proof if completed (reusable)
3. Fall back to weak coherence approach (plan v6) as alternative
4. Document the semantic mismatch clearly in code comments
