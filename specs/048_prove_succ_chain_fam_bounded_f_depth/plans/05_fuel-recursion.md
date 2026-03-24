# Implementation Plan: Task #48 (v5)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 47 (completed), v4 phases 1-4 (completed)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/07_team-research.md
- **Previous Plans**:
  - plans/01_restricted-succ-chain.md (phases 1-2 partial)
  - plans/02_augmented-closure.md (phases 0-3 complete, 4-6 blocked)
  - plans/03_restricted-p-step.md (phase 1 blocked - theorem FALSE as stated)
  - plans/04_restricted-blocking.md (phases 1-4 complete, phase 5 partial)
- **Artifacts**: plans/05_fuel-recursion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the fuel-based well-founded recursion solution for the persistence case in `restricted_forward_chain_iter_F_witness`. Team research (2 teammates) converged with HIGH confidence on using an explicit fuel parameter bounded by `closure_F_bound phi`, with a contradiction derived at fuel exhaustion via `iter_F_not_mem_deferralClosure`.

The key insight: `deferralClosure(phi)` is finite (a `Finset`), so persistence cannot continue indefinitely. If F-nesting depth never decreases over `closure_F_bound phi` steps, `iter_F` would leave `deferralClosure`, contradicting the restricted chain membership.

### Research Integration

From `07_team-research.md`:
- **Fuel parameter approach**: Both teammates recommend this as "most straightforward" and "simpler but effective"
- **Base case (fuel=0)**: Derive contradiction via `iter_F_not_mem_deferralClosure`
- **Recursive case**: Persistence decreases fuel; depth-decrease uses existing strong induction on d
- **All required lemmas exist**: `iter_F_not_mem_deferralClosure`, `closure_F_bound`, `restricted_forward_chain_F_step_witness`

## Goals & Non-Goals

**Goals**:
- Define `restricted_forward_chain_iter_F_witness_fuel` with explicit fuel parameter
- Prove fuel=0 base case derives contradiction from `iter_F_not_mem_deferralClosure`
- Handle recursive case: persistence decreases fuel, depth-decrease stays within fuel budget
- Define entry point wrapper that calls fuel version with `closure_F_bound phi - d`
- Remove the sorry at line 2261 of SuccChainFMCS.lean
- Optionally add deprecation markers to old `f_nesting_is_bounded` / `p_nesting_is_bounded` (already have sorry markers)

**Non-Goals**:
- Implementing backward chain (`constrained_predecessor_restricted`) - separate follow-up task
- Removing the deprecated sorries at lines 736, 971 (already marked for migration)
- Changing the `restricted_forward_chain_forward_F` entry point (it will just call the fixed helper)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fuel bound arithmetic off-by-one | Medium | Medium | Research provided precise formula; test with d=1 case first |
| Missing lemma for chain-in-deferralClosure | Low | Low | Research notes `h_restricted` method should work |
| Strong induction interferes with fuel | Low | Low | Fuel theorem is separate; entry point wraps it |
| Type mismatch between iter_F and chain membership | Low | Low | Existing code already handles this |

## Implementation Phases

### Phase 1: Define Fuel-Based Helper Theorem [PARTIAL]

**Goal**: Create the fuel-parameterized version of the witness theorem.

**Tasks**:
- [ ] Add `restricted_forward_chain_iter_F_witness_fuel` private theorem:
  ```lean
  private theorem restricted_forward_chain_iter_F_witness_fuel (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k d fuel : Nat) (psi : Formula)
      (h_d_ge : d ≥ 1)
      (h_iter : iter_F d psi ∈ restricted_forward_chain phi M0 k)
      (h_fuel_bound : d + fuel ≥ closure_F_bound phi) :
      ∃ m : Nat, k < m ∧ psi ∈ restricted_forward_chain phi M0 m := by
    induction fuel generalizing k d with
    | zero => ...  -- Base case: contradiction
    | succ fuel' ih => ...  -- Recursive case: F-step dichotomy
  ```
- [ ] Prove base case (fuel=0): derive contradiction
  - `h_d_ge`: `d ≥ 1`
  - `h_fuel_bound` with `fuel=0` gives `d ≥ closure_F_bound phi`
  - `iter_F d psi ∈ chain(k)` and `chain(k) ⊆ deferralClosure phi` (via `h_restricted`)
  - `iter_F_not_mem_deferralClosure` with `n = d ≥ closure_F_bound phi` gives contradiction

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add fuel helper before current theorem

**Verification**:
- `lake build` succeeds
- Base case (fuel=0) compiles without sorry

---

### Phase 2: Complete Recursive Case [NOT STARTED]

**Goal**: Handle the two F-step outcomes with proper fuel management.

**Tasks**:
- [ ] Handle `inl` case (depth decrease):
  - If `d = 1`: `iter_F 0 psi = psi ∈ chain(k+1)`, done
  - If `d > 1`: Apply `ih` with `d-1`, `k+1`, same `fuel'`
  - Verify fuel bound: `(d-1) + fuel' + 1 = d + fuel' ≥ closure_F_bound phi - 1` (need adjustment)
- [ ] Handle `inr` case (persistence):
  - `iter_F d psi ∈ chain(k+1)`
  - Apply `ih` with same `d`, `k+1`, `fuel'` (fuel decreased)
  - Fuel bound: `d + fuel' = d + (fuel' + 1) - 1 ≥ closure_F_bound phi - 1`
- [ ] Resolve fuel bound arithmetic:
  - Research suggests `h_fuel_bound : d + fuel ≥ closure_F_bound phi`
  - For `inr` case: need `d + fuel' ≥ closure_F_bound phi` which follows if `fuel' + 1 = fuel`
  - May need to adjust bound condition or use `d + fuel > closure_F_bound phi - 1`

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Complete fuel helper recursive cases

**Verification**:
- `lake build` succeeds
- No sorries in fuel helper theorem

---

### Phase 3: Update Entry Point and Remove Sorry [NOT STARTED]

**Goal**: Replace the existing sorry-containing theorem with the fuel-based solution.

**Tasks**:
- [ ] Replace the body of `restricted_forward_chain_iter_F_witness`:
  ```lean
  private theorem restricted_forward_chain_iter_F_witness (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (psi : Formula)
      (h_d_ge : d ≥ 1)
      (h_iter : iter_F d psi ∈ restricted_forward_chain phi M0 k) :
      ∃ m : Nat, k < m ∧ psi ∈ restricted_forward_chain phi M0 m :=
    restricted_forward_chain_iter_F_witness_fuel phi M0 k d
      (closure_F_bound phi - d) psi h_d_ge h_iter (by omega)
  ```
- [ ] Remove the sorry at line 2261
- [ ] Update docstring to reflect the fuel-based implementation
- [ ] Verify `restricted_forward_chain_forward_F` still works (should be unchanged)

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace sorry with fuel call

**Verification**:
- `lake build` succeeds
- `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows one fewer sorry (4 instead of 5)
- `restricted_forward_chain_forward_F` theorem compiles

---

### Phase 4: Documentation and Cleanup [NOT STARTED]

**Goal**: Update documentation and verify overall reduction in sorries.

**Tasks**:
- [ ] Update the documentation section at end of SuccChainFMCS.lean:
  - Remove item 2 from "Sorries remaining" list (`restricted_forward_chain_iter_F_witness`)
  - Note that forward F coherence is now fully proven
- [ ] Update docstrings for both fuel helper and main theorem explaining the approach
- [ ] Verify deprecated sorries (lines 736, 971) are unchanged and marked appropriately
- [ ] Run final build verification

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Documentation updates

**Verification**:
- `lake build` succeeds
- Documentation accurately reflects current state
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows exactly 4 sorries (2 deprecated, 2 in backward chain section)

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] Sorry count in SuccChainFMCS.lean reduced from 5 to 4
- [ ] `restricted_forward_chain_forward_F` theorem type-checks without changes to its statement
- [ ] The fuel helper theorem has no sorries
- [ ] Entry point wrapper correctly calls fuel version with `closure_F_bound phi - d`
- [ ] `lean_goal` at critical proof positions shows expected states

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Updated with fuel-based proof
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/05_fuel-recursion-summary.md` - Implementation summary (on completion)

## Rollback/Contingency

If fuel approach proves problematic:

1. **Fuel bound mismatch**: Adjust the bound condition. Research suggests `d + fuel ≥ closure_F_bound phi` but may need `d + fuel > closure_F_bound phi - 1` for strict inequality.

2. **Type errors with iter_F**: The existing `iter_F` infrastructure should handle this, but if issues arise, add explicit type annotations.

3. **Chain membership lemma missing**: If `(restricted_forward_chain phi M0 k).h_restricted` doesn't directly give deferralClosure membership, add a small helper lemma `restricted_forward_chain_in_deferralClosure`.

4. **Lexicographic fallback**: If fuel approach is awkward, implement the alternative using `WellFounded.prod_lex Nat.lt_wf Nat.lt_wf` as mentioned in research (more elegant but harder).

## Notes

- **Key lemmas already exist**:
  - `iter_F_not_mem_deferralClosure` (RestrictedMCS.lean:1254) - gives contradiction at bound
  - `closure_F_bound` (CanonicalTaskRelation.lean:154) - `max_F_depth + 1`
  - `restricted_forward_chain_F_step_witness` (SuccChainFMCS.lean) - F-step dichotomy

- **Fuel vs Strong Induction**: The existing strong induction on `d` handles depth decrease; fuel handles persistence count. These are orthogonal and compose cleanly.

- **Mathematical validity**: Both research teammates confirmed HIGH confidence. The proof follows the standard "finite model property" argument from temporal logic literature.
